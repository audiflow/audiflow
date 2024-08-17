import 'dart:async';

import 'package:audiflow/features/player/ui/expandable_player_frame/expandable_player_frame_controller.dart';
import 'package:audiflow/features/player/ui/expandable_player_frame/expandable_player_frame_state.dart';
import 'package:audiflow/features/player/ui/expandable_player_frame/utils.dart';
import 'package:flutter/material.dart';

///Type definition for the builder function
typedef ExpandablePlayerBuilder = Widget Function(
  double height,
  double percentage,
);

///Type definition for onDismiss. Will be used in a future version.
typedef DismissCallback = void Function(double percentage);

///MiniPlayer class
class ExpandablePlayerFrame extends StatefulWidget {
  const ExpandablePlayerFrame({
    super.key,
    required this.miniHeight,
    required this.fullHeight,
    required this.builder,
    this.curve = Curves.easeOut,
    this.elevation = 0,
    this.backgroundColor,
    this.valueNotifier,
    this.duration = const Duration(milliseconds: 300),
    this.onDismissed,
    this.controller,
    this.backgroundBoxShadow = Colors.black45,
  });

  ///Required option to set the height for mini/full heights
  final double miniHeight;
  final double fullHeight;

  ///Option to enable and set elevation for the miniPlayer
  final double elevation;

  ///Central API-Element
  ///Provides a builder with useful information
  final ExpandablePlayerBuilder builder;

  ///Option to set the animation curve
  final Curve curve;

  ///Sets the background-color of the miniPlayer
  final Color? backgroundColor;

  ///Option to set the animation duration
  final Duration duration;

  ///Allows you to use a global ValueNotifier with the current progress.
  ///This can be used to hide the BottomNavigationBar.
  final ValueNotifier<double>? valueNotifier;

  ///If onDismissed is set, the miniPlayer can be dismissed
  final VoidCallback? onDismissed;

  //Allows you to manually control the miniPlayer in code
  final ExpandablePlayerFrameController? controller;

  ///Used to set the color of the background box shadow
  final Color backgroundBoxShadow;

  @override
  State createState() => _ExpandablePlayerFrameState();
}

