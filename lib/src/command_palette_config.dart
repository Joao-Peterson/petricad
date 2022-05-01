import 'package:command_palette/command_palette.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petricad/src/cache.dart';
import 'package:petricad/src/config.dart';
import 'package:petricad/widgets/sidebar.dart';
import 'package:provider/provider.dart';
import 'themes.dart';

List<CommandPaletteAction> buildCommandList(BuildContext context){
    return [
        // theme
        CommandPaletteAction(
            label: "Color: Change theme",
            actionType: CommandPaletteActionType.nested,
            childrenActions: _buildThemeList(context)
        ),
        // sidebar
        CommandPaletteAction(
            label: "Sidebar: Actions", 
            actionType: CommandPaletteActionType.nested,
            childrenActions: _buildSidebarActionList(context),
        ),
        // file/dir actions
        CommandPaletteAction(
            label: "Explorer: Open folder",
            actionType: CommandPaletteActionType.single,
            onSelect: () async {
                var dir = await FilePicker.platform.getDirectoryPath(
                    dialogTitle: "Select a folder to open",
                );
                Provider.of<CacheProvider>(context, listen: false).setValue("openFolder", dir);
                Provider.of<CacheProvider>(context, listen: false).setValue("sidebarAction", TrayItemsEnum.explorer.index);
                Provider.of<CacheProvider>(context, listen: false).setValue("sidebarIsOpen", true);
            }
        ),
        CommandPaletteAction(
            label: "Explorer: Close folder",
            actionType: CommandPaletteActionType.single,
            onSelect: () {
                Provider.of<CacheProvider>(context, listen: false).setValue("openFolder", null);
            }
        ),
    ];
}

// create sidebar command list 
List<CommandPaletteAction> _buildSidebarActionList(BuildContext context){
    List<CommandPaletteAction> list = [];
    for(var action in trayItems){
        list.add(
            CommandPaletteAction(
                label: action.tooltip, 
                actionType: CommandPaletteActionType.single,
                // shortcut: action.shortcut,
                onSelect: (){
                    if(Provider.of<CacheProvider>(context, listen: false).getValue("sidebarIsOpen")){
                        Provider.of<CacheProvider>(context, listen: false).setValue("sidebarAction", TrayItemsEnum.none.index);
                        Provider.of<CacheProvider>(context, listen: false).setValue("sidebarIsOpen", false);
                    }
                    else{
                        Provider.of<CacheProvider>(context, listen: false).setValue("sidebarAction", action.type.index);
                        Provider.of<CacheProvider>(context, listen: false).setValue("sidebarIsOpen", true);
                    }
                }
            )
        );
    }
    return list;
}

// create theme list
List<CommandPaletteAction> _buildThemeList(BuildContext context){
    List<CommandPaletteAction> list = [];
    var provider = Provider.of<ThemesProvider>(context, listen: false);
    var themeList = provider.getThemeNameList();

    for(var theme in themeList){
        list.add(
            CommandPaletteAction(
                label: theme,
                actionType: CommandPaletteActionType.single,
                onSelect: () {
                    provider.setTheme(theme);
                    Provider.of<ConfigProvider>(context, listen: false).setConfig<String>("visual.theme", theme);
                }
            )
        );
    }

    return list;
}

CommandPaletteConfig buildCommandConfig(BuildContext context){
    return CommandPaletteConfig(
        openKeySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP),
        closeKeySet: LogicalKeySet(LogicalKeyboardKey.escape),
        transitionDuration: Duration.zero,
        style: Provider.of<ThemesProvider>(context).getTheme().commandPaletteStyleData,
    );
}
