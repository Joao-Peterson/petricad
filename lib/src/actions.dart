import 'package:command_palette/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:petricad/widgets/sidebar.dart';
import 'package:provider/provider.dart';
import '../src/cache.dart';

// actions list
Map<Type, Action<Intent>> buildActions(){
    return {
        // for sidebar actions
        SidebarActionIntent: CallbackAction<SidebarActionIntent>(
            onInvoke: ( intent ) {
                if( Provider.of<CacheProvider>(intent.context, listen: false).getValue("sidebarAction") == intent.item.index){
                    Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarAction", TrayItemsEnum.none.index);
                    Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarIsOpen", false);
                }
                else{
                    Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarAction", intent.item.index);
                    Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarIsOpen", true);
                }
            } 
        ),
    };
}

// -------------------------------------- Intents ------------------------------- //

// for sidebar actions
class SidebarActionIntent extends Intent{
    final TrayItemsEnum item;
    final BuildContext context;

    const SidebarActionIntent(this.context, this.item);   
}
