import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'custom_padding_raw_scrollbar.dart';
import 'package:flutter/material.dart';

const double _kScrollbarThickness = 8.0;
const double _kScrollbarThicknessWithTrack = 12.0;
const double _kScrollbarMargin = 2.0;
const double _kScrollbarMinLength = 48.0;
const Radius _kScrollbarRadius = Radius.circular(8.0);
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 300);
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 600);

class CustomPaddingScrollbar extends StatelessWidget {
  
  const CustomPaddingScrollbar({
    Key? key,
    required this.child,
    this.controller,
    this.thumbVisibility,
    this.trackVisibility,
    this.showTrackOnHover,
    this.hoverThickness,
    this.thickness,
    this.radius,
    this.notificationPredicate,
    this.interactive,
    this.scrollbarOrientation,
    this.padding,
  }) : super(key: key);
  
  final Widget child;
  
  final ScrollController? controller;
  
  final bool? thumbVisibility;

  final bool? trackVisibility;
  
  final bool? showTrackOnHover;
  
  final double? hoverThickness;
  
  final double? thickness;
  
  final Radius? radius;
  
  final bool? interactive;
  
  final ScrollNotificationPredicate? notificationPredicate;
  
  final ScrollbarOrientation? scrollbarOrientation;

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoScrollbar(
        thumbVisibility: thumbVisibility ?? false,
        thickness: thickness ?? CupertinoScrollbar.defaultThickness,
        thicknessWhileDragging: thickness ?? CupertinoScrollbar.defaultThicknessWhileDragging,
        radius: radius ?? CupertinoScrollbar.defaultRadius,
        radiusWhileDragging: radius ?? CupertinoScrollbar.defaultRadiusWhileDragging,
        controller: controller,
        notificationPredicate: notificationPredicate,
        scrollbarOrientation: scrollbarOrientation,
        child: child,
      );
    }
    return _MaterialCustomPaddingScrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      trackVisibility: trackVisibility,
      showTrackOnHover: showTrackOnHover,
      hoverThickness: hoverThickness,
      thickness: thickness,
      radius: radius,
      notificationPredicate: notificationPredicate,
      interactive: interactive,
      scrollbarOrientation: scrollbarOrientation,
      child: child,
      padding: padding,
    );
  }
}

class _MaterialCustomPaddingScrollbar extends CustomPaddingRawScrollbar {
  const _MaterialCustomPaddingScrollbar({
    Key? key,
    required Widget child,
    ScrollController? controller,
    bool? thumbVisibility,
    this.trackVisibility,
    this.showTrackOnHover,
    this.hoverThickness,
    double? thickness,
    Radius? radius,
    ScrollNotificationPredicate? notificationPredicate,
    bool? interactive,
    ScrollbarOrientation? scrollbarOrientation,
    EdgeInsets? padding,
  }) : super(
         key: key,
         child: child,
         controller: controller,
         thumbVisibility: thumbVisibility,
         thickness: thickness,
         radius: radius,
         fadeDuration: _kScrollbarFadeDuration,
         timeToFade: _kScrollbarTimeToFade,
         pressDuration: Duration.zero,
         notificationPredicate: notificationPredicate ?? defaultScrollNotificationPredicate,
         interactive: interactive,
         scrollbarOrientation: scrollbarOrientation,
         padding: padding,
       );

  final bool? trackVisibility;
  final bool? showTrackOnHover;
  final double? hoverThickness;

  @override
  _MaterialScrollbarState createState() => _MaterialScrollbarState();
}

class _MaterialScrollbarState extends CustomPaddingRawScrollbarState<_MaterialCustomPaddingScrollbar> {
  late AnimationController _hoverAnimationController;
  bool _dragIsActive = false;
  bool _hoverIsActive = false;
  late ColorScheme _colorScheme;
  late ScrollbarThemeData _scrollbarTheme;
  // On Android, scrollbars should match native appearance.
  late bool _useAndroidScrollbar;

  @override
  bool get showScrollbar => widget.thumbVisibility ?? false;

  @override
  bool get enableGestures => widget.interactive ?? _scrollbarTheme.interactive ?? !_useAndroidScrollbar;

  bool get _showTrackOnHover => widget.showTrackOnHover ?? false;

