import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'iconbuttonsimple.dart';
import 'editor.dart';
import 'explorer.dart';

enum TrayItemsEnum{
    explorer,
    search,
    tools,
    debug,
    settings,
    none
}

class TrayItem{
    // constructor
    TrayItem({
        required this.type, 
        required this.icon, 
        required this.tooltip,
        this.widget,
    });
    
    // members
    final TrayItemsEnum type;
    final Icon icon;
    final String tooltip;
    Widget? widget;
}

List<TrayItem> trayItems = [
    // explorer
    TrayItem(
        type: TrayItemsEnum.explorer,
        icon: const Icon(
            Icons.folder_open_outlined,
        ),
        tooltip: "File explorer",
        widget: const Explorer(), 
    ),   
    
    // search
    TrayItem(
        type: TrayItemsEnum.search,
        icon: const Icon(
            Icons.search,
        ),
        tooltip: "Search"
    ),   
    
    // tools
    TrayItem(
        type: TrayItemsEnum.tools,
        icon: const Icon(
            Icons.build_sharp,
        ),
        tooltip: "Tools and components"
    ),   

    // debug
    TrayItem(
        type: TrayItemsEnum.debug,
        icon: const Icon(
            Icons.preview,
        ),
        tooltip: "Debug and watch"
    ),   
    
    // settings
    TrayItem(
        type: TrayItemsEnum.tools,
        icon: const Icon(
            Icons.settings,
        ),
        tooltip: "Program and project settings"
    ),   
];

class Sidebar extends StatefulWidget {
    const Sidebar({ Key? key }) : super(key: key);

    @override
    State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

    bool _isOpen = false;
    TrayItemsEnum? _currentItem = TrayItemsEnum.none;
    final MultiSplitViewController _splitViewController = MultiSplitViewController(weights: [0.3, 0.7]);

    @override
    Widget build(BuildContext context){
        return 
        LayoutBuilder(
            builder: (context, constraints) {

                var tray = Tray(
                    key: UniqueKey(), 
                    onPressed: _onItemClick, 
                    currentItem: _currentItem,
                );


                Widget? panel_child; 
                if (_currentItem == null || _currentItem == TrayItemsEnum.none){
                    panel_child = null;
                }
                else{
                    panel_child = trayItems[(_currentItem ?? TrayItemsEnum.none).index].widget;
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
                                                child: panel_child,
                                            )
                                        )
                                    ],
                                ),
                                const Editor()
                            ],
                            controller: _splitViewController,
                            minimalWeight: 0.2,
                        ),
                        data: MultiSplitViewThemeData(
                            dividerThickness: 6,
                            dividerPainter: DividerPainters.background(
                                color:              Theme.of(context).colorScheme.primary,
                                highlightedColor:   Theme.of(context).colorScheme.onPrimary,
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
        else if(_currentItem == TrayItemsEnum.none){
            _currentItem = item.type;
            _isOpen = true;
        }
        else{
            _currentItem = item.type;
        }
        
        setState(() {});
        
        return;
    }
}

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
                    right: BorderSide(width: 1.5, color: Theme.of(context).dividerColor),
                )
            ),

            child: Column(
                children: [
                    trayItemIconButton(context, trayItems, TrayItemsEnum.explorer,  27),
                    trayItemIconButton(context, trayItems, TrayItemsEnum.search,    27),
                    trayItemIconButton(context, trayItems, TrayItemsEnum.tools,     27),
                    trayItemIconButton(context, trayItems, TrayItemsEnum.debug,     27),
                    Expanded(
                        child: Align(
                            child: trayItemIconButton(context, trayItems, TrayItemsEnum.settings, 25),
                            alignment: Alignment.bottomCenter,
                        ),
                    )
                ],
            ),
        );
    }

    IconButtonSimple trayItemIconButton(
        BuildContext context, List<TrayItem> items, TrayItemsEnum item, double size
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
        );
    }
}

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
