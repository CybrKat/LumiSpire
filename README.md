# LumiSpire

**A world-exploring learning game where every adventure teaches a real skill —
and all of your progress lives encrypted on your own Solid Pod, so it belongs to
you (or your family), not a game company.**

Explore themed worlds (numeracy, cybersecurity, literacy, coding, emotions, and
more), clear levels to earn **XP** and **coins**, and spend them to unlock new
worlds and cosmetics for your avatar. Difficulty scales with the player's
**maturity tier** (ages 2–50), so the same subject grows with the learner — from
"don't share your password" for children up to phishing-spotting for adults, in
the spirit of Hack The Box / Phriendly Phishing.

Inspired by the exploration + progression loops of Roblox, Minecraft, Animal
Crossing, Stardew Valley, Dress to Impress and No Man's Sky — pointed at
building skills for life.

## Features (vertical slice)

- **World map** — explorable worlds, gated by coins and maturity tier.
- **Playable levels** — two worlds fully built (Number Isles, Cyber Harbour)
  with a quiz loop that teaches on every answer; the rest are coin-unlockable
  teasers.
- **Progression** — XP → player levels, coins, per-subject **skill tracking**.
- **Wardrobe** — buy & equip skins, hats, outfits and houses for your avatar.
- **My Explorer** — set name & age (maturity tier), see skills gathered, and
  **load a demo save** to explore everything instantly.
- **Privacy & Sharing** — data-ownership explainer, **consent** toggles
  (including parental consent), and real **WAC/ACP** sharing (grant read-only to
  a teacher/guardian, revoke anytime).

## How it uses Solid

- **Reads and writes** the player's progress to their own Pod (`readPod` /
  `writePod`) through an authenticated Solid session.
- **Encryption is default** — progress is stored with `writePod(encrypted:
  true)` as an encrypted Turtle document (`lumispire_progress.ttl`).
- **Access control (WAC/ACP) + consent** — `grantPermission` / `readPermission`
  / `revokePermission`, each behind an explicit consent step.
- **Data minimisation** — only game progress is stored; nothing is sold.

## Getting started

```bash
flutter pub get
flutter run            # or: flutter run -d chrome / -d windows
flutter test           # progression rules
```

New here? After logging in, open **My Explorer → "Load demo save"** to fill your
Pod with coins, progress and cosmetics and try every feature.

## Project layout

```
lib/
  main.dart              Entry point.
  app.dart               Root widget; wraps the game in SolidLogin.
  app_scaffold.dart      SolidScaffold nav (Explore / Wardrobe / Profile / Privacy / Files).
  theme.dart             Bright "explorer" theme (indigo/teal/amber).
  constants/app.dart     App constants, Solid-OIDC config, progress file.
  content/worlds.dart    World, level, question and cosmetic catalogue.
  models/
    game_models.dart     Maturity tiers, subjects, worlds, levels, questions, cosmetics.
    player_profile.dart  Persisted progress (coins, XP, unlocks, skills, consent).
  services/
    progression.dart     Pure rules: levels, gating, rewards (unit-tested).
    game_repository.dart  Loads/saves encrypted progress on the Pod.
  screens/
    world_map.dart       Home: player header + world grid.
    world_screen.dart    A world's level path.
    play_screen.dart     The quiz gameplay loop + rewards.
    wardrobe.dart        Avatar + cosmetic shop.
    profile_screen.dart  Name, age/tier, skills, demo save.
    privacy_screen.dart  Data ownership, consent, WAC/ACP sharing.
    browse_files.dart    Raw Pod file browser.
test/
  progression_test.dart  Deterministic tests for the progression rules.
```

> LumiSpire is educational entertainment. It gathers learning signals (skills,
> progress) only on the player's own Pod, with consent, to personalise
> difficulty — never to sell.
