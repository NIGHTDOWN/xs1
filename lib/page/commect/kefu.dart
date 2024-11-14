import 'package:dio/dio.dart';
import 'package:extended_text_field/extended_text_field.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/model/user.dart';

import 'package:ng169/page/commect/picviw.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/im.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/richbuild.dart';
import 'package:ng169/tool/t.dart';
import 'package:ng169/model/msg.dart';
import 'package:ng169/tool/url.dart';

// ignore: must_be_immutable
class Kefu extends LoginBase with WidgetsBindingObserver {
  bool needlogin = true;
  late String peerId;
  late String peerAvatar;
  late String id;

  var listMessage;
  late String groupChatId;

  late bool isLoading, issend = true;
  late bool isShowSticker;
  late String imageUrl;
  int page = 0, size = 11;
  int lasttime = 0;
  TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final themeColor = Color(0xfff5a623);
  final primaryColor = Color(0xff203152);
  final greyColor = Color(0xffaeaeae);
  final greyColor2 = Color(0xffE8E8E8);
  List<Widget> emjo = [];
  var showdata = [], senddata = [], history = [];
  List<ListTile> chosimgobj = [];
  late Widget mehead, gmhead;
  bool canscrool = true;
  @override
  void initState() {
    super.initState();
    s("inmsgpage", "1");
    WidgetsBinding.instance.addObserver(this);
    focusNode.addListener(onFocusChange);
    loadbus();
    listScrollController.addListener(() {
      if (listScrollController.position.pixels ==
          listScrollController.position.maxScrollExtent) {
        //加载更多

        gethistory();
      }
    });
    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    initemjo();
    chooseImageinit();
    var user = User.get();

    double headsize = (getScreenWidth(g('context'))) / 10;
    mehead = Container(
        // margin: EdgeInsets.only(left:10,right:10),
        child: ClipOval(
      child: isnull(user, 'avater')
          ? NgImage(
              user['avater'],
              width: headsize,
              fit: BoxFit.cover,
              height: null,
              placeholder: Container(),
            )
          : Image.asset(
              'assets/images/placeholder_avatar.png',
              width: headsize,
            ),
    ));
    gmhead = Container(
        //  margin: EdgeInsets.only(left:10,right:10),
        child: ClipOval(
      child: Image.asset(
        'assets/images/u4.png',
        width: headsize,
      ),
    ));
    readLocal();
    Msg.clearread();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 页面可见时执行的操作
      s("inmsgpage", "1");
      print('页面可见，执行相关操作');
    } else if (state == AppLifecycleState.paused) {
      // 页面不可见时执行的操作
      print('页面不可见，执行相关操作');
      s("inmsgpage", "0");
    }
  }

  loadbus() {
    eventBus.on('msg_im_on', (data) {
      d("更新消息窗口");
      d(data);
    });
  }

  offbus() {
    eventBus.off('msg_im_on');
  }

  @override
  void dispose() {
    offbus();
    WidgetsBinding.instance.removeObserver(this);
    s("inmsgpage", "0");
    super.dispose();
  }

