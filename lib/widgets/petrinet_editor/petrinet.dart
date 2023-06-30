enum PetrinetArcType{
    weighted,
    negated,
    reset,
}

enum PetrinetInputEvt{
    pos,
    neg,
    any,
}

class PetrinetNode{
    String name;
    double offsetX; 
    double offsetY;

    PetrinetNode(this.name, this.offsetX, this.offsetY);
}

class PetrinetPlace extends PetrinetNode{
    int init;

    PetrinetPlace(String name, double offsetX, double offsetY, this.init): super(name, offsetX, offsetY);
}

class PetrinetTransition extends PetrinetNode{
    int delay;
    int? input;
    PetrinetInputEvt? inputEvt;

    PetrinetTransition(
        String name,
        double offsetX,
        double offsetY,
        this.delay,
        this.input,
        this.inputEvt
    ): super(name, offsetX, offsetY);
}

class PetrinetArc{
    PetrinetArcType type;
    int place;
    int transition;
    bool? placeToTransition;
    int? weight;

    PetrinetArc(
        this.type,
        this.place,
        this.transition,
        this.placeToTransition,
        this.weight
    );
}

class Petrinet{
    int _placeIndex = 0;
    int _transitionIndex = 0;
    int _inputIndex = 0;
    int _outputIndex = 0;
    
    late List<PetrinetPlace>        places;
    late List<PetrinetTransition>   transitions;
    late List<PetrinetArc>          arcs;
    late List<String>               inputsNames;
    late List<String>               outputNames;

    Petrinet(){
        places = [];
        transitions = [];
        arcs = [];
        inputsNames = [];
        outputNames = [];
    }

    void addPlace({double? dx, double? dy}){
        places.add(PetrinetPlace("p$_placeIndex", dx ?? 0, dy ?? 0, 0));
        _placeIndex++;
    }


    void addTransition({double? dx, double? dy}){
        transitions.add(PetrinetTransition("t$_transitionIndex", dx ?? 0, dy ?? 0, 0, null, null));
        _transitionIndex++;
    }

    void addArc(PetrinetArcType type, int place, int transition, bool? placeToTransition){
        if(place >= places.length){
            throw Exception("Place index out of bounds");
        }
        if(transition >= transitions.length){
            throw Exception("Transition index out of bounds");
        }

        if(type == PetrinetArcType.weighted){
            arcs.add(PetrinetArc(type, place, transition, placeToTransition, 1));
        }
        else{
            arcs.add(PetrinetArc(type, place, transition, null, null));
        }
    }

    void addInput(){
        inputsNames.add("x$_inputIndex");
        _inputIndex++;
    }

    void addOutput(){
        outputNames.add("q$_outputIndex");
        _outputIndex++;
    }

    void removeNode(PetrinetNode node){
        switch(node.runtimeType){
            case PetrinetPlace:                                                     // place
                var index = places.indexOf(node as PetrinetPlace);
                places.removeAt(index);                                             // remove place

                arcs.removeWhere((element) => element.place == index);              // remove arcs
                for(var arc in arcs){                                               // adjust other arcs references    
                    if(arc.place > index){
                        arc.place--;
                    }
                }

                _placeIndex--;
            break;

            case PetrinetTransition:                                                // transition
                var index = transitions.indexOf(node as PetrinetTransition);
                transitions.removeAt(index);

                arcs.removeWhere((element) => element.transition == index);
                for(var arc in arcs){                                               // adjust other arcs references    
                    if(arc.transition > index){
                        arc.transition--;
                    }
                }

                _transitionIndex--;
            break;
        }
    }
}