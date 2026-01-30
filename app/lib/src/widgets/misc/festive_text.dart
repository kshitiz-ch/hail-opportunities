import 'dart:async';
import 'dart:math';

import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FestiveText extends StatelessWidget {
  const FestiveText({
    Key? key,
    this.agent,
    required this.festiveText,
    required this.festiveIcon,
  }) : super(key: key);

  final AgentModel? agent;
  final String festiveText;
  final String festiveIcon;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlipController>(
      init: FlipController(),
      autoRemove: false,
      builder: (controller) {
        return Flip(
          controller: controller,
          flipDirection: Axis.vertical,
          firstChild: _buildGreetAgent(context, agent),
          secondChild: _buildFestiveText(context),
        );
      },
    );
  }

  Widget _buildFestiveText(BuildContext context) {
    return Row(
      children: [
        Text(
          festiveText,
          style: Theme.of(context).primaryTextTheme.headlineSmall,
        ),
        SizedBox(width: 3),
        Image.asset(festiveIcon, width: 14)
      ],
    );
  }

  Widget _buildGreetAgent(BuildContext context, AgentModel? agent) {
    return Text(
      'Hi ${getDisplayName(agent)}',
      style: Theme.of(context).primaryTextTheme.headlineSmall,
    );
  }

  String getDisplayName(AgentModel? agent) {
    String displayName = agent?.displayName ?? agent?.name ?? 'Agent';

    return displayName.split(" ")[0];
  }
}

class Flip extends StatefulWidget {
  final Widget firstChild;
  final Widget secondChild;
  final FlipController controller;
  final Duration flipDuration;
  final Axis flipDirection;

  const Flip({
    Key? key,
    required this.controller,
    required this.firstChild,
    required this.secondChild,
    this.flipDuration = const Duration(milliseconds: 500),
    this.flipDirection = Axis.horizontal,
  }) : super(key: key);

  @override
  _FlipState createState() => _FlipState();
}

class _FlipState extends State<Flip> with SingleTickerProviderStateMixin {
  late AnimationController flipAnimation;
  late bool isFront;
  late Timer timer;

  @override
  void initState() {
    isFront = widget.controller.isFront;
    timer = Timer.periodic(Duration(milliseconds: 1500), (Timer t) {
      if (widget.controller.index == 4) {
        timer.cancel();
      } else {
        widget.controller.flip();
      }
    });
    flipAnimation = AnimationController(
        value: isFront ? 0 : 1, vsync: this, duration: widget.flipDuration);
    flipAnimation.addListener(_listenAnimationController);
    widget.controller.addListener(_listenFlipController);
    super.initState();
  }

  @override
  void dispose() {
    flipAnimation.removeListener(_listenAnimationController);
    flipAnimation.dispose();
    widget.controller.removeListener(_listenFlipController);
    super.dispose();
  }

  void _listenFlipController() {
    if (widget.controller.isFront) {
      flipAnimation.reverse();
    } else {
      flipAnimation.forward();
    }
  }

  void _listenAnimationController() {
    if (isFront && flipAnimation.value > 0.5) {
      setState(() {
        isFront = false;
      });
    } else if (!isFront && flipAnimation.value < 0.5) {
      setState(() {
        isFront = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var child = AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, child) {
        return Transform(
          transform: _buildAnimatedMatrix4(flipAnimation.value),
          alignment: Alignment.centerLeft,
          child: child,
        );
      },
      child: IndexedStack(
        index: isFront ? 0 : 1,
        alignment: Alignment.centerLeft,
        children: <Widget>[
          widget.firstChild,
          Transform(
              transform: _buildSecondChildMatrix4(),
              alignment: Alignment.centerLeft,
              child: widget.secondChild)
        ],
      ),
    );
    return child;
  }

  Matrix4 _buildSecondChildMatrix4() {
    if (widget.flipDirection == Axis.horizontal) {
      return Matrix4.identity()..rotateY(pi);
    } else {
      return Matrix4.identity()..rotateX(pi);
    }
  }

  Matrix4 _buildAnimatedMatrix4(double value) {
    final matrix = Matrix4.identity()..setEntry(3, 2, 0.002);
    if (widget.flipDirection == Axis.horizontal) {
      matrix.rotateY(value * pi);
    } else {
      matrix.rotateX(value * -pi);
    }
    return matrix;
  }
}

class FlipController extends GetxController {
  bool isFront = true;
  int index = 0;

  void flip() {
    if (index == 4) return;
    isFront = !isFront;
    index++;
    update();
  }
}