//加载表情
  initemjo() {
    for (var i = 1; i < 79; i++) {
      var tmp = InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () => sendemj('$i'),
        child: Container(
            // color: Color(0xffffffff),
            padding: EdgeInsets.all(4),
            child: Image.asset(
              "assets/images/emjo/emj_$i.png",
              fit: BoxFit.cover,
            )),
      );
      Widget tmp2 = Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
            // color: greyColor2,
            borderRadius: BorderRadius.circular(8.0)),
        margin: EdgeInsets.all(5),
        child: Material(
          child: Ink(child: tmp, color: SQColor.white),
        ),
      );
      emjo.add(tmp2);
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    // prefs = await SharedPreferences.getInstance();
    // id = prefs.getString('id') ?? '';
    // if (id.hashCode <= peerId.hashCode) {
    //   groupChatId = '$id-$peerId';
    // } else {
    //   groupChatId = '$peerId-$id';
    // }

    // Firestore.instance.collection('users').document(id).updateData({'chattingWith': peerId});

    // setState(() {});
    loadhttp();
  }

  Future chooseImageinit() async {
    // List<Widget> childs = [];
    var camera = ListTile(
      title: Text(
        lang("拍照"),
        textAlign: TextAlign.center,
        style: TextStyle(color: SQColor.darkGray),
      ),
      onTap: () async {
        Navigator.pop(context);

        // ignore: invalid_use_of_visible_for_testing_member
        PickedFile? tmpimage = await ImagePicker.platform.pickImage(
            source: ImageSource.camera, maxWidth: 500, imageQuality: 80);
        imgtoserver(tmpimage);
        reflash();
      },
    );
    var gallery = ListTile(
      title: Text(
        lang("相册"),
        textAlign: TextAlign.center,
        style: TextStyle(color: SQColor.darkGray),
      ),
      onTap: () async {
        Navigator.pop(context);
        // ignore: invalid_use_of_visible_for_testing_member
        var tmpimage = await ImagePicker.platform.pickImage(
            source: ImageSource.gallery, maxWidth: 500, imageQuality: 80);

        imgtoserver(tmpimage);
        reflash();
      },
    );
    chosimgobj.add(camera);
    chosimgobj.add(gallery);

    //reflash();
  }

  imgtoserver(imgpath) async {
    if (isnull(imgpath)) {
      String path = imgpath.path;

      var tmp = await httpfile(
          'upimg/run', {'file': await MultipartFile.fromFile(path)}, gethead());
      var imgurl = getdata(context, tmp);
      Msg obj = Msg.carete(2, imgurl);
      await obj.send();
      issend = true;
      reflash();
    }
  }

  chosimg() {
    selectbox(context, chosimgobj);
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future<void> onSendMessage(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      var str = textEditingController.text;
      textEditingController.clear();

      d("这里发送了");

      Msg msgobj = Msg.carete(0, str);
      //缓存到本地数据库
      await msgobj.send();
      //更新到List
      // senddata.add(sendmsg);
      issend = true;
      //刷新的时候会重载数据
      reflash();
      // listScrollController.animateTo(0.0,
      //     duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      show(context, lang('Nothing to send'));
    }
  }

  sendemj(String id) {
    String emj = "【emj_$id】";
    // textEditingController.text;
    // d(textEditingController.value);
    String texttmp = textEditingController.text + emj;

    textEditingController = new TextEditingController(text: texttmp);
    reflash();
  }

  Widget buildItem(int index, var document) {
    Msg msgs = Msg.fromJson(document);
    var cc;
    if (msgs.contenttype == '0') {
      cc = Container(
        child: ExtendedTextField(
          readOnly: true,
          maxLines: null,
          minLines: null,
          style:
              TextStyle(color: !isnull(msgs.type) ? primaryColor : greyColor2),
          controller: TextEditingController(text: msgs.content),
          decoration: InputDecoration(border: InputBorder.none),
          specialTextSpanBuilder: RichBuilder(
              showAtBackground: false, type: BuilderType.extendedTextField),
        ),
        padding: EdgeInsets.fromLTRB(15.0, 0, 15, 0),
        // width: 200.0,
        decoration: BoxDecoration(
            color: !isnull(msgs.type) ? greyColor2 : primaryColor,
            borderRadius: BorderRadius.circular(8.0)),
        margin: EdgeInsets.only(left: 10, right: 10.0),
      );
    } else {
      cc = Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: NgImage(
            msgs.content,
            fit: BoxFit.cover,
            width: 0,
            height: 0,
            placeholder: SizedBox(),
            dsl: '',
          ),
        ),
        decoration: BoxDecoration(
            color: greyColor2, borderRadius: BorderRadius.circular(88.0)),
        margin: EdgeInsets.only(left: 10, right: 10),
      );
      cc = GestureDetector(
        onTap: () {
          gourl(context, PicView(url: msgs.content));
        },
        child: cc,
      );
    }
    var row;
    if (msgs.type == '0') {
      row =
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Flexible(
          child: mehead,
          // flex: 2,
        ),
        Flexible(
          child: cc,
          flex: 7,
        ),
        Flexible(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Flexible(child: Container(),flex: 1,),
                msgs.flag ? Icon(Icons.error, color: Colors.red) : Container()
              ],
            ),
          ),
          flex: 2,
        ),
      ]);
    } else {
      row =
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Flexible(
          child: Container(),
          flex: 2,
        ),
        Flexible(
          child: cc,
          flex: 7,
        ),
        Flexible(
          child: gmhead,
        ),
      ]);
    }

    return Container(
      child: Column(children: [
        gettimeoj(msgs),
        row,
      ]),
      margin: EdgeInsets.only(top: 10),
    );
    // if (document['idFrom'] == id) {
    //   // Right (my message)
    //   return Row(
    //     children: <Widget>[
    //       document['type'] == 0
    //           // Text
    //           ? Container(
    //               child: Text(
    //                 document['content'],
    //                 style: TextStyle(color: primaryColor),
    //               ),
    //               padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
    //               width: 200.0,
    //               decoration: BoxDecoration(
    //                   color: greyColor2,
    //                   borderRadius: BorderRadius.circular(8.0)),
    //               margin: EdgeInsets.only(
    //                   bottom: isLastMessageRight(index) ? 20.0 : 10.0,
    //                   right: 10.0),
    //             )
    //           : document['type'] == 1
    //               // Image
    //               ? Container(
    //                   child: FlatButton(
    //                     child: Material(
    //                       child: CachedNetworkImage(
    //                         placeholder: (context, url) => Container(
    //                           child: CircularProgressIndicator(
    //                             valueColor:
    //                                 AlwaysStoppedAnimation<Color>(themeColor),
    //                           ),
    //                           width: 200.0,
    //                           height: 200.0,
    //                           padding: EdgeInsets.all(70.0),
    //                           decoration: BoxDecoration(
    //                             color: greyColor2,
    //                             borderRadius: BorderRadius.all(
    //                               Radius.circular(8.0),
    //                             ),
    //                           ),
    //                         ),
    //                         errorWidget: (context, url, error) => Material(
    //                           child: Image.asset(
    //                             'images/img_not_available.jpeg',
    //                             width: 200.0,
    //                             height: 200.0,
    //                             fit: BoxFit.cover,
    //                           ),
    //                           borderRadius: BorderRadius.all(
    //                             Radius.circular(8.0),
    //                           ),
    //                           clipBehavior: Clip.hardEdge,
    //                         ),
    //                         imageUrl: document['content'],
    //                         width: 200.0,
    //                         height: 200.0,
    //                         fit: BoxFit.cover,
    //                       ),
    //                       borderRadius: BorderRadius.all(Radius.circular(8.0)),
    //                       clipBehavior: Clip.hardEdge,
    //                     ),
    //                     onPressed: () {
    //                       // Navigator.push(
    //                       //     context, MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
    //                     },
    //                     padding: EdgeInsets.all(0),
    //                   ),
    //                   margin: EdgeInsets.only(
    //                       bottom: isLastMessageRight(index) ? 20.0 : 10.0,
    //                       right: 10.0),
    //                 )
    //               // Sticker
    //               : Container(
    //                   // child: Image.asset(
    //                   //   'images/${document['content']}.gif',
    //                   //   width: 100.0,
    //                   //   height: 100.0,
    //                   //   fit: BoxFit.cover,
    //                   // ),
    //                   margin: EdgeInsets.only(
    //                       bottom: isLastMessageRight(index) ? 20.0 : 10.0,
    //                       right: 10.0),
    //                 ),
    //     ],
    //     mainAxisAlignment: MainAxisAlignment.end,
    //   );
    // } else {
    //   // Left (peer message)
    //   return Container(
    //     child: Column(
    //       children: <Widget>[
    //         Row(
    //           children: <Widget>[
    //             isLastMessageLeft(index)
    //                 ? Material(
    //                     child: CachedNetworkImage(
    //                       placeholder: (context, url) => Container(
    //                         child: CircularProgressIndicator(
    //                           strokeWidth: 1.0,
    //                           valueColor:
    //                               AlwaysStoppedAnimation<Color>(themeColor),
    //                         ),
    //                         width: 35.0,
    //                         height: 35.0,
    //                         padding: EdgeInsets.all(10.0),
    //                       ),
    //                       imageUrl: peerAvatar,
    //                       width: 35.0,
    //                       height: 35.0,
    //                       fit: BoxFit.cover,
    //                     ),
    //                     borderRadius: BorderRadius.all(
    //                       Radius.circular(18.0),
    //                     ),
    //                     clipBehavior: Clip.hardEdge,
    //                   )
    //                 : Container(width: 35.0),
    //             document['type'] == 0
    //                 ? Container(
    //                     child: Text(
    //                       document['content'],
    //                       style: TextStyle(color: SQColor.white),
    //                     ),
    //                     padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
    //                     width: 200.0,
    //                     decoration: BoxDecoration(
    //                         color: primaryColor,
    //                         borderRadius: BorderRadius.circular(8.0)),
    //                     margin: EdgeInsets.only(left: 10.0),
    //                   )
    //                 : document['type'] == 1
    //                     ? Container(
    //                         child: FlatButton(
    //                           child: Material(
    //                             child: CachedNetworkImage(
    //                               placeholder: (context, url) => Container(
    //                                 child: CircularProgressIndicator(
    //                                   valueColor: AlwaysStoppedAnimation<Color>(
    //                                       themeColor),
    //                                 ),
    //                                 width: 200.0,
    //                                 height: 200.0,
    //                                 padding: EdgeInsets.all(70.0),
    //                                 decoration: BoxDecoration(
    //                                   color: greyColor2,
    //                                   borderRadius: BorderRadius.all(
    //                                     Radius.circular(8.0),
    //                                   ),
    //                                 ),
    //                               ),
    //                               errorWidget: (context, url, error) =>
    //                                   Material(
    //                                 child: Image.asset(
    //                                   'images/img_not_available.jpeg',
    //                                   width: 200.0,
    //                                   height: 200.0,
    //                                   fit: BoxFit.cover,
    //                                 ),
    //                                 borderRadius: BorderRadius.all(
    //                                   Radius.circular(8.0),
    //                                 ),
    //                                 clipBehavior: Clip.hardEdge,
    //                               ),
    //                               imageUrl: document['content'],
    //                               width: 200.0,
    //                               height: 200.0,
    //                               fit: BoxFit.cover,
    //                             ),
    //                             borderRadius:
    //                                 BorderRadius.all(Radius.circular(8.0)),
    //                             clipBehavior: Clip.hardEdge,
    //                           ),
    //                           onPressed: () {
    //                             // Navigator.push(context,
    //                             //     MaterialPageRoute(builder: (context) => FullPhoto(url: document['content'])));
    //                           },
    //                           padding: EdgeInsets.all(0),
    //                         ),
    //                         margin: EdgeInsets.only(left: 10.0),
    //                       )
    //                     : Container(
    //                         child: Image.asset(
    //                           'images/${document['content']}.gif',
    //                           width: 100.0,
    //                           height: 100.0,
    //                           fit: BoxFit.cover,
    //                         ),
    //                         margin: EdgeInsets.only(
    //                             bottom: isLastMessageRight(index) ? 20.0 : 10.0,
    //                             right: 10.0),
    //                       ),
    //           ],
    //         ),

    //         // Time
    //         isLastMessageLeft(index)
    //             ? Container(
    //                 child: Text(
    //                   '时间',
    //                   // DateFormat('dd MMM kk:mm')
    //                   //     .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),
    //                   style: TextStyle(
    //                       color: greyColor,
    //                       fontSize: 12.0,
    //                       fontStyle: FontStyle.italic),
    //                 ),
    //                 margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
    //               )
    //             : Container()
    //       ],
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //     ),
    //     margin: EdgeInsets.only(bottom: 10.0),
    //   );
    // }
  }

  strtoobj(String str) {
    RegExp reg = new RegExp(r'【emj_(\d+)】');
    // ignore: unused_local_variable
    String? index = '0';

    if (reg.hasMatch(str)) {
      Iterable<Match> matches = reg.allMatches(str);

      // d(reg.firstMatch(str).group(1));
      for (Match m in matches) {
        // d(m.group(0));
        // d(m.group(1));
        index = m.group(1);
        // print(m.group(0));
        // print(m.group(1));
      }
    }
  }

  Widget gettimeoj(Msg msg) {
    Widget obj;

    int time = int.parse(msg.sendtime);
    // obj = Container();

    if ((time % 3) == 0) {
      var t = new DateTime.fromMillisecondsSinceEpoch(time * 1000);

      String dates = t.day.toString().padLeft(2, '0') +
          '/' +
          t.month.toString().padLeft(2, '0') +
          '  ' +
          t.hour.toString().padLeft(2, '0') +
          ':' +
          t.minute.toString().padRight(2, '0');
      obj = Container(
        child: Text(
          dates,
          style: TextStyle(
            color: greyColor,
            fontSize: 12.0,
            // fontStyle: FontStyle.italic
          ),
        ),
        margin: EdgeInsets.all(5),
      );
    } else {
      obj = Container();
    }
    return obj;
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      // Firestore.instance.collection('users').document(id).updateData({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    s("inmsgpage", "1");
    var bbb = Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            // List of messages
            buildListMessage(),

            // Sticker

            // Input content
            buildInput(),
            (isShowSticker ? buildSticker() : Container()),
          ],
        ),

        // Loading
        // buildLoading()
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(lang("在线客服")),
        ),
      ),
      backgroundColor: SQColor.white,
      body: bbb,
    );
  }

