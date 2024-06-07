import 'package:ng169/conf/conf.dart';
import 'package:sqflite/sqflite.dart';

import 'function.dart';

//创建数据库
//添加
//更新
//删除
// open,
// 	creat,
// 	select,
// 	limit,
// 	where,
// 	order,
// 	field,
// 	del,
// 	update,
// 	insert,
class Db {
  late Database db;

  static getpath(dbname) async {
    var databasesPath = await getDatabasesPath();

    // var databasesPath = '/mnt/sdcard';
    d(databasesPath);
    String path = (databasesPath + '/' + dbname);
    return path;
  }

  open(String dbname) async {
    // // var databasesPath = await getDatabasesPath();
    // var databasesPath = '/mnt/sdcard';
    // String path = (databasesPath + '/' + dbname);
    String path = await Db.getpath(dbname);
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      this.db = db;

      for (var sql in datatable) {
        creat(sql);
      }
    });
  }

  creat(sql) async {
    await this.db.execute(sql);
  }

  del(_sql) async {
    int count = await db.rawDelete(_sql);

    return count;
  }

  updata(sql) async {
    int count = await db.rawUpdate(sql);

    return count;
  }

  update(sql) {
    return this.updata(sql);
  }

  add(sql) {
    return this.insert(sql);
  }

  Future insert(sql) async {
    //这里不要启用事务
    try {
      int id = await db.rawInsert(sql);
      return id;
    } catch (e) {
      d(e, 2);
      return false;
    }
    // return await db.rawInsert(sql);
    // return await db.transaction((txn) async {
    //   //int id = await txn.rawInsert(sql);
    //   try {
    //     int id = await txn.rawInsert(sql);
    //     return id;
    //   } catch (e) {
    //     d(e);
    //   }
    // });
  }

  Future close() async {
    await db.close();
  }

  Future getone(_sql) async {
    var data = await db.rawQuery(_sql);

    _sql = '';

    if (data.length <= 0) {
      return null;
    } else {
      return data.first;
    }
  }

  Future getall(_sql) async {
    return await db.rawQuery(_sql);
  }

  Future getcount(_sql) async {
    int? count = Sqflite.firstIntValue(await db.rawQuery(_sql));
    _sql = '';

    return count;
  }
}
