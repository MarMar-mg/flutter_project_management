import 'package:flutter/material.dart';

class AppColor {

  static const Color baliHai = Color(0xff8D98AF);

  static const Color blue = Color(0xff38B7FE);
  static const Color indigo = Color(0xff0085FE);
  static const Color shimmerColor = Color(0xffF0F0F0);

  static const Color backgroundGreen = Color(0xFF174251);
  static const Color mainGreen = Color(0xFF0A3747);

  static Color grey(bool isThemeLight, int volume, {int extraVolumeForDark = 0}) {
    if (volume <= 10) volume = volume * 100;
    if (isThemeLight) {
      switch (volume) {
        case 0:
          return const Color(0xffffffff);
        case 100:
          return const Color(0xffF3F4F6);
        case 200:
          return const Color(0xffE5E7EB);
        case 300:
          return const Color(0xffD1D5DB);
        case 400:
          return const Color(0xff9CA3AF);
        case 500:
          return const Color(0xffD4DBE1);
        case 600:
          return const Color(0xffB0B7C3);
        case 700:
          return const Color(0xff374151);
        case 800:
          return const Color(0xff343D5C);
        case 900:
          return const Color(0xff081131);
        case 1000:
          return const Color(0xff000000);
      }
      return Color.lerp(grey(isThemeLight, volume ~/ 100), grey(isThemeLight, (volume ~/ 100) + 1), (volume % 100) / 100)!;
    } else {
      return grey(true, 1000 - (volume + extraVolumeForDark));
    }
  }

  static Color blackBase(bool isThemeLight, int volume) {
    if (isThemeLight) {
      switch (volume) {
        case 2:
        case 200:
          return const Color(0xffF4F5F6);
        case 3:
        case 300:
          return const Color(0xffE6E8EC);
        case 4:
        case 400:
          return const Color(0xffB1B5C3);
        case 5:
        case 500:
          return const Color(0xff777E90);
        case 600:
          return Color.lerp(blackBase(isThemeLight, 500), blackBase(isThemeLight, 700), 0.5)!;
        case 7:
        case 700:
          return const Color(0xff23262F);
        case 8:
        case 800:
          return const Color(0xff141416);
      }
    } else {
      switch (volume) {
        case 2:
        case 200:
          return const Color(0xffE5E5E5);
        case 3:
        case 300:
          return const Color(0xffE3E3E3);
        case 4:
        case 400:
          return const Color(0xffD7D7D7);
        case 5:
        case 500:
          return const Color(0xffBFBFBF);
        case 7:
        case 700:
          return const Color(0xffF4F5F6);
        case 8:
        case 800:
          return const Color(0xffE6E8EC);
      }
    }
    return Colors.white;
  }

  static Color colorLight(bool isThemeLight, int volume) {
    if (isThemeLight) {
      switch (volume) {
        case 1:
          return const Color(0xff212B36);
        case 2:
          return const Color(0xff637381);
      }
    } else {
      switch (volume) {
        case 1:
          return const Color(0xffFFFFFF);
        case 2:
          return const Color(0xffE6E8EC);
      }
    }
    return Colors.white;
  }

  static secondary(bool isThemeLight) {
    if (isThemeLight) {
      return const Color(0xff979797);
    } else {
      return const Color(0xff3f3f3f);
    }
  }

  static shadow(bool isThemeLight) {
    if (isThemeLight) {
      return Colors.grey;
    } else {
      return Colors.black;
    }
  }
}