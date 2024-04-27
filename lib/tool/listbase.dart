import 'package:flutter/material.dart';

import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';

class Listbase extends StatefulWidget {
  final List<Widget> childrens;
  final EdgeInsetsGeometry margin;
  final MoreClaaback onRefresh;
  final MoreClaaback onMore;
  final ScrollBack scroll;
  Listbase(this.childrens,
      {required this.margin, required this.onRefresh, required this.onMore, required this.scroll});
  // const Listbase(this.childrens, {this.margin, this.onRefresh, this.onMore});
  @override
  State<StatefulWidget> createState() => ListbaseState();
}

class ListbaseState extends State<Listbase> with AutomaticKeepAliveClientMixin {
  bool isLoading = false; //是否正在加载数据
  ScrollController _scrollController = ScrollController(); //listview的控制器

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (isnull(widget.scroll)) {
        widget.scroll(_scrollController);
      }
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });
  }

  /**
   * 上拉加载更多
   */
  Future _getMore() async {
    //判断是否需要做更多的处理
    // ignore: unnecessary_null_comparison
    if (widget.onMore != null) {
      if (!isLoading) {
        setState(() {
          isLoading = true;
        });
        await widget.onMore();
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /**
   * 加载更多时显示的组件,给用户提示
   */
  Widget _getMoreWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '加载中...',
              style: TextStyle(fontSize: 16.0),
            ),
            CircularProgressIndicator(
              strokeWidth: 1.0,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
  
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: <Widget>[
        Container(
            color: SQColor.white,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: getListView(),
                ),
              ],
            )),
      ],
    );
  }

  Future<void> onloadRefresh() async {
    await widget.onRefresh();
  }

  Widget getListView() {
      // ignore: unnecessary_null_comparison
    if (widget.childrens == null || widget.childrens.length == 0) {
      return Container();
    }
    // return Column(children: widget.childrens);
    int itemCount = widget.childrens.length;
      // ignore: unnecessary_null_comparison
    if (widget.onMore != null) {
      itemCount = widget.childrens.length + 1;
    }
      // ignore: unnecessary_null_comparison
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onloadRefresh,
        child: Container(
          // ignore: unnecessary_null_comparison
          margin: widget.margin == null
              ? EdgeInsets.fromLTRB(10, 0, 0, 0)
              : widget.margin,
          child: ListView.builder(
            primary: true,
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            cacheExtent: 10.0,
            itemBuilder: _renderRow,
            itemCount: itemCount,
            controller: _scrollController,
          ),
        ),
      );
    } else {
      return Container(
        // ignore: unnecessary_null_comparison
        margin: widget.margin == null
            ? EdgeInsets.fromLTRB(10, 0, 0, 0)
            : widget.margin,
        child: ListView.builder(
          itemBuilder: _renderRow,
          itemCount: itemCount,
          controller: _scrollController,
        ),
      );
    }
  }

  Widget _renderRow(BuildContext context, int index) {
    if (index < widget.childrens.length) {
     // return Column(children: <Widget>[widget.childrens[index]],);
      return widget.childrens[index];
    }
    return _getMoreWidget();
  }
}

typedef MoreClaaback = Future<void> Function();
typedef ScrollBack = Future<void> Function(ScrollController scrollController);
