import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'iconbuttonsimple.dart';

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
    const TrayItem({
        required this.type, 
        required this.icon, 
        required this.tooltip
    });
    
    // members
    final TrayItemsEnum type;
    final Icon icon;
    final String tooltip;
}

List<TrayItem> trayItems = const[
    // explorer
    TrayItem(
        type: TrayItemsEnum.explorer,
        icon: Icon(
            Icons.folder_open_outlined,
        ),
        tooltip: "File explorer"
    ),   
    
    // search
    TrayItem(
        type: TrayItemsEnum.search,
        icon: Icon(
            Icons.search,
        ),
        tooltip: "Search"
    ),   
    
    // tools
    TrayItem(
        type: TrayItemsEnum.tools,
        icon: Icon(
            Icons.build_sharp,
        ),
        tooltip: "Tools and components"
    ),   

    // debug
    TrayItem(
        type: TrayItemsEnum.debug,
        icon: Icon(
            Icons.preview,
        ),
        tooltip: "Debug and watch"
    ),   
    
    // settings
    TrayItem(
        type: TrayItemsEnum.tools,
        icon: Icon(
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

    @override
    Widget build(BuildContext context){
        return 
        LayoutBuilder(
            builder: (context, constraints) {
                if(_isOpen){
                    return 
                    MultiSplitViewTheme(
                        child: MultiSplitView(
                            children: [
                                Row( 
                                    children: [
                                        _buildTray(context),
                                        const Expanded(
                                            child: Panel()
                                        )
                                    ],
                                ),
                                const Editor()
                            ],
                            initialWeights: const [0.3, 0.7],
                            minimalWeight: 0.2,
                        ),
                        data: MultiSplitViewThemeData(
                            dividerThickness: 4,
                            dividerPainter: DividerPainters.background(
                                color:              Theme.of(context).colorScheme.primary,
                                highlightedColor:   Theme.of(context).colorScheme.onPrimary
                            )
                        )
                    );
                }
                else{
                    return 
                    Row( 
                        children: [
                            _buildTray(context),
                            const Expanded(
                                child: Editor()
                            )
                        ],
                    );
                }
            },
        );
    }

    Widget _buildTray(BuildContext context) {
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
        var trayitem = trayItems[item.index];
        return IconButtonSimple(
            onPressed: () => _onItemClick(item), 
            icon: trayitem.icon,
            iconSize: size,
        
            tooltip: trayitem.tooltip,
        
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        );
    }

    void _onItemClick(TrayItemsEnum item){
        if(_currentItem == item){
            _currentItem = TrayItemsEnum.none;
            _isOpen = false;
        }
        else if(_currentItem == TrayItemsEnum.none){
            _currentItem = item;
            _isOpen = true;
        }
        else{
            _currentItem = item;
        }
        
        setState(() {});
        
        return;
    }
}


class Panel extends StatelessWidget {
    const Panel({ Key? key }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return 
        Container(
            width: 400,
            height: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
            ),
        );
    }
}

class Editor extends StatelessWidget {
    const Editor({ Key? key }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Theme.of(context).colorScheme.background,
        );
    }
}

