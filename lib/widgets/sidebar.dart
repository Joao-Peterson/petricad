import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:petricad/src/actions.dart';
import 'package:petricad/src/cache.dart';
import 'package:petricad/src/shortcut_helper.dart';
import 'package:provider/provider.dart';
import 'iconbuttonsimple.dart';
import 'editor.dart';
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

        return LayoutBuilder(
            builder: (context, constraints) {

                var tray = Tray(
                    key: UniqueKey(), 
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
}

// just the sidebar, a tray to hold buttons
class Tray extends StatelessWidget {
    
    // current ative item on tray
    final SidebarActionEnum? currentItem;

    const Tray({ 
        Key? key, 
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
                children: _buildTrayActions(context, Provider.of<SidebarActionsProvider>(context).actions, 27)
            ),
        );
    }

    List<Widget> _buildTrayActions(BuildContext context, List<SidebarAction> actions, double size){
        List<Widget> widgetList = [];
        List<Widget> bottomWidgetList = [];

        for(var action in actions){
            var widget = IconButtonSimple(
                onPressed: (){
                    // call sidebar action, open panel and callback logic
                    Actions.invoke(context, SidebarActionIntent(context, action));
                }, 
                pressed: ((currentItem == action.type) && action.openSidePanel) ? true : false,
                icon: action.icon,
                iconSize: size,
                tooltip: ((action.shortcut == null) ? action.tooltip : action.tooltip + " (" + singleActivatorToPrettyString(action.shortcut as SingleActivator) + ")"),
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                color: Theme.of(context).iconTheme.color,
                highlightColor: Theme.of(context).highlightColor,
            );

            if(action.toTheBottom == true){
                bottomWidgetList.add(widget);
            }
            else{
                widgetList.add(widget);
            }
        }

        widgetList.add(const Spacer());
        return widgetList + bottomWidgetList;
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
