import 'package:flutter/material.dart';
import 'package:ng169/page/novel_detail/novel_detail_header.dart';
import 'package:ng169/page/reader/reader_utils.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';

class ReaderPageAgent {
  // static List<Map<String, int>> getPageOffsets(String content) {
  //   String tempStr = gettextStr(content);

  //   // height = height - fontSize;
  //   double width = getwidth();
  //   double height = getHeight();
  //   double fsize = fixedFontSize(Styles.getTheme()['fontsize']);
  //   TextStyle style = TextStyle(
  //       height: 1.3,
  //       letterSpacing: 1.1,
  //       // fontWeight: FontWeight.w200,
  //       fontSize: fsize);
  //   List<Map<String, int>> pageConfig = [];
  //   int last = 0;

  //   if (content.length < 40000) {
  //     while (true) {
  //       Map<String, int> offset = {};
  //       offset['start'] = last;
  //       TextPainter textPainter = TextPainter(
  //         textDirection: TextDirection.ltr,
  //       );

  //       textPainter.text = TextSpan(text: tempStr, style: style);
  //       // TextSpan(children: gettextwidget(tempStr));
  //       // gettextStr(tempStr);

  //       String tmp2 = trim(tempStr);

  //       if (tmp2.length == 0) {
  //         break;
  //       }
  //       // textPainter.
  //       textPainter.layout(
  //         maxWidth: width,
  //       );

  //       //每一行的字符串数量
  //       var hsize = width / (fsize * 1.1);
  //       var pgstr;
  //       //偏移量的移动
  //       var end =
  //           textPainter.getPositionForOffset(Offset(width, height)).offset;

  //       if (end == 0) {
  //         break;
  //       }
  //       //判断是否段落结束
  //       // pgstr = tempStr.substring(last,end);
  //       // d(pgstr);
  //       tempStr = tempStr.substring(end, tempStr.length);
  //       offset['end'] = last + end;
  //       last = last + end;
  //       pageConfig.add(offset);
  //     }
  //   } else {
  //     pageConfig.add({'start': 0, 'end': content.length});
  //   }

  //   return pageConfig;
  // }

  static List<String> getPage(String content) {
    String tempStr = gettextStr(content);

    double width = getwidth();
    double height = getHeight();

    TextStyle style = getstyle();
    List<String> pageConfig = [];
    int last = 0;

    if (content.length < 40000) {
      while (true) {
        Map<String, int> offset = {};
        offset['start'] = last;
        TextPainter textPainter = TextPainter(
          textDirection: TextDirection.ltr,
        );
        textPainter.text = TextSpan(text: tempStr, style: style);
        String tmp2 = trim(tempStr);
        if (tmp2.length == 0) {
          break;
        }
        textPainter.layout(
          maxWidth: width,
        );

        //每一行的字符串数量
        // var hsize = width / (fsize * 1.1);
        var pgstr;
        //偏移量的移动
        var end =
            textPainter.getPositionForOffset(Offset(width, height)).offset;

        if (end == 0) {
          break;
        }
        //判断是否段落结束
        pgstr = tempStr.substring(0, end);
        //截取的字符串去掉占位符号
        // pgstr = pgstr.replaceAll("☐", "\u3000");

        tempStr = tempStr.substring(end, tempStr.length);
        // offset['end'] = last + end;
        // last = last + end;
        pageConfig.add(pgstr);
      }
    } else {
      pageConfig.add(content);
    }

    return pageConfig;
  }

  static TextStyle getstyle() {
    double fsize = getfontsize();
    var color = Styles.getTheme()['fontcolor'];
    //letterSpacing 会导致换行不连续
    TextStyle style = TextStyle(
        color: color, height: 1.8, fontSize: fsize, letterSpacing: 1.1);
    return style;
  }

  static double getfontsize() {
    double fsize = fixedFontSize(Styles.getTheme()['fontsize']);
    return fsize;
  }

  static String hh = "\n\n";
//获取文本空间
  static List<InlineSpan> gettextwidget(String strings) {
    List<String> rawTextLines = strings.replaceAll("\r", "").split("\n");

    List<InlineSpan> txet = [];
    InlineSpan tmpp;

    var kes = "";
    //两个字符串宽度的缩进
    var ke = WidgetSpan(
        child: SizedBox(
      width: getfontsize() * 1.1 * 2,
      height: getfontsize(),
      // child: Card(color: Colors.red),
    ));
    TextStyle style = getstyle();
    for (var i = 0; i < rawTextLines.length; i++) {
      if (i == 0) {
        tmpp = TextSpan(text: rawTextLines[i] + hh, style: style);
        txet.add(tmpp);
      } else if (i == rawTextLines.length - 1) {
        //最后一行不要加换行
        String tmps = trim(rawTextLines[i]);
        if (isnull(tmps)) {
          tmpp = TextSpan(text: kes + tmps, style: style);
          txet.add(ke);
          txet.add(tmpp);
        }
      } else {
        String tmps = trim(rawTextLines[i]);
        if (isnull(tmps)) {
          tmpp = TextSpan(text: kes + tmps + hh, style: style);
          txet.add(ke);
          txet.add(tmpp);
        }
      }
    }

    return txet;
  }

  static String gettextStr(String strings) {
    //文本分段

    List<String> rawTextLines = strings.replaceAll("\r", "").split("\n");

    // List<InlineSpan> txet = [];
    String text;
    // InlineSpan tmpp;

    //两个字符串宽度的缩进
    var ke = "\u3000\u3000";

    for (var i = 0; i < rawTextLines.length; i++) {
      if (i == 0) {
        text = rawTextLines[i] + hh;
      } else if (i == rawTextLines.length - 1) {
        //最后一行不要加换行
        String tmps = trim(rawTextLines[i]);
        if (isnull(tmps)) {
          text += ke + tmps;
        }
      } else {
        String tmps = trim(rawTextLines[i]);
        if (isnull(tmps)) {
          text += ke + tmps + hh;
        }
      }
    }
    // d(text);
    return text;
    // return TextSpan(text: text, style: style);
  }

  static String trim(String xhtml) {
    String result = "";
    if (isnull(xhtml)) {
      RegExp q = new RegExp(r'^[　*| *| *|//s*]*');
      RegExp h = new RegExp(r'[　*| *| *|//s*]*$');
      result = xhtml.replaceAll(q, "").replaceAll(h, "");
    }
    return result;
  }

//获取内容容器宽度
  static double getwidth() {
    var contentWidth = Screen.width - 15 - 15;
    return contentWidth;
  }

  //获取内容容器高度
  static double getHeight() {
    double topSafeHeight = 0;
    var contentHeight = Screen.height -
        topSafeHeight -
        ReaderUtils.topOffset -
        Screen.bottomSafeHeight -
        ReaderUtils.bottomOffset -
        20;
    return contentHeight;
  }
}
