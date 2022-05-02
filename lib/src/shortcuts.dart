import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petricad/widgets/sidebar.dart';
import 'package:provider/provider.dart';
import 'actions.dart';
import '../src/cache.dart';

// shortcut list
Map<ShortcutActivator, Intent> buildShortcuts(BuildContext context){
    Map<ShortcutActivator, Intent> shortcuts = {
        // ! add shortcuts here
    };

    shortcuts = _buildSidebarActionsShortcuts(context, shortcuts); 
    
    return shortcuts;
}

// -------------------------------------- Builders ------------------------------ //

// sidebar actions shorcut builder
Map<ShortcutActivator, Intent> _buildSidebarActionsShortcuts(BuildContext context, Map<ShortcutActivator, Intent> shortcuts){

    for(var item in trayItems){
        if(item.shortcut != null){
            shortcuts[item.shortcut!] = SidebarActionIntent(context, item.type);
        }
    }

    return shortcuts;
}