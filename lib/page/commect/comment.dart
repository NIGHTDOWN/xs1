import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';

import 'package:ng169/page/novel_detail/novel_comment.dart';
import 'package:ng169/page/novel_detail/novel_comment_cell.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';

class Comment extends StatefulWidget {
  final Novel novel;

  const Comment({Key? key, required this.novel}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CommentState();
}

class CommentState extends State<Comment> {
  late List hotbook, mallcache;
  List<Widget> more = [SizedBox()];
  var index = 'Comment_';
  var cachedata = 'Comment_data_', page = 1;
  String api = 'common/getmore_discuss';
  bool moredata = false, stop = false;
  Map<String, dynamic> post = {};
  ScrollController scrollController = ScrollController();

  Future<void> gethttpdata() async {
    page = 0;
    post.addAll({'page': page});
    var hotbooks = await http(api, post, gethead());
    var data2 = getdata(context, hotbooks!);
    if (isnull(data2)) {
      hotbook = data2;
    }

    mallcache = [hotbook];

    setcache(cachedata, mallcache, '-1');
    more = [SizedBox()];
    stop = false;
    page = 1;
    refresh();
  }

  @override
  void initState() {
    super.initState();
    if (int.parse(widget.novel.type) == 2) {
      post.addAll({'cartoon_id': widget.novel.id});
    } else {
      post.addAll({'book_id': widget.novel.id});
    }
    var hascode = api.toString().hashCode;
    index = index + hascode.toString();
    cachedata = cachedata + hascode.toString();
    loadpage();
    scrollController.addListener(() {
      loadmore();
    });
  }

  loadingstatu() {
    if(!mounted)return false;
    setState(() {
      moredata = !moredata;
    });
  }

  loadmore() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (stop) {
        return false;
      }
      loadingstatu();
      post.addAll({'page': page});
      var data = await http(api, post, gethead());
      var tmpmore = getdata(context, data!);

      if (isnull(tmpmore)) {
        // more.add(bookCardWithInfo(5, '', tmpmore));
        hotbook.addAll(tmpmore);
        page++;
      } else {
        stop = true;
      }
      loadingstatu();
      refresh();
    }
  }
  //  gethttpdata(); //加载数据

  //加载页面
  //先读缓存
  //在读http数据
  loadpage() async {
    //20分钟刷新缓存数据重新加载
    var mallcachebool = getcache(index);

    if (!isnull(mallcachebool)) {
      await gethttpdata();
      //半个小时的缓存
      setcache(index, 1, '1800');
    } else {
      mallcache = getcache(cachedata);

      if (isnull(mallcache)) {
        hotbook = mallcache[0];
      } else {
        setcache(index, 0, '0');
      }
    }
  }

  refresh() {
    if(mounted){
setState(() {});
    }
    
  }

  @override
  Widget build(BuildContext context) {
    titlebarcolor(false);
    var body = Container(
      child: RefreshIndicator(
        onRefresh: gethttpdata,
        child: ListView.builder(
            controller: scrollController,
            itemCount: isnull(hotbook) ? hotbook.length : 0,
            itemBuilder: (BuildContext context, int index) {
              return NovelCommentCell(NovelComment.fromJson(hotbook[index]));
            }),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('更多评论')),
      ),
      backgroundColor: SQColor.white,
      body: body,
    );
  }
}
