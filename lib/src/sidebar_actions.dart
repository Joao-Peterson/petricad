import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petricad/src/config.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:petricad/widgets/explorer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SidebarAction{    
    // members
    final SidebarActionEnum type;
    final Icon icon;
    String tooltip;
    ShortcutActivator? shortcut;
    bool openSidePanel;
    Widget? sidePanelWidget;

    // constructor
    SidebarAction({
        required this.type, 
        required this.icon, 
        this.tooltip = "",
        this.sidePanelWidget,
        this.shortcut,
        this.openSidePanel = false,
    });
}

enum SidebarActionEnum{
    explorer,
    search,
    tools,
    debug,
    settings,
    none
}

class SidebarActionsProvider extends ChangeNotifier{

    List<SidebarAction> actions = [
        // explorer
        SidebarAction(
            type: SidebarActionEnum.explorer,
            icon: const Icon(
                Icons.folder_open_outlined,
            ),
            openSidePanel: true,
            sidePanelWidget: const Explorer(), 
            shortcut: const SingleActivator(LogicalKeyboardKey.keyE, control: true),
        ),   
        
        // search
        SidebarAction(
            type: SidebarActionEnum.search,
            icon: const Icon(
                Icons.search,
            ),
            openSidePanel: true,
            shortcut: const SingleActivator(LogicalKeyboardKey.keyR, control: true),
        ),   
        
        // tools
        SidebarAction(
            type: SidebarActionEnum.tools,
            icon: const Icon(
                Icons.build_sharp,
            ),
            openSidePanel: true,
            shortcut: const SingleActivator(LogicalKeyboardKey.keyT, control: true),
        ),   

        // debug
        SidebarAction(
            type: SidebarActionEnum.debug,
            icon: const Icon(
                Icons.preview,
            ),
            openSidePanel: true,
            shortcut: const SingleActivator(LogicalKeyboardKey.keyD, control: true),
        ),   
        
        // settings
        SidebarAction(
            type: SidebarActionEnum.settings,
            icon: const Icon(
                Icons.settings,
            ),
        ),   
    ];

    // constructor
    SidebarActionsProvider();

    update(BuildContext context){
        for(var item in actions){
            switch (item.type){
                case SidebarActionEnum.explorer:
                    item.tooltip = AppLocalizations.of(context)!.sidebarActionExplorerTooltip;
                    item.shortcut = singleActivatorFromString(Provider.of<ConfigProvider>(context).getConfig("shortcuts.sidebarActionExplorer"));
                break;
                
                case SidebarActionEnum.search:
                    item.tooltip = AppLocalizations.of(context)!.sidebarActionSearchTooltip;
                    item.shortcut = singleActivatorFromString(Provider.of<ConfigProvider>(context).getConfig("shortcuts.sidebarActionSearch"));
                break;
                
                case SidebarActionEnum.tools:
                    item.tooltip = AppLocalizations.of(context)!.sidebarActionToolsTooltip;
                    item.shortcut = singleActivatorFromString(Provider.of<ConfigProvider>(context).getConfig("shortcuts.sidebarActionTools"));
                break;
                
                case SidebarActionEnum.debug:
                    item.tooltip = AppLocalizations.of(context)!.sidebarActionDebugTooltip;
                    item.shortcut = singleActivatorFromString(Provider.of<ConfigProvider>(context).getConfig("shortcuts.sidebarActionDebug"));
                break;
                
                case SidebarActionEnum.settings:
                    item.tooltip = AppLocalizations.of(context)!.sidebarActionSettingsTooltip;
                    item.shortcut = singleActivatorFromString(Provider.of<ConfigProvider>(context).getConfig("shortcuts.sidebarActionSettings"));
                break;
                
                default:
                    item.tooltip = AppLocalizations.of(context)!.sidebarActionNoneTooltip;
                break;
            }
        }

        // notifyListeners();
    }
}

