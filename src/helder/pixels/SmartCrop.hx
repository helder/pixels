package helder.pixels;

// Port of https://github.com/jwagner/smartcrop.js/blob/6c8ffbdc007350081bf1f543149caced6c237501/smartcrop.js
// Which is copyright (c) 2016 Jonas Wagner
// Note: boosts are currently not available

import helder.Pixels;
import Math.*;
import Std.int;

typedef SmartCropOptions = {
  ?width:Int,
  ?height:Int,
  ?aspect:Int,
  ?cropWidth:Int,
  ?cropHeight:Int,
  ?detailWeight:Float,
  ?skinColor:Array<Float>,
  ?skinBias:Float,
  ?skinBrightnessMin:Float,
  ?skinBrightnessMax:Float,
  ?skinThreshold:Float,
  ?skinWeight:Float,
  ?saturationBrightnessMin:Float,
  ?saturationBrightnessMax:Float,
  ?saturationThreshold:Float,
  ?saturationBias:Float,
  ?saturationWeight:Float,
  ?scoreDownSample:Int,
  ?step:Int,
  ?scaleStep:Float,
  ?minScale:Float,
  ?maxScale:Float,
  ?edgeRadius:Float,
  ?edgeWeight:Float,
  ?outsideImportance:Float,
  ?boostWeight:Float,
  ?ruleOfThirds:Bool,
  ?prescale:Bool,
  ?debug:Bool
}

final defaults = {
  width: 0,
  height: 0,
  aspect: 0,
  cropWidth: 0,
  cropHeight: 0,
  detailWeight: 0.2,
  skinColor: [0.78, 0.57, 0.44],
  skinBias: 0.01,
  skinBrightnessMin: 0.2,
  skinBrightnessMax: 1.0,
  skinThreshold: 0.8,
  skinWeight: 1.8,
  saturationBrightnessMin: 0.05,
  saturationBrightnessMax: 0.9,
  saturationThreshold: 0.4,
  saturationBias: 0.2,
  saturationWeight: 0.1,
  scoreDownSample: 8,
  step: 8,
  scaleStep: 0.1,
  minScale: 1.0,
  maxScale: 1.0,
  edgeRadius: 0.4,
  edgeWeight: -20.0,
  outsideImportance: -0.5,
  boostWeight: 100.0,
  ruleOfThirds: true,
  prescale: true,
  debug: false
}

typedef Crop = {
  x: Int,
  y: Int,
  width: Float,
  height: Float,
  ?score: Score
}

typedef Score = {
  detail:Float, 
  saturation:Float, 
  skin:Float, 
  boost:Float, 
  total:Float
}

typedef CropSuggestion = {
  topCrop: Crop,
  ?crops: Array<Crop>,
  ?debugOutput: Pixels,
  ?debugOptions: SmartCropOptions
} 

function suggestCrop(pixels:Pixels, cropOptions:SmartCropOptions): CropSuggestion {
  final options = Reflect.copy(defaults);

  for (key in Reflect.fields(cropOptions))
    Reflect.setField(options, key, Reflect.field(cropOptions, key));

  if (options.aspect != 0) {
    options.width = options.aspect;
    options.height = 1;
  }

  var scale = 1.;
  var prescale = 1.;

  // calculate desired crop dimensions based on the image size
  if (options.width != null && options.height != null) {
    scale = min(
      pixels.width / options.width, 
      pixels.height / options.height
    );
    options.cropWidth = int(options.width * scale);
    options.cropHeight = int(options.height * scale);
    // Img = 100x100, width = 95x95, scale = 100/95, 1/scale > min
    // don't set minscale smaller than 1/scale
    // -> don't pick crops that need upscaling
    options.minScale = min(options.maxScale, max(1 / scale, options.minScale));

    // prescale if possible
    if (options.prescale != false) {
      prescale = min(max(256 / pixels.width, 256 / pixels.height), 1);
      if (prescale < 1) {
        pixels = pixels.resample(prescale);
        options.cropWidth = int(options.cropWidth * prescale);
        options.cropHeight = int(options.cropHeight * prescale);
      } else {
        prescale = 1;
      }
    }
  }

  var result = analyse(pixels, options);

  var crops = switch [result.crops, result.topCrop] {
    case [null, null]: [];
    case [v, _] if (v != null): v;
    case [_, top]: [top]; 
  }
  for (crop in crops) {
    crop.x = floor(crop.x / prescale);
    crop.y = floor(crop.y / prescale);
    crop.width = floor(crop.width / prescale);
    crop.height = floor(crop.height / prescale);
  }
  return result;
}

