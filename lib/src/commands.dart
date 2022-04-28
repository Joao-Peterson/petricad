import 'package:command_palette/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'themes.dart';

List<CommandPaletteAction> buildCommandList(ThemesProvider provider){
    return [
        CommandPaletteAction(
            label: "Change color theme",
            // description: "Change the color scheme of the application UI",
            actionType: CommandPaletteActionType.nested,
            childrenActions: _buildThemeList(provider)
        )
    ];
}

List<CommandPaletteAction> _buildThemeList(ThemesProvider provider){
    List<CommandPaletteAction> list = [];
    var themeList = provider.getThemeNameList();

    for(var theme in themeList){
        list.add(
            CommandPaletteAction(
                label: theme,
                actionType: CommandPaletteActionType.single,
                onSelect: () {
                    provider.setTheme(theme);
                }
            )
        );
    }

    return list;
}

CommandPaletteConfig buildCommandConfig(ThemesProvider provider){
    return CommandPaletteConfig(
        openKeySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP),
        closeKeySet: LogicalKeySet(LogicalKeyboardKey.escape),
        transitionDuration: Duration.zero,
        style: const CommandPaletteStyle(
            elevation: 0,
            borderRadius: BorderRadius.all(Radius.zero),
            commandPaletteBarrierColor: Colors.transparent,
            highlightSearchSubstring: true,
            textFieldInputDecoration: InputDecoration(
                hintText: "Type a command ...",
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 1)
            )
            
        ),
    );
}