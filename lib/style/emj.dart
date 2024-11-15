import 'dart:ffi';

import 'package:flutter/material.dart';

class AnimatedEmoji extends StatefulWidget {
  final String emoji;
  final int indexnum;
  final Function(String) onEmojiSelected;

  AnimatedEmoji(
      {required this.emoji,
      required this.onEmojiSelected,
      required this.indexnum});

  @override
  _AnimatedEmojiState createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
        widget.onEmojiSelected(widget.indexnum.toString());
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Image.asset(
          'assets/images/emjo/${widget.emoji}',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class EmojiGrid extends StatefulWidget {
  final Function(String) sendemj;

  EmojiGrid(Function(dynamic data) sendemj) : this.sendemj = sendemj;

  @override
  _EmojiGridState createState() => _EmojiGridState();
}

class _EmojiGridState extends State<EmojiGrid> {
  List<String> emojis = List.generate(78, (index) => 'emj_${index + 1}.png');

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: emojis.length,
      itemBuilder: (BuildContext context, int index) {
        return AnimatedEmoji(
          emoji: emojis[index],
          indexnum: index,
          onEmojiSelected: widget.sendemj,
        );
      },
    );
  }
}
