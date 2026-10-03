import 'package:flutter/material.dart';

final int secondaryCOLR = 0xFFB54DE8;
final int primaryTextCOLR = 0xFF9D8AC5;
final LinearGradient defaultGradientTTB = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFB54DE8), Color(0xFF520E92)],
);
final LinearGradient defaultGradientTTB50 = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color.fromRGBO(181, 77, 232, 0.5), Color.fromRGBO(82, 14, 146, 0.5)],
);
final LinearGradient capsuleGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color.fromRGBO(255, 255, 255, 0.1),
    Color.fromRGBO(255, 255, 255, 0.1),
  ],
);
final LinearGradient defaultGradientLTR = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFFB54DE8), Color(0xFF520E92)],
);

LinearGradient whiteGradientCOLR = LinearGradient(
  colors: [Colors.white, Colors.white],
);

LinearGradient pageGradientCOLR = LinearGradient(
  colors: [Color(0xFF1D0632), Colors.black],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

LinearGradient profileIconCardGradientCOLR = LinearGradient(
  colors: [Color(0xFF1D0545), Color(0xff0E032C)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

final LinearGradient authorLeadGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFEECAFF), Color(0xFF520E92)],
);
