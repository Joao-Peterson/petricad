import 'package:flutter/material.dart';

class Statusbar extends StatelessWidget {
    const Statusbar({ Key? key }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            height: 21,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                // border: Border(top: BorderSide(width: 1, color: Theme.of(context).dividerColor))
            ),
        );
    }
}
