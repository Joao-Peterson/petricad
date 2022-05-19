import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_single_child_scroll_view.dart';
import 'package:provider/provider.dart';
import 'custom_padding_scrollbar.dart';
import 'dart:math' as math;

// TODO: style class

class EditorViewController{
    late ScrollController xScrollController;
    late ScrollController yScrollController;
    
    EditorViewController(){
        xScrollController = ScrollController();
        yScrollController = ScrollController();
    }

    Offset getScrollOffset(){
        return Offset(xScrollController.position.pixels, yScrollController.position.pixels);
    }

    Size getScrollSize(){
        return Size(xScrollController.position.maxScrollExtent, yScrollController.position.maxScrollExtent);
    }

    void setScrollOffset(Offset offset){

        var xMinScrollExtent = xScrollController.position.minScrollExtent;
        var xMaxScrollExtent = xScrollController.position.maxScrollExtent;
        var yMinScrollExtent = yScrollController.position.minScrollExtent;
        var yMaxScrollExtent = yScrollController.position.maxScrollExtent;

        xScrollController.position.jumpTo(mathBound(offset.dx, xMinScrollExtent, xMaxScrollExtent));
        yScrollController.position.jumpTo(mathBound(offset.dy, yMinScrollExtent, yMaxScrollExtent));
    }
}

class EditorView extends StatefulWidget {

    final List<Widget> children;
    final Size size;
    final bool? thumbVisibility;
    final bool? trackVisibility;
    final double? thickness;
    final Radius? radius;
    final bool? interactive;
    final EditorViewController controller;
    final LogicalKeyboardKey? scrollKey;
    final int? panKey;
    final LogicalKeyboardKey? zoomKey;
    final double? zoomSensibility;
    final bool zoomReversed;

    const EditorView({ 
        required this.size,
        required this.controller,
        required this.children,
        this.thumbVisibility = false,
        this.trackVisibility = false,
        this.thickness = 8,
        this.radius = const Radius.circular(8),
        this.interactive = true,
        this.scrollKey,
        this.panKey = kMiddleMouseButton,
        this.zoomKey = LogicalKeyboardKey.control,
        this.zoomSensibility = 1.0,
        this.zoomReversed = false,
        Key? key 
    }) : super(
        key: key
    );

