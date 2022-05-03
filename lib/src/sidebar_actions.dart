import 'package:flutter/material.dart';
import 'package:petricad/src/config.dart';
import 'package:petricad/src/filemgr.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:petricad/widgets/explorer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// enumerator defining sidebar actions
enum SidebarActionEnum{
    explorer,
    search,
    tools,
    debug,
    settings,
    none
}

// class for a sidebar action
class SidebarAction{    
    /// type based on the enumerator [SidebarActionEnum]
    final SidebarActionEnum type;
    /// the icon used for display
    final Icon icon;
    /// the tooltip
    String tooltip;
    /// keyboard shortcut, can be [SingleActivator] or [LogicalKeySet]
    ShortcutActivator? shortcut;
    /// if the sidebar should open to reveal the panel
    bool openSidePanel;
    /// the widget to display on the opened panel
    Widget? sidePanelWidget;
    /// optional callback when the icon is pressed 
    void Function(BuildContext context)? onPress;
    bool toTheBottom;

    // constructor
    SidebarAction({
        required this.type, 
        required this.icon, 
        this.tooltip = "",
        this.sidePanelWidget,
        this.shortcut,
        this.openSidePanel = false,
        this.onPress,
        this.toTheBottom = false
    });
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
        ),   
        
        // search
        SidebarAction(
            type: SidebarActionEnum.search,
            icon: const Icon(
                Icons.search,
            ),
            openSidePanel: true,
        ),   
        
        // tools
        SidebarAction(
            type: SidebarActionEnum.tools,
            icon: const Icon(
                Icons.build_sharp,
            ),
            openSidePanel: true,
        ),   

        // debug
        SidebarAction(
            type: SidebarActionEnum.debug,
            icon: const Icon(
                Icons.preview,
            ),
            openSidePanel: true,
        ),   
        
        // settings
        SidebarAction(
            type: SidebarActionEnum.settings,
            icon: const Icon(
                Icons.settings,
            ),
            toTheBottom: true,
            // shortcut: SingleActivator(LogicalKeyboardKey.keyK, control: true),
            onPress: (BuildContext context){
                launchUrl(
                    Uri.file(
                        Provider.of<Filemgr>(context, listen: false).getFilePath("config")!,
                    )
                );
            }
        ),   
    ];

    // constructor
    SidebarActionsProvider();

    // update tooltips and shortcuts 
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

