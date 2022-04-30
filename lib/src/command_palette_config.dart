import 'package:command_palette/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            childrenActions: _buildSidebarActionList(),
        ),
        // file/dir actions
        CommandPaletteAction(
            label: "Explorer: Open folder",
            actionType: CommandPaletteActionType.single,
            onSelect: (){
                // todo: implement cache to access currently open folder 
            }
        ),
    ];
}

// create sidebar command list 
List<CommandPaletteAction> _buildSidebarActionList(){
    List<CommandPaletteAction> list = [];
    for(var action in trayItems){
        list.add(CommandPaletteAction(
            label: action.tooltip, 
            actionType: CommandPaletteActionType.single,
            onSelect: (){
                // todo: means of accesing currently opened sidebar action
            }
        ));
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
                    Provider.of<ConfigProvider>(context, listen: false).save();
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
