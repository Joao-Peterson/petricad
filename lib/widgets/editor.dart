import 'package:flutter/material.dart';

class Editor extends StatelessWidget {
    const Editor({ Key? key }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                border: Border(
                    left: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 2,
                    )
                )
            ),
        );
    }
}