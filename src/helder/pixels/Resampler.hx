package helder.pixels;

import haxe.io.Float32Array;
import haxe.io.Bytes;
import haxe.ds.Vector;

// See https://github.com/sergey-miryanov/ImageResizeHx/blob/e9f5fd3f8fd13b5a81022e4fe1af3905fb4adfd9/ImageResize.hx
// Which is copyright (c) 2013 Sergey Miryanov

class Resampler {
  static var CACHE_PRE: Int = 100;

  final cache: Vector<Float>;
  final kernel: IKernel;

  public function new(kernel: IKernel) {
    this.kernel = kernel;
    final maxCache = kernel.radius() * kernel.radius() * CACHE_PRE;
    this.cache = new Vector(maxCache);

    var invPre = 1.0 / CACHE_PRE;
    for (cacheKey in 0...maxCache) {
      var x = Math.sqrt(cacheKey * invPre);
      var v = kernel.calculate(x);

      cache[cacheKey] = (v < 0 ? 0 : v);
    }
  }

  public function scale(source: Pixels, ratio: Float) {
    var w: Int = Std.int(source.width);
    var h: Int = Std.int(source.height);

    var width: Int = Std.int(w * ratio);
    var height: Int = Std.int(h * ratio);

    var invRatio = 1.0 / ratio;

    var cw = 1.0 / (w * ratio);
    var ch = 1.0 / (h * ratio);

    var csx = Math.min(1, ratio) * Math.min(1, ratio);
    var csy = Math.min(1, ratio) * Math.min(1, ratio);

    var filterSize: Int = kernel.radius();

    final res = Pixels.createBuffer(width, height);
    final values = new Float32Array(width * height);

    for (y in 0...height) {
      var yCenter = (y + 0.5) * invRatio;
      var y1b: Int = Math.floor(Math.max(yCenter - filterSize, 0));
      var y1e: Int = Math.round(Math.min(yCenter + filterSize, h));

      var cy = y * ch - yCenter;

      for (x in 0...width) {
        var xCenter = (x + 0.5) * invRatio;
        var x1b: Int = Math.floor(Math.max(xCenter - filterSize, 0));
        var x1e: Int = Math.round(Math.min(xCenter + filterSize, w));

        var cx = x * cw - xCenter;

        var i: Int = 0;
        var total: Float = 0;

        for (y1 in y1b...y1e) {
          var distY = (y1 + cy) * (y1 + cy) * csy;
          for (x1 in x1b...x1e) {
            var distX = (x1 + cx) * (x1 + cx) * csx;
            var dist = Math.round((distX + distY) * CACHE_PRE);
            var value: Float = dist < cache.length ? cache[dist] : 0;
            values[i] = value;
            total += value;

            i += 1;
          }
        }
        if (total == 0.0)
          total = 1.0;

        var color = getColor(source, values, x1b, x1e, y1b, y1e, w, 1.0 / total);
        res.set(x, y, color);
      }
    }

    return res;
  }

  function getColor(source: Pixels, values: Float32Array, x1b: Int, x1e: Int, y1b: Int, y1e: Int, w: Int,
      total: Float): Pixel {
    var i = 0;

    var r = .0;
    var g = .0;
    var b = .0;
    var a = .0;
    for (y1 in y1b...y1e) {
      for (x1 in x1b...x1e) {
        var color = source.get(x1, y1);
        var value = values[i] * total;
        r += color.r * value;
        g += color.g * value;
        b += color.b * value;
        a += color.a * value;
        ++i;
      }
    }

    return Pixel.createFromFloats(r, g, b, a);
  }
}

interface IKernel {
  function radius(): Int;
  function calculate(x: Float): Float;
}

class LanczosKernel implements IKernel {
  public static var FILTER_SIZE: Int = 3;

  public function new() {}

  public function radius(): Int {
    return FILTER_SIZE;
  }

  public function calculate(x: Float): Float {
    var v: Float = 0.0;
    if (x < -FILTER_SIZE)
      v = 0.0;
    else if (x < 0.0)
      v = sinc(-x) * sinc(-x / FILTER_SIZE);
    else if (x < FILTER_SIZE)
      v = sinc(x) * sinc(x / FILTER_SIZE);
    else
      v = 0.0;

    return v;
  }

  function sinc(x: Float): Float {
    if (x == 0.0)
      return 1.0;

    var arg = Math.PI * x;
    return Math.sin(arg) / arg;
  }
}

class BlackmanKernel implements IKernel {
  static var FILTER_SIZE: Int = 3;

  public function new() {}

  public function radius(): Int {
    return FILTER_SIZE;
  }

  public function calculate(x: Float): Float {
    if (x < 0)
      return blackman(-x);
    else
      return blackman(x);
  }

  function blackman(x: Float): Float {
    if (x == 0.0)
      return 1.0;
    if (x > FILTER_SIZE)
      return 0.0;

    x *= Math.PI;
    var xr = x / FILTER_SIZE;
    return (Math.sin(x) / x) * (0.42
      + 0.5 * Math.cos(xr)
      + 0.08 * Math.cos(2 * xr));
  }
}

class BicubicKernel implements IKernel {
  static var FILTER_SIZE: Int = 2;

  public function new() {}

  public function radius(): Int {
    return FILTER_SIZE;
  }

  public function calculate(x: Float): Float {
    return (1.0 / 6.0) * (pow3(x + 2)
      - 4 * pow3(x + 1)
      + 6 * pow3(x)
      - 4 * pow3(x - 1));
  }

  function pow3(x: Float): Float {
    return x <= 0.0 ? 0.0 : x * x * x;
  }
}

class BilinearKernel implements IKernel {
  static var FILTER_SIZE: Int = 1;

  public function new() {}

  public function radius(): Int {
    return FILTER_SIZE;
  }

  public function calculate(x: Float): Float {
    if (x < 0.0)
      return 1.0 + x;
    return 1.0 - x;
  }
}

class MitchellKernel implements IKernel {
  static var FILTER_SIZE: Int = 2;

  var B: Float;
  var C: Float;
  var P0: Float;
  var P2: Float;
  var P3: Float;
  var Q0: Float;
  var Q1: Float;
  var Q2: Float;
  var Q3: Float;

  public function new() {
    B = (1.0 / 3.0);
    C = (1.0 / 3.0);
    P0 = ((6.0 - 2.0 * B) / 6.0);
    P2 = ((-18.0 + 12.0 * B + 6.0 * C) / 6.0);
    P3 = ((12.0 - 9.0 * B - 6.0 * C) / 6.0);
    Q0 = ((8.0 * B + 24.0 * C) / 6.0);
    Q1 = ((-12.0 * B - 48.0 * C) / 6.0);
    Q2 = ((6.0 * B + 30.0 * C) / 6.0);
    Q3 = ((-1.0 * B - 6.0 * C) / 6.0);
  }

  public function radius(): Int {
    return FILTER_SIZE;
  }

  public function calculate(x: Float): Float {
    if (x < -2.0)
      return 0.0;
    if (x < -1.0)
      return Q0 - x * (Q1 - x * (Q2 - x * Q3));
    if (x < 0.0)
      return P0 + x * x * (P2 - x * P3);
    if (x < 1.0)
      return P0 + x * x * (P2 + x * P3);
    if (x < 2.0)
      return Q0 + x * (Q1 + x * (Q2 + x * Q3));

    return 0.0;
  }
}
