package tests;

import helder.Pixels;
import helder.pixels.PixelFormat;

using StringTools;

@:asserts
class TestFormat {
  public function new() {}

  public function testFormat() {
    final sample: Pixel = 0xaa2266bb;
    final argb = ARGB.transparent();
    asserts.assert(argb.normalize(0x552266bb) == sample);
    final rgba = RGBA.transparent();
    asserts.assert(rgba.normalize(0x2266bb55) == sample);
    final bgra = BGRA.transparent();
    asserts.assert(bgra.normalize(0xbb662255) == sample);
    return asserts.done();
  }
}