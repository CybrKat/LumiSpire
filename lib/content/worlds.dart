/// LumiSpire - the world, level and cosmetic catalogue.
///
/// This is the hand-authored content for the vertical slice. Two worlds are
/// fully playable across the maturity tiers — **Number Isles** (numeracy) and
/// **Cyber Harbour** (cybersecurity, ramping from "don't share your password"
/// for children up to phishing spotting for adults, in the spirit of Hack The
/// Box / Phriendly Phishing). The rest are teasers that unlock with coins and
/// are marked [GameWorld.comingSoon].
///
/// Questions are deliberately short; the difficulty ladder is expressed through
/// each level's [GameLevel.minTier].

library;

import 'package:flutter/material.dart';

import 'package:lumispire_app/models/game_models.dart';

/// Every world in the game, in map order.
const List<GameWorld> gameWorlds = [
  GameWorld(
    id: 'number_isles',
    name: 'Number Isles',
    tagline: 'Hop island to island, taming numbers as you go.',
    subject: Subject.numeracy,
    minTier: MaturityTier.sprout,
    icon: Icons.calculate_rounded,
    levels: [
      GameLevel(
        id: 'num_1',
        title: 'Counting Cove',
        minTier: MaturityTier.sprout,
        xpReward: 40,
        coinReward: 15,
        questions: [
          Question(
            prompt: 'How many apples? 🍎🍎🍎',
            options: ['2', '3', '4'],
            correctIndex: 1,
            explanation: 'Count them one by one: 1, 2, 3!',
          ),
          Question(
            prompt: 'Which number comes after 5?',
            options: ['4', '6', '7'],
            correctIndex: 1,
            explanation: '5 then 6 — we go up by one.',
          ),
        ],
      ),
      GameLevel(
        id: 'num_2',
        title: 'Adding Atoll',
        minTier: MaturityTier.explorer,
        questions: [
          Question(
            prompt: '7 + 5 = ?',
            options: ['11', '12', '13'],
            correctIndex: 1,
            explanation: '7 + 5 = 12.',
          ),
          Question(
            prompt: 'A pack has 4 rows of 3 stickers. How many stickers?',
            options: ['7', '12', '9'],
            correctIndex: 1,
            explanation: '4 × 3 = 12 — arrays are multiplication!',
          ),
        ],
      ),
      GameLevel(
        id: 'num_3',
        title: 'Fraction Fjord',
        minTier: MaturityTier.pathfinder,
        xpReward: 70,
        coinReward: 30,
        questions: [
          Question(
            prompt: 'Which is bigger: 1/2 or 3/4?',
            options: ['1/2', '3/4', 'They are equal'],
            correctIndex: 1,
            explanation: '3/4 = 0.75, which is more than 1/2 = 0.5.',
          ),
          Question(
            prompt: 'What is 25% of 80?',
            options: ['15', '20', '25'],
            correctIndex: 1,
            explanation: '25% is a quarter, and 80 ÷ 4 = 20.',
          ),
        ],
      ),
      GameLevel(
        id: 'num_4',
        title: 'Algebra Archipelago',
        minTier: MaturityTier.voyager,
        xpReward: 90,
        coinReward: 40,
        questions: [
          Question(
            prompt: 'Solve for x:  2x + 6 = 20',
            options: ['x = 5', 'x = 7', 'x = 8'],
            correctIndex: 1,
            explanation: '20 − 6 = 14, then 14 ÷ 2 = 7.',
          ),
          Question(
            prompt: 'A jacket is \$60 with 20% off. Final price?',
            options: ['\$40', '\$48', '\$52'],
            correctIndex: 1,
            explanation: '20% of 60 is 12, and 60 − 12 = 48.',
          ),
        ],
      ),
    ],
  ),
  GameWorld(
    id: 'cyber_harbour',
    name: 'Cyber Harbour',
    tagline: 'Guard the harbour — spot the tricks, stay safe online.',
    subject: Subject.cyber,
    minTier: MaturityTier.explorer,
    icon: Icons.shield_rounded,
    unlockCost: 40,
    levels: [
      GameLevel(
        id: 'cyber_1',
        title: 'Secret Keeper',
        minTier: MaturityTier.explorer,
        questions: [
          Question(
            prompt:
                'A game asks for your password to give you free coins. '
                'What do you do?',
            options: [
              'Type it in — free coins!',
              'Never share it, and tell a grown-up',
              'Share only the first letter',
            ],
            correctIndex: 1,
            explanation:
                'Passwords are secrets. Real games never need your password '
                'to give rewards.',
          ),
          Question(
            prompt: 'Which is the strongest password?',
            options: ['1234', 'password', 'Purple-Otter-97!'],
            correctIndex: 2,
            explanation:
                'Long passwords with a mix of words, numbers and symbols are '
                'much harder to guess.',
          ),
        ],
      ),
      GameLevel(
        id: 'cyber_2',
        title: 'Phish Market',
        minTier: MaturityTier.voyager,
        xpReward: 80,
        coinReward: 35,
        questions: [
          Question(
            prompt:
                'An email says "Your account is locked! Click here now to '
                'verify." What is the biggest red flag?',
            options: [
              'It says hello',
              'Urgency + a link asking you to log in',
              'It has a subject line',
            ],
            correctIndex: 1,
            explanation:
                'Phishing uses urgency to rush you onto a fake login page. '
                'Go to the site yourself instead of clicking.',
          ),
          Question(
            prompt: 'Best way to protect an important account?',
            options: [
              'Use the same password everywhere',
              'Turn on two-factor authentication (2FA)',
              'Write it on a sticky note',
            ],
            correctIndex: 1,
            explanation:
                '2FA adds a second step, so a stolen password alone is not '
                'enough to get in.',
          ),
        ],
      ),
      GameLevel(
        id: 'cyber_3',
        title: 'Breach Point',
        minTier: MaturityTier.pioneer,
        xpReward: 110,
        coinReward: 50,
        questions: [
          Question(
            prompt: 'A URL reads  https://paypa1.com/login  — what stands out?',
            options: [
              'Nothing, it is fine',
              'The domain is misspelled (paypa1 vs paypal)',
              'It uses https',
            ],
            correctIndex: 1,
            explanation:
                'Look-alike domains (a "1" for an "l") are a classic phishing '
                'trick. Always check the domain carefully.',
          ),
          Question(
            prompt:
                'You receive a document you were not expecting from a '
                'colleague. Safest first step?',
            options: [
              'Enable macros and open it',
              'Verify with the sender through another channel',
              'Forward it to the whole team',
            ],
            correctIndex: 1,
            explanation:
                'Confirming out-of-band catches compromised accounts before a '
                'malicious attachment runs.',
          ),
        ],
      ),
    ],
  ),
  GameWorld(
    id: 'story_glade',
    name: 'Story Glade',
    tagline: 'Words, tales and the magic of reading.',
    subject: Subject.literacy,
    minTier: MaturityTier.sprout,
    icon: Icons.menu_book_rounded,
    unlockCost: 30,
    comingSoon: true,
    levels: [],
  ),
  GameWorld(
    id: 'feelings_falls',
    name: 'Feelings Falls',
    tagline: 'Name big feelings and learn to ride the waves.',
    subject: Subject.emotions,
    minTier: MaturityTier.sprout,
    icon: Icons.favorite_rounded,
    unlockCost: 30,
    comingSoon: true,
    levels: [],
  ),
  GameWorld(
    id: 'time_terraces',
    name: 'Time Terraces',
    tagline: 'Climb through history, one era at a time.',
    subject: Subject.history,
    minTier: MaturityTier.pathfinder,
    icon: Icons.account_balance_rounded,
    unlockCost: 60,
    comingSoon: true,
    levels: [],
  ),
  GameWorld(
    id: 'code_canyon',
    name: 'Code Canyon',
    tagline: 'Bend logic to your will and build with code.',
    subject: Subject.coding,
    minTier: MaturityTier.pathfinder,
    icon: Icons.code_rounded,
    unlockCost: 80,
    comingSoon: true,
    levels: [],
  ),
  GameWorld(
    id: 'agora_heights',
    name: 'Agora Heights',
    tagline: 'How people decide together: society and politics.',
    subject: Subject.politics,
    minTier: MaturityTier.voyager,
    icon: Icons.how_to_vote_rounded,
    unlockCost: 90,
    comingSoon: true,
    levels: [],
  ),
  GameWorld(
    id: 'office_orbit',
    name: 'Office Orbit',
    tagline: 'Real-world digital skills: docs, sheets, and the web.',
    subject: Subject.digital,
    minTier: MaturityTier.voyager,
    icon: Icons.devices_rounded,
    unlockCost: 90,
    comingSoon: true,
    levels: [],
  ),
];

