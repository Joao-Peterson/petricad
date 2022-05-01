import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:path/path.dart' as p;
import 'package:petricad/src/themes.dart';
import 'package:petricad/widgets/sidebar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import '../src/cache.dart';

import 'package:provider/provider.dart';

class Explorer extends StatefulWidget {
    const Explorer({ Key? key }) : super(key: key);

    @override
    State<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {

    String? _currentPath = null;
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

        _currentPath = Provider.of<CacheProvider>(context).getValue<String>("openFolder");
        
        if(_currentPath == null){
            return Container(
                alignment: Alignment.topCenter,
                child: Column(
                    children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(5,20,5,5),
                            child: Text(AppLocalizations.of(context)!.explorerClosedText),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(5,5,5,20),
                            child: TextButton(
                                child: Text(AppLocalizations.of(context)!.explorerClosedButtonLabel),
                                onPressed: () async {
                                    _currentPath = await FilePicker.platform.getDirectoryPath(
                                        dialogTitle: AppLocalizations.of(context)!.explorerClosedFilePickDialogueTitle,
                                    );
                                    Provider.of<CacheProvider>(context, listen: false).setValue("openFolder", _currentPath);
                                    Provider.of<CacheProvider>(context, listen: false).setValue("sidebarAction", TrayItemsEnum.explorer.index);
                                    Provider.of<CacheProvider>(context, listen: false).setValue("sidebarIsOpen", true);
                                }, 
                            ),
                        ),
                    ],
                ),
            );
        }
        else{
            return Column(
                children: [
                    Tooltip(
                        child: Container(
                            child: Text("\"" + AppLocalizations.of(context)!.explorerOpenFolderPrefix + _currentPath! + "\"", 
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: Theme.of(context).textTheme.button?.copyWith(fontSize: 11),
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

    list = _sortNodeList(list);

    return list; 
}

// sorst map alphabetically
List<Node> _sortNodeList(List<Node> list){
    list.sort((a,b){
        return a.label.compareTo(b.label);
    });

    for(var node in list){
        if(node.children.isNotEmpty){
            node = node.copyWith(children: _sortNodeList(node.children)); 
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