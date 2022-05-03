import 'package:flutter/material.dart';
import 'package:petricad/src/config.dart';
import 'package:petricad/src/sidebar_actions.dart';
import 'package:petricad/src/themes.dart';
import 'package:provider/provider.dart';
import '../src/cache.dart';

// actions list
Map<Type, Action<Intent>> buildActions(){
    return {
        // for sidebar actions
        SidebarActionIntent: CallbackAction<SidebarActionIntent>(
            onInvoke: ( intent ) {
                if(intent.action.openSidePanel){
                    if( Provider.of<CacheProvider>(intent.context, listen: false).getValue("sidebarIsOpen")){
                        if(Provider.of<CacheProvider>(intent.context, listen: false).getValue("sidebarAction") == intent.action.type.index){
                            Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarIsOpen", false);
                        }
                        else{
                            Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarAction", intent.action.type.index);
                        }
                    }
                    else{
                        Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarAction", intent.action.type.index);
                        Provider.of<CacheProvider>(intent.context, listen: false).setValue("sidebarIsOpen", true);
                    }
                }

                var call = intent.action.onPress;
                if(call != null){
                    call(intent.context);
                }

                return null;
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

                return null;
            },
        ),

        // reload cache, config and themes
        ReloadIntent: CallbackAction<ReloadIntent>(
            onInvoke: (intent) {
                Provider.of<ConfigProvider>(intent.context, listen: false).buildConfig();
                Provider.of<CacheProvider>(intent.context, listen: false).buildCache();
                Provider.of<ThemesProvider>(intent.context, listen: false).buildThemes();
                Provider.of<ThemesProvider>(intent.context, listen: false).setTheme(
                    Provider.of<ConfigProvider>(intent.context, listen: false).getConfig("visual.theme")
                );
                return null;
            },
        ),
    };
}

// -------------------------------------- Intents ------------------------------- //

// for sidebar actions
class SidebarActionIntent extends Intent{
    final SidebarAction action;
    final BuildContext context;

    const SidebarActionIntent(this.context, this.action);   
}

class SidebarToggleOpenIntent extends Intent{
    final BuildContext context;

    const SidebarToggleOpenIntent(this.context);
}

// reload cache, config and themes
class ReloadIntent extends Intent{
    final BuildContext context;

    const ReloadIntent(this.context);
}