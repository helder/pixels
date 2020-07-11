package tests;

import helder.pixels.impl.PixelBuffer;
import tink.unit.TestBatch;
import tink.testrunner.Runner;

class Run {
  static function main() {
    final colors = helder.pixels.impl.ImageLoader.fromFile('tests/colors.png');
    final crop = helder.pixels.impl.ImageLoader.fromFile('tests/crop.png');
    // helder.pixels.impl.ImageLoader.saveFile(crop, 'output.png');
    Runner.run(TestBatch.make([
      new TestPixel(),
      new TestFormat(),
      new TestDriver(colors),
      new TestDriver(colors.copyTo(
        new PixelBuffer(colors.width, colors.height)
      )),
      new TestSmartCrop(helder.pixels.impl.ImageLoader.fromFile('tests/crop.png')),
      //new TestResampler(helder.pixels.impl.GDPixels.fromFile('tests/crop.png')),
    ])).handle(Runner.exit);
  }
}
