import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_single_child_scroll_view.dart';
import 'package:provider/provider.dart';
import 'custom_padding_scrollbar.dart';

class BidirectionalSingleChildScrollViewController{
    late ScrollController xScrollController;
    late ScrollController yScrollController;
    
    BidirectionalSingleChildScrollViewController(){
        xScrollController = ScrollController();
        yScrollController = ScrollController();
    }

    Offset getViewportOffset(){
        return Offset(xScrollController.position.pixels, yScrollController.position.pixels);
    }
}

class BidirectionalSingleChildScrollView extends StatefulWidget {

    final Widget child;
    final Size size;
    final bool? isAlwaysShown;
    final bool? trackVisibility;
    final bool? showTrackOnHover;
    final double? hoverThickness;
    final double? thickness;
    final Radius? radius;
    final bool? interactive;
    final BidirectionalSingleChildScrollViewController controller;
    final LogicalKeyboardKey? scrollKey;

    const BidirectionalSingleChildScrollView({ 
        required this.child,
        required this.size,
        required this.controller,
        this.isAlwaysShown = false,
        this.trackVisibility = false,
        this.showTrackOnHover = true,
        this.hoverThickness = 8,
        this.thickness = 8,
        this.radius = const Radius.circular(8),
        this.interactive = true,
        this.scrollKey,
        Key? key 
    }) : super(
        key: key
    );

    @override
    State<BidirectionalSingleChildScrollView> createState() => _BidirectionalSingleChildScrollViewState();
}

class _BidirectionalSingleChildScrollViewState extends State<BidirectionalSingleChildScrollView> {

    bool _scrollKeyState = false;

    @override
    Widget build(BuildContext context) {
        
        FocusNode _editorFocus = FocusNode();
        FocusScope.of(context).requestFocus(_editorFocus);

        return RawKeyboardListener(
            focusNode: _editorFocus,
            onKey: (event){
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
            },
            child: LayoutBuilder(
                builder: (context, constraints) {
                    return Scrollbar(
                        controller: widget.controller.yScrollController,
                        isAlwaysShown: widget.isAlwaysShown,
                        trackVisibility: widget.trackVisibility,
                        showTrackOnHover: widget.showTrackOnHover,
                        hoverThickness: widget.hoverThickness,
                        thickness: widget.thickness,
                        radius: widget.radius,
                        interactive: widget.interactive,
            
                        child: CustomSingleChildScrollView(
                            scrollKey: _scrollKeyState,
                            controller: widget.controller.yScrollController,
                            scrollDirection: Axis.vertical,
            
                            child: ChangeNotifierProvider(
                                create: (context) {
                                    return widget.controller.yScrollController;
                                },
                                child: Builder(
                                    builder: (context) {
                                        return CustomPaddingScrollbar(
                                            isAlwaysShown: widget.isAlwaysShown,
                                            trackVisibility: widget.trackVisibility,
                                            showTrackOnHover: widget.showTrackOnHover,
                                            hoverThickness: widget.hoverThickness,
                                            thickness: widget.thickness,
                                            radius: widget.radius,
                                            interactive: widget.interactive,
                                            padding: EdgeInsets.only(bottom: widget.size.height - constraints.maxHeight - Provider.of<ScrollController>(context).position.pixels),
                                            controller: widget.controller.xScrollController,
                                            child: CustomSingleChildScrollView(
                                                scrollKey: _scrollKeyState,
                                                controller: widget.controller.xScrollController,
                                                scrollDirection: Axis.horizontal,
                                                child: SizedBox(
                                                    height: widget.size.height,
                                                    width: widget.size.width,
                                                    child: widget.child
                                                ),
                                            ),
                                        );
                                    }
                                ),
                            ),
                        ),
                    );
                },
            ),
        );
    }
}
