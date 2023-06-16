import 'package:flutter/material.dart';
// import 'package:petricad/src/config.dart';
// import 'package:provider/provider.dart';
import 'package:petricad/src/petrinet.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:petricad/widgets/arc_widget.dart';
import 'place_widget.dart';
import 'transition_widget.dart';

enum PetrinetEditorActions{
    placingArc
}

enum PetrinetEditorInserts{
    place,
    transition,
}

// editor place intent
class EditorPlaceIntent extends Intent{
    final PetrinetEditorInserts insert;
    final Offset pos;
    const EditorPlaceIntent(this.insert, this.pos);
}

// arc place intent
class EditorInsertArcIntent extends Intent{
    final PetrinetArcType type;
    const EditorInsertArcIntent(this.type);
}

// editor reset actions intent
class EditorResetActionsIntent extends Intent{
    const EditorResetActionsIntent();
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

    // data
    final _size = const Size(5000, 5000);
    final _transformationController = TransformationController();
    late Petrinet _petrinet;

    // mouse track
    var _lastMousePosOnKeypress = const Offset(0, 0);
    RenderBox? _editorRenderBox;

    // actions
    String? _editorMessage;
    PetrinetEditorActions? _executingAction;

    // arc placing
    PetrinetArcType? _arcType;
    PetrinetNode? _arcAnchoredTo;

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
                singleActivatorFromString("a")! : const EditorInsertArcIntent(PetrinetArcType.weighted),
                singleActivatorFromString("n")! : const EditorInsertArcIntent(PetrinetArcType.negated),
                singleActivatorFromString("r")! : const EditorInsertArcIntent(PetrinetArcType.reset),
                singleActivatorFromString("esc")! : const EditorResetActionsIntent(),
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
                        }

                        setState(() {});
                        return null;
                    },),
                    EditorInsertArcIntent: CallbackAction<EditorInsertArcIntent>(onInvoke: (intent) {
                        _arcType = intent.type;
                        _executingAction = PetrinetEditorActions.placingArc;
                        _editorMessage = "Inserting arc ${intent.type.name}";
                        return null;
                    },),
                    EditorResetActionsIntent: CallbackAction<EditorResetActionsIntent>(onInvoke: (intent) {
                        _editorMessage = null;
                        _executingAction = null;
                        _arcAnchoredTo = null;
                        _arcType = null;
                        return null;
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
                        
                                        // widgets tray overlay
                                        Align(
                                            alignment: Alignment.bottomRight,
                                            child: Row(
                                                children: [
                                                    Text(
                                                        _editorMessage ?? "",
                                                        style: const TextStyle(color: Colors.amber),
                                                    ),
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

        Size nodeSize = const Size(100, 200);

        // arcs
        for(var arc in _petrinet.arcs){
            Offset from, to;
            var centerOffset = Offset(nodeSize.width / 2, nodeSize.height / 2);

            from = centerOffset + Offset(_petrinet.places[arc.place].offsetX, _petrinet.places[arc.place].offsetY);
            to = centerOffset + Offset(_petrinet.transitions[arc.transition].offsetX, _petrinet.transitions[arc.transition].offsetY);
            
            if(arc.placeToTransition != null && !(arc.placeToTransition!)){         // if inverted
                var swap = from;
                from = to;
                to = swap;
            }
            
            widgets.add(
                Positioned(
                    top: 0,
                    left: 0,
                    child: ArcWidget(
                        type: arc.type, 
                        from: from, 
                        to: to,
                        thickness: 5,
                        offset: nodeSize.shortestSide / 2 + 25,
                    ),
                )
            );
        }

        // places
        for(var place in _petrinet.places){
            var widget = PlaceWidget(place.name, nodeSize, tokens: place.init);
            list.add(widget);
            nodes.add(place);
        }

        // transitions
        for(var i = 0; i < _petrinet.transitions.length; i++){
            String? inputEvt;
            int? inputindex = _petrinet.transitions[i].input;
            
            if(inputindex != null){
                switch(_petrinet.transitions[i].inputEvt){
                    case PetrinetInputEvt.pos:
                        inputEvt = "${_petrinet.inputsNames[inputindex]} ↿";
                        break;
                    case PetrinetInputEvt.neg:
                        inputEvt = "${_petrinet.inputsNames[inputindex]} ⇂";
                        break;
                    case PetrinetInputEvt.any:
                        // inputEvt = "${_petrinet.inputsNames[inputindex]} ⥮";
                        inputEvt = "${_petrinet.inputsNames[inputindex]} ↿ ⇂";
                        break;

                    default:
                    break;
                }
            }
            
            var widget = TransitionWidget(
                _petrinet.transitions[i].name, 
                nodeSize, 
                inputEvt: _petrinet.transitions[i].inputEvt?.name ?? "", 
                delay: _petrinet.transitions[i].delay
            );
            list.add(widget);
            nodes.add(_petrinet.transitions[i]);
        }
        
        for(var i = 0; i < list.length; i++){
            widgets.add(
                Positioned(
                    top: nodes[i].offsetY,
                    left: nodes[i].offsetX,
                    child: Draggable<PetrinetNode>(
                        hitTestBehavior: HitTestBehavior.opaque,
                        maxSimultaneousDrags: 1,
                        childWhenDragging: Opacity(
                            opacity: .6,
                            child: list[i],
                        ),
                        dragAnchorStrategy: pointerDragAnchorStrategy, 
                        // needed to tranform feed back because it would not do it itself inside the tranformed sizedbox 
                        feedback: Transform.scale(scale: scale, child: list[i], alignment: Alignment.topLeft),
                        data: nodes[i],
                        child: Listener(
                            child: list[i],
                            onPointerDown: (event) => _onNodeClick(event, nodes[i]),
                        )
                    ),
                )
            );
        }

        return widgets;
    }

    void _onNodeClick(PointerDownEvent event, PetrinetNode node){
        switch(_executingAction){
            case PetrinetEditorActions.placingArc:                                  // arc placing
                if(_arcAnchoredTo == null){                                         // first anchor to node
                    _arcAnchoredTo = node;
                    return;
                }

                if(_arcAnchoredTo == node){                                         // self arc
                    return;
                }

                if(                                                                 // to same tipe
                    (_arcAnchoredTo is PetrinetPlace && node is PetrinetPlace) ||
                    (_arcAnchoredTo is PetrinetTransition && node is PetrinetTransition)
                ){
                    return;
                }

                bool? placeToTransition;
                int place, transition;

                if(_arcAnchoredTo is PetrinetPlace){                                // place to transition
                    placeToTransition = true;
                    place = _petrinet.places.indexOf(_arcAnchoredTo as PetrinetPlace);
                    transition = _petrinet.transitions.indexOf(node as PetrinetTransition);
                }
                else{                                                               // transition to place
                    placeToTransition = false;
                    place = _petrinet.places.indexOf(node as PetrinetPlace);
                    transition = _petrinet.transitions.indexOf(_arcAnchoredTo as PetrinetTransition);
                }

                try{
                    _petrinet.addArc(_arcType!, place, transition, placeToTransition);
                }
                finally{
                    _editorMessage = null;
                    _arcAnchoredTo = null;
                    _arcType = null;
                    _executingAction = null;
                    setState(() {});
                }

            break;

            default:
                return;
        }
    }
}