function edgeDetect(input: Pixels, output: Pixels) {
  var w = input.width;
  var h = input.height;

  for (y in 0 ... h) {
    for (x in 0 ... w) {
      final lightness = 
        if (x == 0 || x >= w - 1 || y == 0 || y >= h - 1)
          input.get(x, y).cie()
        else 
          (input.get(x, y).cie() * 4) -
          input.get(x, y - 1).cie() -
          input.get(x - 1, y).cie() -
          input.get(x + 1, y).cie() -
          input.get(x, y + 1).cie();
      output.clampChannel(G, x, y, int(lightness));
    }
  }
}

function skinColor(options: SmartCropOptions, r: Int, g: Int, b: Int) {
  var mag = sqrt(r * r + g * g + b * b);
  var rd = r / mag - options.skinColor[0];
  var gd = g / mag - options.skinColor[1];
  var bd = b / mag - options.skinColor[2];
  var d = sqrt(rd * rd + gd * gd + bd * bd);
  return 1 - d;
}

function skinDetect(options: SmartCropOptions, i: Pixels, o: Pixels) {
  var w = i.width;
  var h = i.height;

  for (y in 0 ... h) {
    for (x in 0 ... w) {
      final pixel = i.get(x, y);
      var lightness = pixel.cie() / 255;
      var skin = skinColor(options, pixel.r, pixel.g, pixel.b);
      var isSkinColor = skin > options.skinThreshold;
      var isSkinBrightness =
        lightness >= options.skinBrightnessMin &&
        lightness <= options.skinBrightnessMax;
      if (isSkinColor && isSkinBrightness) {
        o.clampChannel(R, x, y, int(
          (skin - options.skinThreshold) *
          (255 / (1 - options.skinThreshold))
        ));
      } else {
        o.clampChannel(R, x, y, 0);
      }
    }
  }
}

function saturationDetect(options: SmartCropOptions, i: Pixels, o: Pixels) {
  var w = i.width;
  var h = i.height;

  for (y in 0 ... h) {
    for (x in 0 ... w) {
      final pixel = i.get(x, y);
      final lightness = pixel.cie() / 255;
      final sat = pixel.saturation();
      final acceptableSaturation = sat > options.saturationThreshold;
      final acceptableLightness =
        lightness >= options.saturationBrightnessMin &&
        lightness <= options.saturationBrightnessMax;
      if (acceptableLightness && acceptableSaturation) {
        o.clampChannel(B, x, y, int(
          (sat - options.saturationThreshold) *
          (255 / (1 - options.saturationThreshold))
        ));
      } else {
        o.clampChannel(B, x, y, 0);
      }
    }
  }
}

function downSample(input: Pixels, factor: Int) {
  var iwidth = input.width;
  var width = floor(input.width / factor);
  var height = floor(input.height / factor);
  var output = Pixels.createBuffer(width, height);
  var ifactor2 = 1 / (factor * factor);

  for (y in 0 ... height) {
    for (x in 0 ... width) {
      var a = 0;
      var r = 0;
      var g = 0;
      var b = 0;

      var mr = 0.;
      var mg = 0.;

      for (v in 0 ... factor) {
        for (u in 0 ... factor) {
          final pixel = input.get(x * factor + u, y * factor + v);
          r += pixel.r;
          g += pixel.g;
          b += pixel.b;
          a += pixel.a;
          mr = max(mr, pixel.r);
          mg = max(mg, pixel.g);
          // unused
          // mb = Math.max(mb, idata[j + 2]);
        }
      }
      // this is some funky magic to preserve detail a bit more for
      // skin (r) and detail (g). Saturation (b) does not get this boost.
      output.set(x, y, 
        Pixel.createFromFloats(
          r * ifactor2 * 0.5 + mr * 0.5,
          g * ifactor2 * 0.7 + mg * 0.3,
          b * ifactor2,
          a * ifactor2
        )
      );
    }
  }
  return output;
}