/// The cosmetic shop catalogue for the avatar.
const List<CosmeticItem> cosmeticCatalogue = [
  CosmeticItem(
    id: 'skin_default',
    name: 'Classic',
    type: CosmeticType.skin,
    cost: 0,
    emoji: '🙂',
    color: Color(0xFF7B5EA7),
  ),
  CosmeticItem(
    id: 'skin_robot',
    name: 'Robot',
    type: CosmeticType.skin,
    cost: 60,
    emoji: '🤖',
    color: Color(0xFF4361EE),
  ),
  CosmeticItem(
    id: 'skin_cat',
    name: 'Cat',
    type: CosmeticType.skin,
    cost: 60,
    emoji: '🐱',
    color: Color(0xFFEA7317),
  ),
  CosmeticItem(
    id: 'hat_crown',
    name: 'Crown',
    type: CosmeticType.hat,
    cost: 120,
    emoji: '👑',
    color: Color(0xFFF4C430),
  ),
  CosmeticItem(
    id: 'hat_wizard',
    name: 'Wizard hat',
    type: CosmeticType.hat,
    cost: 100,
    emoji: '🧙',
    color: Color(0xFF6A994E),
  ),
  CosmeticItem(
    id: 'outfit_explorer',
    name: 'Explorer kit',
    type: CosmeticType.outfit,
    cost: 90,
    emoji: '🎒',
    color: Color(0xFF2A9D8F),
  ),
  CosmeticItem(
    id: 'house_cottage',
    name: 'Cosy cottage',
    type: CosmeticType.house,
    cost: 200,
    emoji: '🏡',
    color: Color(0xFFEA7317),
  ),
  CosmeticItem(
    id: 'house_castle',
    name: 'Castle',
    type: CosmeticType.house,
    cost: 400,
    emoji: '🏰',
    color: Color(0xFFB07219),
  ),
];

/// Look up a world by id.
GameWorld? worldById(String id) {
  for (final w in gameWorlds) {
    if (w.id == id) return w;
  }
  return null;
}

/// Look up a cosmetic by id.
CosmeticItem? cosmeticById(String id) {
  for (final c in cosmeticCatalogue) {
    if (c.id == id) return c;
  }
  return null;
}
