#!/usr/bin/env node
"use strict";

// prettier-ignore
const cdef = Object.fromEntries([
  "0000000000000000", "1818181818001800", "6c6c6c0000000000", "36367f367f363600",
  "0c3f683e0b7e1800", "60660c1830660600", "386c6c386d663b00", "0c18300000000000",
  "0c18303030180c00", "30180c0c0c183000", "00187e3c7e180000", "0018187e18180000",
  "0000000000181830", "0000007e00000000", "0000000000181800", "00060c1830600000",
  "3c666e7e76663c00", "1838181818187e00", "3c66060c18307e00", "3c66061c06663c00",
  "0c1c3c6c7e0c0c00", "7e607c0606663c00", "1c30607c66663c00", "7e060c1830303000",
  "3c66663c66663c00", "3c66663e060c3800", "0000181800181800", "0000181800181830",
  "0c18306030180c00", "00007e007e000000", "30180c060c183000", "3c660c1818001800",
  "3c666e6a6e603c00", "3c66667e66666600", "7c66667c66667c00", "3c66606060663c00",
  "786c6666666c7800", "7e60607c60607e00", "7e60607c60606000", "3c66606e66663c00",
  "6666667e66666600", "7e18181818187e00", "3e0c0c0c0c6c3800", "666c7870786c6600",
  "6060606060607e00", "63777f6b6b636300", "6666767e6e666600", "3c66666666663c00",
  "7c66667c60606000", "3c6666666a6c3600", "7c66667c6c666600", "3c66603c06663c00",
  "7e18181818181800", "6666666666663c00", "66666666663c1800", "63636b6b7f776300",
  "66663c183c666600", "6666663c18181800", "7e060c1830607e00", "7c60606060607c00",
  "006030180c060000", "3e06060606063e00", "183c664200000000", "00000000000000ff",
  "1c36307c30307e00", "00003c063e663e00", "60607c6666667c00", "00003c6660663c00",
  "06063e6666663e00", "00003c667e603c00", "1c30307c30303000", "00003e66663e063c",
  "60607c6666666600", "1800381818183c00", "1800381818181870", "6060666c786c6600",
  "3818181818183c00", "0000367f6b6b6300", "00007c6666666600", "00003c6666663c00",
  "00007c66667c6060", "00003e66663e0607", "00006c7660606000", "00003e603c067c00",
  "30307c3030301c00", "0000666666663e00", "00006666663c1800", "0000636b6b7f3600",
  "0000663c183c6600", "00006666663e063c", "00007e0c18307e00", "0c18187018180c00",
  "1818180018181800", "3018180e18183000", "316b460000000000"
].map((bits, i) => [(i+32), bits]))

const bits2dots = bits =>
  bits
    .split(/(..)/)
    .filter(Boolean)
    .map(h => parseInt(h, 16) | 0x100)
    .map(v => v.toString(2).substr(1))
    .map(b => b.split("").map(Number));

const pad = (n, v = 0) => Array(Math.max(n, 0)).fill(v);
const padTo = (a, w, v) => [...a, ...pad(w - a.length, v)];

const trim = (dots, [left, right]) => {
  const ri = dots.length - right;
  const t = (d, l, r) => [...d, ...pad(r - d.length)].slice(l, r);
  if (left < 0) return t([...pad(-left), ...dots], 0, ri - left);
  return t(dots, left, ri);
};

class BeebKerner {
  constructor(opt) {
    this.opt = Object.assign(
      {
        maxLeftTrim: 2,
        maxRightTrim: 1,
        minGap: 1,
        minRowGap: 2
      },
      opt || {}
    );
    this._pairs = {};
  }

  kern(l, r) {
    const { opt, _pairs } = this;

    const k2 = (lrm, rlm) => {
      const minGap = Math.min(...lrm.map((m, i) => m + rlm[i]));
      const minRight = Math.min(...lrm);
      const minLeft = Math.min(...rlm);
      const minRowGap = minRight + minLeft;
      const trim = Math.min(minGap - opt.minGap, minRowGap - opt.minRowGap);
      const leftTrim = Math.min(opt.maxLeftTrim, minRight, trim);
      const rightTrim = Math.min(opt.maxRightTrim, minLeft, trim - leftTrim);

      return [leftTrim, rightTrim];
    };

    const kern = (l, r) => {
      const h = Math.max(l.height, r.height);
      return k2(
        padTo(l.rightMargin, h, l.width),
        padTo(r.leftMargin, h, r.width)
      );
    };

    const key = l.cc + "-" + r.cc;
    return (_pairs[key] = _pairs[key] || kern(l, r));
  }
}

class BeebGlyph {
  constructor(cc, bits) {
    this.cc = cc;
    this.dots = bits2dots(bits);
    this.width = 8;
  }

  get height() {
    return this.dots.length;
  }

  get leftMargin() {
    return (this._lm =
      this._lm ||
      this.dots.map(row => row.indexOf(1)).map(m => (m < 0 ? this.width : m)));
  }

  get rightMargin() {
    return (this._rm =
      this._rm ||
      this.dots
        .map(row => row.lastIndexOf(1))
        .map(m => (m < 0 ? this.width : this.width - 1 - m)));
  }
}

class BeebFont {
  constructor(cdef, opt) {
    this.cdef = cdef || {};
    this.opt = Object.assign({ mark: "@", space: " " }, opt || {});
    this._cc = {};
  }

  define(cdef) {
    this._height = undefined;
    Object.assign(this.cdef, cdef);
  }

  get height() {
    return (this._height =
      this._height ||
      Math.max(...Object.values(this.cdef).map(def => def.length / 2)));
  }

  glyph(cc) {
    return (this._cc[cc] =
      this._cc[cc] || (cdef => cdef && new BeebGlyph(cc, cdef))(this.cdef[cc]));
  }

  glyphs(str) {
    return str
      .split("")
      .map(s => s.charCodeAt(0))
      .map(cc => this.glyph(cc));
  }

  kern(glyphs) {
    const { kerner } = this.opt;

    if (!kerner) return glyphs.map(() => [0, 0]);

    const pairs = glyphs
      .slice(1)
      .map((rg, i) => kerner.kern(glyphs[i], rg))
      .flat();

    const fp = [0, ...pairs, 0];
    const out = [];
    while (fp.length) out.push(fp.splice(0, 2));

    return out;
  }

  measure(str) {
    const { height } = this;
    const glyphs = this.glyphs(str);
    const ki = this.kern(glyphs);
    const width =
      glyphs.reduce((a, g) => a + g.width, 0) -
      ki.reduce((a, k) => a + k[0] + k[1], 0);
    return [width, height];
  }

  render(str) {
    const { height, opt } = this;

    const pixel = dot => (dot ? opt.mark : opt.space);

    const glyphs = this.glyphs(str);
    const ki = this.kern(glyphs);

    return pad(height).map((z, row) =>
      glyphs
        .map((g, i) =>
          trim(g.dots[row] || pad(g.width), ki[i])
            .map(pixel)
            .join("")
        )
        .join("")
    );
  }
}

for (const k of [false, true]) {
  const bf = new BeebFont(cdef, { kerner: k && new BeebKerner() });

  const text = ["BBC Micro 32K", "[more...]"];

  for (const line of text) {
    const [width, height] = bf.measure(line);
    const rule = Array(width)
      .fill("=")
      .join("");
    console.log(rule);
    const rasters = bf.render(line);
    for (const r of rasters) console.log(r);
    console.log(rule);
  }
}
