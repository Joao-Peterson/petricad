import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:petricad/src/cache.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'iconbuttonsimple.dart';
import 'editor.dart';
import 'explorer.dart';
import '../src/filemgr.dart';
import '../src/sidebar_actions.dart';

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
    SidebarActionEnum? _currentItem = SidebarActionEnum.none;
    final MultiSplitViewController _splitViewController = MultiSplitViewController(weights: [0.3, 0.7]);

    @override
    Widget build(BuildContext context){
        
        int sidebarActionIndex = Provider.of<CacheProvider>(context).getValue<int>("sidebarAction") ?? SidebarActionEnum.none.index;
        _currentItem = SidebarActionEnum.values.elementAt(sidebarActionIndex);
        _isOpen = Provider.of<CacheProvider>(context).getValue<bool>("sidebarIsOpen") ?? false;
        
        // sidebar must be closed with currentItem == none
        // because the toggle logic will leave selected items with the sidebar closed
        // if(!_isOpen && _currentItem != SidebarActionEnum.none){
        //     _currentItem = SidebarActionEnum.none;
        // }

        return LayoutBuilder(
            builder: (context, constraints) {

                var tray = Tray(
                    key: UniqueKey(), 
                    onPressed: _onItemClick, 
                    currentItem: _isOpen ? _currentItem : SidebarActionEnum.none,
                );


                Widget? panelChild; 
                if (_currentItem == null || _currentItem == SidebarActionEnum.none){
                    panelChild = null;
                }
                else{
                    panelChild = Provider.of<SidebarActionsProvider>(context).actions[(_currentItem ?? SidebarActionEnum.none).index].sidePanelWidget;
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
                                color:              Theme.of(context).colorScheme.secondary,
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

    void _onItemClick(SidebarAction item){
        if(_isOpen){
            if(_currentItem == item.type){
                _isOpen = false;
            }
            else{
                _currentItem = item.type;
            }
        }
        else{
            _isOpen = true;
            _currentItem = item.type;
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
    final void Function(SidebarAction item)? onPressed; 
    /// current ative item on tray
    final SidebarActionEnum? currentItem;

    const Tray({ 
        Key? key, 
        this.onPressed,
        this.currentItem = SidebarActionEnum.none,
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
                    trayItemIconButton(context, SidebarActionEnum.explorer,  27),
                    trayItemIconButton(context, SidebarActionEnum.search,    27),
                    trayItemIconButton(context, SidebarActionEnum.tools,     27),
                    trayItemIconButton(context, SidebarActionEnum.debug,     27),
                    Expanded(
                        child: Align(
                            child: Builder(
                                builder: (context) {
                                    var item = Provider.of<SidebarActionsProvider>(context).actions[SidebarActionEnum.settings.index];
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
        BuildContext context, SidebarActionEnum item, double size
    ){
        var trayItem = Provider.of<SidebarActionsProvider>(context).actions[item.index];
        return IconButtonSimple(
            onPressed: (){
                onPressed!(trayItem);
            }, 
            pressed: currentItem == item ? true : false,
            icon: trayItem.icon,
            iconSize: size,
            tooltip: ((trayItem.shortcut == null) ? trayItem.tooltip : trayItem.tooltip + " (" + singleActivatorToPrettyString(trayItem.shortcut as SingleActivator) + ")"),
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
                color: Theme.of(context).colorScheme.secondary,
            ),
            child: child,
        );
    }
}
