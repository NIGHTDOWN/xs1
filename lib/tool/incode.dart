import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:ng169/tool/function.dart';
import 'package:sqflite/utils/utils.dart';

// ignore: camel_case_types
class Incode {
  String string;
  String key;
  String code="";
  String buweileng = '0';
  int size = 7;
  Incode(this.string, this.key);
  String _intbytestostr(digest) {
    return hex(digest.bytes);
  }

  String tohex(String value) {
    String tmp = '';

    int index = 0;
    for (var i = 0;
        i < int.parse((value.length / size).toStringAsFixed(0));
        i++) {
      index = i * size;
// d((value.substring(index, index + size)));
      // tmp.add(int.parse(value.substring(index, index + 4)));
      try {
        tmp += String.fromCharCode(
            int.parse(value.substring(index, index + size)));
      } catch (e) {
        d(e);
      }
    }

    return tmp;
  }

  String md5s(String str) {
    String md5dx = _intbytestostr(md5.convert(Utf8Encoder().convert(str)));
    return md5dx.toLowerCase();
  }

  String b64en(String str) {
    List<int> bytes = utf8.encode(str);
    String encodedStr = base64Encode(bytes);
    return encodedStr;
  }

  String b64de(String str) {
    List<int> bytes2 = base64Decode(str);
    str = String.fromCharCodes(bytes2);
    return str;
  }

  ord(String str) {
    var i = str.codeUnits;

    String tmp = '';
    for (var item in i) {
      tmp += item.toString().padLeft(size, '0');
    }

    return (tmp);
  }

  String decode() {
    key = md5s(key);
    var s1 = key.substring(0, 16);
    var s2 = key.substring(16);
    var keya = md5s(s1);
    var keyb = md5s(s2);
    code = string.substring(0, string.length - 5);

    buweileng = string.substring(string.length - 5);

    int step = int.parse((code.length / 2).toStringAsFixed(0));

    List strs = [(code.substring(0, step)), (code.substring(step))];

    strs[0] = toyh2(strs[0], keyb);
    strs[1] = toyh2(strs[1], keya);
    string = strs[0] + strs[1];

    var pad = buweileng.substring(0, 1);
    if (isnull(pad)) {
      string = string.substring(0, string.length - int.parse(pad));
    }

    return tohex(string);
  }

  String encode() {
    key = md5s(key);
    var s1 = key.substring(0, 16);
    var s2 = key.substring(16);
    var keya = md5s(s1);
    var keyb = md5s(s2);
    string = ord(string);

    var stringLength = string.length;
    var result = '';
    var ys = stringLength % 2;
    if (ys != 0) {
      buweileng = '1';
      string += '0';
    }
    int step = int.parse((stringLength / 2).toStringAsFixed(0));
    List strs = [(string.substring(0, step)), (string.substring(step))];

    strs[0] = toyh(strs[0], keyb);
    strs[1] = toyh(strs[1], keya);
    result = strs[0] + strs[1];

    return result + buweileng.padRight(5, '0');
  }

  getkeyint(String ints) {
    String aa = ints.replaceAll('0', '');
    if (aa.length < 15) {
      aa.padRight(15, '0');
    }
    return aa;
  }

  toyh2(String str, String keys) {
    int step1 = 15;
    int step2 = 16;
    var length = int.parse((str.length / step2).toStringAsFixed(0));
    int index = 0;
    var tmp2 = '';

    int keyss = int.parse(getkeyint(ord(keys)).substring(0, step1));

    for (int i = 0; i <= length; i++) {
      index = i * step2;
      String tmp = '';
      if (index >= str.length) {
        break;
      }

      tmp = (str.substring(index, index + step2));

      var tt = (int.parse(tmp) ^ keyss).toString().padLeft(step1, '0');

      tmp2 += tt;
    }
    int tmpbw = int.parse(buweileng.substring(buweileng.length - 2));
    if (tmpbw == 0) {
      return tmp2;
    } else {
      return tmp2.substring(tmpbw);
    }
  }

  toyh(String str, String keys) {
    int step = 15;
    int bw = step - str.length % step;

    if (bw != 0) {
      buweileng += bw.toString().padLeft(2, '0');
      str = str.padLeft(str.length + bw, '0');
    }

    var length = int.parse((str.length / step).toStringAsFixed(0));

    int index = 0;
    var tmp2 = '';
    int keyss = int.parse(getkeyint(ord(keys)).substring(0, step));

    for (int i = 0; i <= length; i++) {
      index = i * step;
      String tmp = '';

      if (index >= str.length) {
        break;
      }

      tmp = (str.substring(index, index + step));

      tmp2 += (int.parse(tmp) ^ keyss).toString().padLeft(16, '0');
    }
    return tmp2;
  }
}
