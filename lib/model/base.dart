import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
abstract class LoginBase extends StatefulWidget {
  bool needlogin = false;
  late State<LoginBase> state;
  late BuildContext context;
  bool mounted = false;

  Function setState = () {};
  Function reflash = () {};
  @override
  createState() => _LoginBaseState();

  @protected
  Widget build(BuildContext context);

  void initState() {}

  void dispose() {}
}

class _LoginBaseState extends State<LoginBase> {
  @override
  void initState() {
    super.initState();
    widget.initState();
    widget.mounted = mounted;
  }

  void reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.mounted = mounted;
    widget.state = this;
    widget.context = context;
    widget.setState = setState;
    widget.reflash = reflash;
    // setState(() {

    // });
    return widget.build(context);
  }

  @override
  void dispose() {
    super.dispose();
    widget.dispose();
  }
}
