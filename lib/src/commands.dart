import 'package:command_palette/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'themes.dart';

List<CommandPaletteAction> buildCommandList(BuildContext context){
    return [
        CommandPaletteAction(
            label: "Change color theme",
            actionType: CommandPaletteActionType.nested,
            childrenActions: _buildThemeList(Provider.of<ThemesProvider>(context))
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

CommandPaletteConfig buildCommandConfig(BuildContext context){
    return CommandPaletteConfig(
        openKeySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP),
        closeKeySet: LogicalKeySet(LogicalKeyboardKey.escape),
        transitionDuration: Duration.zero,

        style: CommandPaletteStyle(
            elevation: 5,
            borderRadius: BorderRadius.zero,
            commandPaletteBarrierColor: Colors.black12,
            highlightSearchSubstring: true,

            actionLabelTextStyle: Theme.of(context).textTheme.subtitle1,
            highlightedLabelTextStyle: Theme.of(context).textTheme.subtitle1?.copyWith(
                color: Theme.of(context).colorScheme.inversePrimary
            ),

            actionColor: Theme.of(context).colorScheme.primary,
            selectedColor: Theme.of(context).colorScheme.tertiary,

            textFieldInputDecoration: const InputDecoration(
                hintText: "Type a command ...",
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            )
        ),
    );
}
