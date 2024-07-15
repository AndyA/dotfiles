import argparse, hashlib, os, sqlite3
from functools import cached_property
from itertools import batched
from typing import Generator, Sequence


def sha_sum(filename):
    with open(filename, "rb", buffering=0) as f:
        return hashlib.file_digest(f, "sha256").hexdigest()


def bind_slot(keys: Sequence[str]) -> str:
    return ", ".join("?" * len(keys))


class DestinyObject:
    path: str
    dev: int
    ino: int
    size: int
    mtime: int

    def __init__(self, entry: os.DirEntry):
        stat = entry.stat()
        self.path = entry.path
        self.dev = stat.st_dev
        self.ino = stat.st_ino
        self.size = stat.st_size
        self.mtime = stat.st_mtime

    @property
    def has_hash(self) -> bool:
        return "hash" in self.__dict__

    @cached_property
    def hash(self) -> str:
        return sha_sum(self.path)


class Destiny:
    root: str
    db: str
    con: sqlite3.Connection

    def __init__(self, *, root: str, db: str):
        self.root = os.path.abspath(root)
        self.db = os.path.abspath(db)

        self.con = sqlite3.connect(self.db)
        self.con.autocommit = False

        self._create_tables()
        self._update_meta()

    def _update_meta(self):
        dev = os.stat(self.root).st_dev
        old_meta = self.con.execute("SELECT root, dev FROM meta").fetchone()
        if old_meta:
            _, old_dev = old_meta
            if old_dev != dev:
                self.con.execute(
                    "UPDATE object SET dev = ? WHERE dev = ?",
                    (dev, old_dev),
                )
        self.con.execute("INSERT OR REPLACE INTO meta VALUES (?, ?)", (self.root, dev))
        self.con.commit()

    def _create_tables(self) -> None:
        def index(tbl: str, cols: tuple[str]):
            name = "_".join([tbl] + list(cols))
            return f"CREATE INDEX IF NOT EXISTS {name} ON {tbl} ({', '.join(cols)});"

        self.con.executescript(
            f"""
            CREATE TABLE IF NOT EXISTS object (
                path VARCHAR NOT NULL,
                generation INTEGER NOT NULL,
                hash VARCHAR NOT NULL,
                dev INTEGER NOT NULL,
                ino INTEGER NOT NULL,
                size INTEGER NOT NULL,
                mtime REAL NOT NULL,
                PRIMARY KEY (path)
            );

            {index("object", ("generation",))}
            {index("object", ("hash",))}
            {index("object", ("path",))}
            {index("object", ("dev",))}
            {index("object", ("ino",))}

            CREATE TABLE IF NOT EXISTS meta (
                root VARCHAR NOT NULL,
                dev INTEGER NOT NULL,
                PRIMARY KEY (root)
            );
            """
        )
        self.con.commit()

    def _get_generation(self):
        return self.con.execute(
            "SELECT MAX(generation) AS last FROM object"
        ).fetchone()[0]

    def _find_files(self, dir: str) -> Generator[os.DirEntry, None, None]:
        for entry in os.scandir(dir):
            if entry.is_dir():
                yield from self._find_files(entry.path)
            elif entry.path != self.db:
                yield DestinyObject(entry)

    def _resolve_path(self, objs: tuple[DestinyObject, ...]):
        path_map = {obj.path: obj for obj in objs if not obj.has_hash}
        if not path_map:
            return
        paths = tuple(path_map.keys())
        res = self.con.execute(
            f"""
            SELECT path, hash, size, mtime 
              FROM object 
             WHERE path IN ({bind_slot(paths)})
            """,
            paths,
        )
        for path, hash, size, mtime in res:
            obj = path_map[path]
            if obj.size == size and obj.mtime == mtime:
                obj.hash = hash

    def _resolve_ino(self, objs: tuple[DestinyObject, ...]):
        dev_ino_map = {}
        for obj in objs:
            if not obj.has_hash:
                dev_ino_map.setdefault(obj.dev, {}).setdefault(obj.ino, []).append(obj)
        for dev, ino_map in dev_ino_map.items():
            inos = tuple(ino_map.keys())
            res = self.con.execute(
                f"""
                SELECT ino, hash, size, mtime 
                  FROM object 
                 WHERE dev = ? 
                   AND ino in ({bind_slot(inos)})
                """,
                (dev, *inos),
            )
            for ino, hash, size, mtime in res:
                for obj in ino_map[ino]:
                    if obj.size == size and obj.mtime == mtime:
                        obj.hash = hash

    def _calc_hash(self, objs: tuple[DestinyObject, ...]):
        for obj in objs:
            if not obj.has_hash:
                print(f"{obj.hash} {obj.path}")

    def update(self) -> None:
        last = self._get_generation()
        generation = 0 if last is None else last + 1
        for objs in batched(self._find_files(self.root), 100):
            self._resolve_path(objs)
            self._resolve_ino(objs)
            self._calc_hash(objs)

            for o in objs:
                rel_path = os.path.relpath(o.path, self.root)
                self.con.execute(
                    "INSERT OR REPLACE INTO object VALUES (?, ?, ?, ?, ?, ?, ?)",
                    (rel_path, generation, o.hash, o.dev, o.ino, o.size, o.mtime),
                )

        self.con.execute("DELETE FROM object WHERE generation < ?", (generation,))
        self.con.commit()

    def vacuum(self):
        self.con.autocommit = True
        self.con.commit()
        self.con.execute("VACUUM")
        self.con.autocommit = False


def add_common_args(parser):
    parser.add_argument("root", nargs="?", help="directory to scan")
    parser.add_argument("-d", "--db", required=False, help="destiny database file")
    return parser


def process_args(args):
    if not args.root:
        if not args.db:
            parser.error("either root or db must be provided")
        args.root = os.path.dirname(args.db)
    if not args.db:
        args.db = os.path.join(args.root, "destiny.db")

    return args


parser = argparse.ArgumentParser(
    prog="destiny",
    description="Content addressable filesystem tools",
)

sub = parser.add_subparsers(dest="command")
update = add_common_args(sub.add_parser("update", help="freshen the database"))
args = process_args(parser.parse_args())

destiny = Destiny(db=args.db, root=args.root)

match args.command:
    case "update":
        destiny.update()
        destiny.vacuum()
    case _:
        parser.print_help()
