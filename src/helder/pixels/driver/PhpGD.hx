package helder.pixels.driver;

import php.Resource;
import haxe.io.Path;
import helder.Pixels;

class PhpGD implements Pixels {
  final image: Resource;
  final supportsAlpha: Bool;

  inline public function new(image, supportsAlpha = false) {
    this.image = image;
    this.supportsAlpha = supportsAlpha;
  }

  public var width(get, never): Int;
  function get_width() return GD.imagesx(image);
  
  public var height(get, never): Int;
  function get_height() return GD.imagesy(image);

  public function get(x: Int, y: Int)
    return Pixel.fromA7RGB(GD.imagecolorat(image, x, y));

  public function set(x: Int, y: Int, pixel: Pixel)
    GD.imagesetpixel(image, x, y, pixel.toA7RGB());

  public function resample(width: Int, height: Int) {
    final destination = GD.imagecreatetruecolor(width, height);
    if (supportsAlpha) {
      GD.imagealphablending(destination, false);
      GD.imagesavealpha(destination, true);
      final overlay = GD.imagecolorallocatealpha(destination, 255, 255, 255, 127);
      GD.imagefill(destination, 0, 0, overlay);
    }
    GD.imagecopyresampled(
      destination, image, 0, 0, 0, 0, 
      width, height, this.width, this.height
    );
    return new PhpGD(
      destination,
      supportsAlpha
    );
  }

  public static function fromFile(file: String) {
    return switch Path.extension(file) {
      case 'png': 
        final image = GD.imagecreatefrompng(file);
        GD.imagealphablending(image, false);
        GD.imagesavealpha(image, true);
        new PhpGD(image, true);
      default: null;
    }
  }

  public function writeFile(file: String) {
    switch Path.extension(file) {
      case 'png': GD.imagepng(image, file, 9);
      default: null;
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
	static function imagecreatetruecolor(w:Int, h:Int): Resource;
	static function imagecopyresampled(dst_image: Resource, src_image: Resource, dst_x:Int, dst_y:Int, src_x:Int, src_y:Int, dst_w:Int, dst_h:Int, src_w:Int, src_h:Int): Resource;
	static function imagealphablending(image: Resource, blendmode: Bool): Bool;
  static function imagesavealpha(image: Resource, saveFlag: Bool): Bool;
	static function imagepng(_image:Resource, ?_to:String, ?quality:Int): Bool;
  static function imagecolorallocatealpha(image: Resource, red: Int, green: Int, blue: Int, alpha: Int): Int;
  static function imagefill(image: Resource, x: Int, y: Int, color: Int): Bool;
}
