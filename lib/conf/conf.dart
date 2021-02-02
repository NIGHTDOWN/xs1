const apiurl = 'http://api.lookstory.xyz/api/';
// const apiurl = 'http://192.168.2.106/api/';
const serverurl = 'http://api.lookstory.xyz/';

const defaultAvatar = 'assets/images/ww_default_avatar.png'; //默认头像
const dbname = 'lsdb.db';
//数据库结构
const datatable = [
  // 'CREATE TABLE "msglist" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,"msgid" integer,"chatid" integer,"comeid" integer,"sendtime" integer,"readflag" integer NOT NULL DEFAULT 0,"content" text,"type" integer, "resid" integer,"url" text,"murl" text,"size" integer,"length" integer)',
  // 'CREATE TABLE "chatlist" ("id" INTEGER NOT NULL,"chatid" INTEGER NOT NULL,"uid" INTEGER NOT NULL,"uid2" integer NOT NULL,"name" TEXT,"lock" integer NOT NULL DEFAULT 0,"username" TEXT,"headimg" TEXT,"num" INTEGER NOT NULL, "msgtime" integer NOT NULL,"msg" TEXT,PRIMARY KEY ("id"));',
  'CREATE TABLE "optinon" ("id" INTEGER PRIMARY KEY AUTOINCREMENT,"name" TEXT,"value" TEXT)',
  "CREATE UNIQUE INDEX 'name' ON 'optinon' ('name' COLLATE BINARY)",
  'CREATE TABLE "book" (	"id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,	"bookid" INTEGER NOT NULL,"uid" INTEGER NOT NULL DEFAULT 0,	"price" integer NOT NULL DEFAULT 0,	"type" integer NOT NULL DEFAULT 1,	"bookname" integer NOT NULL,	"author" TEXT,	"pic" TEXT,	"about" TEXT,	"isfree" integer NOT NULL DEFAULT 0,	"flag" integer NOT NULL DEFAULT 0,	"addtime" integer NOT NULL DEFAULT 0,	"scroe" integer NOT NULL DEFAULT 0,	"isgroom" integer NOT NULL DEFAULT 0,	"groomtime" integer NOT NULL DEFAULT 0,	"readtime" integer NOT NULL DEFAULT 0,	"readsec" integer NOT NULL DEFAULT 0,	"secnum" INTEGER NOT NULL DEFAULT 0,	"wordnum" INTEGER NOT NULL DEFAULT 0,"isdownload" INTEGER NOT NULL DEFAULT 0, "lastsecnum" INTEGER NOT NULL DEFAULT 0, "nowsecnum" INTEGER NOT NULL DEFAULT 0);',
  'CREATE  INDEX "bookid" ON "book" ("bookid");',
  'CREATE UNIQUE INDEX "weyi" ON "book" ("bookid" ASC, "type" ASC);',
  'CREATE  INDEX "type" ON "book" ("type");',
  'CREATE  INDEX "readtime" ON "book" ("readtime");',
  'CREATE  INDEX "groomtime" ON "book" ("groomtime");',
  'CREATE TABLE "sec" (	"id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,	"section_id" INTEGER NOT NULL,"book_id" INTEGER NOT NULL DEFAULT 0,	"isfree" integer NOT NULL DEFAULT 0,	"secnum" integer NOT NULL DEFAULT 1,	"update_time" integer NOT NULL,	"title" TEXT,	"coin" integer NOT NULL DEFAULT 0,	"ispay" integer NOT NULL DEFAULT 0,	"booktype" integer NOT NULL DEFAULT 0,	"index" integer NOT NULL DEFAULT 0,"cacheflag" integer NOT NULL DEFAULT 0,"cachedata" TEXT,"cacheword" TEXT);',
  'CREATE UNIQUE INDEX "secindex" ON "sec" ("section_id" ASC, "book_id" ASC, "booktype" ASC);',
  'CREATE TABLE "read" ( "id" INTEGER PRIMARY KEY AUTOINCREMENT, "bookid" INTEGER, "type" INTEGER, "readtime" INTEGER, "uid" INTEGER, "secid" INTEGER );',
  'CREATE UNIQUE INDEX "weyi2" ON "read" ("uid" ASC, "bookid" ASC,"type" ASC);',
  'CREATE TABLE "pay" ( "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "bookid" INTEGER NOT NULL DEFAULT 0, "type" INTEGER NOT NULL DEFAULT 0, "secid" INTEGER NOT NULL DEFAULT 0, "pay" INTEGER NOT NULL DEFAULT 0, "uid" INTEGER NOT NULL DEFAULT 0 ,"coin" text NOT NULL DEFAULT 0.0 );',
  'CREATE UNIQUE INDEX "wey3" ON "pay" ( "secid", "uid", "type", "bookid" );',
  'CREATE TABLE "msg" ( "id" INTEGER NOT NULL, "msgid" INTEGER,"flag" INTEGER NOT NULL DEFAULT 0,"fuid" INTEGER, "tuid" INTEGER, "type" INTEGER, "sendtime" INTEGER, "contenttype" INTEGER, "content" TEXT, PRIMARY KEY ("id"));',
  // 'CREATE TABLE "bookinfo" ( "bookid" INTEGER NOT NULL, "type" INTEGER, "lastsecnum" INTEGER, "nowsecnum" INTEGER, PRIMARY KEY ( "bookid" ) );',
  // 'CREATE INDEX "wey4" ON "bookinfo" ( "bookid" );'
];
const fb_app_id = '2090299167929890';
const fb_app_secret = '38dca4e8957b0e7e194849875769abe2';
const fb_LoginUrl = 'https://192.168.6.6/api/login/fbback';
const autounlock = 'autounlock'; //自动解锁缓存名称
const appversion = ''; //版本号
const appupinfo = 'appupinfo'; //获取的更新信息json
const downdocment = 'downdocment'; //文件下载目录名称
const appstatus = 'appstatus'; //app前后台状态名称
const isnight = 'isnight'; //黑夜模式
const themecache = 'themecache'; //主题
const oldthemecache = 'oldthemecache'; //原主题
const fontsizecache = 'fontsizecache'; //原主题
const autolight = 'autolight'; //屏幕亮度自动适应
const langlist = [
  {'en': "English"},
  {'th': "ไทย"},
  {'zh': "简体中文"},
  {'vi': "Tiếng Việt"},
  {'id': "bahasa Indonesia"},
  {'ko': "한국어"},
  {'ms': "Melayu"}
];
const readfx = 'readfx'; //阅读方向
// 下载渠道，打包的时候修改此处
const downqd = 'google';
//测试
// const loghttp = true;
// const loghttprq = true;
// const loghttpcn = true; //显示http错误内容，false显示错误码
// const isdebug = true; //显示各种调试信息，false不显示任何调试信息
// const delanguage = 'zh'; //默认语言

//正式
const loghttp = false;
const loghttprq = false;
const loghttpcn = false; //显示http错误内容，false显示错误码
const isdebug = false; //显示各种调试信息，false不显示任何调试信息
const delanguage = 'th'; //默认语言
