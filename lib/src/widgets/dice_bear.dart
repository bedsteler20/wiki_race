import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DiceBearAvatar extends StatelessWidget {
  const DiceBearAvatar({
    super.key,
    required this.type,
    required this.seed,
  });

  final String seed;
  final DiceBearAvatarType type;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Image.network(
          Uri.parse("https://avatars.dicebear.com/api/${_conv(type)}/$seed.png")
              .toString()),
    );
  }
}

enum DiceBearAvatarType {
  adventurer,
  adventurerNeutral,
  avataaars,
  bigEars,
  bigEarsNeutral,
  bigSmile,
  bottts,
  croodles,
  croodlesNeutral,
  identicon,
  initials,
  micah,
  miniavs,
  openPeeps,
  personas,
  pixelArt,
  pixelArtNeutral
}

String _conv(DiceBearAvatarType e) {
  switch (e) {
    case DiceBearAvatarType.adventurer:
      return "adventurer";
    case DiceBearAvatarType.avataaars:
      return "avataaars";
    case DiceBearAvatarType.bottts:
      return "bottts";
    case DiceBearAvatarType.adventurerNeutral:
      return "adventurer-neutral";
    case DiceBearAvatarType.bigEarsNeutral:
      return "big-ears-neutral";
    case DiceBearAvatarType.bigEars:
      return "big-ears";
    case DiceBearAvatarType.bigSmile:
      return "big-smile";
    case DiceBearAvatarType.croodlesNeutral:
      return "croodles-neutral";
    case DiceBearAvatarType.croodles:
      return "croodles";
    case DiceBearAvatarType.identicon:
      return "identicon";
    case DiceBearAvatarType.micah:
      return "micah";
    case DiceBearAvatarType.miniavs:
      return "miniavs";
    case DiceBearAvatarType.openPeeps:
      return "open-peeps";
    case DiceBearAvatarType.personas:
      return "personas";
    case DiceBearAvatarType.pixelArt:
      return "pixel-art";
    case DiceBearAvatarType.pixelArtNeutral:
      return "pixel-art-neutral";
    case DiceBearAvatarType.initials:
      return "initials";
  }
}
