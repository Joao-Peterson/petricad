import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'src/platforminfo.dart';
import 'dart:io';
import 'src/filemgr.dart';
import 'themes/dark.dart';
import 'widgets/toolbar.dart';
import 'widgets/sidebar.dart';

void main() async{

    Filemgr fileMgr = Filemgr();
    await fileMgr.addStdDir();
    await fileMgr.addNewFile("config.json", "std");
    await fileMgr.addLogFile("log.txt", "std");

    await fileMgr.logInfo("Hi");
    await fileMgr.logWarning("Watch out");
    await fileMgr.logError("RUNNNN!!@@^^^^^~~~~~~");

    // make sure to initialize the framework binding before DesktopWindow calls
    WidgetsFlutterBinding.ensureInitialized();

    // set min window size, (DesktopWindow package), on desktop builds
    // await because its a Future<> call, async on main() 
    if(PlatformInfo.isDesktop()){
        await DesktopWindow.setMinWindowSize(const Size(500, 500));
    }

    runApp(const App());
}

class App extends StatelessWidget {
    const App({ Key? key }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: "PetriCAD",
            home: const Home(),
            theme: Themes.dark,
        );
    }
}

class Home extends StatelessWidget {
    const Home({ Key? key }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Column(children: const [
                Toolbar(),
                Expanded(
                    child: Sidebar()
                ),
                Statusbar()
            ],)
        );
    }
}

class Statusbar extends StatelessWidget {
    const Statusbar({ Key? key }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            height: 21,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                // border: Border(top: BorderSide(width: 1, color: Theme.of(context).dividerColor))
            ),
        );
    }
}
