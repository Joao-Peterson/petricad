import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petricad/src/config.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:petricad/widgets/editor_view.dart';
import 'package:provider/provider.dart';

class NodeGraphEditor extends StatefulWidget {
    const NodeGraphEditor({Key? key}) : super(key: key);

    @override
    State<NodeGraphEditor> createState() => _NodeGraphEditorState();
}

class _NodeGraphEditorState extends State<NodeGraphEditor> {

    Offset pos = const Offset(0, 0);
    
    var biController = EditorViewController();

    Widget box = Container(color: Colors.amber, width: 50, height: 50);
    Widget box2 = Container(color: Colors.blue, width: 50, height: 50);

    @override
    Widget build(BuildContext context) {

        final _scrollKey = logicalKeySetFromString(Provider.of<ConfigProvider>(context).getConfig("mouse.editorScrollKey"))?.keys.first;
        final _panKey = mouseButtonFromString(Provider.of<ConfigProvider>(context).getConfig("mouse.editorPanKey")) ?? kMiddleMouseButton;
        final _zoomKey = logicalKeySetFromString(Provider.of<ConfigProvider>(context).getConfig("mouse.editorZoomKey"))?.keys.first ?? LogicalKeyboardKey.control;
        final _zoomSensibility = mathBound((Provider.of<ConfigProvider>(context).getConfig("mouse.editorZoomSensibility") ?? 1.0) as double, 0.1, 100.0);
        final _zoomReversed = Provider.of<ConfigProvider>(context).getConfig("mouse.editorZoomReversed") ?? false;

        return 
            EditorView(
                size: const Size(5000,5000),
                children: [
                    box,
                    box2
                ],
                thumbVisibility: true,
                controller: biController,
                scrollKey: _scrollKey,
                panKey: _panKey,
                zoomKey: _zoomKey,
                zoomSensibility: _zoomSensibility,
                zoomReversed: _zoomReversed
            );
    }
}