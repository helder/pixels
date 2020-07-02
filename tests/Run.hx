package tests;

import helder.pixels.impl.PixelBuffer;
import tink.unit.TestBatch;
import tink.testrunner.Runner;

class Run {
  static function main() {
    final colors = helder.pixels.impl.ImageLoader.fromFile('tests/colors.png');
    Runner.run(TestBatch.make([
      new TestPixel(),
      new TestSmartCrop(helder.pixels.impl.GDPixels.fromFile('tests/crop2.jpg')),
      new TestResampler(helder.pixels.impl.GDPixels.fromFile('tests/crop2.jpg')),
      new TestDriver(colors),
      new TestDriver(colors.copyTo(
        PixelBuffer.create(colors.width, colors.height)
      )),
    ])).handle(Runner.exit);
  }
}