//显示表情
  Widget buildSticker() {
    var c = Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
          color: SQColor.white),
      // padding: EdgeInsets.all(5.0),
      height: 180.0,
      child: SingleChildScrollView(child: Wrap(children: emjo)),
    );
    //
    return c;
    // return Material(child:c);
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              ),
              color: SQColor.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

//底部输入按钮
  Widget buildInput() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: () {
                  chosimg();
                },
                color: primaryColor,
              ),
            ),
            color: SQColor.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: SQColor.white,
          ),

          // Edit text
          Flexible(
              child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                  child: ExtendedTextField(
                    onSubmitted: (String str) {
                      onSendMessage(str, 0);
                    },
                    minLines: 1,
                    maxLines: 8,
                    style: TextStyle(color: primaryColor, fontSize: 15.0),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: lang('Type your message...'),
                      hintStyle: TextStyle(color: greyColor),
                    ),
                    focusNode: focusNode,
                    specialTextSpanBuilder: RichBuilder(
                        showAtBackground: true,
                        type: BuilderType.extendedTextField),
                  ))
              // Container(
              //   child: TextField(
              //     onSubmitted: (String str) {
              //       onSendMessage(str, 0);
              //     },
              //     style: TextStyle(color: primaryColor, fontSize: 15.0),
              //     controller: textEditingController,
              //     decoration: InputDecoration.collapsed(
              //       hintText: 'Type your message...',
              //       hintStyle: TextStyle(color: greyColor),
              //     ),
              //     focusNode: focusNode,
              //   ),
              // ),
              ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: SQColor.white,
          ),
          // Material(
          //   child: Container(
          //     margin: EdgeInsets.symmetric(horizontal: 8.0),
          //     child: IconButton(
          //       icon: Icon(Icons.send),
          //       onPressed: () {
          //         T('msg').del();
          //       },
          //       color: primaryColor,
          //     ),
          //   ),
          //   color: SQColor.white,
          // ),
        ],
      ),
      width: double.infinity,
      //height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
          color: SQColor.white),
    );
  }

  Future<void> gethistory() async {
    if (!canscrool) return;
    page++;
    var p = page * size;
    var str = "$p, $size";
    var data = await T('msg')
        .where({'msgid': User.getuid()})
        .order('id desc')
        .limit(str)
        .getall();
    if (!isnull(data)) {
      canscrool = false;
    } else {
      showdata.addAll(data);
    }

    reflash();
    //return data;
  }

  Widget buildListMessage() {
    return Flexible(
      child: FutureBuilder(
        future: mockNetworkData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // 请求已结束
          var load = Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          var listobj = ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) => buildItem(index, showdata[index]),
            itemCount: showdata.length,
            reverse: true,
            controller: listScrollController,
          );

          // var listobj = RefreshIndicator(
          //     child: Container(child: ltmp), onRefresh: gethistory);

          if (snapshot.connectionState == ConnectionState.done) {
            issend = false;
            if (snapshot.hasError) {
              // 请求失败，显示错误
              // return Text("Error: ${snapshot.error}");
              return load;
            } else {
              // 请求成功，显示数据
              return listobj;
              // return ListView(
              //   reverse: true,
              //   controller: listScrollController,

              //   children: <Widget>[
              //     ListView.builder(
              //       padding: EdgeInsets.all(10.0),
              //        shrinkWrap: true,
              //       itemBuilder: (context, index) =>
              //           buildItem(index, senddata[index]),
              //       itemCount: senddata.length,
              //     ),
              //     // Text('ddd'),
              //     ListView.builder(
              //       shrinkWrap: true,
              //       padding: EdgeInsets.all(10.0),
              //       itemBuilder: (context, index) =>
              //           buildItem(index, showdata[index]),
              //       itemCount: showdata.length,
              //       reverse: true,
              //     ),
              //     ListView.builder(
              //       padding: EdgeInsets.all(10.0),
              //       shrinkWrap: true,
              //       itemBuilder: (context, index) =>
              //           buildItem(index, history[index]),
              //       itemCount: history.length,
              //     ),
              //   ],
              // );
              // return Text("Contents: ${snapshot.data}");
            }
          } else {
            // 请求未结束，显示loading
            if (issend) {
              return load;
            }
            return listobj;
            // return Center(
            //     child: CircularProgressIndicator(
            //         valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          }
        },
      ),
    );

    // : StreamBuilder(
    //     // stream: Firestore.instance
    //     //     .collection('messages')
    //     //     .document(groupChatId)
    //     //     .collection(groupChatId)
    //     //     .orderBy('timestamp', descending: true)
    //     //     .limit(20)
    //     //     .snapshots(),
    //     stream: () {
    //       //这里是socket流监听
    //       // return Stream.periodic(Duration(seconds: 1), (i) async {
    //       //   return await T('msg').where({}).getone();
    //       // });
    //     },
    //     builder: (context, snapshot) {
    //       if (!snapshot.hasData) {
    //         return Center(
    //             child: CircularProgressIndicator(
    //                 valueColor:
    //                     AlwaysStoppedAnimation<Color>(themeColor)));
    //       } else {
    //         listMessage = snapshot.data.documents;
    //         return ListView.builder(
    //           padding: EdgeInsets.all(10.0),
    //           itemBuilder: (context, index) =>
    //               buildItem(index, snapshot.data.documents[index]),
    //           itemCount: snapshot.data.documents.length,
    //           reverse: true,
    //           controller: listScrollController,
    //         );
    //       }
    //     },
    //   ),
  }

  Future mockNetworkData() async {
    // return Future.delayed(Duration(seconds: 2), () => "我是从互联网上获取的数据");
    if (issend) {
      showdata = [];
      page = 0;
      canscrool = true;
      var str = "$page, $size";
      var data = await T('msg')
          .where({'msgid': User.getuid()})
          .order('id desc')
          .limit(str)
          .getall();

      showdata.addAll(data);
      return data;
    }
    return showdata;
  }

  loadhttp() async {
    //
    // var checktmp = await http('chat/havemsg', {}, gethead());
    // var check = getdata(context, checktmp);
    var check = Msg.cheack();
    if (isnull(check)) {
      //有未读消息
      //拉取消息
      var mg = await T('msg').order('id desc').getone();
      var tmp = await http(
          'chat/list', {'msgid': isnull(mg) ? mg['id'] : ''}, gethead());
      var data = getdata(context, tmp!);
      if (isnull(data)) {
        //更新本地数据库
        for (var item in data) {
          // ignore: await_only_futures
          await Msg.fromhttpJson(item)
            ..savedb();
        }
        //刷新列表
        issend = true;
        s('msg', 0);
        reflash();
      }
    } else {
      //没未读消息
    }
  }
}
