package helder;

interface Pixels {
  var width(get, never): Int;
  var height(get, never): Int;
  function get(x: Int, y: Int): Pixel;
  function set(x: Int, y: Int, pixel: Pixel): Void;
  function resample(width: Int, height: Int): Pixels;
}

typedef Pixel = helder.pixels.Pixel;