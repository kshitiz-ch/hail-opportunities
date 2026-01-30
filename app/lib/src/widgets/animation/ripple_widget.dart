import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RippleAnimationWidget extends StatefulWidget {
  const RippleAnimationWidget(
      {Key? key,
      this.child,
      this.constraints,
      this.color,
      this.minRadius,
      this.maxRadius,
      this.startAnimation})
      : super(key: key);
  final Widget? child;
  final BoxConstraints? constraints;
  final Color? color;
  final double? minRadius;
  final double? maxRadius;
  final bool? startAnimation;

  @override
  State<RippleAnimationWidget> createState() => _RippleAnimationWidgetState();
}

class _RippleAnimationWidgetState extends State<RippleAnimationWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.startAnimation!) {
      _controller = AnimationController(
        vsync: this,
        lowerBound: 0,
        duration: Duration(milliseconds: 1500),
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RippleAnimationWidget oldWidget) {
    if (widget.startAnimation! && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        lowerBound: 0,
        duration: Duration(milliseconds: 1500),
      )..repeat();
    } else if (widget.startAnimation! && _controller != null) {
      _controller!.repeat();
    } else if (!widget.startAnimation! && _controller != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _controller!.reset();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_controller == null) {
      return Stack(alignment: Alignment.center, children: [widget.child!]);
    }
    return AnimatedBuilder(
      animation:
          CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildContainer(
                widget.constraints, _controller!.value, widget.startAnimation!),

            //* add below containers for more waves
            // _buildContainer(
            //     BoxConstraints(
            //       maxHeight: widget.constraints.maxHeight + 10,
            //       minHeight: widget.constraints.minHeight + 10,
            //       maxWidth: widget.constraints.maxWidth + 10,
            //       minWidth: widget.constraints.minWidth + 10,
            //     ),
            //     _controller.value),
            // _buildContainer(250 * _controller.value),
            // _buildContainer(300 * _controller.value),
            // _buildContainer(350 * _controller.value),
            widget.child!
          ],
        );
      },
    );
  }

  Widget _buildContainer(
      BoxConstraints? constraints, double value, bool startAnimation) {
    if (!startAnimation)
      return Container(
        width: constraints!.minWidth,
        height: constraints.minHeight,
      );
    return Container(
      width: value * (constraints!.maxWidth - constraints.minWidth) +
          constraints.minWidth,
      height: value * (constraints.maxHeight - constraints.minHeight) +
          constraints.minHeight,
      decoration: BoxDecoration(
        // shape: BoxShape.circle,
        borderRadius: BorderRadius.circular(
            value * (widget.maxRadius! - widget.minRadius!) + widget.minRadius!),
        color: widget.color!.withOpacity(1 - _controller!.value),
      ),
    );
  }
}
