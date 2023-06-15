import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petricad/src/config.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:petricad/src/sidebar_actions.dart';
import 'package:provider/provider.dart';
import 'actions.dart';

// global shortcuts
Map<ShortcutActivator, Intent> buildGlobalShortcuts(BuildContext context){
    Map<ShortcutActivator, Intent> shortcuts = {
        singleActivatorFromString(Provider.of<ConfigProvider>(context).getConfig<String>("shortcuts.sidebarToggleOpen")) ?? const SingleActivator(LogicalKeyboardKey.keyP): SidebarToggleOpenIntent(context),
    };

    shortcuts = _buildSidebarActionsShortcuts(context, shortcuts); 
    
    return shortcuts;
}

// -------------------------------------- Builders ------------------------------ //

// sidebar actions shorcut builder
Map<ShortcutActivator, Intent> _buildSidebarActionsShortcuts(BuildContext context, Map<ShortcutActivator, Intent> shortcuts){

    for(var item in Provider.of<SidebarActionsProvider>(context).actions){
        if(item.shortcut != null){
            shortcuts[item.shortcut!] = SidebarActionIntent(context, item);
        }
    }

    return shortcuts;
}