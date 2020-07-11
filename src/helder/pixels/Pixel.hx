package helder.pixels;

import helder.pixels.PixelFormat.PixelOpacity;
import haxe.Int32;

// A lot of this comes straight from
// https://github.com/azrafe7/hxPixels/blob/0a471d358490ec13586bb2bf9837bcff16a14045/src/hxPixels/Pixels.hx
// Which is copyright (c) 2014 Giuseppe Di Mauro (azrafe7)

abstract Pixel(Int32) to Int32 {
  inline function new(value: Int32, opacity: PixelOpacity = ZeroOpaque) {
    this = value;
    if (opacity == ZeroTransparent) a = (255 - a);
  }

  inline public static function create(r:Int32, g:Int32, b:Int32, a:Int32)
    return new Pixel(((a & 0xff) << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | b);

  inline static public function createFromFloats(r:Float, g:Float, b:Float, a:Float):Pixel
    return create(Std.int(r), Std.int(g), Std.int(b), Std.int(a));

  @:from 
  inline public static function fromInt32(value: Int32)
    return new Pixel(value);

  inline public static function fromARGB(value: Int32, opacity: PixelOpacity = ZeroOpaque)
    return new Pixel(value, opacity);

  inline public static function fromRGBA(value: Int32, opacity: PixelOpacity = ZeroOpaque)
    return new Pixel((value >>> 8) | ((value & 0xff) << 24), opacity);

  inline public static function fromBGRA(value: Int32, opacity: PixelOpacity = ZeroOpaque)
    return new Pixel(
      (((value) & 0xff) << 24) |
      (((value >> 8) & 0xff) << 16) |
      (((value >> 16) & 0xff) << 8) |
      ((value >> 24) & 0xff), 
      opacity
    );

  inline public static function fromA7RGB(value: Int32) {
    final pixel = new Pixel((value & 0xffffff) | ((value & 0x7f000000) << 1));
    if (pixel.a > 0) pixel.a += 1;
    return pixel;
  }

  inline public static function ofFormat(format: PixelFormat, value: Int32)
    return format.normalize(value);

  inline public function toFormat(format: PixelFormat)
    return format.convert((cast this: Pixel));

  inline public function toARGB(opacity: PixelOpacity = ZeroOpaque): Int32
    return  switch opacity {
      case ZeroOpaque: this;
      case ZeroTransparent: 
        (0x00ffffff & this) | (255 - a);
    }

  inline public function toRGBA(opacity: PixelOpacity = ZeroOpaque): Int32
    return (this << 8) | switch opacity {
      case ZeroOpaque: a;
      case ZeroTransparent: (255 - a);
    }

  inline public function toBGRA(opacity: PixelOpacity = ZeroOpaque): Int32
    return (b << 24) | (g << 16) | (r << 8) | switch opacity {
      case ZeroOpaque: a;
      case ZeroTransparent: (255 - a);
    }

  inline public function toA7RGB(): Int32
    return (this & 0x00ffffff) | ((a >> 1) << 24);

  inline public function toString()
    return StringTools.hex(this, 8).toLowerCase();

  inline public function cie(): Float
    return 0.5126 * b + 0.7152 * g + 0.0722 * r;

  inline public function saturation(): Float {
    final maximum = Math.max(Math.max(r / 255, g / 255), b / 255);
    final minimum = Math.min(Math.min(r / 255, g / 255), b / 255);
    if (maximum == minimum) return 0;
    final l = (maximum + minimum) / 2;
    final d = maximum - minimum;
    return if (l > 0.5) d / (2 - maximum - minimum) else d / (maximum + minimum);
  }

  inline public function readChannel(channel: Channel)
    return switch channel {
      case A: a;
      case R: r;
      case G: g;
      case B: b;
    }

  inline public function withChannel(channel: Channel, value: Int32)
    return switch channel {
      case A: withA(value);
      case R: withR(value);
      case G: withG(value);
      case B: withB(value);
    }
  
  public var a(get, set): Int32;
  inline function get_a(): Int32
    return (this >> 24) & 0xFF;
  inline function set_a(a: Int32): Int32 {
    this = (this & 0x00FFFFFF) | (a << 24);
    return a;
  }
  inline public function withA(a: Int32): Pixel
    return create(r, g, b, a);

  public var r(get, set): Int32;
  inline function get_r(): Int32
    return (this >> 16) & 0xFF;
  inline function set_r(r: Int32): Int32 {
    this = (this & 0x00FFFFFF) | (r << 16);
    return r;
  }
  inline public function withR(r: Int32): Pixel
    return create(r, g, b, a);

  public var g(get, set): Int32;
  inline function get_g(): Int32
    return (this >> 8) & 0xFF;
  inline function set_g(g: Int32): Int32 {
    this = (this & 0xFF00FFFF) | (g << 8);
    return g;
  }
  inline public function withG(g: Int32): Pixel
    return create(r, g, b, a);

  public var b(get, set): Int32;
  inline function get_b(): Int32
    return this & 0xFF;
  inline function set_b(b: Int32): Int32 {
    this = (this & 0xFFFFFF00) | b;
    return b;
  }
  inline public function withB(b: Int32): Pixel
    return create(r, g, b, a);

  @:op(A == B) static function eq(a:Pixel, b:Pixel):Bool;
  @:op(A == B) @:commutative static function eqInt(a:Pixel, b:Int32):Bool;
  @:op(A == B) @:commutative static function eqFloat(a:Pixel, b:Float):Bool;

  @:op(A != B) static function neq(a:Pixel, b:Pixel):Bool;
  @:op(A != B) @:commutative static function neqInt(a:Pixel, b:Int32):Bool;
  @:op(A != B) @:commutative static function neqFloat(a:Pixel, b:Float):Bool;
}