import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:petricad/src/cache.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'iconbuttonsimple.dart';
import 'editor.dart';
import 'explorer.dart';
import '../src/filemgr.dart';

enum TrayItemsEnum{
    explorer,
    search,
    tools,
    debug,
    settings,
    none
}

class TrayItem{    
    // members
    final TrayItemsEnum type;
    final Icon icon;
    String tooltip;
    final List<String>? shortcut;
    Widget? widget;

    // constructor
    TrayItem({
        required this.type, 
        required this.icon, 
        this.tooltip = "",
        this.widget,
        this.shortcut,
    });
}

List<TrayItem> trayItems = [
    // explorer
    TrayItem(
        type: TrayItemsEnum.explorer,
        icon: const Icon(
            Icons.folder_open_outlined,
        ),
        shortcut: ["ctrl", "shift", "e"],
        widget: const Explorer(), 
    ),   
    
    // search
    TrayItem(
        type: TrayItemsEnum.search,
        icon: const Icon(
            Icons.search,
        ),
    ),   
    
    // tools
    TrayItem(
        type: TrayItemsEnum.tools,
        icon: const Icon(
            Icons.build_sharp,
        ),
    ),   

    // debug
    TrayItem(
        type: TrayItemsEnum.debug,
        icon: const Icon(
            Icons.preview,
        ),
    ),   
    
    // settings
    TrayItem(
        type: TrayItemsEnum.settings,
        icon: const Icon(
            Icons.settings,
        ),
    ),   
];

// sidebar with editor, expads the whole screen width
class Sidebar extends StatefulWidget {

    const Sidebar({ 
        Key? key 
    }) : super(key: key);

    @override
    State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

    bool _isOpen = false;
    TrayItemsEnum? _currentItem = TrayItemsEnum.none;
    final MultiSplitViewController _splitViewController = MultiSplitViewController(weights: [0.3, 0.7]);

    @override
    Widget build(BuildContext context){

        _applyTrayItemsLocale(context, trayItems);
        int sidebarActionIndex = Provider.of<CacheProvider>(context).getValue<int>("sidebarAction") ?? TrayItemsEnum.none.index;
        _currentItem = TrayItemsEnum.values.elementAt(sidebarActionIndex);
        _isOpen = Provider.of<CacheProvider>(context).getValue<bool>("sidebarIsOpen") ?? false;
        
        // sidebar must be closed with currentItem == none
        // because the toggle logic will leave selected items with the sidebar closed
        if(!_isOpen && _currentItem != TrayItemsEnum.none){
            _currentItem = TrayItemsEnum.none;
        }

        return LayoutBuilder(
            builder: (context, constraints) {

                var tray = Tray(
                    key: UniqueKey(), 
                    onPressed: _onItemClick, 
                    currentItem: _currentItem,
                );


                Widget? panelChild; 
                if (_currentItem == null || _currentItem == TrayItemsEnum.none){
                    panelChild = null;
                }
                else{
                    panelChild = trayItems[(_currentItem ?? TrayItemsEnum.none).index].widget;
                }

                if(_isOpen){
                    return 
                    MultiSplitViewTheme(
                        child: MultiSplitView(
                            children: [
                                Row( 
                                    children: [
                                        tray,
                                        Expanded(
                                            child: Panel(
                                                child: panelChild,
                                            )
                                        )
                                    ],
                                ),
                                const Editor(leftBorderActive: true)
                            ],
                            controller: _splitViewController,
                            globalMinimalWeight: 0.2,
                        ),
                        data: MultiSplitViewThemeData(
                            dividerThickness: 6,
                            dividerPainter: DividerPainters.background(
                                color:              Theme.of(context).colorScheme.primary,
                                highlightedColor:   Theme.of(context).colorScheme.tertiary,
                            )
                        )
                    );
                }
                else{
                    return 
                    Row( 
                        children: [
                            tray,
                            const Expanded(
                                child: Editor()
                            )
                        ],
                    );
                }
            },
        );
    }

