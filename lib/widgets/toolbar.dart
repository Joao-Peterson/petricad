import 'package:command_palette/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

            child: DefaultTextStyle(
                style: Theme.of(context).textTheme.button!,
                child: Row(
                    children: [
                        Container(
                            child: PopupMenuButton<String>(
                                child: Text(AppLocalizations.of(context)!.toolbarToolsLabel),
                                itemBuilder: (context) {
                                    return [
                                        PopupMenuItem(
                                            child: Text(AppLocalizations.of(context)!.toolbarToolsEntryCommandPalette),
                                            value: "commandPalette",
                                            height: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                                        ),
                                        // const PopupMenuDivider(height: 1),
                                    ];
                                },
                                offset: Offset.zero,
                                padding: const EdgeInsets.all(0),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                ),
                                onSelected: (item){
                                    switch (item) {
                                        case "commandPalette":
                                            CommandPalette.of(context).open();   
                                        break;
                                    }
                                },
                                tooltip: AppLocalizations.of(context)!.toolbarToolsTooltip,
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        Container(
                            child: PopupMenuButton<String>(
                                child: Text(AppLocalizations.of(context)!.toolbarHelpLabel),
                                itemBuilder: (context) {
                                    return [
                                        PopupMenuItem(
                                            child: Text(AppLocalizations.of(context)!.toolbarHelpEntryAbout),
                                            value: "about",
                                            height: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                                        ),
                                        // const PopupMenuDivider(height: 1),
                                    ];
                                },
                                offset: Offset.zero,
                                padding: const EdgeInsets.all(0),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                ),
                                onSelected: (item) async {
                                    switch (item) {
                                        case "about":
                                            var pinfo = await PackageInfo.fromPlatform();
                                            showAboutDialog(
                                                context: context,
                                                applicationLegalese: AppLocalizations.of(context)!.aboutLegalese,
                                                applicationName: pinfo.appName.toUpperCase(),
                                                applicationVersion: "Version: " + pinfo.version + "\nBuild: " + pinfo.buildNumber,
                                            );
                                        break;
                                    }
                                },
                                tooltip: AppLocalizations.of(context)!.toolbarHelpTooltip,
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                    ],
                ),
            )
        );
    }
}


