# mod-forever-class-combos

An [AzerothCore](https://www.azerothcore.org/) (WotLK 3.3.5a) module that unlocks the new
race/class combinations from World of Warcraft: Forever:

| Faction  | Combo          |
|----------|----------------|
| Horde    | Orc Mage       |
| Horde    | Troll Warlock  |
| Horde    | Undead Paladin |
| Alliance | Human Hunter   |
| Alliance | Gnome Priest   |
| Alliance | Dwarf Shaman   |

Forever's new Skyborne race and its reworked racials are not included.

Forked from [maluramichael/mod-race-class-combos](https://github.com/maluramichael/mod-race-class-combos).

## What it does

- **Character creation.** Each combo gets a start position in its race's starting zone, an
  action bar and starter gear. Starting skills and spells need no extra rows: the core keys them
  by race and class bitmasks (`playercreateinfo_skills`, `playercreateinfo_spell_custom`), so a
  race's racials and a class's abilities already cover any new pairing.
- **Class quests.** Class quests only allow the races that could originally play the class
  (`quest_template.AllowableRaces`). Without a fix the new combos could never learn quest-only
  spells and items: Tame Beast, the Voidwalker, Redemption and the paladin mounts. The module
  lets each new race take the single-class quests of a same-faction donor race:

  | Combo          | Donor race | Where                     |
  |----------------|------------|---------------------------|
  | Human Hunter   | Dwarf      | Kharanos, Dun Morogh      |
  | Troll Warlock  | Orc        | Valley of Trials, Durotar |
  | Undead Paladin | Blood Elf  | Eversong / Silvermoon     |
  | Orc Mage       | Troll      | Valley of Trials, Durotar |

  Gnome Priests need no donor: the only priest quests they can't take are other races'
  racial-spell quests (Desperate Prayer, Fear Ward). Dwarf Shamans have no donor either: the
  only Alliance shaman quests are on Azuremyst and Bloodmyst Isle, so they get their own (below).
- **Dwarf Shaman totem quests.** The Call of Earth, Fire, Water and Air chains are rebuilt in
  Khaz Modan for dwarves. They follow the Draenei chains step for step and use the same quest
  items, with new text, copies of the elemental spirits and creatures that already live there:

  | Quest         | Level | Starts at                | Where it goes                                              | Reward                             |
  |---------------|-------|--------------------------|------------------------------------------------------------|------------------------------------|
  | Call of Earth | 4     | Farseer Amaan, Anvilmar  | Spirit of the Ridge at Talin Keeneye's camp; Burly Rockjaw Troggs | Stoneskin Totem             |
  | Call of Fire  | 10    | Farseer Javad, Ironforge | Smolder in Brewnall Village; Frostmane Seers on Shimmer Ridge; the effigy at Frostmane Hold | Fire Totem, Searing Totem |
  | Call of Water | 20    | Farseer Javad, Ironforge | Meltwater in the Loch; Black Slimes in the Wetlands; the Stonewrought Dam; Tel'athion's barrel in the marsh | Water Totem, Healing Stream Totem |
  | Call of Air   | 30    | Farseer Javad, Ironforge | Skirl at the south end of the Thandol Span                 | Air Totem                          |

  Farseer Javad also gives Call of Earth, for dwarves who have already left Coldridge Valley.
  Trainers don't teach rank 1 of Stoneskin, Searing or Healing Stream Totem; the quests do, and
  the higher ranks need them. Dwarves are no longer offered the Draenei chains, and a dwarf who
  already finished one isn't offered the matching dwarf chain. The quests, creatures and objects
  use entries 9500210–9500223. No client patch is needed for them.
- **Start-zone trainers.** Three of the new combos have no trainer for their class in their
  starting zone, so the module adds one. Each is a copy of a capital trainer of that class, with
  the same spells and its own name:

  | Combo          | Trainer                   | Where                        | Copied from                          |
  |----------------|---------------------------|------------------------------|--------------------------------------|
  | Human Hunter   | Brannoc Stoneshield       | Northshire Abbey             | Thorfin Stoneshield, Stormwind       |
  | Dwarf Shaman   | Farseer Amaan             | Anvilmar, Coldridge Valley   | Farseer Javad, Ironforge             |
  | Undead Paladin | Champion Aeldris Dawnrose | Deathknell church            | Champion Cyssa Dawnrose, Undercity   |

  They use creature entries and spawn guids 9500200–9500202.
- **Earth Totem.** Dwarf Shamans start with an Earth Totem, so Earthbind Totem works from the
  trainer at level 6 even before Call of Earth is done.
- **Weapon skills.** A character only gets a skill if a `SkillRaceClassInfo` row covers its race
  and class. Some stock weapon rows list only the races that could originally play the class, so
  the module overrides them in `skillraceclassinfo_dbc` to add the new race:

  | Combo          | Skills                 |
  |----------------|------------------------|
  | Undead Paladin | Swords                 |
  | Human Hunter   | Axes, Guns, Daggers    |

  Human Hunters also get Guns as a starting skill. Existing characters pick the skills up on
  their next login. The client reads the same table to decide which skills the character window
  lists, so the client patch carries a matching `SkillRaceClassInfo.dbc`.

All SQL is safe to run more than once.

## Installation

```bash
cd azerothcore/modules
git clone https://github.com/buildthehomelab/wow-mod-forever-class-combos.git mod-forever-class-combos
```

Clone into `mod-forever-class-combos` exactly: AzerothCore derives the module's loader function from the
folder name. Rebuild the worldserver; the SQL applies on the next start.

## Client patch required

The 3.3.5a client decides which combinations to offer on the character-creation screen from
`CharBaseInfo.dbc`. Copy `Client_Patch/patch-8.MPQ` into each client's `Data/` folder (rename it
if `patch-8.MPQ` is already taken). Without it the server accepts the combinations but the client
won't let you pick them.
The patch also carries `CharStartOutfit.dbc` with starter outfits for the new combos, so the
character-creation preview shows their gear, and `SkillRaceClassInfo.dbc` with the weapon-skill
rows above. Without that file the combos can still use those weapons, but the skills are missing
from the character window's Skills tab.

## Configuration

`conf/mod_forever_class_combos.conf.dist`:

| Key                           | Default | Description                       |
|-------------------------------|---------|-----------------------------------|
| `ForeverClassCombos.Announce` | `1`     | Log a line at startup when active |

## License

Released under the GNU GPL v2 (or later).
