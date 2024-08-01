import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';

// App Colors //

const  Color white                     = Colors.white;
const  Color black                     = Colors.black;
const  Color blue                      = Colors.blue;
const  Color red                       = Colors.red;
const  Color yellow                    = Colors.yellow;
const  Color green                     = Colors.green;
const  Color transparent               = Colors.transparent;
const  Color gold                      = Color(0xFFD4AF37);
const  Color orange                    = Colors.orange;
const  Color teal                      = Colors.teal;
const  Color indigo                    = Colors.indigo;
const  Color grey                      = Colors.grey;
Color? grey200                         = Colors.grey[200];
Color? grey300                         = Colors.grey[300];
Color? grey400                         = Colors.grey[400];
Color? grey500                         = Colors.grey[500];
Color? grey600                         = Colors.grey[600];
Color? grey700                         = Colors.grey[700];
Color? grey800                         = Colors.grey[800];
Color? grey900                         = Colors.grey[900];
const  Color scaffoldBgColor           = black;
const  Color emberQuestBackgroundColor = Color.fromARGB(255, 173, 223, 247);

// App Themes //
ThemeData lightTheme = ThemeData(
  useMaterial3:true,
  applyElevationOverlayColor: false,
  appBarTheme: const AppBarTheme(
    scrolledUnderElevation: 0.0
  ),
  scaffoldBackgroundColor: scaffoldBgColor,
  // Use the colorScheme property to set the background color in light and dark themes
  colorScheme: ColorScheme.fromSwatch().copyWith(surface: transparent),
  // Use the canvasColor property to set the background color in light and dark themes for certain elements like the Drawer
  canvasColor: transparent,
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  applyElevationOverlayColor: false,
  appBarTheme: const AppBarTheme(
    scrolledUnderElevation: 0.0
  ),
  scaffoldBackgroundColor: scaffoldBgColor,
  // Use the colorScheme property to set the background color in light and dark themes
  colorScheme: ColorScheme.fromSwatch().copyWith(surface: transparent),
  // Use the canvasColor property to set the background color in light and dark themes for certain elements like the Drawer
  canvasColor: transparent,
);

// App Styles //
TextStyle textExtraSmallWhite() => const TextStyle(
  color: white,
  fontSize: 14.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textSmallWhite() => const TextStyle(
  color: white,
  fontSize: 16.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textMediumWhite() => const TextStyle(
  color: white,
  fontSize: 20.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textLargeWhite() => const TextStyle(
  color: white,
  fontSize: 26.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textExtraLargeWhite() => const TextStyle(
  color: white,
  fontSize: 30.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textHugeWhite() => const TextStyle(
  color: white,
  fontSize: 40.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textExtraSmallBlack() => const TextStyle(
  color: black,
  fontSize: 14.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textSmallBlack() => const TextStyle(
  color: black,
  fontSize: 16.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textMediumBlack() => const TextStyle(
  color: black,
  fontSize: 20.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textLargeBlack() => const TextStyle(
  color: black,
  fontSize: 26.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textExtraLargeBlack() => const TextStyle(
  color: black,
  fontSize: 30.0,
  fontFamily: 'OldGameFatty',
);

TextStyle textHugeBlack() => const TextStyle(
  color: black,
  fontSize: 40.0,
  fontFamily: 'OldGameFatty',
);

// App Gradients //
Gradient skyGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.blue[200]!,
    Colors.blue[400]!,
    Colors.blue[600]!,
    Colors.blue[800]!,
  ],
);

final List<List<Color>> _gradientColors = [
  GradientColors.blue,
  GradientColors.coolBlues,
  GradientColors.pink,
  GradientColors.orange,
  GradientColors.indigo,
  GradientColors.alchemistLab,
  GradientColors.almost,
  GradientColors.amour,
  GradientColors.amyCrisp,
  GradientColors.aubergine,
  GradientColors.awesomePine,
  GradientColors.beautifulGreen,
  GradientColors.bigMango,
  GradientColors.black,
  GradientColors.blackGray,
  GradientColors.blessingGet,
  GradientColors.bloodyMary
  // Add more gradient colors as needed
];

List<Color> getRandomGradientColors() {
  final Random random = Random();
  return _gradientColors[random.nextInt(_gradientColors.length)];
}