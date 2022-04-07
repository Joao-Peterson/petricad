import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'dart:io';

class Explorer extends StatefulWidget {
    const Explorer({ Key? key }) : super(key: key);

    @override
    State<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {

    String? _current_path;
    // late TreeViewController _treeViewController;

    @override
    void initState(){

        
        // _treeViewController = TreeViewController(
        //     children: [

        //     ]
        // );

        super.initState();
    }
    
    @override
    Widget build(BuildContext context) {
        return Container(
            // child: TreeView(
            //     controller: _treeViewController
            // ),
        );
    }
}