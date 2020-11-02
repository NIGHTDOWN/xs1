import 'package:flutter/material.dart';

class NgDashedLine extends StatelessWidget {
  final Axis axis;
  final double dashedWidth;
  final double dashedHeight;
  final int count;
  final double width;
  final Color color;

  NgDashedLine(
      {@required this.axis,
      this.dashedWidth = 1,
      this.dashedHeight = 1,
      this.count,
      this.width,
      this.color = const Color(0xffff0000)});

  @override
  Widget build(BuildContext context) {
    var line = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        //根据宽度计算个数
        return Flex(
          direction: this.axis,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(this.count, (int index) {
            return SizedBox(
              width: dashedWidth,
              height: dashedHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
    if (this.axis == Axis.horizontal) {
      return Container(
        child: line,
        width: this.width,
      );
    }
    return Container(
      child: line,
      height: this.width,
    );
  }
}
