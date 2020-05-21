package tests;

import tink.unit.TestBatch;
import tink.testrunner.Runner;

class Run {
  static function main() {
    Runner.run(TestBatch.make([
      new TestPixel(),
      #if php
      new TestDriver(helder.pixels.driver.PhpGD.fromFile('tests/colors.png'))
      #end
    ])).handle(Runner.exit);
  }
}
