package helder.pixels;

// A lot of this comes straight from
// https://github.com/azrafe7/hxPixels/blob/0a471d358490ec13586bb2bf9837bcff16a14045/src/hxPixels/Pixels.hx
// Which is copyright (c) 2014 Giuseppe Di Mauro (azrafe7)

abstract Pixel(Int) to Int {
  inline function new(value: Int)
    this = value;

  inline public static function create(r:Int, g:Int, b:Int, a:Int)
    return new Pixel(((a & 0xff) << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | b);

  inline static public function fcreate(r:Float, g:Float, b:Float, a:Float):Pixel
    return create(Std.int(a * 255.), Std.int(r * 255.), Std.int(g * 255.), Std.int(b * 255.));

  @:from
  inline public static function fromARGB(value: Int)
    return new Pixel(value);

  inline public static function fromRGBA(value: Int)
    return new Pixel((value >>> 8) | ((value & 0xff) << 24));

  inline public static function fromBGRA(value: Int)
    return new Pixel(
      (((value) & 0xff) << 24) |
      (((value >> 8) & 0xff) << 16) |
      (((value >> 16) & 0xff) << 8) |
      ((value >> 24) & 0xff)
    );

  inline public static function fromA7RGB(value: Int) {
    final pixel = new Pixel((value & 0xffffff) | ((value & 0x7f000000) << 1));
    if (pixel.a > 0) pixel.a += 1;
    return pixel;
  }

  inline public function toARGB(): Int
    return this;

  inline public function toRGBA(): Int
    return (this << 8) | a;

  inline public function toBGRA(): Int
    return (b << 24) | (g << 16) | (r << 8) | a;

  inline public function toA7RGB(): Int
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

  inline public function withChannel(channel: Channel, value: Int)
    return switch channel {
      case A: withA(value);
      case R: withR(value);
      case G: withG(value);
      case B: withB(value);
    }
  
  public var a(get, set): Int;
  inline function get_a(): Int
    return (this >> 24) & 0xFF;
  inline function set_a(a: Int): Int {
    this = (this & 0x00FFFFFF) | (a << 24);
    return a;
  }
  inline public function withA(a: Int): Pixel
    return create(r, g, b, a);

  public var r(get, set): Int;
  inline function get_r(): Int
    return (this >> 16) & 0xFF;
  inline function set_r(r: Int): Int {
    this = (this & 0x00FFFFFF) | (r << 16);
    return r;
  }
  inline public function withR(r: Int): Pixel
    return create(r, g, b, a);

  public var g(get, set): Int;
  inline function get_g(): Int
    return (this >> 8) & 0xFF;
  inline function set_g(g: Int): Int {
    this = (this & 0xFF00FFFF) | (g << 8);
    return g;
  }
  inline public function withG(g: Int): Pixel
    return create(r, g, b, a);

  public var b(get, set): Int;
  inline function get_b(): Int
    return this & 0xFF;
  inline function set_b(b: Int): Int {
    this = (this & 0xFFFFFF00) | b;
    return b;
  }
  inline public function withB(b: Int): Pixel
    return create(r, g, b, a);

  @:op(-A) function negate():Pixel;
  @:op(++A) function preIncrement():Pixel;
  @:op(A++) function postIncrement():Pixel;
  @:op(--A) function preDecrement():Pixel;
  @:op(A--) function postDecrement():Pixel;

  @:op(A + B) static function add(a:Pixel, b:Pixel):Pixel;
  @:op(A + B) @:commutative static function addInt(a:Pixel, b:Int):Pixel;
  @:op(A + B) @:commutative static function addFloat(a:Pixel, b:Float):Float;
  @:op(A - B) static function sub(a:Pixel, b:Pixel):Pixel;
  @:op(A - B) static function subInt(a:Pixel, b:Int):Pixel;
  @:op(A - B) static function intSub(a:Int, b:Pixel):Pixel;
  @:op(A - B) static function subFloat(a:Pixel, b:Float):Float;
  @:op(A - B) static function floatSub(a:Float, b:Pixel):Float;
  @:op(A * B) static function mul(a:Pixel, b:Pixel):Pixel;
  @:op(A * B) @:commutative static function mulInt(a:Pixel, b:Int):Pixel;
  @:op(A * B) static function mul(a:Pixel, b:Pixel):Pixel;
  @:op(A * B) @:commutative static function mulInt(a:Pixel, b:Int):Pixel;
  @:op(A * B) @:commutative static function mulFloat(a:Pixel, b:Float):Float;
  @:op(A / B) static function div(a:Pixel, b:Pixel):Float;
  @:op(A / B) static function divInt(a:Pixel, b:Int):Float;
  @:op(A / B) static function intDiv(a:Int, b:Pixel):Float;
  @:op(A / B) static function divFloat(a:Pixel, b:Float):Float;
  @:op(A / B) static function floatDiv(a:Float, b:Pixel):Float;

  @:op(A % B) static function mod(a:Pixel, b:Pixel):Pixel;
  @:op(A % B) static function modInt(a:Pixel, b:Int):Int;
  @:op(A % B) static function intMod(a:Int, b:Pixel):Int;
  @:op(A % B) static function modFloat(a:Pixel, b:Float):Float;
  @:op(A % B) static function floatMod(a:Float, b:Pixel):Float;

  @:op(A == B) static function eq(a:Pixel, b:Pixel):Bool;
  @:op(A == B) @:commutative static function eqInt(a:Pixel, b:Int):Bool;
  @:op(A == B) @:commutative static function eqFloat(a:Pixel, b:Float):Bool;

  @:op(A != B) static function neq(a:Pixel, b:Pixel):Bool;
  @:op(A != B) @:commutative static function neqInt(a:Pixel, b:Int):Bool;
  @:op(A != B) @:commutative static function neqFloat(a:Pixel, b:Float):Bool;

  @:op(A < B) static function lt(a:Pixel, b:Pixel):Bool;
  @:op(A < B) static function ltInt(a:Pixel, b:Int):Bool;
  @:op(A < B) static function intLt(a:Int, b:Pixel):Bool;
  @:op(A < B) static function ltFloat(a:Pixel, b:Float):Bool;
  @:op(A < B) static function floatLt(a:Float, b:Pixel):Bool;

  @:op(A <= B) static function lte(a:Pixel, b:Pixel):Bool;
  @:op(A <= B) static function lteInt(a:Pixel, b:Int):Bool;
  @:op(A <= B) static function intLte(a:Int, b:Pixel):Bool;
  @:op(A <= B) static function lteFloat(a:Pixel, b:Float):Bool;
  @:op(A <= B) static function floatLte(a:Float, b:Pixel):Bool;

  @:op(A > B) static function gt(a:Pixel, b:Pixel):Bool;
  @:op(A > B) static function gtInt(a:Pixel, b:Int):Bool;
  @:op(A > B) static function intGt(a:Int, b:Pixel):Bool;
  @:op(A > B) static function gtFloat(a:Pixel, b:Float):Bool;
  @:op(A > B) static function floatGt(a:Float, b:Pixel):Bool;

  @:op(A >= B) static function gte(a:Pixel, b:Pixel):Bool;
  @:op(A >= B) static function gteInt(a:Pixel, b:Int):Bool;
  @:op(A >= B) static function intGte(a:Int, b:Pixel):Bool;
  @:op(A >= B) static function gteFloat(a:Pixel, b:Float):Bool;
  @:op(A >= B) static function floatGte(a:Float, b:Pixel):Bool;

  @:op(~A) function complement():Pixel;

  @:op(A & B) static function and(a:Pixel, b:Pixel):Pixel;
  @:op(A & B) @:commutative static function andInt(a:Pixel, b:Int):Pixel;

  @:op(A | B) static function or(a:Pixel, b:Pixel):Pixel;
  @:op(A | B) @:commutative static function orInt(a:Pixel, b:Int):Pixel;

  @:op(A ^ B) static function xor(a:Pixel, b:Pixel):Pixel;
  @:op(A ^ B) @:commutative static function xorInt(a:Pixel, b:Int):Pixel;


  @:op(A >> B) static function shr(a:Pixel, b:Pixel):Pixel;
  @:op(A >> B) static function shrInt(a:Pixel, b:Int):Pixel;
  @:op(A >> B) static function intShr(a:Int, b:Pixel):Pixel;

  @:op(A >>> B) static function ushr(a:Pixel, b:Pixel):Pixel;
  @:op(A >>> B) static function ushrInt(a:Pixel, b:Int):Pixel;
  @:op(A >>> B) static function intUshr(a:Int, b:Pixel):Pixel;

  @:op(A << B) static function shl(a:Pixel, b:Pixel):Pixel;
  @:op(A << B) static function shlInt(a:Pixel, b:Int):Pixel;
  @:op(A << B) static function intShl(a:Int, b:Pixel):Pixel;
}