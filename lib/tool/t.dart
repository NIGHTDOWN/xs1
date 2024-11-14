import 'package:ng169/tool/db.dart';
import 'function.dart';
import 'global.dart';

//创建数据库

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
class T {
  late Db obj;
  String table = "";
  String _field = '*',
      _order = '',
      _limit = '',

      // ignore: unused_field
      _sql = '',
      _where = '',
      _join = '';
  _reset() {
    this._field = '*';
    this._order = '';
    this._limit = '';
    this._sql = '';
    this._where = '';
    this._join = '';
  }

  T(tablename) {
    obj = g('db');
    table = tablename;
  }
  field(String? field) {
    // ignore: unnecessary_null_comparison
    if (null != field) {
    } else {
      field = '*';
    }
    _field = field;
    return this;
  }

  where(Map<String, dynamic> where) {
    var key = '';
    for (var var1 in where.keys) {
      key += ' and `' + var1 + '`=\'' + where[var1].toString() + '\'';
    }
    var k = key.substring(4);
    // ignore: unnecessary_null_comparison
    if (null != k) {
      if (isnull(this._where)) {
        this._where = this._where + ' AND ' + k;
      } else {
        this._where = ' WHERE ' + k;
      }
    }
    return this;
  }

  join(String jointable, String jointype, String onwhere) {
    var joinword = ' ' + jointype + ' ' + ' join ';
    if (isnull(this._join)) {
      this._join = joinword + jointable + ' on ' + onwhere;
    } else {
      this._join += joinword + jointable + ' on ' + onwhere;
    }

    return this;
  }

  wherestring(String where) {
    if (isnull(this._where)) {
      this._where = this._where + ' AND ' + where;
    } else {
      this._where = ' WHERE ' + where;
    }

    return this;
  }

  order(String $order) {
    // ignore: unnecessary_null_comparison
    if (null != $order) {
      $order = " ORDER BY " + $order;
    }
    _order = $order;
    return this;
  }

  limit(String $limit) {
    // ignore: unnecessary_null_comparison
    if (null != $limit) {
      $limit = " limit " + $limit;
    }
    _limit = $limit;
    return this;
  }

  del([where]) async {
    if (isnull(where)) {
      where(where);
    }

    var _sql = ' DELETE FROM ' + table + _where;
    _reset();
    obj.del(_sql);
  }

  updata(updata, [where]) async {
    var key = '';
    var tmp = '';
    for (var var1 in updata.keys) {
      if ((updata[var1]) != null) {
        tmp = ',`' + var1 + '`=\'' + _fix(updata[var1].toString()) + '\'';
      }
      key += tmp;
    }

    var up = key.substring(1);
    if (isnull(where)) {
      this.where(where);
    }

    var _sql = ' UPDATE ' + table + ' SET ' + up + _where;
    // d(_sql);
    _reset();

    return await obj.updata(_sql);
  }

  String _fix(String str) {
    //str = str.replaceAll("'", "\\'");

    return str = str.replaceAll("'", '"');
  }

  update(updata, [where]) {
    return this.updata(updata, where);
  }

  add(Map<String, dynamic> insert) async {
    return await this.insert(insert);
  }

  Future insert(Map<String, dynamic> insert) async {
    var key = '';
    var val = '';
    for (var var1 in insert.keys) {
      key += ',\'' + var1 + '\'';
      val += ',\'' + _fix(insert[var1].toString()) + '\'';
    }

    key = key.substring(1);
    val = val.substring(1);

    var sql = 'INSERT INTO ' + table + ' (' + key + ') VALUES (' + val + ')';
    return obj.insert(sql);
  }

  Future getone([where]) async {
    limit('1');
    if (null != where) {
      this.where(where);
    }
    var _sql = 'SELECT ' +
        _field +
        ' FROM ' +
        table +
        ' ' +
        _join +
        ' ' +
        _where +
        " " +
        _order +
        " " +
        _limit;
    _where = '';
    _order = '';
    _limit = '';
    this.field(null);
    _reset();
    return await obj.getone(_sql);
  }

  Future getall([where]) async {
    if (null != where) {
      this.where(where);
    }
    var _sql = 'SELECT ' +
        _field +
        ' FROM ' +
        table +
        ' ' +
        _join +
        ' ' +
        _where +
        " " +
        _order +
        " " +
        _limit;
    _where = '';
    _order = '';
    _limit = '';
    this.field(null);
    _reset();
    // d(_sql);
    return await obj.getall(_sql);
  }

  List<Map<String, dynamic>> convertToPhpArray(
      List<Map<String, dynamic>> rows) {
    // 遍历每行数据并转换为PHP数组形式
    return rows.map((row) {
      // 将每个QueryRow转换为Map<String, dynamic>，这已经是PHP数组的形式
      return row.cast<String, dynamic>();
    }).toList();
  }

  Future getcount() async {
    this.field('count(*)');

    var _sql = 'SELECT ' +
        _field +
        ' FROM ' +
        table +
        ' ' +
        _join +
        ' ' +
        _where +
        " " +
        _order +
        " " +
        _limit;
    _where = '';
    _order = '';
    _limit = '';
    this.field(null);
    _reset();
    return await obj.getcount(_sql);
  }
}