    void _onItemClick(TrayItem item){
        if(_currentItem == item.type){
            _currentItem = TrayItemsEnum.none;
            _isOpen = false;
        }
        else{
            _currentItem = item.type;
            _isOpen = true;
        }
        
        Provider.of<CacheProvider>(context, listen: false).setValue("sidebarAction", item.type.index);
        Provider.of<CacheProvider>(context, listen: false).setValue("sidebarIsOpen", _isOpen);

        setState(() {});
        
        return;
    }
}

// just the sidebar, a tray to hold buttons
class Tray extends StatelessWidget {
    
    /// callback for click handling of all buttons in the tray
    final void Function(TrayItem item)? onPressed; 
    /// current ative item on tray
    final TrayItemsEnum? currentItem;

    const Tray({ 
        Key? key, 
        this.onPressed,
        this.currentItem = TrayItemsEnum.none,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return 
        Container(
            width: 50,
            height: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border(
                    right: BorderSide(width: 1, color: Theme.of(context).dividerColor),
                )
            ),

            child: Column(
                children: [
                    trayItemIconButton(context, TrayItemsEnum.explorer,  27),
                    trayItemIconButton(context, TrayItemsEnum.search,    27),
                    trayItemIconButton(context, TrayItemsEnum.tools,     27),
                    trayItemIconButton(context, TrayItemsEnum.debug,     27),
                    Expanded(
                        child: Align(
                            child: Builder(
                                builder: (context) {
                                    var item = trayItems[TrayItemsEnum.settings.index];
                                    // config button
                                    return IconButtonSimple(
                                        icon: item.icon, 
                                        iconSize: 25,
                                        tooltip: item.tooltip,
                                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                        color: Theme.of(context).iconTheme.color,
                                        highlightColor: Theme.of(context).highlightColor,
                                        onPressed: (){
                                            launchUrl(
                                                Uri.file(
                                                    Provider.of<Filemgr>(context, listen: false).getFilePath("config")!,
                                                )
                                            );
                                        }
                                    );
                                }
                            ),
                            alignment: Alignment.bottomCenter,
                        ),
                    )
                ],
            ),
        );
    }

    IconButtonSimple trayItemIconButton(
        BuildContext context, TrayItemsEnum item, double size
    ){
        var trayItem = trayItems[item.index];
        return IconButtonSimple(
            onPressed: (){
                onPressed!(trayItem);
            }, 
            pressed: currentItem == item ? true : false,
            icon: trayItem.icon,
            iconSize: size,
            tooltip: trayItem.tooltip,
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            color: Theme.of(context).iconTheme.color,
            highlightColor: Theme.of(context).highlightColor,
        );
    }
}

// the panel that opens with the sidebar button click
class Panel extends StatelessWidget {
    final Widget? child;
    
    const Panel({ 
        Key? key,
        this.child
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return 
        Container(
            width: 400,
            height: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
            ),
            child: child,
        );
    }
}

_applyTrayItemsLocale(BuildContext context, List<TrayItem> trayItems){
    for(var item in trayItems){
        switch (item.type){
            case TrayItemsEnum.explorer:
                item.tooltip = AppLocalizations.of(context)!.sidebarActionExplorerTooltip;
            break;
            
            case TrayItemsEnum.search:
                item.tooltip = AppLocalizations.of(context)!.sidebarActionSearchTooltip;
            break;
            
            case TrayItemsEnum.tools:
                item.tooltip = AppLocalizations.of(context)!.sidebarActionToolsTooltip;
            break;
            
            case TrayItemsEnum.debug:
                item.tooltip = AppLocalizations.of(context)!.sidebarActionDebugTooltip;
            break;
            
            case TrayItemsEnum.settings:
                item.tooltip = AppLocalizations.of(context)!.sidebarActionSettingsTooltip;
            break;
            
            default:
                item.tooltip = AppLocalizations.of(context)!.sidebarActionNoneTooltip;
            break;
        }
    }
}