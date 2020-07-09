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

typedef PixelFormatData = {
  order: PixelOrder,
  opacity: PixelOpacity
}

@:forward
abstract PixelFormat(PixelFormatData) from PixelFormatData {
  @:from static function fromOrder(order: PixelOrder): PixelFormat
    return {
      opacity: ZeroOpaque,
      order: order
    }
}