"use strict";

const path = require("path");
const fsp = require("fs").promises;

const homeTags = [".q"];
const dirTags = [".q", "q"];

const configFile = path.join(process.env.HOME, ".cdq.json");

const defaultConfig = {
  historySize: 10,
  history: []
};

const isBelow = (dir, target) =>
  path
    .relative(dir, target)
    .split(path.sep)
    .every(p => p === "..");

const isWithin = (dir, target) => dir === target || isBelow(dir, target);

const shellQuote = (...words) =>
  words
    .map(s => {
      if (/["\s]/.test(s) && !/'/.test(s))
        return "'" + s.replace(/(['\\])/g, "\\$1") + "'";
      else if (/["'\s]/.test(s))
        return '"' + s.replace(/(["\\$`!])/g, "\\$1") + '"';
      else
        return String(s).replace(
          /([A-z]:)?([#!"$&'()*,:;<=>?@\[\\\]^`{|}])/g,
          "$1\\$2"
        );
    })
    .join(" ");

const exportVar = (env, val) => `export ${env}=${shellQuote(val)}`;

const loadJSON = async name =>
  JSON.parse(await fsp.readFile(name, { encoding: "utf8" }));

const saveJSON = async (name, data) => {
  const tmp = name + ".tmp";
  await fsp.writeFile(tmp, JSON.stringify(data, null, 2));
  await fsp.rename(tmp, name);
};

const makeConfigStore = (file, fallback) => {
  let conf;
  const load = async () => {
    try {
      return await loadJSON(file);
    } catch (e) {
      if (e.code === "ENOENT") return fallback;
      throw e;
    }
  };

  return [
    () => (conf = conf || load()),
    async c => {
      await saveJSON(file, c);
      conf = c;
    }
  ];
};

const [loadConfig, saveConfig] = makeConfigStore(configFile, defaultConfig);

async function safeReadDir(dir, opt) {
  try {
    return await fsp.readdir(dir, opt);
  } catch (e) {
    if (e.code === "ENOENT") return [];
    throw e;
  }
}

async function loadTags(dict, base, paths) {
  const sp = [
    ...paths.map(p => path.join(base, p, "local")),
    ...paths.map(p => path.join(base, p))
  ];

  for (const dir of sp) {
    const links = (await safeReadDir(dir, { withFileTypes: true }))
      .filter(e => e.isSymbolicLink())
      .map(e => e.name);

    for (const tag of links) {
      if (dict[tag]) continue;
      const dst = await fsp.readlink(path.join(dir, tag));
      dict[tag] = path.resolve(dir, dst);
    }
  }
  return dict;
}

async function loadPath(dict, base, paths) {
  while (true) {
    await loadTags(dict, base, paths);
    const up = path.dirname(base);
    if (up === base) break;
    base = up;
  }
  return dict;
}

async function loadInit() {
  const dict = {};
  const cwd = process.cwd();
  const home = process.env.HOME;
  await loadPath(dict, cwd, dirTags);
  // In case we missed home
  if (!isWithin(cwd, home)) await loadTags(dict, home, homeTags);
  return dict;
}

async function walkPath(dict, tags) {
  if (!tags.length) return dict;
  const [next, ...tail] = tags;
  if (!dict[next]) throw new Error(`No tag "${next}"`);
  const nd = await loadTags({}, dict[next], dirTags);
  return await walkPath(nd, tail);
}

function showCompletion(tags) {
  for (const tag of tags.sort()) console.log(tag);
}

async function completePath(dict, args) {
  const [cmd, ...tags] = args;
  const target = tags.pop();
  const nd = await walkPath(dict, tags);

  if (target !== undefined) {
    if (nd[target]) {
      const td = await loadTags({}, nd[target], dirTags);
      return showCompletion(Object.keys(td));
    }

    return showCompletion(Object.keys(nd).filter(t => t.startsWith(target)));
  }

  return showCompletion(Object.keys(nd));
}

async function pushHistory(tags) {
  const conf = await loadConfig();
  if (conf.history[conf.history.length - 1] !== tags) {
    conf.history.push(tags);
    conf.history = conf.history.slice(-conf.historySize);
    await saveConfig(conf);
  }
}

async function resolvePath(dict, tags, setVars) {
  const target = tags.pop(); // destination
  const nd = await walkPath(dict, tags);
  const dest = nd[target];
  if (!dest) throw new Error(`No tag "${target}"`);

  const cmd = [];

  if (setVars) {
    const addr = [...tags, target].join(" ");
    const current = process.env.CDQ_CURRENT;
    if (addr !== current) {
      if (current) cmd.push(exportVar("CDQ_PREVIOUS", current));
      cmd.push(exportVar("CDQ_CURRENT", addr));
    }
    await pushHistory(addr);
  }

  cmd.push(shellQuote("cd", dest));
  console.error(dest);

  console.log(cmd.join("; "));
}

function syntax() {
  console.error(`Syntax: cdq <tag> ...`);
  process.exit(1);
}

async function goVar(dict, name, setVars) {
  const addr = process.env[name];
  if (!addr) throw new Error(`${name} not set`);
  return resolvePath(dict, addr.split(/\s+/), setVars);
}

async function goGlobal(dict, setVars) {
  const { history } = await loadConfig();
  if (!history || !history.length)
    throw new Error(`No global history in ${configFile}`);
  const addr = history[history.length - 1];
  return resolvePath(dict, addr.split(/\s+/), setVars);
}

async function cdq(args) {
  const dict = await loadInit();

  if (args.length === 0) return goVar(dict, "CDQ_CURRENT", false);

  if (args.length === 1) {
    if (args[0] === "-") return goVar(dict, "CDQ_PREVIOUS", true);
    if (args[0] === ".") return goGlobal(dict, true);
  }

  if (args[0] === "-c") return completePath(dict, args.slice(1));

  return resolvePath(dict, args, true);
}

(async () => {
  try {
    await cdq(process.argv.slice(2));
  } catch (e) {
    console.error(e.message);
    process.exit(1);
  }
})();
