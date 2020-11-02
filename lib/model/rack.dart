import 'package:ng169/obj/novel.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';

import 'package:ng169/tool/t.dart';

class Rackmodel {
  addrack(Novel novel) {
    T('book').update({
      'isgroom': 1,
      'uid': getuid(),
      'addtime': gettime(),
    }, {
      'bookid': novel.id,
      'type': novel.type
    });

    rackrf();
  }

  upreadtime(Novel novel) async {
    var inser = {
      'addtime': gettime(),
    };

    if (isnull(novel.chapterCount) || isnull(novel.nowsecnum)) {
      //记录上次加载本书的章节数目
      // await novel.getchapterCount();
      inser.addAll({'lastsecnum': novel.chapterCount.toString()});
      if (isnull(novel.nowsecnum)) {
        //这里修复，章节入库不完整时候；更新数量不正确问题

        inser.addAll({'lastsecnum': novel.nowsecnum.toString()});
      }
    } else {
      await novel.getchapterCount();
      inser.addAll({'lastsecnum': novel.chapterCount.toString()});
    }

    T('book').update(inser, {'bookid': novel.id, 'type': novel.type});

    rackrf();
  }

  rackrf() {
    eventBus.emit('rfrack');
  }
}