class _ExpandablePlayerFrameState extends State<ExpandablePlayerFrame>
    with TickerProviderStateMixin {
  late ValueNotifier<double> heightNotifier;
  ValueNotifier<double> dragDownPercentage = ValueNotifier(0);

  /// Temporary variable as long as onDismiss is deprecated. Will be removed in
  /// a future version.
  VoidCallback? onDismissed;

  ///Current y position of drag gesture
  late double _dragHeight;

  ///Used to determine SnapPosition
  late double _startHeight;

  bool dismissed = false;

  bool animating = false;

  /// Counts how many updates were required for a distance (onPanUpdate) ->
  /// necessary to calculate the drag speed
  int updateCount = 0;

  final StreamController<double> _heightController =
      StreamController<double>.broadcast();
  AnimationController? _animationController;

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _resetAnimationController();
    }
  }

  void _resetAnimationController({Duration? duration}) {
    if (_animationController != null) {
      _animationController!.dispose();
    }
    _animationController = AnimationController(
      vsync: this,
      duration: duration ?? widget.duration,
    );
    _animationController!.addStatusListener(_statusListener);
    animating = false;
  }

  @override
  void initState() {
    if (widget.valueNotifier == null) {
      heightNotifier = ValueNotifier(widget.miniHeight);
    } else {
      heightNotifier = widget.valueNotifier!;
    }

    _resetAnimationController();

    _dragHeight = heightNotifier.value;

    if (widget.controller != null) {
      widget.controller!.addListener(controllerListener);
    }

    if (widget.onDismissed != null) {
      onDismissed = widget.onDismissed;
    }

    super.initState();
  }

  @override
  void dispose() {
    _heightController.close();

    if (_animationController != null) {
      _animationController!.dispose();
    }

    if (widget.controller != null) {
      widget.controller!.removeListener(controllerListener);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (dismissed) {
      return Container();
    }

    return PopScope(
      canPop: widget.miniHeight < heightNotifier.value,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _snapToPosition(ExpandablePlayerFrameState.mini);
        }
      },
      child: ValueListenableBuilder(
        valueListenable: heightNotifier,
        builder: (BuildContext context, double height, Widget? _) {
          final percentage = (height - widget.miniHeight) /
              (widget.fullHeight - widget.miniHeight);

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (0 < percentage)
                GestureDetector(
                  onTap: () => _animateToHeight(widget.miniHeight),
                  child: Opacity(
                    opacity: borderDouble(percentage),
                    child: Container(color: widget.backgroundColor),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: height,
                  child: GestureDetector(
                    child: ValueListenableBuilder(
                      valueListenable: dragDownPercentage,
                      builder:
                          (BuildContext context, double value, Widget? child) {
                        return Opacity(
                          opacity: borderDouble(1 - value * 0.8),
                          child: Transform.translate(
                            offset: Offset(0, widget.miniHeight * value * 0.5),
                            child: child,
                          ),
                        );
                      },
                      child: Material(
                        child: widget.builder(height, percentage),
                      ),
                    ),
                    onTap: () => _snapToPosition(
                      _dragHeight != widget.fullHeight
                          ? ExpandablePlayerFrameState.full
                          : ExpandablePlayerFrameState.mini,
                    ),
                    onPanStart: (details) {
                      _startHeight = _dragHeight;
                      updateCount = 0;

                      if (animating) {
                        _resetAnimationController();
                      }
                    },
                    onPanEnd: (details) async {
                      // Calculates drag speed
                      final speed = (_dragHeight - _startHeight * _dragHeight <
                                  _startHeight
                              ? 1
                              : -1) /
                          updateCount *
                          100;

                      // Define the percentage distance depending on the speed
                      // with which the widget should snap
                      var snapPercentage = 0.005;
                      if (speed <= 4) {
                        snapPercentage = 0.2;
                      } else if (speed <= 9) {
                        snapPercentage = 0.08;
                      } else if (speed <= 50) {
                        snapPercentage = 0.01;
                      }

                      // Determine to which SnapPosition the widget should snap
                      var snap = ExpandablePlayerFrameState.mini;

                      final percentageMax = percentageFromValueInRange(
                        min: widget.miniHeight,
                        max: widget.fullHeight,
                        value: _dragHeight,
                      );

                      // Started from expanded state
                      if (_startHeight > widget.miniHeight) {
                        if (percentageMax > 1 - snapPercentage) {
                          snap = ExpandablePlayerFrameState.full;
                        }
                      }

                      // Started from minified state
                      else {
                        if (percentageMax > snapPercentage) {
                          snap = ExpandablePlayerFrameState.full;
                        }

                        // DismissedPercentage > 0.2 -> dismiss
                        else if (onDismissed != null &&
                            percentageFromValueInRange(
                                  min: widget.miniHeight,
                                  max: 0,
                                  value: _dragHeight,
                                ) >
                                snapPercentage) {
                          snap = ExpandablePlayerFrameState.dismiss;
                        }
                      }

                      // Snap to position
                      _snapToPosition(snap);
                    },
                    onPanUpdate: (details) {
                      if (dismissed) {
                        return;
                      }

                      _dragHeight -= details.delta.dy;
                      updateCount++;

                      _handleHeightChange();
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Determines whether the panel should be updated in height or discarded
  void _handleHeightChange({bool animation = false}) {
    // Drag above minHeight
    if (widget.miniHeight <= _dragHeight) {
      if (dragDownPercentage.value != 0) {
        dragDownPercentage.value = 0;
      }

      if (widget.fullHeight < _dragHeight) {
        return;
      }

      heightNotifier.value = _dragHeight;
    }

    // Drag below minHeight
    else if (onDismissed != null) {
      final percentageDown = borderDouble(
        percentageFromValueInRange(
          min: widget.miniHeight,
          max: 0,
          value: _dragHeight,
        ),
      );

      if (dragDownPercentage.value != percentageDown) {
        dragDownPercentage.value = percentageDown;
      }

      if (percentageDown >= 1 && animation && !dismissed) {
        if (onDismissed != null) {
          onDismissed?.call();
        }
        setState(() => dismissed = true);
      }
    }
  }

  ///Animates the panel height according to a SnapPoint
  void _snapToPosition(ExpandablePlayerFrameState snapPosition) {
    switch (snapPosition) {
      case ExpandablePlayerFrameState.full:
        _animateToHeight(widget.fullHeight);
        return;
      case ExpandablePlayerFrameState.mini:
        _animateToHeight(widget.miniHeight);
        return;
      case ExpandablePlayerFrameState.dismiss:
        _animateToHeight(0);
        return;
    }
  }

  ///Animates the panel height to a specific value
  void _animateToHeight(double h, {Duration? duration}) {
    if (_animationController == null) {
      return;
    }
    final startHeight = _dragHeight;

    if (duration != null) {
      _resetAnimationController(duration: duration);
    }

    final sizeAnimation = Tween(
      begin: startHeight,
      end: h,
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: widget.curve),
    );

    sizeAnimation.addListener(() {
      if (sizeAnimation.value == startHeight) {
        return;
      }

      _dragHeight = sizeAnimation.value;

      _handleHeightChange(animation: true);
    });

    animating = true;
    _animationController!.forward(from: 0);
  }

  //Listener function for the controller
  void controllerListener() {
    if (widget.controller == null) {
      return;
    }
    if (widget.controller!.value == null) {
      return;
    }

    switch (widget.controller!.value!.height) {
      case -1:
        _animateToHeight(
          widget.miniHeight,
          duration: widget.controller!.value!.duration,
        );
      case -2:
        _animateToHeight(
          widget.fullHeight,
          duration: widget.controller!.value!.duration,
        );
      case -3:
        _animateToHeight(
          0,
          duration: widget.controller!.value!.duration,
        );
      default:
        _animateToHeight(
          widget.controller!.value!.height.toDouble(),
          duration: widget.controller!.value!.duration,
        );
        break;
    }
  }
}
