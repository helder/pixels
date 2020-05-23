package tests;

import helder.pixels.impl.GDPixels;
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
    trace(result);
    GDPixels.saveFile(result.debugOutput, 'output.png');
    return asserts.done();
  }
}