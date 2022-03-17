import 'package:flutter/material.dart';

class IconButtonSimple extends StatefulWidget {
    final Icon icon;
    final double? iconSize;
    final String? tooltip;
    final AlignmentGeometry? alignment;
    final EdgeInsetsGeometry? padding;
    final Color? color;
    final Color? hoverColor;
    final Color? focusColor;
    final Color? highlightColor;

    final void Function()? onPressed; 
    
    const IconButtonSimple({ 
        Key? key , 
        required this.icon,
        this.iconSize,
        this.tooltip,
        this.alignment,
        this.padding,
        this.color,
        this.hoverColor,
        this.focusColor,
        this.highlightColor, 
        this.onPressed,
    }) : super(key: key);    

    @override
    State<IconButtonSimple> createState() => _IconButtonSimpleState();
}

class _IconButtonSimpleState extends State<IconButtonSimple> {

    bool _isHighlight = false;
    bool _isPressed = false;
    
    @override
    Widget build(BuildContext context) {
        return 
        GestureDetector(
            child: MouseRegion(
                child: Container(
                    child: Tooltip(
                        child: _iconModify(
                            context,
                            widget.icon, 
                            widget.iconSize,
                            _isHighlight ? 
                            (widget.highlightColor ?? Theme.of(context).highlightColor) : 
                            (widget.color ?? Theme.of(context).colorScheme.onPrimary)
                        ),
                        message: widget.tooltip,
                    ),
                    padding: widget.padding,
                ),
                onEnter: _onEnter,
                onExit: _onExit,
                cursor: SystemMouseCursors.click,
            ),
            onTap: _onTap,
        );
    }

    void _onEnter(PointerEvent? details){
        _isHighlight = true;
        setState(() {});
    }

    void _onExit(PointerEvent? details){
        _isHighlight = _isPressed ? _isPressed : false;
        setState(() {});
    }

    void _onTap(){
        if(_isPressed){
            _isPressed = false;
        }
        else{
            _isPressed = true;
            _isHighlight = true;

            widget.onPressed!();
        }
        setState(() {});
    }

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
}