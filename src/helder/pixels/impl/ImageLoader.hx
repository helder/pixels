package helder.pixels.impl;

import haxe.io.Path;
import helder.pixels.PixelFormat;

@:require('format')
class ImageLoader {

  #if (sys || nodejs)
  public static function fromFile(file: String): Pixels {
    return switch Path.extension(file).toLowerCase() {
      case 'png': 
        fromPngData(
          new format.png.Reader(sys.io.File.read(file)).read()
        );
      case 'jpg' | 'jpeg':
        fromJpegData(
          sys.io.File.getBytes(file)
        );
      case extension: throw 'Extension "$extension" not supported';
    }
  }

  public static function saveFile(pixels: Pixels, file: String, quality = 96) {
    switch Path.extension(file).toLowerCase() {
      case 'png':
        final output = sys.io.File.write(file);
        final writer = new format.png.Writer(output);
        writer.write(format.png.Tools.build32ARGB(
          pixels.width,
          pixels.height,
          pixels.toBytes(ARGB.transparent())
        ));
      case extension: throw 'Extension "$extension" not supported';
    }
  }
  #end

  static function fromJpegData(bytes: haxe.io.Bytes) {
    final data = NanoJpeg.decode(bytes);
    return Pixels.createBuffer(
      data.width,
      data.height,
      BGRA,
      data.pixels
    );
  }


  static function fromPngData(data: format.png.Data): Pixels {
    final header = format.png.Tools.getHeader(data);
    final bytes = format.png.Tools.extract32(data);
		for (i in 0 ... bytes.length >> 2) {
			var a = bytes.get((i * 4) + 3);
			bytes.set((i * 4) + 3, 255 - a);
		}
    return Pixels.createBuffer(
      header.width,
      header.height,
      ARGB,
      bytes
    );
  }
}