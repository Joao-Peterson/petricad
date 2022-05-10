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

    Offset getViewportOffset(){
        return Offset(xScrollController.position.pixels, yScrollController.position.pixels);
    }
}

class EditorView extends StatefulWidget {

    final List<Widget> children;
    final Size size;
    final bool? isAlwaysShown;
    final bool? trackVisibility;
    final bool? showTrackOnHover;
    final double? hoverThickness;
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
        this.isAlwaysShown = false,
        this.trackVisibility = false,
        this.showTrackOnHover = true,
        this.hoverThickness = 8,
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
    double _scale = 1.0;
    Offset _pointerPositionOnScrollStart = Offset.zero;

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
                                                                        width: 1 * 1/_scale,
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
                                                        isAlwaysShown: widget.isAlwaysShown,
                                                        trackVisibility: widget.trackVisibility,
                                                        showTrackOnHover: widget.showTrackOnHover,
                                                        hoverThickness: widget.hoverThickness,
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
                                    isAlwaysShown: widget.isAlwaysShown,
                                    trackVisibility: widget.trackVisibility,
                                    showTrackOnHover: widget.showTrackOnHover,
                                    hoverThickness: widget.hoverThickness,
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
                            widget.controller.xScrollController.position.jumpTo(0.0);
                            widget.controller.yScrollController.position.jumpTo(0.0);
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

            var transChild = Transform(
                transform: Matrix4(
                    _scale  , 0     , 0     , 0,
                    0       , _scale, 0     , 0,
                    0       , 0     , 0     , 0,
                    0       , 0     , 0     , 1
                ),
                child: child,
            );

            list.add(
                Positioned(
                    top: _offsets[children.indexOf(child)].dy,
                    left: _offsets[children.indexOf(child)].dx,
                    child: Draggable(
                        maxSimultaneousDrags: 1,
                        childWhenDragging: Opacity(
                            opacity: .6,
                            child: transChild,
                        ),
                        // needed to tranform feed back because it would not do it itself inside the tranformed sizedbox 
                        feedback: Transform.scale(
                            scale: _scale,
                            child: transChild
                        ),
                        onDragEnd: (drag) {
                            _offsets[children.indexOf(child)] = _correctOffset(drag.offset, viewPortConstrains, const Size(50,50));
                            setState(() {});
                        },
                        child: transChild,
                    ),
                ),
            );
        }

        return list;
    }

    Offset _correctOffset(Offset dragViewPortOffset, BoxConstraints viewPortConstrains, Size widgetSize){
        var viewPortOffset = widget.controller.getViewportOffset();

        // correct drag pointer so the offset is relative to the top left of the widget
        var dx = (dragViewPortOffset.dx) - widgetSize.width;
        var dy = (dragViewPortOffset.dy) - (widgetSize.height/2);

        dx += viewPortOffset.dx;
        dy += viewPortOffset.dy;
        
        return Offset(dx,dy);
    }

    // keep a double inside a min and max limit
    double _mathBound(double value, double min, double max){
        return math.max(math.min(value, max), min);
    }

    void _handleScroll(PointerSignalEvent event){
        // TODO: add min and max width and height for scaled area, should be small than layoutBuilder constrain area, logic breaks when full zoom out
        if(widget.zoomKey == null || (widget.zoomKey != null && _zoomKeyState)){
            if(event is PointerScrollEvent){
                var newScale = _mathBound(_scale + (widget.zoomReversed ? -1 : 1) * event.scrollDelta.dy/1000*widget.zoomSensibility!, 0.1, 10.0);
                _pointerPositionOnScrollStart = event.localPosition;

                var xScroll = widget.controller.xScrollController.position.pixels;
                var yScroll = widget.controller.yScrollController.position.pixels;

                if(newScale < _scale){
                    xScroll /= _scale;
                    yScroll /= _scale;
                    xScroll += event.localPosition.dx/_scale;
                    yScroll += event.localPosition.dy/_scale;
                }
                else{
                    xScroll *= _scale;
                    yScroll *= _scale;
                    xScroll -= event.localPosition.dx*_scale;
                    yScroll -= event.localPosition.dy*_scale;
                }

                var xMinScrollExtent = widget.controller.xScrollController.position.minScrollExtent;
                var xMaxScrollExtent = widget.controller.xScrollController.position.maxScrollExtent;
                var yMinScrollExtent = widget.controller.yScrollController.position.minScrollExtent;
                var yMaxScrollExtent = widget.controller.yScrollController.position.maxScrollExtent;

                widget.controller.xScrollController.position.jumpTo(_mathBound(xScroll, xMinScrollExtent, xMaxScrollExtent));
                widget.controller.yScrollController.position.jumpTo(_mathBound(yScroll, yMinScrollExtent, yMaxScrollExtent));
                _scale = newScale;
                setState(() {});
            }
        }
    }

    void _handlePointerMove(PointerMoveEvent event){
        if(_scrollPanKeyState){
            widget.controller.xScrollController.position.jumpTo(widget.controller.xScrollController.position.pixels - event.delta.dx);
            widget.controller.yScrollController.position.jumpTo(widget.controller.yScrollController.position.pixels - event.delta.dy);
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
