import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petricad/src/actions.dart';
import 'package:petricad/src/cache.dart';
import 'package:petricad/src/licenses.dart';
import 'package:petricad/src/shortcuts.dart';
import 'package:petricad/src/sidebar_actions.dart';
import 'package:provider/provider.dart';
import 'package:command_palette/command_palette.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'src/platforminfo.dart';
import 'src/filemgr.dart';
import 'src/config.dart';
import 'src/themes.dart';
import 'src/command_palette_config.dart';
import 'src/licenses.dart';
import 'widgets/toolbar.dart';
import 'widgets/sidebar.dart';
import 'widgets/statusbar.dart';

void main() async{

    // make sure to initialize the framework binding before DesktopWindow calls
    WidgetsFlutterBinding.ensureInitialized();

    // files
    Filemgr fileMgr = Filemgr();
    await fileMgr.addStdDir();
    await fileMgr.addLogFile("log", "log.txt", "std");
    await fileMgr.addNewFile("config", "config.json", "std", defaultContent: await rootBundle.loadString("assets/config.json"));
    await fileMgr.addNewFile("cache", "cache.json", "std", defaultContent: await rootBundle.loadString("assets/cache.json"));
    await fileMgr.addDirToDir("themes", "themes/", "std");
    await fileMgr.addNewFile("owlet-palenight", "owlet-theme-palenight.json", "themes", 
        defaultContent: await rootBundle.loadString("assets/themes/owlet-theme-palenight.json")
    );

    // licenses
    LicenseRegistry.addLicense(() async* {
        yield LicenseEntryWithLineBreaks(
            licenseOwlet.name,
            licenseOwlet.license,
        );
    });

    // get paths for config and themes
    String? configPath = fileMgr.getFilePath("config");
    String? cachePath = fileMgr.getFilePath("cache");
    String? themesDir = fileMgr.getDirPath("themes");
    if(
        configPath == null || 
        themesDir == null ||
        cachePath == null
    ){
        exit(-1);
    }

    // set min window size, (DesktopWindow package), on desktop builds
    // await because its a Future<> call, async on main() 
    if(PlatformInfo.isDesktop()){
        await DesktopWindow.setMinWindowSize(const Size(500, 500));
    }

    var configProvider          = ConfigProvider(filename: configPath);
    var cacheProvider           = CacheProvider(filename: cachePath);
    var themeProvider           = ThemesProvider(themesDir: themesDir, startTheme: configProvider.getConfig<String>("visual.theme") ?? "Owlet (Palenight)");
    var sidebarActionsProvider  = SidebarActionsProvider();

    runApp(
        MultiProvider(
            providers: [
                ChangeNotifierProvider(create: (context) {return fileMgr;}),
                ChangeNotifierProvider(create: (context) {return configProvider;}),
                ChangeNotifierProvider(create: (context) {return themeProvider;}),
                ChangeNotifierProvider(create: (context) {return cacheProvider;}),
                ChangeNotifierProvider(create: (context) {return sidebarActionsProvider;}),
            ],
            child: const App()
        )
    );
}

class App extends StatelessWidget {
    
    const App({ Key? key }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        
        return MaterialApp(
            title: "PetriCAD",
            theme: Provider.of<ThemesProvider>(context).getTheme().libThemeData,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: Locale.fromSubtags(
                languageCode: Provider.of<ConfigProvider>(context).getConfig("locale.languageCode"),
                countryCode: Provider.of<ConfigProvider>(context).getConfig("locale.countryCode"),
                scriptCode: Provider.of<ConfigProvider>(context).getConfig("locale.scriptCode"),
            ),

            home: Builder(
                builder: (context) {
                    // remake trayitems tooltips on locale change before command palette and sidebar and their shorcuts
                    Provider.of<SidebarActionsProvider>(context, listen: false).update(context);
                    return Scaffold(
                        body: Shortcuts(
                            shortcuts: buildShortcuts(context),
                            child: Actions(
                                actions: buildActions(),
                                child: Builder(
                                    builder: (context) {
                                        return CommandPalette(
                                            // focus should be below Commandpalette to do not disturb its internal shortcut focus
                                            child: Focus(
                                                autofocus: true,
                                                child: Column(children: const [
                                                    Toolbar(),
                                                    Expanded(
                                                        child: Sidebar()
                                                    ),
                                                    Statusbar()
                                                ],),
                                            ),
                                            config: buildCommandConfig(context),
                                            actions: buildCommandList(context),
                                        );
                                    }
                                ),
                            ),
                        ),
                    );
                }
            )
        );
    }
}