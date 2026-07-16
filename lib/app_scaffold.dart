/// LumiSpire - the primary application scaffold.
///
/// A [SolidScaffold] whose navigation exposes the game's top-level areas: the
/// world map, the avatar wardrobe, the player's profile & skills, the privacy /
/// sharing centre, and a raw view of the files stored on their Pod.

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:lumispire_app/constants/app.dart';
import 'package:lumispire_app/screens/browse_files.dart';
import 'package:lumispire_app/screens/privacy_screen.dart';
import 'package:lumispire_app/screens/profile_screen.dart';
import 'package:lumispire_app/screens/wardrobe.dart';
import 'package:lumispire_app/screens/world_map.dart';

final _scaffoldController = SolidScaffoldController();

const appScaffold = AppScaffold();

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return SolidScaffold(
      controller: _scaffoldController,
      hideNavRail: false,
      enableProfile: true,
      onLogout: (context) => SolidAuthHandler.instance.handleLogout(context),
      menu: const [
        SolidMenuItem(
          icon: Icons.explore_rounded,
          title: 'Explore',
          tooltip: '''

            **Explore**

            Your world map. Dive into worlds to learn subjects, earn XP and
            coins, and unlock new areas.

            ''',
          child: WorldMap(),
        ),
        SolidMenuItem(
          icon: Icons.checkroom_rounded,
          title: 'Wardrobe',
          tooltip: '''

            **Wardrobe**

            Spend your coins on skins, hats, outfits and houses for your
            avatar, then equip them.

            ''',
          child: Wardrobe(),
        ),
        SolidMenuItem(
          icon: Icons.person_rounded,
          title: 'My Explorer',
          tooltip: '''

            **My Explorer**

            Set your name and age, see the skills you have gathered, and load a
            demo save to try everything.

            ''',
          child: ProfileScreen(),
        ),
        SolidMenuItem(
          icon: Icons.lock_rounded,
          title: 'Privacy',
          tooltip: '''

            **Privacy & Sharing**

            See how your encrypted data stays yours, manage consent, and share
            read-only progress with a grown-up or teacher.

            ''',
          child: PrivacyScreen(),
        ),
        SolidMenuItem(
          icon: Icons.folder_rounded,
          title: 'My Files',
          tooltip: '''

            **My Files**

            Browse the raw files LumiSpire stores on your Pod.

            ''',
          child: BrowseFiles(),
        ),
      ],
      appBar: SolidAppBarConfig(title: appTitle.split(' - ')[0]),
      themeToggle: const SolidThemeToggleConfig(
        enabled: true,
        showInAppBarActions: true,
      ),
      child: const WorldMap(),
    );
  }
}
