import 'package:ng169/obj/novel.dart';
import 'package:ng169/obj/chapter.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';

class BookParse {
  String text;

  BookParse(this.text);

  Future<bool> parse(String bookName) async {
    List<String> lineList = text.split('\n');
    d(text);
    // print('lineList:${lineList.length}'); //总行数
    // var strs = [๑,๒,๓,๔,๕,๖,๗,๘,๙,๐,0-9,-\.]

    // RegExp chapterMatch = RegExp(r"第.{1,8}章|^\d+");
    //匹配泰文的  l
    //类似  บทที่ ๑   或者   ตอนที่ 1 โดนวางยา   其中数字可能为泰文也可能是阿拉伯 包括点号跟 横杠
    RegExp chapterMatch =
        RegExp(r"(ตอนที่|บทที่)+[๑,๒,๓,๔,๕,๖,๗,๘,๙,๐,0-9,-,_,\., ]+\S+");
    //此处匹配无第字前缀的章节 容易出现错误，段落里面待数字的都匹配上了
    // RegExp(r"(ตอนที่|บทที่)?[๑,๒,๓,๔,๕,๖,๗,๘,๙,๐,0-9,-, ]+\S+");

    String title = lang('前言'); // ='บทนำ'; //匹配不到章节时候
    String chapterText = '';
    int chapterOrder = 0;
    int inbookid = await Novel.fromloacl(bookName);

    if (!isnull(inbookid)) {
      d('已经导入');
      return false;
    }
    // BookModel bookModel = await bookModelProvider.getBookByName(bookName);
    // if(bookModel == null) {
    //   bookModel = await bookModelProvider.insert(BookModel(bookName, 0,0, updateAt: getCurTimestamp()));
    //   if(bookModel == null) {
    //     print('parse create db bookname:$bookName  falie');
    //     return Future.value(false);
    //   }
    // }

    // await bookChapterModelProvider.deleteByBookId(bookModel.id);

    for (String line in lineList) {
      // print('line:$line');
      // print('match: ${chapterMatch.hasMatch(line)}');
      //标题长度不能超过80个字符串
      if (chapterMatch.hasMatch(line) && line.length < 80) {
        //title
        // d('匹配内容: $line');
        // d(chapterMatch.firstMatch(line).group(0));
        if (title.isNotEmpty) {
          // chapterOrder++;
          // await bookChapterModelProvider.insert(BookChapterModel(bookModel.id, title, chapterOrder++, chapterText, getCurTimestamp()));
//          print('parse insert chapter text:$chapterText');
          chapterText = title + '\n' + chapterText;
          Chapter.insetlocal(inbookid, chapterOrder++, title, chapterText);
        }
        title = line.replaceAll('　　', '');
        //把标题带入章节内容入库
        chapterText = '';
      } else {
        //text
        // if (line != '\r' && !line.contains('更新时间:')) {
        if (line != '\r') {
          // chapterText += line.replaceAll('\r', '\n');
          chapterText += line;
          // chapterText += "\r" + line + "\n";
        }
      }
    }

    chapterText = title + '\n' + chapterText;
    Chapter.insetlocal(inbookid, chapterOrder++, title, chapterText);
    // print('chapterText:$chapterText');
    // if(chapterText.isNotEmpty) {
    //   print('insert chapterText:$chapterText');
    //   await bookChapterModelProvider.insert(BookChapterModel(bookModel.id, title, chapterOrder++, chapterText, getCurTimestamp()));
    // }

    // bookModel.totalChapter = chapterOrder;

    // await bookModelProvider.update(bookModel);

    // print('parse finsh total chapterOrder: $chapterOrder');
    return Future.value(true);
  }
}
