package helder.pixels.impl;

import haxe.io.Bytes;
import helder.Pixels;

enum PixelFormat {
  ARGB;
  RGBA;
  BGRA;
}

class PixelBuffer {
  public static function create(
    width: Int, height: Int, 
    ?format: PixelFormat, ?bytes: Bytes
  ): Pixels
    return switch format {
      case null | ARGB: new ARGBPixelBuffer(width, height, bytes);
      case RGBA: new RGBAPixelBuffer(width, height, bytes);
      case BGRA: new BGRAPixelBuffer(width, height, bytes);
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
      case B: 0;
      case G: 1;
      case R: 2;
      case A: 3;
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
}

private class PixelBufferImpl implements PixelsImpl {
  final bytes: Bytes;
  final width: Int;
  final height: Int;

  inline public function new(width: Int, height: Int, ?bytes: Bytes) {
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
    throw 'abstract';

  public function set(x: Int, y: Int, pixel: Pixel): Void
    throw 'abstract';

  public function getChannel(channel: Channel, x: Int, y: Int): Int
    return bytes.get(position(x, y) + offsetChannel(channel));

  public function setChannel(channel: Channel, x: Int, y: Int, value: Int)
    return bytes.set(position(x, y) + offsetChannel(channel), value);

  public function clone(): Pixels
    throw 'abstract';

  public function resample(width: Int, height: Int): Pixels
    throw 'todo';

  function position(x: Int, y: Int)
    return (y * width + x) << 2;

  function offsetChannel(channel: Channel): Int
    return channel;

  function cloneBuffer() {
    final clone = Bytes.alloc(bytes.length);
    clone.blit(0, bytes, 0, bytes.length);
    return clone;
  }
}