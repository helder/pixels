package tests;

import helder.Pixels;
import helder.pixels.SmartCrop.suggestCrop;

@:asserts
class TestResampler {
  final pixels: Pixels;
  public function new(pixels)
    this.pixels = pixels;

  public function testResampler() {
    final buffer = Pixels.createBuffer(pixels.width, pixels.height);
    pixels.copyTo(buffer);
    final result = buffer.resample(
      Math.round(buffer.width * .5),
      Math.round(buffer.height * .5)
    );
    helder.pixels.impl.GDPixels.saveFile(result, 'output.png');
    return asserts.done();
  }
}