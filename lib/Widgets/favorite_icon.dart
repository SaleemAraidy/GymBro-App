import 'package:flutter/material.dart';


// Animated button to indicate if a post/comment is liked
// Pass in onPressed
class FavoriteIconButton extends StatefulWidget {
  const FavoriteIconButton({
    Key? key,
    required this.isLiked,
    this.size = 22,
    required this.onTap,
}) : super(key: key);

  // indicates if it is liked or not
  final bool isLiked;

  // size of the icon
  final double size;

  // onTap callback. Returns a value to indicate if liked or not
  final Function(bool val) onTap;

  @override
  _FavoriteIconButtonState createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<FavoriteIconButton> {
  late bool isLiked = widget.isLiked;

  void _handleTap() {
    setState(() {
      isLiked = !isLiked;
    });
    widget.onTap(isLiked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      // AnimatedCrossFade widget is used to animate between two icons:
      // Icons.favorite (a filled heart) and
      // Icons.favorite_outline (an outline heart).
      child: AnimatedCrossFade(
        firstCurve: Curves.easeIn,
        secondCurve: Curves.easeOut,
        firstChild: Icon(
          Icons.favorite,
          color: Colors.red,
          size: widget.size,
        ),
        secondChild: Icon(
          Icons.favorite_outline,
          size: widget.size,
        ),
        // controls the transition between the two icons
        crossFadeState:
            isLiked ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }
}