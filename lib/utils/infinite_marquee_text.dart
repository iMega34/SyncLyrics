
import 'package:flutter/material.dart';

class InfiniteMarqueeText extends StatefulWidget {
  /// Marquee text widget that scrolls infinitely
  /// 
  /// Parameters:
  /// - [text] is the text to be displayed
  /// - [style] is the text style to be applied
  /// - [spacing] is the space between the repeated text
  /// - [backgroundColor] is the background color of the widget. If not provided, it will be transparent
  const InfiniteMarqueeText({
    super.key,
    required this.text,
    this.style,
    this.backgroundColor,
    this.spacing = 10,
    this.speed = 25
  });

  // Class attributes
  final String text;
  final TextStyle? style;
  final Color? backgroundColor;
  final double spacing;
  final double speed;

  @override
  State<InfiniteMarqueeText> createState() => _InfiniteMarqueeTextState();
}

class _InfiniteMarqueeTextState extends State<InfiniteMarqueeText> {
  late ScrollController _scrollController;
  double _textWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Trigger the animation after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Start the animation
  Future<void> _startAnimation() async {
    // Calculate the scroll length
    final scrollLength = _textWidth + widget.spacing;

    // Animate the scroll controller to the end of the text
    while (_scrollController.hasClients) {
      await _scrollController.animateTo(
        scrollLength,
        duration: Duration(milliseconds: (scrollLength / widget.speed * 1000).toInt()),
        curve: Curves.linear
      );

      // Reset the scroll position and start the animation again
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  /// Get the width of the text
  /// 
  /// Parameters:
  /// - [context] is the build context
  /// 
  /// Returns:
  /// - The width of the text as a [double]
  double _getTextWidth(BuildContext context) {
    // Return 0 if the text is empty
    if (widget.text.isEmpty) return 0;

    // Create a text painter to measure the width of the text
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1
    )..layout(maxWidth: double.infinity);

    return textPainter.width;
  }

  /// Calculate the number of times the text should be repeated in order to fill the available space
  /// 
  /// Parameters:
  /// - [maxWidth] is the maximum width available
  /// 
  /// Returns:
  /// - The number of times the text should be repeated as an [int]
  int _calculateRepeatCount(double maxWidth) => (maxWidth / (_textWidth + widget.spacing)).ceil() + 1;

  @override
  Widget build(BuildContext context) {
    // Get the width of the text
    _textWidth = _getTextWidth(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the number of times the text should be repeated
        final repeatCount = _calculateRepeatCount(constraints.maxWidth);
        return Container(
          color: widget.backgroundColor ?? Colors.transparent,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: List.generate(repeatCount, (_) => Padding(
                padding: EdgeInsets.only(right: widget.spacing),
                child: Text(widget.text, style: widget.style, maxLines: 1),
              )),
            ),
          ),
        );
      },
    );
  }
}
