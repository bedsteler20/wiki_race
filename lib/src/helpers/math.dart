import 'dart:math';

const _CHARS = "abcdefghijklmnopqrstuvwxyz1234567890";

extension RandomExt on Random {
  String string([int length = 16]) {
    var s = '';
    for (var i = 0; i < length; i++) {
      s += _CHARS[nextInt(_CHARS.length)];
    }
    return s;
  }
}
