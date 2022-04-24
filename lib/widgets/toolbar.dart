import 'package:flutter/material.dart';

class Toolbar extends StatelessWidget {
    const Toolbar({ Key? key }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            height: 24,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border(bottom: BorderSide(width: 1, color: Theme.of(context).dividerColor))
            ),
        );
    }
}