function generateCrops(options: SmartCropOptions, width: Int, height: Int): Array<Crop> {
  var results: Array<Crop> = [];
  var minDimension = min(width, height);
  var cropWidth = if (options.cropWidth == null) minDimension else options.cropWidth;
  var cropHeight = if (options.cropHeight == null) minDimension else options.cropHeight;
  var scale = options.maxScale;
  while (scale >= options.minScale) {
    var y = 0;
    while (y + cropHeight * scale <= height) {
      var x = 0;
      while (x + cropWidth * scale <= width) {
        results.push({
          x: x,
          y: y,
          width: cropWidth * scale,
          height: cropHeight * scale
        });
        x += options.step;
      }
      y += options.step;
    }
    scale -= options.scaleStep;
  }
  return results;
}

function thirds(x: Float) {
  x = (((x - 1 / 3 + 1.0) % 2.0) * 0.5 - 0.5) * 16;
  return max(1.0 - x * x, 0.0);
}

function importance(options: SmartCropOptions, crop: Crop, x: Float, y: Float) {
  if (
    crop.x > x ||
    x >= crop.x + crop.width ||
    crop.y > y ||
    y >= crop.y + crop.height
  ) {
    return options.outsideImportance;
  }
  x = (x - crop.x) / crop.width;
  y = (y - crop.y) / crop.height;
  var px = abs(0.5 - x) * 2;
  var py = abs(0.5 - y) * 2;
  // Distance from edge
  var dx = max(px - 1.0 + options.edgeRadius, 0);
  var dy = max(py - 1.0 + options.edgeRadius, 0);
  var d = (dx * dx + dy * dy) * options.edgeWeight;
  var s = 1.41 - sqrt(px * px + py * py);
  if (options.ruleOfThirds) {
    s += max(0, s + d + 0.5) * 1.2 * (thirds(px) + thirds(py));
  }
  return s + d;
}

function score(options: SmartCropOptions, output: Pixels, crop: Crop) {
  var result = {
    detail: 0.,
    saturation: 0.,
    skin: 0.,
    boost: 0.,
    total: 0.
  };

  var downSample = options.scoreDownSample;
  var invDownSample = 1 / downSample;
  var outputHeightDownSample = output.height * downSample;
  var outputWidthDownSample = output.width * downSample;

  var y = 0;
  while (y < outputHeightDownSample) {
    var x = 0;
    while (x < outputWidthDownSample) {
      var pixel =
        output.get(floor(x * invDownSample), floor(y * invDownSample));
      var i = importance(options, crop, x, y);
      var detail = pixel.g / 255;

      result.skin += (pixel.r / 255) * (detail + options.skinBias) * i;
      result.detail += detail * i;
      result.saturation +=
        (pixel.b / 255) * (detail + options.saturationBias) * i;
      result.boost += (pixel.a / 255) * i;
      x += downSample;
    }
    y += downSample;
  }
  result.total =
    (result.detail * options.detailWeight +
      result.skin * options.skinWeight +
      result.saturation * options.saturationWeight +
      result.boost * options.boostWeight) /
    (crop.width * crop.height);
  return result;
}

function analyse(input: Pixels, options: SmartCropOptions) {
  var result: {
    ?topCrop: Crop,
    ?crops: Array<Crop>,
    ?debugOutput: Pixels,
    ?debugOptions: SmartCropOptions
  } = {}
  var output = Pixels.createBuffer(input.width, input.height);

  edgeDetect(input, output);
  skinDetect(options, input, output);
  saturationDetect(options, input, output);
  //applyBoosts(options, output);

  var scoreOutput = downSample(output, options.scoreDownSample);

  var topScore = NEGATIVE_INFINITY;
  var topCrop = null;
  var crops = generateCrops(options, input.width, input.height);

  for (crop in crops) {
    crop.score = score(options, scoreOutput, crop);
    if (crop.score.total > topScore) {
      topCrop = crop;
      topScore = crop.score.total;
    }
  }

  result.topCrop = topCrop;

  if (options.debug && topCrop != null) {
    result.crops = crops;
    result.debugOutput = output;
    result.debugOptions = options;
    // Create a copy which will not be adjusted by the post scaling of smartcrop.crop
    //result.debugTopCrop = extend({}, result.topCrop);
  }
  return result;
}
