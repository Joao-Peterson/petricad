import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:path/path.dart' as p;
import 'package:petricad/src/themes.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class Explorer extends StatefulWidget {
    const Explorer({ Key? key }) : super(key: key);

    @override
    State<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {

    // ! remove this later
    String? _currentPath = "/home/peterson/source/petricad/";
    // String? _currentPath = null;
    late String _currentNode;
    late List<Node> _nodes;
    late TreeViewController _treeViewController;

    @override
    void initState(){
        if(_currentPath != null){
            _nodes = _buildNodeList(_currentPath!);
            _treeViewController = TreeViewController(
                children: [

                ]
            );
        }
        super.initState();
    }
    
    @override
    Widget build(BuildContext context) {
        if(_currentPath == null){
            return Container(
                alignment: Alignment.topCenter,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: TextButton(
                        child: const Text("Open folder"),
                        onPressed: () async {
                            _currentPath = await FilePicker.platform.getDirectoryPath();
                            setState(() {});
                        }, 
                    ),
                ),
            );
        }
        else{
            return Column(
                children: [
                    Tooltip(
                        child: Container(
                            child: Text("\"" + _currentPath! + "\"", 
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1,
                                        color: Theme.of(context).dividerColor,
                                    )
                                )
                            ),
                        ),
                        message: _currentPath!,
                        verticalOffset: 0,
                    ),
                    Expanded(
                        child: TreeView(
                            controller: _buildTreeViewController(_currentPath!),
                            theme: Provider.of<ThemesProvider>(context).getTheme().treeViewThemeData,
                        ),
                    ),
                ],
            );
        }
    }
}

// treeViewController builder
TreeViewController _buildTreeViewController(String dirPath){
    return TreeViewController(
        children: _buildNodeList(dirPath),
        selectedKey: null,
    );
}

// build node list based on the directory specified
List<Node> _buildNodeList(String dirPath){
    List<Node> list = [];
    var path = Directory(dirPath);

    for(var entity in path.listSync(recursive: false, followLinks: true)){
        switch (FileSystemEntity.typeSync(entity.path)){
            case FileSystemEntityType.directory:
                list.add(
                    Node(
                        key: entity.hashCode.toString(),
                        label: p.basename(entity.path),
                        icon: _getIcon(entity),
                        children: _buildNodeList(entity.path),
                    )
                );
            break;

            case FileSystemEntityType.file:
                list.add(
                    Node(
                        key: entity.hashCode.toString(),
                        label: p.basename(entity.path),
                        icon: _getIcon(entity),
                    )
                );
            break;

            case FileSystemEntityType.link:
            case FileSystemEntityType.notFound:
            default:
                list.add(
                    Node(
                        key: entity.hashCode.toString(),
                        label: p.basename(entity.path),
                        icon: _getIcon(entity),
                    )
                );            
            break;
        }
    }

    return list; 
}

// get material icons for folder/files 
IconData _getIcon(FileSystemEntity entity){
    IconData icon;

    switch(FileSystemEntity.typeSync(entity.path)){
        case FileSystemEntityType.directory:
            icon = Icons.folder;
            break;
        case FileSystemEntityType.file:
            icon = Icons.insert_drive_file_outlined;
            break;
            
        case FileSystemEntityType.link:
        case FileSystemEntityType.notFound:
        default:
            icon = Icons.clear;
            break;
    }

    return icon;
}