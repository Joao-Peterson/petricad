import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:petricad/widgets/bidirectional_singlechild_scrollview.dart';
import 'package:provider/provider.dart';

class NodeGraphEditor extends StatefulWidget {
    const NodeGraphEditor({Key? key}) : super(key: key);

    @override
    State<NodeGraphEditor> createState() => _NodeGraphEditorState();
}

class _NodeGraphEditorState extends State<NodeGraphEditor> {

    Widget box = Container(color: Colors.amber, width: 50, height: 50);
    Offset pos = Offset(1000, 500);
    final ScrollController _xScrollController = ScrollController(); 
    final ScrollController _yScrollController = ScrollController(); 

    @override
    Widget build(BuildContext context) {
        return BidirectionalSingleChildScrollView(
            size: const Size(5000,5000),
            child: GestureDetector(
                child: Stack(
                    children: [
                        // Positioned.fill(child: Container(color: Colors.black.withOpacity(0.4))),
                        Positioned(
                            top: pos.dy,
                            left: pos.dx,
                            child: Draggable(
                                maxSimultaneousDrags: 1,
                                childWhenDragging: Opacity(
                                    opacity: .6,
                                    child: box,
                                ),
                                feedback: box,
                                onDragEnd: (drag) {
                                    pos = _correctOffset(drag.offset, const Size(50, 50));
                                    setState(() {});
                                },
                                child: box,
                            ),
                        ),
                    ],
                )
            ),
        );
    }

    Offset _correctOffset(Offset offset, Size size){
        return Offset(offset.dx - size.width, offset.dy - (size.height/2));
    }
}