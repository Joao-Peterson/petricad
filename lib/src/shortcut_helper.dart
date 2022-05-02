import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

List<String> singleActivatorToPrettyStringList(SingleActivator shortcut){
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

String singleActivatorToPrettyString(SingleActivator shortcut){
    var list = singleActivatorToPrettyStringList(shortcut);
    return list.join("+");
}

// parse string like "ctrl+e" to single activator
SingleActivator? singleActivatorFromString(String? shortcutString){
    if(shortcutString == null){return null;}
    List<String> list = shortcutString.split("+");
    
    var control = false;
    var shift = false;
    var alt = false;
    var meta = false;
    LogicalKeyboardKey? logicKey;

    for(var key in list){
        switch(key){
            case "ctrl":
                control = true;
            break;
            case "shift":
                shift = true;
            break;
            case "alt":
                alt = true;
            break;
            case "meta":
                meta = true;
            break;
            default:
                logicKey = LogicalKeyboardKey.findKeyByKeyId(key.codeUnitAt(0));
            break;
        }
    }

    if(logicKey != null){
        return SingleActivator(
            logicKey,
            control: control,
            shift: shift,
            alt: alt,
            meta: meta,
        );
    }
    else{
        return null;
    }
}
