package tests;

import helder.Pixels;

@:asserts
class TestDriver {
  final pixels: Pixels;
  public function new(pixels)
    this.pixels = pixels;

  public function testDriver() {
    asserts.assert(pixels.get(0, 0).toString() == '00ff0000');
    asserts.assert(pixels.get(1, 0).toString() == '0000ff00');
    asserts.assert(pixels.get(2, 0).toString() == '000000ff');
    asserts.assert(pixels.get(3, 0).toString() == '00000000');
    asserts.assert(pixels.get(4, 0).toString() == '00ffffff');
    asserts.assert(pixels.get(5, 0).a == 0xff);
    
    asserts.assert(pixels.get(0, 2).toString() == '7fff0000');
    asserts.assert(pixels.get(1, 2).toString() == '7f00ff00');
    asserts.assert(pixels.get(2, 2).toString() == '7f0000ff');
    asserts.assert(pixels.get(3, 2).toString() == '7f000000');
    asserts.assert(pixels.get(4, 2).toString() == '7fffffff');

    pixels.set(0, 0, 0xeeeeee);
    asserts.assert(pixels.get(0, 0).toString() == '00eeeeee');

    pixels.set(0, 0, 0xaeffea26);
    asserts.assert(pixels.get(0, 0).toString() == 'aeffea26');
    asserts.assert(pixels.get(0, 0).a == 0xae);
    asserts.assert(pixels.get(0, 0).r == 0xff);
    asserts.assert(pixels.get(0, 0).g == 0xea);
    asserts.assert(pixels.get(0, 0).b == 0x26);

    return asserts.done();
  }
}