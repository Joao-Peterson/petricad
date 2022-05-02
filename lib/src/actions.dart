import 'package:command_palette/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:petricad/src/sidebar_actions.dart';
import 'package:petricad/widgets/sidebar.dart';
import 'package:provider/provider.dart';
import '../src/cache.dart';

// actions list
Map<Type, Action<Intent>> buildActions(){
    return {
        // for sidebar actions
        SidebarActionIntent: CallbackAction<SidebarActionIntent>(
            onInvoke: ( intent ) {
                if( Provider.of<CacheProvider>(intent.context, listen: false).getValue("sidebarIsOpen")){
                    if(Provider.of<CacheProvider>(intent.context, listen: false).getValue("sidebarAction") == intent.item.index){
                        Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarIsOpen", false);
                    }
                    else{
                        Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarAction", intent.item.index);
                    }
                }
                else{
                    Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarAction", intent.item.index);
                    Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarIsOpen", true);
                }
            } 
        ),
        SidebarToggleOpenIntent: CallbackAction<SidebarToggleOpenIntent>(
            onInvoke: (intent) {
                if(Provider.of<CacheProvider>(intent.context, listen: false).getValue("sidebarIsOpen")){
                    Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarIsOpen", false);
                }
                else{
                    if(Provider.of<CacheProvider>(intent.context, listen: false).getValue("sidebarAction") == SidebarActionEnum.none){
                        Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarAction", SidebarActionEnum.explorer);
                    }
                    Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarIsOpen", true);
                }
            },
        ),
    };
}

// -------------------------------------- Intents ------------------------------- //

// for sidebar actions
class SidebarActionIntent extends Intent{
    final SidebarActionEnum item;
    final BuildContext context;

    const SidebarActionIntent(this.context, this.item);   
}

class SidebarToggleOpenIntent extends Intent{
    final BuildContext context;

    const SidebarToggleOpenIntent(this.context);
}
