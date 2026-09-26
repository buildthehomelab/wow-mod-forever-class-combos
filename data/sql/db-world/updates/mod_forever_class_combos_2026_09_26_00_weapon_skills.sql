-- Weapon skills for the new combos.
-- The core only gives a character a skill if a SkillRaceClassInfo row covers its race and class
-- (starting skills, trainer spells and skill loading all check it). The stock rows for a few
-- weapon skills list only the races that could originally play the class, so:
--   Undead Paladin: no Swords (can't equip or train them)
--   Human Hunter:   no Axes, Guns or Daggers (its starting axe and gun are unusable)
-- Override those rows through skillraceclassinfo_dbc, adding the new race to RaceMask. Each row is
-- limited to one class, so no other race/class pair changes. Other fields are the stock 3.3.5a values.
-- Existing characters pick the skills up on their next login (LearnDefaultSkills runs then).
-- The client hides skills it has no row for from the Skills tab, so Client_Patch/patch-8.MPQ carries a
-- SkillRaceClassInfo.dbc with the same four RaceMask changes. Keep the two in sync.
-- Idempotent: clear then insert.
--
-- Race bits:  Human 1, Dwarf 4, Undead 16, Draenei 1024

DELETE FROM `skillraceclassinfo_dbc` WHERE `ID` IN (885, 117, 133, 632);
INSERT INTO `skillraceclassinfo_dbc` (`ID`, `SkillID`, `RaceMask`, `ClassMask`, `Flags`, `MinLevel`, `SkillTierID`, `SkillCostIndex`) VALUES
(885, 43,  1045, 2, 128, 0, 0, 0), -- Swords,  Paladin: Human, Dwarf, Draenei (1029) + Undead
(117, 44,  167,  4, 128, 0, 0, 0), -- Axes,    Hunter:  Orc, Dwarf, Tauren, Troll (166) + Human
(133, 46,  37,   4, 128, 0, 0, 0), -- Guns,    Hunter:  Dwarf, Tauren (36) + Human
(632, 173, 1191, 4, 128, 0, 0, 0); -- Daggers, Hunter:  Orc, Dwarf, Tauren, Troll, Draenei (1190) + Human

-- Starting Guns skill: the stock row covers only Dwarf and Tauren hunters.
-- Swords (Undead Paladin) and Axes/Daggers (Human Hunter) already have starting rows that cover them.
DELETE FROM `playercreateinfo_skills` WHERE `raceMask` = 1 AND `classMask` = 4 AND `skill` = 46;
INSERT INTO `playercreateinfo_skills` (`raceMask`, `classMask`, `skill`, `rank`, `comment`) VALUES
(1, 4, 46, 0, 'Guns - Human Hunter (mod-forever-class-combos)');
