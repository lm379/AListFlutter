import 'dart:developer';

import 'package:alist_flutter/generated/l10n.dart';
import 'package:alist_flutter/generated_api.dart';
import 'package:alist_flutter/pages/alist/alist.dart';
import 'package:alist_flutter/pages/app_update_dialog.dart';
import 'package:alist_flutter/pages/settings/settings.dart';
import 'package:alist_flutter/pages/web/web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MyHomePage(title: ""),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (await AppConfig().isAutoCheckUpdateEnabled()) {
        AppUpdateDialog.checkUpdateAndShowDialog(context, null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemBuilder: (context, index) {
          return [
            WebScreen(key: webGlobalKey),
            const AListScreen(),
            const SettingsScreen()
          ][index];
        },
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.preview),
            label: S.current.webPage,
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              "assets/alist.svg",
              color: Theme.of(context).hintColor,
              width: 32,
              height: 32,
            ),
            label: S.current.appName,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: S.current.settings,
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          log(index.toString());
          // Web
          if (_selectedIndex == 0 && index == 0) {
            webGlobalKey.currentState?.onClickNavigationBar();
          }

          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic);
        },
      ),
    );
  }
}

class NavigationBarController extends GetxController {
  final _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;

  void setIndex(int index) {
    _selectedIndex.value = index;
  }
}
