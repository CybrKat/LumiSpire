/// LumiSpire - main entry point.
///
/// A world-exploring learning game whose progress lives encrypted on the
/// player's own Solid Pod.

library;

import 'package:flutter/material.dart';

import 'package:lumispire_app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
