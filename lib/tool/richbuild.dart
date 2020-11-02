import 'dart:ui';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'function.dart';

class EmojiText extends SpecialText {
  static const String flag = "【";
  final int start;
  EmojiText(TextStyle textStyle, {this.start})
      : super(EmojiText.flag, "】", textStyle);

  @override
  InlineSpan finishText() {
    // TODO: implement finishText
    var key = toString();

    RegExp reg = new RegExp(r'emj_(\d+)');
    var index = '0';
    if (reg.hasMatch(key)) {
      Iterable<Match> matches = reg.allMatches(key);

      for (Match m in matches) {
        index = m.group(1);
        // print(m.group(0));
        // print(m.group(1));
      }
    }
    
    if (isnull(index)) {
      //fontsize id define image height
      //size = 30.0/26.0 * fontSize
      final double size = 30.0;

      ///fontSize 26 and text height =30.0
      //final double fontSize = 26.0;
      
      return ImageSpan(AssetImage(EmojiUitl.instance.emojiMap[index]),
          actualText: key,
          imageWidth: size,
          imageHeight: size,
          start: start,
          fit: BoxFit.fill,
          margin: EdgeInsets.only(left: 2.0, top: 2.0, right: 2.0));
    }
    return TextSpan(text: toString(), style: textStyle);
  }
}

class EmojiUitl {
  final Map<String, String> _emojiMap = new Map<String, String>();

  Map<String, String> get emojiMap => _emojiMap;

  final String _emojiFilePath = "assets/images/emjo/emj_";

  static EmojiUitl _instance;
  static EmojiUitl get instance {
    if (_instance == null) _instance = new EmojiUitl._();
    return _instance;
  }

  EmojiUitl._() {
    for (int i = 1; i < 79; i++) {
      _emojiMap["$i"] = "$_emojiFilePath$i.png";
    }
  }
}

class AtText extends SpecialText {
  static const String flag = "@";
  final int start;

  /// whether show background for @somebody
  final bool showAtBackground;

  final BuilderType type;
  AtText(TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.showAtBackground: false, this.type, this.start})
      : super(flag, " ", textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    // TODO: implement finishText
    TextStyle textStyle =
        this.textStyle?.copyWith(color: Colors.blue, fontSize: 16.0);

    final String atText = toString();

    if (type == BuilderType.extendedText)
      return TextSpan(
          text: atText,
          style: textStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (onTap != null) onTap(atText);
            });

    return showAtBackground
        ? BackgroundTextSpan(
            background: Paint()..color = Colors.blue.withOpacity(0.15),
            text: atText,
            actualText: atText,
            start: start,
            deleteAll: false,
            style: textStyle,
            recognizer: type == BuilderType.extendedText
                ? (TapGestureRecognizer()
                  ..onTap = () {
                    if (onTap != null) onTap(atText);
                  })
                : null)
        : SpecialTextSpan(
            text: atText,
            actualText: atText,
            start: start,
            deleteAll: false,
            style: textStyle,
            recognizer: type == BuilderType.extendedText
                ? (TapGestureRecognizer()
                  ..onTap = () {
                    if (onTap != null) onTap(atText);
                  })
                : null);
  }
}

class RichBuilder extends SpecialTextSpanBuilder {
  /// whether show background for @somebody
  final bool showAtBackground;
  final BuilderType type;
  RichBuilder(
      {this.showAtBackground: false, this.type: BuilderType.extendedText});

  @override
  TextSpan build(String data, {TextStyle textStyle, onTap}) {
    // TODO: implement build
    var textSpan = super.build(data, textStyle: textStyle, onTap: onTap);
    //for performance, make sure your all SpecialTextSpan are only in textSpan.children
    //extended_text_field will only check SpecialTextSpan in textSpan.children
    return textSpan;
  }

  @override
  SpecialText createSpecialText(String flag,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap, int index}) {
    if (flag == null || flag == "") return null;
    // TODO: implement createSpecialText

    ///index is end index of start flag, so text start index should be index-(flag.length-1)
    // if (isStart(flag, AtText.flag)) {
    //   return AtText(textStyle, onTap,
    //       start: index - (AtText.flag.length - 1),
    //       showAtBackground: showAtBackground,
    //       type: type);
    // } else 
    if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle, start: index - (EmojiText.flag.length - 1));
    }
    // } else if (isStart(flag, DollarText.flag)) {
    //   return DollarText(textStyle, onTap,
    //       start: index - (DollarText.flag.length - 1), type: type);
    // } else if (isStart(flag, ImageText.flag)) {
    //   return ImageText(textStyle,
    //       start: index - (ImageText.flag.length - 1), type: type, onTap: onTap);
    // }
    return null;
  }
}

enum BuilderType { extendedText, extendedTextField }
