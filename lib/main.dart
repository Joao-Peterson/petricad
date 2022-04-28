import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:command_palette/command_palette.dart';
import 'src/platforminfo.dart';
import 'src/filemgr.dart';
import 'src/config.dart';
import 'src/themes.dart';
import 'src/commands.dart';
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
    await fileMgr.addDirToDir("themes", "themes/", "std");
    await fileMgr.addNewFile("owlet-palenight", "owlet-theme-palenight.json", "themes", 
        defaultContent: await rootBundle.loadString("assets/themes/owlet-theme-palenight.json")
    );

    // get paths for config and themes
    String? configPath = fileMgr.getFilePath("config");
    String? themesDir = fileMgr.getDirPath("themes");
    if(configPath == null || themesDir == null){
        exit(-1);
    }

    // set min window size, (DesktopWindow package), on desktop builds
    // await because its a Future<> call, async on main() 
    if(PlatformInfo.isDesktop()){
        await DesktopWindow.setMinWindowSize(const Size(500, 500));
    }

    runApp(
        MultiProvider(
            providers: [
                ChangeNotifierProvider(create: (context) => ConfigProvider(filename: configPath)),
                ChangeNotifierProvider(create: (context) => ThemesProvider(themesDir: themesDir)),
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

            home: CommandPalette(
                child: Scaffold(
                    body: Column(children: const [
                        Toolbar(),
                        Expanded(
                            child: Sidebar()
                        ),
                        Statusbar()
                    ],)
                ),
                config: buildCommandConfig(Provider.of<ThemesProvider>(context)),
                actions: buildCommandList(Provider.of<ThemesProvider>(context)),
            )
        );
    }
}