    @override
    State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {

    bool _scrollKeyState = false;
    bool _scrollPanKeyState = false;
    bool _zoomKeyState = false;

    Offset _viewPortTopLeftToEditorTopLeft = Offset.zero;
    Size _viewPortSize = Size.zero;

    double _scale = 1.0;
    double _prevScale = 1.0;

    List<Offset> _offsets = [];

    @override
    void initState() {
        for(var widget in widget.children){
            _offsets.add(const Offset(0,0));
        }
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        
        FocusNode _editorFocus = FocusNode();
        FocusScope.of(context).requestFocus(_editorFocus);

        return Stack(
            children: [  
                Listener(
                    child: RawKeyboardListener(
                        child: LayoutBuilder(
                            builder: (context, constraints) {
                                _viewPortSize = Size(constraints.maxWidth, constraints.maxHeight);
                                return Scrollbar(
                                    child: CustomSingleChildScrollView(
                                        child: ChangeNotifierProvider(
                                            child: Builder(
                                                builder: (context) {
                                                    return CustomPaddingScrollbar(
                                                        child: CustomSingleChildScrollView(
                                                            child: Container(
                                                                height: widget.size.height*_scale,
                                                                width: widget.size.width*_scale,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width: 1,
                                                                        color: Colors.amber,
                                                                    )
                                                                ),
                                                                child: Stack(
                                                                    children: _buildChildren(widget.children, constraints),
                                                                ),
                                                            ),
                                                            scrollKey: _scrollKeyState,
                                                            controller: widget.controller.xScrollController,
                                                            scrollDirection: Axis.horizontal,
                                                        ),
                                                        thumbVisibility: widget.thumbVisibility,
                                                        trackVisibility: widget.trackVisibility,
                                                        showTrackOnHover: true,
                                                        hoverThickness: 8,
                                                        thickness: widget.thickness,
                                                        radius: widget.radius,
                                                        interactive: widget.interactive,
                                                        padding: EdgeInsets.only(bottom: widget.size.height*_scale - constraints.maxHeight - Provider.of<ScrollController>(context).position.pixels),
                                                        controller: widget.controller.xScrollController,
                                                    );
                                                }
                                            ),
                                            create: (context) {
                                                return widget.controller.yScrollController;
                                            },
                                        ),
                                        scrollKey: _scrollKeyState,
                                        controller: widget.controller.yScrollController,
                                        scrollDirection: Axis.vertical,
                                    ),
                                    controller: widget.controller.yScrollController,

                                    thumbVisibility: widget.thumbVisibility,
                                    trackVisibility: widget.trackVisibility,
                                    thickness: widget.thickness,
                                    radius: widget.radius,
                                    interactive: widget.interactive,
                                );
                            },
                        ),
                        focusNode: _editorFocus,
                        onKey: _handleKeyPress,
                    ),
                    onPointerSignal: _handleScroll,
                    onPointerDown: _handlePointerDown,
                    onPointerMove: _handlePointerMove,
                    onPointerUp: _handlePointerUp,
                ),
                Positioned(
                    bottom: 30,
                    right: 30,
                    child: IconButton(
                        icon: const Icon(
                            Icons.other_houses_rounded,
                            size: 40,
                            color: Colors.white,
                        ),
                        onPressed: (){
                            _scale = 1.0;
                            widget.controller.setScrollOffset(Offset.zero);
                            setState(() {});
                        }, 
                    ),
                )
            ]
        );
    }

    List<Widget> _buildChildren(List<Widget> children, BoxConstraints viewPortConstrains){
        List<Widget> list = [];

        for(var child in children){
            list.add(
                Positioned(
                    top: _offsets[children.indexOf(child)].dy * _scale,
                    left: _offsets[children.indexOf(child)].dx * _scale,
                    child: Transform.scale(
                        scale: _scale,
                        alignment: AlignmentDirectional.topStart,
                        child: Draggable(
                            maxSimultaneousDrags: 1,
                            childWhenDragging: Opacity(
                                opacity: .6,
                                child: child,
                            ),
                            // needed to tranform feed back because it would not do it itself inside the tranformed sizedbox 
                            feedback: Transform.scale(
                                alignment: AlignmentDirectional.topStart,
                                scale: _scale,
                                child: child
                            ),
                            onDragEnd: (drag) {
                                _offsets[children.indexOf(child)] = _correctOffset(drag.offset, viewPortConstrains, const Size(50,50));
                                setState(() {});
                            },
                            child: child,
                        ),
                    ),
                ),
            );
        }

        return list;
    }

    Offset _correctOffset(Offset dragViewPortOffset, BoxConstraints viewPortConstrains, Size widgetSize){
        var scrollOffset = widget.controller.getScrollOffset();

        // correct drag pointer so the offset is relative to the top left of the widget
        var dx = (dragViewPortOffset.dx) - widgetSize.width;
        var dy = (dragViewPortOffset.dy) - (widgetSize.height/2);

        dx /= _scale;
        dy /= _scale;

        dx += scrollOffset.dx;
        dy += scrollOffset.dy;
        
        return Offset(dx,dy);
    }

    void _handleScroll(PointerSignalEvent event){
        if(event is PointerScrollEvent){
            _handleZoom(event.scrollDelta.dy/1000);
        }
    }

    void _handleZoom(double scale){
        if(widget.zoomKey == null || (widget.zoomKey != null && _zoomKeyState)){

            var newScale = mathBound(_scale + (widget.zoomReversed ? -1 : 1) * scale*widget.zoomSensibility!, 0.1, 10.0);

            // _viewPortTopLeftToEditorTopLeft = widget.controller.getScrollOffset() * _scale;
            // var mousePos = event.localPosition * _scale;

            // widget.controller.setScrollOffset(
            //     (_viewPortTopLeftToEditorTopLeft*newScale) + (Offset(_viewPortSize.width,_viewPortSize.height)/2*(newScale-1))
            // );

            _prevScale = _scale;
            _scale = newScale;

            setState(() {});
        }
    }

    void _handlePointerMove(PointerMoveEvent event){
        if(_scrollPanKeyState){
            widget.controller.setScrollOffset(widget.controller.getScrollOffset() - event.delta);
            setState(() {});
        }
    }

    void _handlePointerDown(PointerDownEvent event){
        if((event.buttons & widget.panKey!) != 0){
            _scrollPanKeyState = true;
            setState(() {});
        }
    }

    void _handlePointerUp(PointerUpEvent event){
        if((event.buttons & widget.panKey!) == 0){
            _scrollPanKeyState = false;
            setState(() {});
        }
    }

    void _handleKeyPress(RawKeyEvent event){
        if(LogicalKeyboardKey.collapseSynonyms({event.logicalKey}).first == widget.scrollKey){
            if(event is RawKeyDownEvent){
                _scrollKeyState = true;
                setState(() {});
            }
            else if(event is RawKeyUpEvent){
                _scrollKeyState = false;
                setState(() {});
            }
        }
        else if(LogicalKeyboardKey.collapseSynonyms({event.logicalKey}).first == widget.zoomKey){
            if(event is RawKeyDownEvent){
                _zoomKeyState = true;
                setState(() {});
            }
            else if(event is RawKeyUpEvent){
                _zoomKeyState = false;
                setState(() {});
            }
        }
    }
}

// keep a double inside a min and max limit
double mathBound(double value, double min, double max){
    return math.max(math.min(value, max), min);
}