  MaterialStateProperty<bool> get _trackVisibility => MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.hovered) && _showTrackOnHover) {
      return true;
    }
    return widget.trackVisibility ?? _scrollbarTheme.trackVisibility?.resolve(states) ?? false;
  });

  Set<MaterialState> get _states => <MaterialState>{
    if (_dragIsActive) MaterialState.dragged,
    if (_hoverIsActive) MaterialState.hovered,
  };

  MaterialStateProperty<Color> get _thumbColor {
    final Color onSurface = _colorScheme.onSurface;
    final Brightness brightness = _colorScheme.brightness;
    late Color dragColor;
    late Color hoverColor;
    late Color idleColor;
    switch (brightness) {
      case Brightness.light:
        dragColor = onSurface.withOpacity(0.6);
        hoverColor = onSurface.withOpacity(0.5);
        idleColor = _useAndroidScrollbar
          ? Theme.of(context).highlightColor.withOpacity(1.0)
          : onSurface.withOpacity(0.1);
        break;
      case Brightness.dark:
        dragColor = onSurface.withOpacity(0.75);
        hoverColor = onSurface.withOpacity(0.65);
        idleColor = _useAndroidScrollbar
          ? Theme.of(context).highlightColor.withOpacity(1.0)
          : onSurface.withOpacity(0.3);
        break;
    }

    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.dragged)) {
        return _scrollbarTheme.thumbColor?.resolve(states) ?? dragColor;
      }

      // If the track is visible, the thumb color hover animation is ignored and
      // changes immediately.
      if (_trackVisibility.resolve(states)) {
        return _scrollbarTheme.thumbColor?.resolve(states) ?? hoverColor;
      }

      return Color.lerp(
        _scrollbarTheme.thumbColor?.resolve(states) ?? idleColor,
        _scrollbarTheme.thumbColor?.resolve(states) ?? hoverColor,
        _hoverAnimationController.value,
      )!;
    });
  }

  MaterialStateProperty<Color> get _trackColor {
    final Color onSurface = _colorScheme.onSurface;
    final Brightness brightness = _colorScheme.brightness;
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (_trackVisibility.resolve(states)) {
        return _scrollbarTheme.trackColor?.resolve(states)
          ?? (brightness == Brightness.light
            ? onSurface.withOpacity(0.03)
            : onSurface.withOpacity(0.05));
      }
      return const Color(0x00000000);
    });
  }

  MaterialStateProperty<Color> get _trackBorderColor {
    final Color onSurface = _colorScheme.onSurface;
    final Brightness brightness = _colorScheme.brightness;
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (_trackVisibility.resolve(states)) {
        return _scrollbarTheme.trackBorderColor?.resolve(states)
          ?? (brightness == Brightness.light
            ? onSurface.withOpacity(0.1)
            : onSurface.withOpacity(0.25));
      }
      return const Color(0x00000000);
    });
  }

  MaterialStateProperty<double> get _thickness {
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.hovered) && _trackVisibility.resolve(states)) {
        return widget.hoverThickness
          ?? _scrollbarTheme.thickness?.resolve(states)
          ?? _kScrollbarThicknessWithTrack;
      }
      // The default scrollbar thickness is smaller on mobile.
      return widget.thickness
        ?? _scrollbarTheme.thickness?.resolve(states)
        ?? (_kScrollbarThickness / (_useAndroidScrollbar ? 2 : 1));
    });
  }

  @override
  void initState() {
    super.initState();
    _hoverAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverAnimationController.addListener(() {
      updateScrollbarPainter();
    });
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _colorScheme = theme.colorScheme;
    _scrollbarTheme = theme.scrollbarTheme;
    switch (theme.platform) {
      case TargetPlatform.android:
        _useAndroidScrollbar = true;
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        _useAndroidScrollbar = false;
        break;
    }
    super.didChangeDependencies();
  }

  @override
  void updateScrollbarPainter() {
    scrollbarPainter
      ..color = _thumbColor.resolve(_states)
      ..trackColor = _trackColor.resolve(_states)
      ..trackBorderColor = _trackBorderColor.resolve(_states)
      ..textDirection = Directionality.of(context)
      ..thickness = _thickness.resolve(_states)
      ..radius = widget.radius ?? _scrollbarTheme.radius ?? (_useAndroidScrollbar ? null : _kScrollbarRadius)
      ..crossAxisMargin = (_scrollbarTheme.crossAxisMargin ?? (_useAndroidScrollbar ? 0.0 : _kScrollbarMargin))
      ..mainAxisMargin = _scrollbarTheme.mainAxisMargin ?? 0.0
      ..minLength = _scrollbarTheme.minThumbLength ?? _kScrollbarMinLength
      ..scrollbarOrientation = widget.scrollbarOrientation
      ..padding = widget.padding ?? const EdgeInsets.all(0)
      ..ignorePointer = !enableGestures;
  }

  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);
    setState(() { _dragIsActive = true; });
  }

  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    super.handleThumbPressEnd(localPosition, velocity);
    setState(() { _dragIsActive = false; });
  }

  @override
  void handleHover(PointerHoverEvent event) {
    super.handleHover(event);
    // Check if the position of the pointer falls over the painted scrollbar
    if (isPointerOverScrollbar(event.position, event.kind, forHover: true)) {
      // Pointer is hovering over the scrollbar
      setState(() { _hoverIsActive = true; });
      _hoverAnimationController.forward();
    } else if (_hoverIsActive) {
      // Pointer was, but is no longer over painted scrollbar.
      setState(() { _hoverIsActive = false; });
      _hoverAnimationController.reverse();
    }
  }

  @override
  void handleHoverExit(PointerExitEvent event) {
    super.handleHoverExit(event);
    setState(() { _hoverIsActive = false; });
    _hoverAnimationController.reverse();
  }

  @override
  void dispose() {
    _hoverAnimationController.dispose();
    super.dispose();
  }
}
