package helder.pixels.impl;

import php.Resource;
import haxe.io.Path;
import helder.Pixels;

class GDPixels implements PixelsImpl {
  final image: Resource;
  final supportsAlpha: Bool;

  inline public function new(image, supportsAlpha = true) {
    this.image = image;
    this.supportsAlpha = supportsAlpha;
  }

  public function getWidth() 
    return GD.imagesx(image);
  
  public function getHeight() 
    return GD.imagesy(image);

  public function get(x: Int, y: Int)
    return Pixel.fromA7RGB(GD.imagecolorat(image, x, y));

  public function set(x: Int, y: Int, pixel: Pixel)
    GD.imagesetpixel(image, x, y, pixel.toA7RGB());

  public function getChannel(channel: Channel, x: Int, y: Int): Int
    return get(x, y).readChannel(channel);

  public function setChannel(channel: Channel, x: Int, y: Int, value: Int) {
    final pixel = get(x, y).withChannel(channel, value);
    set(x, y, pixel);
  }

  public function resample(width: Int, height: Int): Pixels {
    final destination = createImage(width, height, supportsAlpha);
    GD.imagecopyresampled(
      destination, image, 0, 0, 0, 0, 
      width, height, this.getWidth(), this.getHeight()
    );
    return new GDPixels(destination, supportsAlpha);
  }

  public function clone(): Pixels {
    final destination = createImage(getWidth(), getHeight(), supportsAlpha);
    GD.imagecopy(
      destination, image, 0, 0, 0, 0, 
      getWidth(), getHeight()
    );
    return new GDPixels(destination, supportsAlpha);
  }

  static function createImage(width: Int, height: Int, supportsAlpha = true) {
    final destination = GD.imagecreatetruecolor(width, height);
    if (supportsAlpha) {
      GD.imagealphablending(destination, false);
      GD.imagesavealpha(destination, true);
      final overlay = GD.imagecolorallocatealpha(destination, 255, 255, 255, 127);
      GD.imagefill(destination, 0, 0, overlay);
    }
    return destination;
  }

  public static function create(width: Int, height: Int, supportsAlpha = true): Pixels
    return new GDPixels(createImage(width, height, supportsAlpha));

  public static function fromFile(file: String): Pixels {
    return switch Path.extension(file).toLowerCase() {
      case 'png': 
        final image = GD.imagecreatefrompng(file);
        GD.imagealphablending(image, false);
        GD.imagesavealpha(image, true);
        new GDPixels(image);
      case 'jpg' | 'jpeg':
        new GDPixels(GD.imagecreatefromjpeg(file), false);
      case 'bmp':
        new GDPixels(GD.imagecreatefrombmp(file), false);
      case 'gif':
        new GDPixels(GD.imagecreatefromgif(file), false);
      case 'webp':
        new GDPixels(GD.imagecreatefromwebp(file));
      default: null;
    }
  }

  public static function saveFile(pixels: Pixels, file: String, quality = 96) {
    final output = 
      if (!Std.is(pixels, GDPixels)) 
        pixels.copyTo(create(pixels.width, pixels.height))
      else pixels;
    switch Path.extension(file) {
      case 'png': GD.imagepng((cast output: GDPixels).image, file, 9);
      case 'jpg' | 'jpeg': GD.imagejpeg((cast output: GDPixels).image, file, quality);
      case 'bmp': GD.imagebmp((cast output: GDPixels).image, file);
      case 'gif': GD.imagegif((cast output: GDPixels).image, file);
      case 'webp': GD.imagewebp((cast output: GDPixels).image, file);
      default: throw 'unsupported extension';
    }
  }
}

@:phpGlobal
extern class GD {
  static function imagesx(image: Resource): Int;
  static function imagesy(image: Resource): Int;
  static function imagecolorat(image: Resource, x: Int, y: Int): Int;
  static function imagesetpixel(image: Resource, x: Int, y: Int, color: Int): Int;
  static function imagecreatefrompng(file: String): Resource;
  static function imagecreatefromjpeg(file: String): Resource;
  static function imagecreatefromgif(file: String): Resource;
  static function imagecreatefromwebp(file: String): Resource;
  static function imagecreatefrombmp(file: String): Resource;
  static function imagecreatetruecolor(w:Int, h:Int): Resource;
  static function imagecopyresampled(dst_image: Resource, src_image: Resource, dst_x:Int, dst_y:Int, src_x:Int, src_y:Int, dst_w:Int, dst_h:Int, src_w:Int, src_h:Int): Resource;
  static function imagealphablending(image: Resource, blendmode: Bool): Bool;
  static function imagesavealpha(image: Resource, saveFlag: Bool): Bool;
  static function imagepng(_image:Resource, ?_to:String, ?quality:Int): Bool;
  static function imagejpeg(_image:Resource, ?_to:String, ?quality:Int): Bool;
  static function imagewebp(_image:Resource, ?_to:String, ?quality:Int): Bool;
  static function imagegif(_image:Resource, ?_to:String): Bool;
  static function imagebmp(_image:Resource, ?_to:String): Bool;
  static function imagecolorallocatealpha(image: Resource, red: Int, green: Int, blue: Int, alpha: Int): Int;
  static function imagefill(image: Resource, x: Int, y: Int, color: Int): Bool;
  static function imagecopy(to: Resource, from: Resource, dst_x: Int, dst_y: Int, src_x: Int, src_y: Int, src_w: Int, src_h: Int): Void;
}
