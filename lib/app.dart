/// LumiSpire - root widget; wraps the game in Solid login.
///
/// On startup [SolidLogin] connects the player to their own Pod on their chosen
/// Solid server; once authenticated it hands over to [appScaffold]. The bright
/// "explorer" theme (see lib/theme.dart) carries the playful, all-ages feel.

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:lumispire_app/app_scaffold.dart';
import 'package:lumispire_app/constants/app.dart';
import 'package:lumispire_app/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return SolidThemeApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: lumiLightTheme,
      darkTheme: lumiDarkTheme,
      home: SolidLogin(
        title: 'LumiSpire\nExplore. Learn. Level up.',
        webID: appServerUrl,
        appDirectory: appPodDirectory,
        link: appLink,
        clientId: appClientId,
        redirectUris: appRedirectUris,
        postLogoutRedirectUris: appPostLogoutRedirectUris,
        child: appScaffold,
      ),
    );
  }
}
