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

            child: Row(
                children: [
                    Container(
                        child: PopupMenuButton<String>(
                            child: const Text("Settings"),
                            itemBuilder: (context) {
                                return [
                                    const PopupMenuItem(
                                        child: Text("Visual"),
                                        height: 0,
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    ),
                                    const PopupMenuDivider(height: 1),
                                    const PopupMenuItem(
                                        child: Text("FF"),
                                        height: 0,
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    ),
                                ];
                            },
                            offset: Offset.zero,
                            elevation: 0,
                            padding: const EdgeInsets.all(0),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                            ),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                    )
                ],
            )
        );
    }
}


