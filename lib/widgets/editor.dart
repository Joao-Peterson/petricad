import 'package:flutter/material.dart';

class Editor extends StatelessWidget {

    final bool leftBorderActive;
    
    const Editor({ 
        this.leftBorderActive = false,
        Key? key 
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
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