import 'package:command_palette/command_palette.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:petricad/src/actions.dart';
import 'package:petricad/src/cache.dart';
import 'package:petricad/src/config.dart';
import 'package:petricad/src/shortcut_to_string_list.dart';
import 'package:petricad/widgets/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'themes.dart';

List<CommandPaletteAction> buildCommandList(BuildContext context){
    return [
        // language/locale
        CommandPaletteAction(
            label: AppLocalizations.of(context)!.commandLocaleChangeLabel,
            actionType: CommandPaletteActionType.nested,
            childrenActions: _buildLocaleList(context),
        ),
        // theme
        CommandPaletteAction(
            label: AppLocalizations.of(context)!.commandThemeChangeLabel,
            actionType: CommandPaletteActionType.nested,
            childrenActions: _buildThemeList(context)
        ),
        // sidebar
        CommandPaletteAction(
            label: AppLocalizations.of(context)!.commandSidebarActionLabel,
            actionType: CommandPaletteActionType.nested,
            childrenActions: _buildSidebarActionList(context),
        ),
        // file/dir actions
        CommandPaletteAction(
            label: AppLocalizations.of(context)!.commandExplorerOpenLabel,
            actionType: CommandPaletteActionType.single,
            onSelect: () async {
                var dir = await FilePicker.platform.getDirectoryPath(
                    dialogTitle: AppLocalizations.of(context)!.explorerClosedFilePickDialogueTitle,
                );
                Provider.of<CacheProvider>(context, listen: false).setValue("openFolder", dir);
                Provider.of<CacheProvider>(context, listen: false).setValue("sidebarAction", TrayItemsEnum.explorer.index);
                Provider.of<CacheProvider>(context, listen: false).setValue("sidebarIsOpen", true);
            }
        ),
        CommandPaletteAction(
            label: AppLocalizations.of(context)!.commandExplorerCloseLabel,
            actionType: CommandPaletteActionType.single,
            onSelect: () {
                Provider.of<CacheProvider>(context, listen: false).setValue("openFolder", null);
            }
        ),
    ];
}

// create locales command list
List<CommandPaletteAction> _buildLocaleList(BuildContext context){
    List<CommandPaletteAction> list = [];
    
    for(var locale in AppLocalizations.supportedLocales){
        list.add(CommandPaletteAction(
            label: locale.toString(), 
            actionType: CommandPaletteActionType.single,
            onSelect: (){
                Provider.of<ConfigProvider>(context, listen: false).setConfig("locale.languageCode", locale.languageCode);
                Provider.of<ConfigProvider>(context, listen: false).setConfig("locale.countryCode", locale.countryCode);
                Provider.of<ConfigProvider>(context, listen: false).setConfig("locale.scriptCode", locale.scriptCode);
            }
        ));
    }

    return list;
}

// create sidebar command list 
List<CommandPaletteAction> _buildSidebarActionList(BuildContext context){
    List<CommandPaletteAction> list = [];
    for(var action in trayItems){
        list.add(
            CommandPaletteAction(
                label: action.tooltip, 
                actionType: CommandPaletteActionType.single,
                shortcut: action.shortcut != null ? singleActivatorToStringList(action.shortcut as SingleActivator) : null,
                onSelect: (){
                    Actions.invoke(context, SidebarActionIntent(context, action.type));
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

// config and style of the command palette
CommandPaletteConfig buildCommandConfig(BuildContext context){

    return CommandPaletteConfig(
        openKeySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP),
        closeKeySet: LogicalKeySet(LogicalKeyboardKey.escape),
        transitionDuration: Duration.zero,
        style: Provider.of<ThemesProvider>(context).getTheme().commandPaletteStyleData,
    );
}
