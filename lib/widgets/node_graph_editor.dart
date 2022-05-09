import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petricad/src/config.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:petricad/widgets/bidirectional_singlechild_scrollview.dart';
import 'package:provider/provider.dart';

class NodeGraphEditor extends StatefulWidget {
    const NodeGraphEditor({Key? key}) : super(key: key);

    @override
    State<NodeGraphEditor> createState() => _NodeGraphEditorState();
}

class _NodeGraphEditorState extends State<NodeGraphEditor> {

    Offset pos = const Offset(200, 200);
    double prevScale = 1.0;
    double scale = 1.0;
    
    var biController = BidirectionalSingleChildScrollViewController();

    Widget box = Container(color: Colors.amber, width: 50, height: 50);

    @override
    Widget build(BuildContext context) {

        final _scrollKey = logicalKeySetFromString(Provider.of<ConfigProvider>(context).getConfig("shortcuts.editorScrollKey"))?.keys.first;
        
        return 
            GestureDetector(
                child: BidirectionalSingleChildScrollView(
                    controller: biController,
                    size: const Size(5000,5000),
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
                    ),
                    scrollKey: _scrollKey
                ),
                onScaleUpdate: (zoom){
                    scale = prevScale * zoom.scale;
                    setState(() {});
                },
                onScaleEnd: (zoom){
                    prevScale = scale;
                    setState(() {});
                },
            );
    }

    Offset _correctOffset(Offset offset, Size size){
        var viewPortOffset = biController.getViewportOffset();
        return Offset(offset.dx - size.width + viewPortOffset.dx, offset.dy - (size.height/2) + viewPortOffset.dy);
    }
}