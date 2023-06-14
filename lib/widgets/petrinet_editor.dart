import 'package:flutter/material.dart';
import 'package:petricad/src/config.dart';
import 'package:petricad/src/petrinet.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:provider/provider.dart';
import 'place_widget.dart';
import 'transition_widget.dart';

class Node{
    Offset offset;
    Widget widget;

    Node(
        this.offset,
        this.widget,
    );
}

class PetrinetEditor extends StatefulWidget {    
    const PetrinetEditor({
        Key? key
    }) : super(key: key);

    @override
    State<PetrinetEditor> createState() => _PetrinetEditorState();
}

class _PetrinetEditorState extends State<PetrinetEditor> {

    // final _scrollKey = logicalKeySetFromString(Provider.of<ConfigProvider>(context).getConfig("mouse.editorScrollKey"))?.keys.first;
    // final _panKey = mouseButtonFromString(Provider.of<ConfigProvider>(context).getConfig("mouse.editorPanKey")) ?? kMiddleMouseButton;
    // final _zoomKey = logicalKeySetFromString(Provider.of<ConfigProvider>(context).getConfig("mouse.editorZoomKey"))?.keys.first ?? LogicalKeyboardKey.control;
    // final _zoomSensibility = mathBound((Provider.of<ConfigProvider>(context).getConfig("mouse.editorZoomSensibility") ?? 1.0) as double, 0.1, 100.0);
    // final _zoomSensibility = 1.0;
    // final _zoomReversed = Provider.of<ConfigProvider>(context).getConfig("mouse.editorZoomReversed") ?? false;

    final _size = const Size(5000, 5000);
    final _transformationController = TransformationController();
    late Petrinet _petrinet;

    @override
    void initState() {
        _petrinet = Petrinet(); 
        _petrinet.addPlace();
        _petrinet.addTransition();
        super.initState();
    }

    @override
    Widget build(BuildContext context){
        FocusNode _editorFocus = FocusNode();
        FocusScope.of(context).requestFocus(_editorFocus);

        return Stack(children: [
            Listener(child: RawKeyboardListener(
                child: InteractiveViewer(
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                            var scale = _transformationController.value.storage[0];
                            var widgets = _buildNodes(scale);
                            
                            return DragTarget<PetrinetNode>(
                                builder: (context, candidateData, rejectedData) {
                                    return Container(
                                        height: _size.height,
                                        width: _size.width,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1 / scale,
                                                color: Colors.amber,
                                            )
                                        ),
                                        child: Stack(children: widgets),
                                    );
                                },
                                onAcceptWithDetails: (details) {
                                    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                                    final Offset? localOffset = renderBox?.globalToLocal(details.offset);
                                    if(localOffset == null) return;
                                    
                                    setState(() {
                                        details.data.offsetX = localOffset.dx;
                                        details.data.offsetY = localOffset.dy;
                                    });
                                },
                            );
                        }
                    ),
                    transformationController: _transformationController,
                    boundaryMargin: EdgeInsets.all(_size.longestSide),
                    constrained: false,
                    clipBehavior: Clip.hardEdge,
                    interactionEndFrictionCoefficient: double.minPositive,
                    panEnabled: true,   
                    trackpadScrollCausesScale: false,
                    minScale: 1/20,
                    maxScale: 3,
                ), 
                focusNode: _editorFocus,
            ),),

            Align(
                alignment: Alignment.bottomRight,
                child: Row(
                    children: [
                        IconButton(icon: const Icon(Icons.home), onPressed: () {
                            _transformationController.value = Matrix4.identity();
                        },),
                    ],
                    mainAxisAlignment: MainAxisAlignment.end
                ),
            )
        ]);    
    }

    List<Widget> _buildNodes(double scale){
        List<Widget> list = [];
        List<Widget> widgets = [];
        List<PetrinetNode> nodes = [];

        // places
        for(var place in _petrinet.places){
            var widget = PlaceWidget(place.name, place.init);
            list.add(widget);
            nodes.add(place);
        }

        // transitions
        for(var transition in _petrinet.transitions){
            var widget = TransitionWidget(transition.name, "${transition.inputEvt?.toString() ?? ''}", transition.delay);
            list.add(widget);
            nodes.add(transition);
        }
        
        for(var i = 0; i < list.length; i++){
            widgets.add(
                Positioned(
                    top: nodes[i].offsetY,
                    left: nodes[i].offsetX,
                    child: Draggable<PetrinetNode>(
                        maxSimultaneousDrags: 1,
                        childWhenDragging: Opacity(
                            opacity: .6,
                            child: list[i],
                        ),
                        dragAnchorStrategy: pointerDragAnchorStrategy, 
                        // needed to tranform feed back because it would not do it itself inside the tranformed sizedbox 
                        feedback: Transform.scale(scale: scale, child: list[i], alignment: Alignment.topLeft),
                        data: nodes[i],
                        child: list[i],
                    ),
                )
            );
        }

        return widgets;
    }
}