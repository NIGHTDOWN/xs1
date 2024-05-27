import 'package:flutter/material.dart';
import 'package:ng169/style/sq_color.dart';

class NovelSummaryView extends StatelessWidget {
  final String summary;
  final bool isUnfold;
  final VoidCallback onPressed;

  NovelSummaryView(this.summary, this.isUnfold, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        color: SQColor.white,
        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            Text(
              summary,
              maxLines: isUnfold ? null : 3,
              style: TextStyle(fontSize: 14),
            ),
            //Image.asset('assets/images/detail_fold_bg.png'),
            Image.asset(
              isUnfold
                  ? 'assets/images/detail_up.png'
                  : 'assets/images/detail_down.png',
              width: 15,
            ),
          ],
        ),
      ),
    );
  }
}
