import 'package:flutter/material.dart';

class IconButtonSimple extends StatefulWidget {
    final Icon icon;

    /// if true the button shall be highlighted
    final bool pressed;

    final double? iconSize;
    final String? tooltip;
    /// little left marker width, displayed when the button is pressed
    final double selectedMarkerWidth; 
    final AlignmentGeometry? alignment;
    final EdgeInsetsGeometry padding;
    /// button color 
    final Color? color;
    /// button color when hovered or pressed
    final Color? highlightColor;

    /// called when the button is pressed
    final void Function()? onPressed; 

    const IconButtonSimple({ 
        Key? key, 
        required this.icon,
        this.pressed = false,
        this.iconSize,
        this.tooltip,
        this.selectedMarkerWidth = 3,
        this.alignment,
        this.padding = const EdgeInsets.fromLTRB(0, 15, 0, 15),
        this.color,
        this.highlightColor, 
        this.onPressed,
    }) : super(key: key);    

  @override
  State<IconButtonSimple> createState() => _IconButtonSimpleState();
}

class _IconButtonSimpleState extends State<IconButtonSimple> {

    bool _hovered = false;
    
    @override
    Widget build(BuildContext context) {
        return 
        GestureDetector(
            child: MouseRegion(
                child: Container(
                    width: double.infinity,
                    child: Tooltip(
                        child: _iconModify(
                            context,
                            widget.icon, 
                            widget.iconSize,
                            _colorHighlight(context, widget.pressed | _hovered),
                        ),
                        message: widget.tooltip,
                    ),
                    padding: widget.padding,
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: _colorMarker(context, widget.pressed),
                                width: widget.selectedMarkerWidth,
                            ),
                        )
                    ),
                ),
                onEnter: _onEnter,
                onExit: _onExit,
                cursor: SystemMouseCursors.click,
            ),
            onTap: _onTap,
        );
    }

    /// Takes a base icon and return a new one based on size eand color, used for recolor
    /// 
    /// [context]   Buildcontext
    /// [icon]      Reference Icon object
    /// [iconSize]  New Icon size
    /// [colo]      New icon Colro
    /// Returns the new Icon
    Icon _iconModify(
        BuildContext context, 
        Icon icon, 
        double? iconSize,
        Color? color,
    ){
        return Icon(
            icon.icon,
            size: iconSize,
            semanticLabel: icon.semanticLabel,
            textDirection:  icon.textDirection, 

            color: color ?? Theme.of(context).colorScheme.onPrimary,
        );
    }

    /// Returns a highlight color based on a boolean
    /// 
    /// [context]   Buildcontext
    /// [show]      Boolean, if false return base color, if true return highlight color
    /// Returns the base or highlight color
    Color _colorHighlight(BuildContext context, bool show){
        if(show){
            return widget.highlightColor ?? Theme.of(context).highlightColor;
        }
        else{
            return widget.color ?? Theme.of(context).colorScheme.onPrimary;
        }
    }

    /// Returns a marker color based on a boolean
    /// 
    /// [context]   Buildcontext
    /// [show]      Boolean, if false return tranparent color, if true return highlight color
    /// Returns the base or highlight color
    Color _colorMarker(BuildContext context, bool show){
        if(show){
            return Theme.of(context).highlightColor;
        }
        else{
            return Colors.transparent;
        }

    }

    /// called when the mouse cursor enters the button region
    void _onEnter(PointerEvent? details){
        _hovered = true;
        setState(() {});
    }

    /// called when the mouse cursor exits the button region
    void _onExit(PointerEvent? details){
        _hovered = widget.pressed || false;
        setState(() {});
    }

    /// called when the mouse cursor click the button
    void _onTap(){
        widget.onPressed!();
    }
}