import 'package:flutter/material.dart';
import 'package:petricad/widgets/node_graph_editor.dart';

class Editor extends StatelessWidget {

    final bool leftBorderActive;
    
    const Editor({ 
        this.leftBorderActive = false,
        Key? key 
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            child: const NodeGraphEditor(),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                border: Border(
                    left: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: leftBorderActive ? 1 : 0,
                    )
                )
            ),
        );
    }
}