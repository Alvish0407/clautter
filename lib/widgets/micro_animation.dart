import 'package:flutter/material.dart';

class MicroAnimation extends StatefulWidget {
  final Widget child;
  final double delay;
  final AxisDirection direction;
  final double offsetAmount;

  const MicroAnimation({
    super.key,
    required this.child,
    this.delay = 0.0,
    this.direction = AxisDirection.up,
    this.offsetAmount = 40.0,
  });

  @override
  State<MicroAnimation> createState() => _MicroAnimationState();
}

class _MicroAnimationState extends State<MicroAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    final Offset startOffset = switch (widget.direction) {
      AxisDirection.up => Offset(0, widget.offsetAmount),
      AxisDirection.down => Offset(0, -widget.offsetAmount),
      AxisDirection.left => Offset(widget.offsetAmount, 0),
      AxisDirection.right => Offset(-widget.offsetAmount, 0),
    };

    _offset = Tween<Offset>(begin: startOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(
      Duration(milliseconds: (widget.delay * 1000).round()),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(offset: _offset.value, child: child),
      ),
      child: widget.child,
    );
  }
}
