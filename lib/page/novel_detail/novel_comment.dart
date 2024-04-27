import 'package:ng169/tool/function.dart';

class NovelComment {
  String nickname="";
  String avatar="";
  String content="";
  String discuss_time="";
  String star="0";
  String users_id="0";
  String discuss_id="0";

  NovelComment.fromJson(Map data) {
    if (!isnull(data)) {
      return;
    }
    nickname = data['nick_name'];

    avatar = data['avater'];
    content = data['content'];
    star = data['star'];
    discuss_time = data['discuss_time'];
    users_id = data['users_id'];
    discuss_id = data['discuss_id'];
  }
}
