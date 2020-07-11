package helder.pixels;

@:using(helder.pixels.PixelFormat.PixelOrderTools)
enum PixelOrder {
  ARGB;
  RGBA;
  BGRA;
}

class PixelOrderTools {
  public static function transparent(order: PixelOrder): PixelFormat
    return {
      opacity: ZeroTransparent,
      order: order
    }
}

enum PixelOpacity {
  ZeroOpaque;
  ZeroTransparent;
}

enum PixelEndian {

}

typedef PixelFormatData = {
  order: PixelOrder,
  opacity: PixelOpacity
}

@:forward
abstract PixelFormat(PixelFormatData) from PixelFormatData {
  public function normalize(value: Int): Pixel
    return switch this {
      case {order: ARGB, opacity: opacity}: Pixel.fromARGB(value, opacity);
      case {order: RGBA, opacity: opacity}: Pixel.fromRGBA(value, opacity);
      case {order: BGRA, opacity: opacity}: Pixel.fromBGRA(value, opacity);
    }

  public function convert(pixel: Pixel): Int
    return switch this {
      case {order: ARGB, opacity: opacity}: pixel.toARGB(opacity);
      case {order: RGBA, opacity: opacity}: pixel.toRGBA(opacity);
      case {order: BGRA, opacity: opacity}: pixel.toBGRA(opacity);
    }

  public function equals(that: PixelFormat) {
    return this.order == that.order && this.opacity == that.opacity;
  }

  @:from static function fromOrder(order: PixelOrder): PixelFormat
    return {
      opacity: ZeroOpaque,
      order: order
    }
}