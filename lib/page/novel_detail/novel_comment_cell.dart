import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/starbar.dart';
import 'package:ng169/tool/function.dart';
import 'novel_comment.dart';

class NovelCommentCell extends StatelessWidget {
  final NovelComment comment;

  NovelCommentCell(this.comment);

  like() {}

  Widget buildButton(
      String image, String title, VoidCallback onPress, bool isSelected) {
    return Row(
      children: <Widget>[
        Image.asset(image),
        SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
              fontSize: 14,
              color: isSelected ? Color(0xfff5a623) : SQColor.gray),
        )
      ],
    );
  }

  Widget buildContent() {
    var head;
    head = AssetImage('assets/images/placeholder_avatar.png');
    //下面的位置经常报错先跳过
    // head = CachedNetworkImageProvider(comment.avatar, errorListener: () {
    //   head = AssetImage('assets/images/placeholder_avatar.png');
    // });
    if (isnull(comment.avatar)) {
      head = CachedNetworkImageProvider(comment.avatar, errorListener: () {
        head = AssetImage('assets/images/placeholder_avatar.png');
      });
    }
    
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 13,
                backgroundImage: head,
              ),
              SizedBox(width: 10),
              Text(comment.nickname,
                  style: TextStyle(fontSize: 14, color: SQColor.gray)),
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      RatingBar(
                        value: double.parse(comment.star) * 2,
                        size: 15,
                        padding: 3,
                        nomalImage: Icon(
                          Icons.star,
                          size: 15,
                          color: Colors.grey,
                        ),
                        selectImage: Icon(
                          Icons.star,
                          size: 15,
                          color: Colors.yellow,
                        ),
                        selectAble: false,
                        onRatingUpdate: (value) {},
                        maxRating: 10,
                        count: 5,
                      ),
                    
                    ]),
              )
            ],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(35, 15, 15, 0),
            child: Text(comment.content, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildContent(),
        Divider(height: 1, indent: 15),
      ],
    );
  }
}
