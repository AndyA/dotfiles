"use strict";

const path = require("path");
const fsp = require("fs").promises;

const homeTags = [".q"];
const dirTags = [".q", "q"];

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

async function completePath(dict, tags) {
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

async function resolvePath(dict, tags, setVars) {
  const target = tags.pop(); // destination
  const nd = await walkPath(dict, tags);
  if (!nd[target]) throw new Error(`No tag "${target}"`);

  const cmd = [];

  if (setVars) {
    if (process.env.CDQ_CURRENT)
      cmd.push(exportVar("CDQ_PREVIOUS", process.env.CDQ_CURRENT));
    cmd.push(exportVar("CDQ_CURRENT", [...tags, target].join(" ")));
  }

  cmd.push(shellQuote("cd", nd[target]));

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

async function cdq(args) {
  const dict = await loadInit();

  if (args.length === 0) return goVar(dict, "CDQ_CURRENT", false);

  if (args.length === 1 && args[0] === "-")
    return goVar(dict, "CDQ_PREVIOUS", true);

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
