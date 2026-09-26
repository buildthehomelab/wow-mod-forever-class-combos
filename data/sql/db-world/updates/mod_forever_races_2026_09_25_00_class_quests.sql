-- Open class quests to the new race/class combos.
-- Class quests are race-gated via quest_template.AllowableRaces to the races that could
-- originally play the class, so a new combo can't learn key quest-only spells/items
-- (Tame Beast, Water/Air Totems, Voidwalker, Redemption, class mounts).
-- Each new race borrows a same-faction donor race's class quests.
-- Only single-class quests (AllowableClasses = exactly that class) are touched.
-- Idempotent: bitwise OR.
--
-- Race bits:  Human 1, Orc 2, Dwarf 4, Undead 16, Gnome 64, Troll 128, Blood Elf 512, Draenei 1024
-- Class bits: Paladin 2, Hunter 4, Shaman 64, Mage 128, Warlock 256

-- Human Hunter <- Dwarf hunter quests (Taming the Beast / Training the Beast in Kharanos)
UPDATE `quest_template` qt JOIN `quest_template_addon` qta ON qta.`ID` = qt.`ID`
SET qt.`AllowableRaces` = qt.`AllowableRaces` | 1
WHERE qta.`AllowableClasses` = 4 AND (qt.`AllowableRaces` & 4) <> 0;

-- Dwarf Shaman <- Draenei shaman quests (Call of Earth/Fire/Water/Air, Azuremyst)
UPDATE `quest_template` qt JOIN `quest_template_addon` qta ON qta.`ID` = qt.`ID`
SET qt.`AllowableRaces` = qt.`AllowableRaces` | 4
WHERE qta.`AllowableClasses` = 64 AND (qt.`AllowableRaces` & 1024) <> 0;

-- Troll Warlock <- Orc warlock quests (Creature of the Void in Durotar, Dreadsteed chain)
UPDATE `quest_template` qt JOIN `quest_template_addon` qta ON qta.`ID` = qt.`ID`
SET qt.`AllowableRaces` = qt.`AllowableRaces` | 128
WHERE qta.`AllowableClasses` = 256 AND (qt.`AllowableRaces` & 2) <> 0;

-- Undead Paladin <- Blood Elf paladin quests (Redemption, Thalassian Warhorse/Charger)
UPDATE `quest_template` qt JOIN `quest_template_addon` qta ON qta.`ID` = qt.`ID`
SET qt.`AllowableRaces` = qt.`AllowableRaces` | 16
WHERE qta.`AllowableClasses` = 2 AND (qt.`AllowableRaces` & 512) <> 0;

-- Orc Mage <- Troll mage quests (Valley of Trials)
UPDATE `quest_template` qt JOIN `quest_template_addon` qta ON qta.`ID` = qt.`ID`
SET qt.`AllowableRaces` = qt.`AllowableRaces` | 2
WHERE qta.`AllowableClasses` = 128 AND (qt.`AllowableRaces` & 128) <> 0;

-- Gnome Priest: no rule. The only Dwarf priest quests gnomes can't take are the Dwarf intro
-- letter and the old racial-spell quests (Desperate Prayer, Fear Ward), which gnomes shouldn't get.
