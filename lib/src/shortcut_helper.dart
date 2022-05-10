import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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
            case "esc":
                logicKey = LogicalKeyboardKey.escape;
            break;
            case "ins":
                logicKey = LogicalKeyboardKey.insert;
            break;
            case "del":
                logicKey = LogicalKeyboardKey.delete;
            break;
            case "enter":
                logicKey = LogicalKeyboardKey.enter;
            break;
            case "space":
                logicKey = LogicalKeyboardKey.space;
            break;
            case "backspace":
                logicKey = LogicalKeyboardKey.backspace;
            break;
            case "f1":
                logicKey = LogicalKeyboardKey.f1;
            break;
            case "f2":
                logicKey = LogicalKeyboardKey.f2;
            break;
            case "f3":
                logicKey = LogicalKeyboardKey.f3;
            break;
            case "f4":
                logicKey = LogicalKeyboardKey.f4;
            break;
            case "f5":
                logicKey = LogicalKeyboardKey.f5;
            break;
            case "f6":
                logicKey = LogicalKeyboardKey.f6;
            break;
            case "f7":
                logicKey = LogicalKeyboardKey.f7;
            break;
            case "f8":
                logicKey = LogicalKeyboardKey.f8;
            break;
            case "f9":
                logicKey = LogicalKeyboardKey.f9;
            break;
            case "f10":
                logicKey = LogicalKeyboardKey.f10;
            break;
            case "f11":
                logicKey = LogicalKeyboardKey.f11;
            break;
            case "f12":
                logicKey = LogicalKeyboardKey.f12;
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

// parse string like "ctrl+e" to logicalkeyset
LogicalKeySet? logicalKeySetFromString(String? shortcutString){
    if(shortcutString == null){return null;}
    List<String> list = shortcutString.split("+");
    
    Set<LogicalKeyboardKey> keys = {};

    for(var key in list){
        switch(key){
            case "ctrl":
                keys.add(LogicalKeyboardKey.control);
            break;
            case "shift":
                keys.add(LogicalKeyboardKey.shift);
            break;
            case "alt":
                keys.add(LogicalKeyboardKey.alt);
            break;
            case "meta":
                keys.add(LogicalKeyboardKey.meta);
            break;
            case "esc":
                keys.add(LogicalKeyboardKey.escape);
            break;
            case "ins":
                keys.add(LogicalKeyboardKey.insert);
            break;
            case "del":
                keys.add(LogicalKeyboardKey.delete);
            break;
            case "enter":
                keys.add(LogicalKeyboardKey.enter);
            break;
            case "space":
                keys.add(LogicalKeyboardKey.space);
            break;
            case "backspace":
                keys.add(LogicalKeyboardKey.backspace);
            break;
            case "f1":
                keys.add(LogicalKeyboardKey.f1);
            break;
            case "f2":
                keys.add(LogicalKeyboardKey.f2);
            break;
            case "f3":
                keys.add(LogicalKeyboardKey.f3);
            break;
            case "f4":
                keys.add(LogicalKeyboardKey.f4);
            break;
            case "f5":
                keys.add(LogicalKeyboardKey.f5);
            break;
            case "f6":
                keys.add(LogicalKeyboardKey.f6);
            break;
            case "f7":
                keys.add(LogicalKeyboardKey.f7);
            break;
            case "f8":
                keys.add(LogicalKeyboardKey.f8);
            break;
            case "f9":
                keys.add(LogicalKeyboardKey.f9);
            break;
            case "f10":
                keys.add(LogicalKeyboardKey.f10);
            break;
            case "f11":
                keys.add(LogicalKeyboardKey.f11);
            break;
            case "f12":
                keys.add(LogicalKeyboardKey.f12);
            break;
            default:
                var lkey = LogicalKeyboardKey.findKeyByKeyId(key.codeUnitAt(0));
                if(lkey == null){return null;}
                keys.add(lkey);
            break;
        }
    }

    if(keys.isNotEmpty){
        return LogicalKeySet.fromSet(keys);
    }
    else{
        return null;
    }
}

int? mouseButtonFromString(String button){
    switch (button){
        case "left":
            return kPrimaryMouseButton;
            
        case "right":
            return kSecondaryMouseButton;

        case "middle":
            return kMiddleMouseButton;

        case "back":
            return kBackMouseButton;

        case "forward":
            return kForwardMouseButton;

        default :
            return null;
    }
}
