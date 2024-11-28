// import 'package:quiver/mirrors.dart';

// /**函数隐式调用 */
import 'dart:convert';
import 'dart:io';

import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/thred.dart';
import 'package:shell_cmd/shell_cmd.dart';
import 'package:socks5_proxy/secure_compare.dart';
import 'package:socks5_proxy/socks.dart';

class Shell {
  //获取系统
  static String getOs() {
    return Platform.operatingSystemVersion;
  }

  //判断是否window
  static bool IsWindows() {
    return ShellCmd.isWindows;
  }

  static Thred? xianchen;
  static Future<void> threadsock() async {
    if (isnull(xianchen)) {
      xianchen!.kill();
      xianchen = null;
    }
    if (!isnull(xianchen)) {
      // xianchen = new Thred();
      // xianchen = await Thred.run("start", () => {Shell.startsock(port: 16980)});
      Shell.startsock(port: 16980);
      // await xianchen!.init(() {
      //   Shell.startsock(port: 16980);
      //   return "";
      // }, true, true);
    }
  }

  //启动sock服务
  static Future<bool> startsock({
    int port = 16980,
    String? user = "lovenovel",
    String? pwd = "y123456",
  }) async {
    final proxy;

    if (isnull(user)) {
      proxy = SocksServer();
    } else {
      proxy = SocksServer(
        authHandler: (username, password) =>
            // Secure compare only make sense with hashes!!!
            // It's not recommended to use it like below.
            secureCompare(username, user!) && secureCompare(password, pwd!),
      );
    }

    try {
      // Listen to all tcp and udp connections
      proxy.connections.listen((connection) async {
        // Apply default handler or create own handler to spy on connections.
        await connection.forward();
      }).onError((error) {
        // Handle error, if necessary
        d(error);
        return false;
      });
      // Bind servers

      await proxy.bind(
        InternetAddress.anyIPv4,
        port,
      );

      d("启动server" +
          InternetAddress.loopbackIPv4.address +
          ":" +
          tostring(port));
      d("测速命令curl -x socks5://lovenovel:y123456@127.0.0.1:16980 https://www.baidu.com");
      // If bind is successful, return true
      return true;
    } catch (e) {
      // If an error occurs, print it and return false
      d(e);
      return false;
    }
  }

  //连接sock代理；请求
  static Future<String> connnectSock(
    String ip,
    String port,
    String url, {
    String? user = null,
    String? pwd = null,
  }) async {
    List<ProxySettings> proxies;
    if (isnull(user)) {
      proxies = [
        ProxySettings(InternetAddress(ip), toint(port),
            password: pwd, username: user),
      ];
    } else {
      proxies = [
        ProxySettings(InternetAddress(ip), toint(port)),
      ];
    }

    // Create HttpClient object
    final client = HttpClient();

    // Assign connection factory
    SocksTCPClient.assignToHttpClientWithSecureOptions(
      client, proxies,
      // Log tls keys
      keyLog: print,
    );
    // GET request
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    // Print response
    final responsestr = (await utf8.decodeStream(response));
    // Close client
    client.close();
    return responsestr;
  }

  //执行系统命令
  static Future<String> exec(String shellcode) async {
    // print('\nDefShell: ${ShellCmd.resetShell()}');
    // final cmdWin = 'echo. & echo %CD%';
    // final cmdPsx = 'echo "" && echo `pwd`';
    // final cmd = ShellCmd(ShellCmd.isWindows ? cmdWin : cmdPsx);
    final cmd = ShellCmd(shellcode);
    final result = await cmd.run(runInShell: true);
    // final status =
    //     (result.exitCode == 0 ? 'Success' : 'Error ${result.exitCode}');
    if (result.exitCode == 0) {
      //成功
      return result.stdout.toString();
    } else {
      //失败
      return 'Error ${result.exitCode}';
    }
    // print('\nSplit - Exe: ${cmd.program}, Args: ${cmd.args}');
    // print('\nCurDir:\n$status\n${result.stdout.toString()}***');
  }
}
