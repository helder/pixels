package helder.pixels.impl;

import helder.pixels.Resampler.BicubicKernel;
import helder.pixels.Resampler.BilinearKernel;
import helder.pixels.Resampler.LanczosKernel;
import helder.pixels.PixelFormat;
import haxe.io.Bytes;
import helder.Pixels;
/*
class PixelBuffer {
  public static function create(
    width: Int, height: Int, 
    ?format: PixelFormat, ?bytes: Bytes
  ): Pixels
    return switch format {
      case null | {order: ARGB}: new ARGBPixelBuffer(width, height, bytes);
      case {order: RGBA}: new RGBAPixelBuffer(width, height, bytes);
      case {order: BGRA}: new BGRAPixelBuffer(width, height, bytes);
    }
}

class ARGBPixelBuffer extends PixelBufferImpl {
  override public function get(x: Int, y: Int)
    return Pixel.fromARGB(bytes.getInt32(position(x, y)));

  override public function set(x: Int, y: Int, pixel: Pixel)
    bytes.setInt32(position(x, y), pixel.toARGB());

  override public function clone()
    return new ARGBPixelBuffer(width, height, cloneBuffer());

  override function offsetChannel(channel: Channel)
    return switch channel {
      case A: 3;
      case R: 2;
      case G: 1;
      case B: 0;
    }
}

class RGBAPixelBuffer extends PixelBufferImpl {
  override public function get(x: Int, y: Int)
    return Pixel.fromRGBA(bytes.getInt32(position(x, y)));

  override public function set(x: Int, y: Int, pixel: Pixel)
    bytes.setInt32(position(x, y), pixel.toRGBA());

  override public function clone()
    return new RGBAPixelBuffer(width, height, cloneBuffer());

  override function offsetChannel(channel: Channel)
    return switch channel {
      case A: 0;
      case B: 1;
      case G: 2;
      case R: 3;
    }
}

class BGRAPixelBuffer extends PixelBufferImpl {
  override public function get(x: Int, y: Int)
    return Pixel.fromBGRA(bytes.getInt32(position(x, y)));

  override public function set(x: Int, y: Int, pixel: Pixel)
    bytes.setInt32(position(x, y), pixel.toBGRA());

  override public function clone()
    return new BGRAPixelBuffer(width, height, cloneBuffer());

  override function offsetChannel(channel: Channel)
    return switch channel {
      case A: 0;
      case R: 1;
      case G: 2;
      case B: 3;
    }
}*/

@:allow(helder.Pixels)
class PixelBuffer implements PixelsImpl {
  final width: Int;
  final height: Int;
  final format: PixelFormat;
  final bytes: Bytes;

  inline public function new(width: Int, height: Int, ?format: PixelFormat, ?bytes: Bytes) {
    this.format = if (format == null) ARGB else format;
    this.bytes = 
      if (bytes == null) Bytes.alloc(width * height * 4) 
      else bytes;
    this.width = width;
    this.height = height;
  }

  public function getWidth() 
    return width;
  
  public function getHeight()
    return height;

  public function get(x: Int, y: Int): Pixel
    return Pixel.ofFormat(format, bytes.getInt32(position(x, y)));

  public function set(x: Int, y: Int, pixel: Pixel): Void
    bytes.setInt32(position(x, y), pixel.toFormat(format));

  // These can be optimized further later
  public function getChannel(channel: Channel, x: Int, y: Int): Int
    return get(x, y).readChannel(channel);

  public function setChannel(channel: Channel, x: Int, y: Int, value: Int) {
    final current = get(x, y);
    set(x, y, current.withChannel(channel, value));
  }

  public function clone(): Pixels
    return new PixelBuffer(width, height, format, cloneBuffer());

  public function resample(ratio: Float): Pixels {
    final resampler = new Resampler(new BilinearKernel());
    return resampler.scale(this, ratio);
  }

  function position(x: Int, y: Int)
    return (y * width + x) << 2;

  /*function offsetChannel(channel: Channel): Int
    return switch format.order {

    }*/

  function cloneBuffer() {
    final clone = Bytes.alloc(bytes.length);
    clone.blit(0, bytes, 0, bytes.length);
    return clone;
  }
}