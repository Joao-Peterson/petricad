import 'package:flutter/cupertino.dart';

List<String> singleActivatorToStringList(SingleActivator shortcut){
    List<String> list = [];

    if(shortcut.alt){
        list.add("Alt");
    }

    if(shortcut.control){
        list.add("Ctrl");
    }

    if(shortcut.shift){
        list.add("Shift");
    }

    if(shortcut.meta){
        list.add("Meta");
    }

    list.add(shortcut.trigger.keyLabel);

    return list;
}

String singleActivatorToString(SingleActivator shortcut){
    var list = singleActivatorToStringList(shortcut);
    return list.join("+");
}