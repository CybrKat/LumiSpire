/// LumiSpire - browse the raw files on the player's POD.
///
/// Uses solidui's [SolidFile] browser so the player (or a curious grown-up) can
/// see exactly which resources LumiSpire stores on their Pod — reinforcing that
/// the data is theirs and lives on their own server.

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:lumispire_app/constants/app.dart';

class BrowseFiles extends StatelessWidget {
  const BrowseFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return const SolidFile(
      currentPath: SolidFile.podRoot,
      friendlyFolderName: 'All Files and Folders',
      uploadConfig: appUploadConfig,
    );
  }
}
