# mod-forever-races

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
  spells and items: Tame Beast, the Water and Air Totems, the Voidwalker, Redemption and the
  paladin mounts. The module lets each new race take the single-class quests of a same-faction
  donor race:

  | Combo          | Donor race | Where                     |
  |----------------|------------|---------------------------|
  | Human Hunter   | Dwarf      | Kharanos, Dun Morogh      |
  | Dwarf Shaman   | Draenei    | Azuremyst Isle / Exodar   |
  | Troll Warlock  | Orc        | Valley of Trials, Durotar |
  | Undead Paladin | Blood Elf  | Eversong / Silvermoon     |
  | Orc Mage       | Troll      | Valley of Trials, Durotar |
  | Gnome Priest   | Dwarf      | Coldridge Valley          |

All SQL is safe to run more than once.

## Installation

```bash
cd azerothcore/modules
git clone https://github.com/buildthehomelab/wow-mod-forever-races.git mod-forever-races
```

Clone into `mod-forever-races` exactly: AzerothCore derives the module's loader function from the
folder name. Rebuild the worldserver; the SQL applies on the next start.

## Client patch required

The 3.3.5a client decides which combinations to offer on the character-creation screen from
`CharBaseInfo.dbc`. Copy `Client_Patch/patch-8.MPQ` into each client's `Data/` folder (rename it
if `patch-8.MPQ` is already taken). Without it the server accepts the combinations but the client
won't let you pick them.

## Configuration

`conf/mod_forever_races.conf.dist`:

| Key                     | Default | Description                       |
|-------------------------|---------|-----------------------------------|
| `ForeverRaces.Announce` | `1`     | Log a line at startup when active |

## License

Released under the GNU GPL v2 (or later).
