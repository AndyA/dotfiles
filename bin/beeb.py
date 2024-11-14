from itertools import batched
from functools import reduce
from typing import Iterable, Self, Sequence


Pixel = int
Raster = list[list[Pixel]]
BLACK: Pixel = 0

BEEB_CDEF = (
    *("0000000000000000", "1818181818001800", "6c6c6c0000000000", "36367f367f363600"),
    *("0c3f683e0b7e1800", "60660c1830660600", "386c6c386d663b00", "0c18300000000000"),
    *("0c18303030180c00", "30180c0c0c183000", "00187e3c7e180000", "0018187e18180000"),
    *("0000000000181830", "0000007e00000000", "0000000000181800", "00060c1830600000"),
    *("3c666e7e76663c00", "1838181818187e00", "3c66060c18307e00", "3c66061c06663c00"),
    *("0c1c3c6c7e0c0c00", "7e607c0606663c00", "1c30607c66663c00", "7e060c1830303000"),
    *("3c66663c66663c00", "3c66663e060c3800", "0000181800181800", "0000181800181830"),
    *("0c18306030180c00", "00007e007e000000", "30180c060c183000", "3c660c1818001800"),
    *("3c666e6a6e603c00", "3c66667e66666600", "7c66667c66667c00", "3c66606060663c00"),
    *("786c6666666c7800", "7e60607c60607e00", "7e60607c60606000", "3c66606e66663c00"),
    *("6666667e66666600", "7e18181818187e00", "3e0c0c0c0c6c3800", "666c7870786c6600"),
    *("6060606060607e00", "63777f6b6b636300", "6666767e6e666600", "3c66666666663c00"),
    *("7c66667c60606000", "3c6666666a6c3600", "7c66667c6c666600", "3c66603c06663c00"),
    *("7e18181818181800", "6666666666663c00", "66666666663c1800", "63636b6b7f776300"),
    *("66663c183c666600", "6666663c18181800", "7e060c1830607e00", "7c60606060607c00"),
    *("006030180c060000", "3e06060606063e00", "183c664200000000", "00000000000000ff"),
    *("1c36307c30307e00", "00003c063e663e00", "60607c6666667c00", "00003c6660663c00"),
    *("06063e6666663e00", "00003c667e603c00", "1c30307c30303000", "00003e66663e063c"),
    *("60607c6666666600", "1800381818183c00", "1800381818181870", "6060666c786c6600"),
    *("3818181818183c00", "0000367f6b6b6300", "00007c6666666600", "00003c6666663c00"),
    *("00007c66667c6060", "00003e66663e0607", "00006c7660606000", "00003e603c067c00"),
    *("30307c3030301c00", "0000666666663e00", "00006666663c1800", "0000636b6b7f3600"),
    *("0000663c183c6600", "00006666663e063c", "00007e0c18307e00", "0c18187018180c00"),
    *("1818180018181800", "3018180e18183000", "316b460000000000", "ffc3c3c3c3c3c3ff"),
)


class BeebBitmap:
    buffer: Raster
    width: int
    height: int
    pixels = " |▘|▝|▀|▖|▌|▞|▛|▗|▚|▐|▜|▄|▙|▟|█".split("|")

    def __init__(self, *, width: int = 0, height: int = 0, dots: Raster = None):
        if dots is None:
            self.buffer = []
            self.width = 0
            self.height = 0
            self.set_size(width, height)
        else:
            self.buffer = dots
            self.width = len(dots[0]) if dots else 0
            self.height = len(dots)

    def set_size(self, width: int, height: int) -> Self:
        w, h = (width + 1) & ~1, (height + 1) & ~1
        if self.width != w or self.height != h:
            self.width, self.height = w, h
            width_adj = [row[:w] + ([BLACK] * (w - len(row))) for row in self.buffer]
            height_adj = [[BLACK] * w for _ in range(h - len(self.buffer))]
            self.buffer = width_adj + height_adj
        return self

    def extend(self, width: int, height: int) -> Self:
        if width > self.width or height > self.height:
            self.set_size(max(width, self.width), max(height, self.height))
        return self

    def set_pixel(self, x: int, y: int, pixel: Pixel) -> Self:
        self.extend(x + 1, y + 1)
        self.buffer[y][x] = pixel
        return self

    def blit(self, x: int, y: int, bitmap: Self) -> Self:
        for dy, row in enumerate(bitmap.buffer):
            for dx, pixel in enumerate(row):
                self.set_pixel(x + dx, y + dy, pixel)
        return self

    def render(self):
        for lines in batched(self.buffer, 2):
            row = ""
            for p in batched(zip(*lines), 2):
                cc = (p[0][0] << 0) + (p[1][0] << 1) + (p[0][1] << 2) + (p[1][1] << 3)
                row += self.pixels[cc]
            yield row


class BeebCharSet:
    dots: list[BeebBitmap]
    base: int

    def __init__(self, cdef: Sequence[str], *, base=32):
        self.dots = [self.decode(cd) for cd in cdef]
        self.base = base

    @staticmethod
    def decode(chardata: str) -> BeebBitmap:
        bits = int(chardata, 16)
        bs = (int(bool(bits & (1 << i))) for i in range(63, -1, -1))
        return BeebBitmap(dots=[*batched(bs, 8)])

    def __getitem__(self, c: int) -> BeebBitmap:
        idx = c - self.base
        if not 0 <= idx < len(self.dots):
            idx = -1
        return self.dots[idx]


class BeebVDU:
    screen: BeebBitmap
    chars: BeebCharSet

    def __init__(self):
        self.screen = BeebBitmap()
        self.chars = BeebCharSet(BEEB_CDEF)

    def measure_string(self, text: str) -> tuple[int, int]:
        width, height = 0, 0
        for c in text:
            sprite = self.chars[ord(c)]
            width += sprite.width
            height = max(height, sprite.height)
        return width, height

    def draw_string(self, x: int, y: int, text: str):
        width, height = self.measure_string(text)
        self.screen.extend(x + width, y + height)
        for c in text:
            sprite = self.chars[ord(c)]
            self.screen.blit(x, y, sprite)
            x += sprite.width
        return width, height


cs = BeebCharSet(BEEB_CDEF)

for ccs in batched(range(32, 128), 16):
    line = "".join(chr(cc) for cc in ccs)
    vdu = BeebVDU()
    vdu.draw_string(0, 0, line)
    for row in vdu.screen.render():
        print(row)
