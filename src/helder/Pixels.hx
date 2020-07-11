package helder;

import helder.pixels.PixelFormat;
import haxe.io.Bytes;
import helder.pixels.impl.PixelBuffer;
import helder.pixels.Channel;

@:forward
abstract Pixels(PixelsImpl) from PixelsImpl {
  public var width(get, never): Int;
  inline function get_width() return this.getWidth();
  
  public var height(get, never): Int;
  inline function get_height() return this.getHeight();

  public function copyTo(that: Pixels) {
    if (width != that.width || height != that.height)
      throw "dimensions don't match";
    for (y in 0 ... height)
      for (x in 0 ... width)
        that.set(x, y, this.get(x, y));
    return that;
  }

  public function clampChannel(channel: Channel, x: Int, y: Int, value: Int)
    return this.setChannel(channel, x, y, 
      if (value < 0) 0 
      else if (value > 255) 255
      else value
    );

  inline public function getA(x: Int, y: Int)
    return this.getChannel(A, x, y);

  inline public function getR(x: Int, y: Int)
    return this.getChannel(R, x, y);

  inline public function getG(x: Int, y: Int)
    return this.getChannel(G, x, y);

  inline public function getB(x: Int, y: Int)
    return this.getChannel(B, x, y);

  inline public function setA(x: Int, y: Int, value: Int)
    return this.setChannel(A, x, y, value);

  inline public function setR(x: Int, y: Int, value: Int)
    return this.setChannel(R, x, y, value);

  inline public function setG(x: Int, y: Int, value: Int)
    return this.setChannel(G, x, y, value);

  inline public function setB(x: Int, y: Int, value: Int)
    return this.setChannel(B, x, y, value);

  inline public static function createBuffer(
    width: Int, height: Int, 
    ?format: PixelFormat, ?bytes: Bytes
  ): Pixels
    return new PixelBuffer(width, height, format, bytes);

  public function toBytes(format: PixelFormat): Bytes {
    return if ((this is PixelBuffer) && format.equals((cast this: PixelBuffer).format)) {
      (cast this: PixelBuffer).bytes;
    } else {
      final buffer = createBuffer(width, height, format);
      copyTo(buffer);
      return buffer.toBytes(format);
    }
  }
}

interface PixelsImpl {
  function getWidth(): Int;
  function getHeight(): Int;
  function get(x: Int, y: Int): Pixel;
  function set(x: Int, y: Int, pixel: Pixel): Void;
  function getChannel(channel: Channel, x: Int, y: Int): Int;
  function setChannel(channel: Channel, x: Int, y: Int, value: Int): Void;
  function clone(): Pixels;
  function resample(ratio: Float): Pixels;
}

typedef Pixel = helder.pixels.Pixel;