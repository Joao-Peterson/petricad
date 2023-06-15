import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petricad/src/config.dart';
import 'package:petricad/src/petrinet.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:provider/provider.dart';
import 'place_widget.dart';
import 'transition_widget.dart';

enum PetrinetEditorInserts{
    place,
    transition,
    arcWeighted,
    arcNot,
    arcReset
}

// editor place intent
class EditorPlaceIntent extends Intent{
    final PetrinetEditorInserts insert;
    final Offset pos;
    const EditorPlaceIntent(this.insert, this.pos);
}

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

    var _lastMousePosOnKeypress = const Offset(0, 0);
    RenderBox? _editorRenderBox;

    @override
    void initState() {
        _petrinet = Petrinet(); 
        super.initState();
    }

    @override
    Widget build(BuildContext context){

        return Shortcuts(
            debugLabel: "petrinet_editor_shortcuts",
            shortcuts: {
                singleActivatorFromString("p")! : EditorPlaceIntent(PetrinetEditorInserts.place, _editorRenderBox?.globalToLocal(_lastMousePosOnKeypress) ?? const Offset(0, 0)),
                singleActivatorFromString("t")! : EditorPlaceIntent(PetrinetEditorInserts.transition, _editorRenderBox?.globalToLocal(_lastMousePosOnKeypress) ?? const Offset(0, 0)),
                singleActivatorFromString("a")! : EditorPlaceIntent(PetrinetEditorInserts.arcWeighted, _editorRenderBox?.globalToLocal(_lastMousePosOnKeypress) ?? const Offset(0, 0)),
                singleActivatorFromString("n")! : EditorPlaceIntent(PetrinetEditorInserts.arcNot, _editorRenderBox?.globalToLocal(_lastMousePosOnKeypress) ?? const Offset(0, 0)),
                singleActivatorFromString("r")! : EditorPlaceIntent(PetrinetEditorInserts.arcReset, _editorRenderBox?.globalToLocal(_lastMousePosOnKeypress) ?? const Offset(0, 0)),
            },
            child: Actions(
                actions: {
                    EditorPlaceIntent: CallbackAction<EditorPlaceIntent>(onInvoke: (intent) {
                        switch (intent.insert){
                            case PetrinetEditorInserts.place:
                                _petrinet.addPlace(dx: intent.pos.dx, dy: intent.pos.dy);
                            break;
                            case PetrinetEditorInserts.transition:
                                _petrinet.addTransition(dx: intent.pos.dx, dy: intent.pos.dy);
                            break;
                            // case PetrinetEditorInserts.arcWeighted:
                            //     _petrinet.addArcWeighted();
                            // break;
                            // case PetrinetEditorInserts.arcNot:
                            //     _petrinet.addArcWeighted();
                            // break;
                            // case PetrinetEditorInserts.arcReset:
                            
                            default:
                            break;
                        }

                        setState(() {});
                    },)
                },
                child: Focus(
                    debugLabel: "petrinet_editor_focus",
                    child: Builder(
                        builder: (context) {
                            FocusNode editorFocus = Focus.of(context); 
                            
                            return SizedBox(
                                child: MouseRegion(
                                    onEnter: (event) {
                                        editorFocus.requestFocus();
                                        //   print(debugDescribeFocusTree());
                                    },
                                    onExit: (event) {
                                        if(editorFocus.hasFocus){
                                            editorFocus.unfocus();
                                        }
                                        //   print(debugDescribeFocusTree());
                                    },
                                    onHover: (event) {
                                        _lastMousePosOnKeypress = event.position;
                                        setState(() {});
                                    },
                                    child: Stack(children: [
                                        InteractiveViewer(
                                            child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                    var scale = _transformationController.value.storage[0];
                                                    var widgets = _buildNodes(scale);
                                                    _editorRenderBox = context.findRenderObject() as RenderBox?;
                                                                    
                                                    //   print(debugDescribeFocusTree());
                                                    
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
                                                            final Offset? localOffset = _editorRenderBox?.globalToLocal(details.offset);
                                                            if(localOffset == null) return;
                                                            
                                                            setState(() {
                                                                details.data.offsetX = localOffset.dx;
                                                                details.data.offsetY = localOffset.dy;
                                                            });
                                                        },
                                                    );
                                                }
                                            ),
                                            onInteractionStart: (details) {
                                                setState(() {});
                                            },
                                            onInteractionEnd: (details) {
                                                setState(() {});
                                            },
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
                                    ]),
                                ),
                            );
                        }
                    ),
                )
            ),
        );
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
            var widget = TransitionWidget(transition.name, transition.inputEvt?.toString() ?? "", transition.delay);
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