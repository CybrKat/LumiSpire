/// LumiSpire - app-wide constants.
///
/// LumiSpire is a world-exploring learning game whose progress, skills and
/// avatar all live **encrypted on the player's own Solid POD**.

library;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:solidui/solidui.dart' show SolidFileUploadConfig;

/// Window / login title.
const String appTitle = 'LumiSpire - Explore. Learn. Level up.';

/// The Solid server LumiSpire authenticates against (pre-fills the login form).
const String appServerUrl = 'https://pods.solidcommunity.au';

/// Solid-OIDC client registration. Update these for your own deployment; the
/// [appClientId] must resolve to a hosted client-profile document listing
/// exactly the redirect URIs resolved below.
const String appClientId =
    'https://cybrkat.github.io/LumiSpire/client-profile.jsonld';

List<String> get appRedirectUris => kIsWeb
    ? ['https://cybrkat.github.io/LumiSpire/redirect.html']
    : const [
        'com.example.lumispireapp://redirect',
        'http://localhost:4400/redirect.html',
      ];

List<String> get appPostLogoutRedirectUris => appRedirectUris;

/// The application folder created on the user's POD to store LumiSpire data.
const String appPodDirectory = 'lumispire_app';

/// Homepage opened from the login page's info button.
const String appLink = 'https://cybrkat.github.io/LumiSpire/';

/// Public URL where LumiSpire is hosted (used by Invite Others).
const String appUrl = 'https://LumiSpire.solidcommunity.au/';

/// Relative path (within the app's `data` directory on the POD) of the single
/// document holding all player progress.
///
/// The extension MUST be `.ttl`: solidpod stores *encrypted* resources as
/// Turtle documents and rejects other extensions for an encrypted write. The
/// JSON we serialise is the plaintext that gets encrypted into this file.
const String progressFile = 'lumispire_progress.ttl';

/// Shared upload configuration for any `SolidFile` view in LumiSpire.
const SolidFileUploadConfig appUploadConfig = SolidFileUploadConfig(
  allowedExtensions: ['ttl', 'json', 'txt'],
);
