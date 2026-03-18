import 'package:flutter/material.dart';

class FadeSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;

  const FadeSlide({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = const Duration(milliseconds: 60),
  });

  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final delay =
        Duration(milliseconds: widget.baseDelay.inMilliseconds * widget.index);
    Future.delayed(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
