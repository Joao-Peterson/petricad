import 'package:command_palette/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petricad/src/config.dart';
import 'package:provider/provider.dart';
import 'themes.dart';

List<CommandPaletteAction> buildCommandList(BuildContext context){
    return [
        CommandPaletteAction(
            label: "Change color theme",
            actionType: CommandPaletteActionType.nested,
            childrenActions: _buildThemeList(context)
        )
    ];
}

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
