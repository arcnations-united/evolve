import 'package:flutter/material.dart';

class ColourInfo{
  double getSaturation(Color clr){
   return HSLColor.fromColor(clr).saturation;
  }
  double getLightness(Color clr){
   return HSLColor.fromColor(clr).lightness;
  }
  double getHue(Color clr){
   return HSLColor.fromColor(clr).hue;
  }
}
class ColourManipulate{
  Color setSaturation(Color clr, {double? sat, Color? fromColor}){
    sat ??= ColourInfo().getSaturation(fromColor!);
    return HSLColor.fromColor(clr).withSaturation(sat).toColor();
  }
  Color setLightness(Color clr, {double? lt, Color? fromColor}){
   lt ??= ColourInfo().getLightness(fromColor!);
   return HSLColor.fromColor(clr).withLightness(lt).toColor();
  }
  Color setHue(Color clr, {double? hue, Color? fromColor}){
    hue ??= ColourInfo().getHue(fromColor!);
    return HSLColor.fromColor(clr).withHue(hue).toColor();
  }
}