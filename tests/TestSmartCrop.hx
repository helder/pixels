package tests;

import helder.Pixels;
import helder.pixels.SmartCrop.suggestCrop;

@:asserts
class TestSmartCrop {
  final pixels: Pixels;
  public function new(pixels)
    this.pixels = pixels;

  public function testSmartCrop() {
    final result = suggestCrop(pixels, {
      debug: true,
      width: 100,
      height: 100
    });
    final top = result.topCrop;
    asserts.assert(top.x == 11 && top.y == 0);
    asserts.assert(top.width == 379 && top.height == 379);
    helder.pixels.impl.ImageLoader.saveFile(result.debugOutput, 'bin/smartcrop.png');
    return asserts.done();
  }
}