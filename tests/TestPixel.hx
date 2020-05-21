package tests;

import helder.Pixels;

using StringTools;

@:asserts
class TestPixel {
  public function new() {}

  public function testPixels() {
    asserts.assert(Pixel.fromARGB(0xaa2266bb).toString() == 'aa2266bb');
    asserts.assert(Pixel.fromRGBA(0x2266bbaa).toString() == 'aa2266bb');
    asserts.assert(Pixel.fromBGRA(0xbb6622aa).toString() == 'aa2266bb');
    asserts.assert(Pixel.fromA7RGB(0x002266bb).toString() == '002266bb');
    asserts.assert(Pixel.fromA7RGB(0x7f2266bb).toString() == 'ff2266bb');

    final ref = Pixel.fromARGB(0xaa2266bb);
    asserts.assert(ref.toARGB().hex(8).toLowerCase() == 'aa2266bb');
    asserts.assert(ref.toRGBA().hex(8).toLowerCase() == '2266bbaa');
    asserts.assert(ref.toBGRA().hex(8).toLowerCase() == 'bb6622aa');
    asserts.assert(ref.toA7RGB().hex(8).toLowerCase() == '552266bb');
    return asserts.done();
  }
}