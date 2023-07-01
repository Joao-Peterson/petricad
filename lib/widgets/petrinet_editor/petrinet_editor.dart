import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:petricad/src/config.dart';
// import 'package:provider/provider.dart';
import 'package:petricad/widgets/petrinet_editor/petrinet.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:petricad/widgets/petrinet_editor/arc_widget.dart';
import 'place_widget.dart';
import 'transition_widget.dart';

// ------------------------------------------------------------ Intents ------------------------------------------------------------

// elements that can be placed inside the editor
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

// editor reset action intent
class EditorResetActionsIntent extends Intent{
    const EditorResetActionsIntent();
}

// editor delete intent
class EditorDeleteIntent extends Intent{
    const EditorDeleteIntent();
}

// ------------------------------------------------------------ Editor -------------------------------------------------------------

// actions that are performed over time
enum PetrinetEditorActions{
    placingArc,
    deleting
}

// editor widget
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

        // shortcuts
        return Shortcuts(
            debugLabel: "petrinet_editor_shortcuts",
            shortcuts: {
                const CharacterActivator("p") : EditorPlaceIntent(PetrinetEditorInserts.place, _editorRenderBox?.globalToLocal(_lastMousePosOnKeypress) ?? const Offset(0, 0)),
                const CharacterActivator("t") : EditorPlaceIntent(PetrinetEditorInserts.transition, _editorRenderBox?.globalToLocal(_lastMousePosOnKeypress) ?? const Offset(0, 0)),
                const CharacterActivator("a") : const EditorInsertArcIntent(PetrinetArcType.weighted),
                const CharacterActivator("n") : const EditorInsertArcIntent(PetrinetArcType.negated),
                const CharacterActivator("r") : const EditorInsertArcIntent(PetrinetArcType.reset),
                const SingleActivator(LogicalKeyboardKey.escape) : const EditorResetActionsIntent(),
                const SingleActivator(LogicalKeyboardKey.delete) : const EditorDeleteIntent(),
                const CharacterActivator("d") : const EditorDeleteIntent(),
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
                        setState(() {});
                        return null;
                    },),
                    EditorResetActionsIntent: CallbackAction<EditorResetActionsIntent>(onInvoke: (intent) {
                        _editorMessage = null;
                        _executingAction = null;
                        _arcAnchoredTo = null;
                        _arcType = null;
                        setState(() {});
                        return null;
                    },),
                    EditorDeleteIntent: CallbackAction<EditorDeleteIntent>(onInvoke: (intent) {
                        _executingAction = PetrinetEditorActions.deleting;
                        _editorMessage = "Deleting...";
                        setState(() {});
                        return null;
                    },),
                },
                child: Stack(children: [
                    InteractiveViewer(
                        child: Focus(
                            child: LayoutBuilder(
                                builder: (context, constraints) {
                                    FocusNode editorFocus = Focus.of(context); 
                                    var scale = _transformationController.value.storage[0];
                                    var widgets = _buildNodes(scale);
                                    _editorRenderBox = context.findRenderObject() as RenderBox?;
                                                    
                                    return DragTarget<PetrinetNode>(
                                        builder: (context, candidateData, rejectedData) {
                                            return MouseRegion(
                                                onEnter: (event) {
                                                    editorFocus.requestFocus();
                                                },
                                                onExit: (event) {
                                                    if(editorFocus.hasFocus){
                                                        editorFocus.unfocus();
                                                    }
                                                },
                                                onHover: (event) {
                                                    _lastMousePosOnKeypress = event.position;
                                                },
                                                child: Container(
                                                    height: _size.height,
                                                    width: _size.width,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1 / scale,
                                                            color: Colors.amber,
                                                        )
                                                    ),
                                                    child: Stack(children: widgets),
                                                ),
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

    // make widgets for the petrinet editor elements
    List<Widget> _buildNodes(double scale){
        List<Widget> list = [];
        List<Widget> widgets = [];
        List<PetrinetNode> nodes = [];

        Size nodeSize = const Size(100, 200);

        for(var arc in _petrinet.arcs){                                             // arcs
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
                    child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 3, color: Colors.pink)),
                        constraints: BoxConstraints.loose(const Size.square(5000)),
                        child: Listener(
                            child: ArcWidget(
                                type: arc.type, 
                                from: from, 
                                to: to,
                                thickness: 5,
                                offset: nodeSize.longestSide / 2,
                                hitTestRadius: nodeSize.shortestSide / 2,
                            ),
                            behavior: HitTestBehavior.deferToChild,
                            onPointerUp: (event) => _onArcClick(arc),
                        ),
                    ),
                )
            );
        }

        for(var place in _petrinet.places){                                         // places
            var widget = PlaceWidget(place.name, nodeSize, tokens: place.init);
            list.add(widget);
            nodes.add(place);
        }

        for(var i = 0; i < _petrinet.transitions.length; i++){                      // transitions
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
                            behavior: HitTestBehavior.translucent,
                            child: list[i],
                            onPointerUp: (event) => _onNodeClick(nodes[i]),
                        )
                    ),
                )
            );
        }

        return widgets;
    }

    // logic node onclick for editor widgets
    void _onNodeClick(PetrinetNode node){
        switch(_executingAction){
            case PetrinetEditorActions.deleting:                                    // delete node
                _petrinet.removeNode(node);
                setState(() {});
            break;

            case PetrinetEditorActions.placingArc:                                  // arc placing
                _placingArc(node);
            break;

            default:
                return;
        }
    }

    // logic node onclick for arc widgets
    void _onArcClick(PetrinetArc arc){
        switch(_executingAction){
            case PetrinetEditorActions.deleting:                                    // delete arc
                _petrinet.removeArc(arc);
                setState(() {});
            break;

            default:
                return;
        }
    }

    // placing arc logic
    void _placingArc(PetrinetNode node){
        if(_arcAnchoredTo == null){                                                 // first anchor to node
            _arcAnchoredTo = node;
            return;
        }

        if(_arcAnchoredTo == node){                                                 // self arc
            return;
        }

        if(                                                                         // to same tipe
            (_arcAnchoredTo is PetrinetPlace && node is PetrinetPlace) ||
            (_arcAnchoredTo is PetrinetTransition && node is PetrinetTransition)
        ){
            return;
        }

        bool? placeToTransition;
        int place, transition;

        if(_arcAnchoredTo is PetrinetPlace){                                        // place to transition
            placeToTransition = true;
            place = _petrinet.places.indexOf(_arcAnchoredTo as PetrinetPlace);
            transition = _petrinet.transitions.indexOf(node as PetrinetTransition);
        }
        else{                                                                       // transition to place
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
    }
}