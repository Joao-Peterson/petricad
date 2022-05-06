import 'package:flutter/material.dart';

class NodeGraphEditor extends StatefulWidget {
    const NodeGraphEditor({Key? key}) : super(key: key);

    @override
    State<NodeGraphEditor> createState() => _NodeGraphEditorState();
}

class _NodeGraphEditorState extends State<NodeGraphEditor> {

    Widget box = Container(color: Colors.amber, width: 50, height: 50);
    Offset pos = Offset(1000, 500);

    @override
    Widget build(BuildContext context) {
        return LayoutBuilder(
            builder: (context, constraints) {
                return InteractiveViewer(
                    
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
                                            pos = _correctOffset(drag.offset, Size(50, 50));
                                            setState(() {});
                                        },
                                        child: box,
                                    ),
                                ),
                            ],
                        )
                    )
                );
            },
        );
    }

    Offset _correctOffset(Offset offset, Size size){
        return Offset(offset.dx - size.width, offset.dy - (size.height/2));
    }
}