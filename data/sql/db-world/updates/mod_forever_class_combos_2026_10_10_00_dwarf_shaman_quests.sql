-- Dwarf Shaman totem quests in Khaz Modan.
-- The Call of Earth/Fire/Water/Air chains only exist on Azuremyst and Bloodmyst Isle. Dwarf
-- Shamans get their own versions, given by Farseer Amaan (Anvilmar) and Farseer Javad
-- (Ironforge). Each is a copy of the Draenei chain with new text: the elemental spirits get
-- copies in Coldridge Valley, Dun Morogh, Loch Modan and the Wetlands, and the objectives use
-- creatures that already live there. The quest items and their spells are the stock ones,
-- so nothing here needs a client patch.
--
--   Earth (4)   Farseer Amaan -> Spirit of the Ridge (Coldridge) -> 6 Burly Rockjaw Troggs
--               -> Earth Crystal to Amaan: Stoneskin Totem (the totem itself is a starter item)
--   Fire (10)   Farseer Javad -> Smolder (Brewnall Village) -> Ritual Torch from the Frostmane
--               Seers (Shimmer Ridge) -> burn the effigy at Frostmane Hold, kill Hauteur
--               -> ashes to Javad: Fire Totem, Searing Totem
--   Water (20)  Farseer Javad -> Meltwater (the Loch) -> 6 Foul Essences from Black Slimes
--               (Wetlands) -> fill the bota bag on the Stonewrought Dam -> destroy the Barrel
--               of Filth, kill Tel'athion -> flask to Javad: Water Totem, Healing Stream Totem
--   Air (30)    Farseer Javad -> Skirl (Thandol Span) -> Whorl of Air to Javad: Air Totem
--
-- Entries used (all in 9500210-9500249, which is this module's):
--   creature_template / creature guid  9500210 Spirit of the Ridge   <- 17087 Spirit of the Vale
--                                      9500211 Smolder               <- 17205 Temper
--                                      9500212 Meltwater             <- 17275 Aqueous
--                                      9500213 Skirl                 <- 17435 Susurrus
--   creature_template                  9500214 Tel'athion the Impure <- 17359 (no fixed move point)
--                                      9500215 Water Spirit          <- 6748  (fights 9500214)
--   gameobject_template / guid         9500210 Wickerman Effigy      <- 181672
--                                      9500211 Stonewrought Spillway <- 107047 (spell focus 223)
--                                      9500212 Barrel of Filth       <- 181699
--   event_scripts                      9500210 (Hauteur), 9500212 (Tel'athion)
--   gossip_menu / npc_text             9500210-9500213
--   quest_template                     9500210-9500212 Earth, 9500213-9500216 Fire,
--                                      9500217-9500221 Water, 9500222-9500223 Air
-- Idempotent: clears its own rows first. Spawn guids are deleted exactly, not by range: the
-- server gives objects spawned in game MAX(guid)+1, which lands right after these.

-- ---------------------------------------------------------------------------------------
-- Clean up
-- ---------------------------------------------------------------------------------------
DELETE FROM `creature`                     WHERE `guid`          BETWEEN 9500210 AND 9500213;
DELETE FROM `creature_template_model`      WHERE `CreatureID`    BETWEEN 9500210 AND 9500249;
DELETE FROM `creature_template_addon`      WHERE `entry`         BETWEEN 9500210 AND 9500249;
DELETE FROM `creature_template_movement`   WHERE `CreatureId`    BETWEEN 9500210 AND 9500249;
DELETE FROM `creature_template_spell`      WHERE `CreatureID`    BETWEEN 9500210 AND 9500249;
DELETE FROM `creature_template_resistance` WHERE `CreatureID`    BETWEEN 9500210 AND 9500249;
DELETE FROM `creature_equip_template`      WHERE `CreatureID`    BETWEEN 9500210 AND 9500249;
DELETE FROM `creature_text`                WHERE `CreatureID`    BETWEEN 9500210 AND 9500249;
DELETE FROM `creature_questitem`           WHERE `CreatureEntry` BETWEEN 9500210 AND 9500249;
DELETE FROM `smart_scripts`                WHERE `source_type` = 0 AND `entryorguid` BETWEEN 9500210 AND 9500249;
DELETE FROM `creature_template`            WHERE `entry`         BETWEEN 9500210 AND 9500249;
DELETE FROM `gameobject`                   WHERE `guid`          BETWEEN 9500210 AND 9500212;
DELETE FROM `gameobject_template_addon`    WHERE `entry`         BETWEEN 9500210 AND 9500249;
DELETE FROM `gameobject_template`          WHERE `entry`         BETWEEN 9500210 AND 9500249;
DELETE FROM `event_scripts`                WHERE `id`            BETWEEN 9500210 AND 9500249;
DELETE FROM `gossip_menu`                  WHERE `MenuID`        BETWEEN 9500210 AND 9500249;
DELETE FROM `npc_text`                     WHERE `ID`            BETWEEN 9500210 AND 9500249;
DELETE FROM `creature_queststarter`        WHERE `quest`         BETWEEN 9500210 AND 9500249;
DELETE FROM `creature_questender`          WHERE `quest`         BETWEEN 9500210 AND 9500249;
DELETE FROM `quest_details`                WHERE `ID`            BETWEEN 9500210 AND 9500249;
DELETE FROM `quest_offer_reward`           WHERE `ID`            BETWEEN 9500210 AND 9500249;
DELETE FROM `quest_request_items`          WHERE `ID`            BETWEEN 9500210 AND 9500249;
DELETE FROM `quest_template_addon`         WHERE `ID`            BETWEEN 9500210 AND 9500249;
DELETE FROM `quest_template`               WHERE `ID`            BETWEEN 9500210 AND 9500249;
DELETE FROM `conditions`                   WHERE `SourceTypeOrReferenceId` = 19 AND (`SourceEntry` BETWEEN 9500210 AND 9500249 OR `SourceEntry` = 9502);
DELETE FROM `creature_loot_template`       WHERE (`Entry` = 1397 AND `Item` = 23733) OR (`Entry` = 1030 AND `Item` = 23744);
DELETE FROM `creature_questitem`           WHERE (`CreatureEntry` = 1397 AND `ItemId` = 23733) OR (`CreatureEntry` = 1030 AND `ItemId` = 23744);

-- ---------------------------------------------------------------------------------------
-- Creatures: the four spirits, Tel'athion and his Water Spirits, copied from the Draenei chain
-- ---------------------------------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS `tmp_fcc_npc`;
CREATE TEMPORARY TABLE `tmp_fcc_npc` (
  `old` INT UNSIGNED NOT NULL PRIMARY KEY,
  `new` INT UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `gossip` INT UNSIGNED NOT NULL,
  `ai` VARCHAR(64) NOT NULL
);
INSERT INTO `tmp_fcc_npc` (`old`, `new`, `name`, `gossip`, `ai`) VALUES
(17087, 9500210, 'Spirit of the Ridge',   9500210, ''),
(17205, 9500211, 'Smolder',               9500211, ''),
(17275, 9500212, 'Meltwater',             9500212, ''),
(17435, 9500213, 'Skirl',                 9500213, ''),  -- no SmartAI: Susurrus' flight to the Exodar stays behind
(17359, 9500214, 'Tel''athion the Impure', 0,      'SmartAI'),
(6748,  9500215, 'Water Spirit',          0,      'SmartAI');

DROP TEMPORARY TABLE IF EXISTS `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `creature_template` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`entry`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`entry`
SET t.`name` = m.`name`, t.`gossip_menu_id` = m.`gossip`, t.`AIName` = m.`ai`, t.`ScriptName` = '', t.`entry` = m.`new`;
INSERT INTO `creature_template` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `creature_template_model` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureID`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureID` SET t.`CreatureID` = m.`new`;
INSERT INTO `creature_template_model` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `creature_template_addon` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`entry`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`entry` SET t.`entry` = m.`new`;
INSERT INTO `creature_template_addon` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `creature_template_movement` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureId`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureId` SET t.`CreatureId` = m.`new`;
INSERT INTO `creature_template_movement` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `creature_template_spell` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureID`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureID` SET t.`CreatureID` = m.`new`;
INSERT INTO `creature_template_spell` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `creature_template_resistance` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureID`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureID` SET t.`CreatureID` = m.`new`;
INSERT INTO `creature_template_resistance` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `creature_equip_template` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureID`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureID` SET t.`CreatureID` = m.`new`;
INSERT INTO `creature_equip_template` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `creature_text` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureID`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureID` SET t.`CreatureID` = m.`new`;
INSERT INTO `creature_text` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `creature_questitem` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureEntry`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_npc` m ON m.`old` = t.`CreatureEntry` SET t.`CreatureEntry` = m.`new`;
INSERT INTO `creature_questitem` SELECT * FROM `tmp_fcc_copy`;

-- Tel'athion's script, without the stock "run to a fixed point on Bloodmyst" step (action 69).
DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT * FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 17359 AND `action_type` <> 69;
UPDATE `tmp_fcc_copy` SET `entryorguid` = 9500214;
INSERT INTO `smart_scripts` SELECT * FROM `tmp_fcc_copy`;

-- The Water Spirits' script looks for Tel'athion by entry (event 75 "distance to creature",
-- then "text over" -> attack target 11 "creature by entry"), so the stock spirits would stand
-- idle next to the copy. Point the copies at 9500214, and at themselves for the text-over.
DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT * FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` = 6748;
UPDATE `tmp_fcc_copy` SET
  `event_param2`  = CASE WHEN `event_type` = 75 AND `event_param2` = 17359 THEN 9500214
                         WHEN `event_type` = 52 AND `event_param2` = 6748  THEN 9500215
                         ELSE `event_param2` END,
  `target_param1` = CASE WHEN `target_type` = 11 AND `target_param1` = 17359 THEN 9500214 ELSE `target_param1` END,
  `entryorguid`   = 9500215;
INSERT INTO `smart_scripts` SELECT * FROM `tmp_fcc_copy`;

-- Factions for a realm with cross-faction groups. The stock pair are Silvermoon (1657) and
-- Exodar (1655): a Horde player could not attack Tel'athion, and the spirits would attack
-- them. 16 = monster, hostile to every player; 250 = escortee, friendly to every player and
-- hostile to monsters. The two stay hostile to each other, which the spirits' script needs.
UPDATE `creature_template` SET `faction` = 16  WHERE `entry` = 9500214;
UPDATE `creature_template` SET `faction` = 250 WHERE `entry` = 9500215;
DROP TEMPORARY TABLE `tmp_fcc_copy`;
DROP TEMPORARY TABLE `tmp_fcc_npc`;

-- Greetings (the stock menus talk about the reef, the Exodar and Ammen Vale).
DROP TEMPORARY TABLE IF EXISTS `tmp_fcc_text`;
CREATE TEMPORARY TABLE `tmp_fcc_text` SELECT * FROM `npc_text` WHERE `ID` = 8832;
UPDATE `tmp_fcc_text` SET `ID` = 9500210, `BroadcastTextID0` = 0,
  `text0_0` = 'The mountain remembers every step taken on it, little one. Tread as though it matters.',
  `text0_1` = 'The mountain remembers every step taken on it, little one. Tread as though it matters.';
INSERT INTO `npc_text` SELECT * FROM `tmp_fcc_text`;
UPDATE `tmp_fcc_text` SET `ID` = 9500211,
  `text0_0` = 'Come closer, shaman. The snow does not trouble me, and it need not trouble you.',
  `text0_1` = 'Come closer, shaman. The snow does not trouble me, and it need not trouble you.';
INSERT INTO `npc_text` SELECT * FROM `tmp_fcc_text`;
UPDATE `tmp_fcc_text` SET `ID` = 9500212,
  `text0_0` = 'Every river in Khaz Modan begins as snow and ends with me. Be welcome, shaman.',
  `text0_1` = 'Every river in Khaz Modan begins as snow and ends with me. Be welcome, shaman.';
INSERT INTO `npc_text` SELECT * FROM `tmp_fcc_text`;
UPDATE `tmp_fcc_text` SET `ID` = 9500213,
  `text0_0` = 'Hold on to your beard, $c. It blows hard up here, and I am not sorry.',
  `text0_1` = 'Hold on to your beard, $c. It blows hard up here, and I am not sorry.';
INSERT INTO `npc_text` SELECT * FROM `tmp_fcc_text`;
DROP TEMPORARY TABLE `tmp_fcc_text`;

INSERT INTO `gossip_menu` (`MenuID`, `TextID`) VALUES
(9500210, 9500210),
(9500211, 9500211),
(9500212, 9500212),
(9500213, 9500213);

-- Spawns (map 0). Each stands beside something that is already there, so the height is known:
--   Spirit of the Ridge  5 yd from the campfire at Talin Keeneye's camp, Coldridge Valley
--   Smolder              3 yd from the campfire in Brewnall Village
--   Meltwater            on the Loch's surface at the fishing pool off Warg Deepwater's camp
--   Skirl                5 yd north of Comar Villard, at the south end of the Thandol Span
INSERT INTO `creature` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `MovementType`) VALUES
(9500210, 9500210, 0, 1, 1, 0, -6226.0,   684.0, 385.1, 0.70, 300, 0, 0),
(9500211, 9500211, 0, 1, 1, 0, -5375.1,   303.5, 393.9, 1.84, 300, 0, 0),
(9500212, 9500212, 0, 1, 1, 0, -5232.6, -3133.1, 297.6, 0.92, 300, 0, 0),
(9500213, 9500213, 0, 1, 1, 0, -2490.0, -2452.5,  79.9, 3.14, 300, 0, 0);

-- ---------------------------------------------------------------------------------------
-- Gameobjects: the effigy, the pure water source and the barrel
-- ---------------------------------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS `tmp_fcc_go`;
CREATE TEMPORARY TABLE `tmp_fcc_go` (`old` INT UNSIGNED NOT NULL PRIMARY KEY, `new` INT UNSIGNED NOT NULL);
INSERT INTO `tmp_fcc_go` (`old`, `new`) VALUES (181672, 9500210), (107047, 9500211), (181699, 9500212);

DROP TEMPORARY TABLE IF EXISTS `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `gameobject_template` t JOIN `tmp_fcc_go` m ON m.`old` = t.`entry`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_go` m ON m.`old` = t.`entry` SET t.`AIName` = '', t.`ScriptName` = '', t.`entry` = m.`new`;
INSERT INTO `gameobject_template` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `gameobject_template_addon` t JOIN `tmp_fcc_go` m ON m.`old` = t.`entry`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_go` m ON m.`old` = t.`entry` SET t.`entry` = m.`new`;
INSERT INTO `gameobject_template_addon` SELECT * FROM `tmp_fcc_copy`;
DROP TEMPORARY TABLE `tmp_fcc_copy`;
DROP TEMPORARY TABLE `tmp_fcc_go`;

-- Goobers: Data1 = quest that may use it, Data2 = event_scripts id.
UPDATE `gameobject_template` SET `Data1` = 9500215, `Data2` = 9500210 WHERE `entry` = 9500210;
-- Data3 = ms before it can be used again (stock barrel 3 s, effigy 60 s); nothing else stops a
-- second pour from summoning a second Tel'athion.
UPDATE `gameobject_template` SET `Data1` = 9500220, `Data2` = 9500212, `Data3` = 60000 WHERE `entry` = 9500212;
-- Spell focus 223 for the Empty Bota Bag. Data1 is the reach in yards (stock is 5).
UPDATE `gameobject_template` SET `name` = 'Stonewrought Spillway', `Data1` = 20 WHERE `entry` = 9500211;

--   Wickerman Effigy       6 yd from the trolls' campfire at the mouth of Frostmane Hold
--   Stonewrought Spillway  on Chief Engineer Hinderweir VII, on top of the Stonewrought Dam (not shown)
--   Barrel of Filth        open marsh east of the Dun Algaz road, on a Black Slime's spawn point
INSERT INTO `gameobject` (`guid`, `id`, `map`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`) VALUES
(9500210, 9500210, 0, 1, 1, -5556.5,    511.5,   382.3,  0, 0, 0, 0, 1, 121, 100, 1),
(9500211, 9500211, 0, 1, 1, -4737.9,  -3263.86,  310.34, 0, 0, 0, 0, 1,  25,   0, 1),
(9500212, 9500212, 0, 1, 1, -4055.26, -2847.83,   12.21, 0, 0, 0, 0, 1, 300,   0, 1);

-- What using them summons (command 10 = temp summon, datalong2 = despawn after ms).
INSERT INTO `event_scripts` (`id`, `delay`, `command`, `datalong`, `datalong2`, `dataint`, `x`, `y`, `z`, `o`) VALUES
(9500210, 2, 10,   17206, 900000, 0, -5555.0,    510.0,   382.4, 2.36),  -- Hauteur
(9500212, 2, 10, 9500214, 900000, 0, -4059.11, -2849.83,   12.3, 0.47),  -- Tel'athion the Impure
(9500212, 5, 10, 9500215, 900000, 0, -4055.18, -2832.73,   12.3, 4.71),  -- Water Spirit
(9500212, 5, 10, 9500215, 900000, 0, -4045.81, -2841.53,   12.3, 3.73);  -- Water Spirit

-- ---------------------------------------------------------------------------------------
-- Quest drops from creatures that already live there (same chance as the Draenei sources)
-- ---------------------------------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT * FROM `creature_loot_template`
WHERE (`Entry` = 17189 AND `Item` = 23733) OR (`Entry` = 17358 AND `Item` = 23744);
UPDATE `tmp_fcc_copy` SET
  `Comment` = CASE `Entry` WHEN 17189 THEN 'Frostmane Seer - Ritual Torch (Dwarf Call of Fire)' ELSE 'Black Slime - Foul Essence (Dwarf Call of Water)' END,
  `Entry`   = CASE `Entry` WHEN 17189 THEN 1397 ELSE 1030 END;
INSERT INTO `creature_loot_template` SELECT * FROM `tmp_fcc_copy`;
DROP TEMPORARY TABLE `tmp_fcc_copy`;

INSERT INTO `creature_questitem` (`CreatureEntry`, `Idx`, `ItemId`, `VerifiedBuild`)
SELECT 1397, COALESCE(MAX(`Idx`) + 1, 0), 23733, 0 FROM `creature_questitem` WHERE `CreatureEntry` = 1397;
INSERT INTO `creature_questitem` (`CreatureEntry`, `Idx`, `ItemId`, `VerifiedBuild`)
SELECT 1030, COALESCE(MAX(`Idx`) + 1, 0), 23744, 0 FROM `creature_questitem` WHERE `CreatureEntry` = 1030;

-- ---------------------------------------------------------------------------------------
-- Quests: copy the Draenei rows (level, XP, flags, class, sort), then rewrite them
-- ---------------------------------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS `tmp_fcc_quest`;
CREATE TEMPORARY TABLE `tmp_fcc_quest` (`old` INT UNSIGNED NOT NULL PRIMARY KEY, `new` INT UNSIGNED NOT NULL);
INSERT INTO `tmp_fcc_quest` (`old`, `new`) VALUES
(9449, 9500210), (9450, 9500211), (9451, 9500212),                                   -- Earth
(9464, 9500213), (9465, 9500214), (9467, 9500215), (9555, 9500216),                  -- Fire
(9501, 9500217), (9503, 9500218), (9504, 9500219), (9508, 9500220), (9509, 9500221), -- Water
(9552, 9500222), (9554, 9500223);                                                    -- Air

DROP TEMPORARY TABLE IF EXISTS `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `quest_template` t JOIN `tmp_fcc_quest` m ON m.`old` = t.`ID`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_quest` m ON m.`old` = t.`ID` SET t.`ID` = m.`new`;
INSERT INTO `quest_template` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `quest_template_addon` t JOIN `tmp_fcc_quest` m ON m.`old` = t.`ID`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_quest` m ON m.`old` = t.`ID` SET t.`ID` = m.`new`;
INSERT INTO `quest_template_addon` SELECT * FROM `tmp_fcc_copy`;

DROP TEMPORARY TABLE `tmp_fcc_copy`;
CREATE TEMPORARY TABLE `tmp_fcc_copy` SELECT t.* FROM `quest_details` t JOIN `tmp_fcc_quest` m ON m.`old` = t.`ID`;
UPDATE `tmp_fcc_copy` t JOIN `tmp_fcc_quest` m ON m.`old` = t.`ID` SET t.`ID` = m.`new`;
INSERT INTO `quest_details` SELECT * FROM `tmp_fcc_copy`;
DROP TEMPORARY TABLE `tmp_fcc_copy`;
DROP TEMPORARY TABLE `tmp_fcc_quest`;

-- Dwarves only, no stock map point, no auto-accept; the chain links are set per quest below.
UPDATE `quest_template` SET `AllowableRaces` = 4, `RewardNextQuest` = 0, `POIContinent` = 0, `POIx` = 0, `POIy` = 0, `POIPriority` = 0
WHERE `ID` BETWEEN 9500210 AND 9500223;
UPDATE `quest_template_addon` SET `PrevQuestID` = 0, `NextQuestID` = 0, `ExclusiveGroup` = 0, `SpecialFlags` = 0
WHERE `ID` BETWEEN 9500210 AND 9500223;

-- ---- Call of Earth ---------------------------------------------------------------------
UPDATE `quest_template` SET `RewardNextQuest` = 9500211, `POIx` = -6226.0, `POIy` = 684.0, `POIPriority` = 1,
  `LogDescription` = 'Speak with the Spirit of the Ridge near Talin Keeneye''s camp in Coldridge Valley.',
  `QuestDescription` = 'You carry an earth totem, $N, as every dwarf who takes up this path does. Until the earth knows you, it is only carved wood.$B$BThe spirits of this land are not the ones I knew on Draenor, but they listen all the same. One of them watches Coldridge Valley from its western slope, near the camp of the hunter Talin Keeneye.$B$BGo and present yourself. Be respectful. Stone has a long memory.',
  `QuestCompletionLog` = ''
WHERE `ID` = 9500210;

UPDATE `quest_template` SET `RewardNextQuest` = 9500212, `RequiredNpcOrGo1` = 724, `RequiredNpcOrGoCount1` = 6,
  `LogDescription` = 'Slay 6 Burly Rockjaw Troggs and then return to the Spirit of the Ridge in Coldridge Valley.',
  `QuestDescription` = 'Not all who dig are so careful. The troggs came up from below when your people broke into their tunnels, and now they gnaw at my roots without thought or thanks. Left alone, they would hollow this valley until it fell in on itself.$B$BThe burly ones do the most harm. Thin them out, $N, and I will know that you mean to stand with the earth and not merely on it.',
  `QuestCompletionLog` = 'Return to the Spirit of the Ridge in Coldridge Valley.'
WHERE `ID` = 9500211;

-- The totem itself is a Dwarf Shaman starter item, so this rewards only Stoneskin Totem.
UPDATE `quest_template` SET `RewardItem1` = 0, `RewardAmount1` = 0,
  `LogDescription` = 'Deliver the Earth Crystal to Farseer Amaan in Anvilmar.',
  `QuestDescription` = 'Take this crystal. It grew in the heart of the ridge, and a part of me goes with it.$B$BCarry it to Farseer Amaan in Anvilmar. He will know how to bind it to the totem you carry, and then the earth will answer when you call.$B$BWalk steady, $N.',
  `QuestCompletionLog` = ''
WHERE `ID` = 9500212;

UPDATE `quest_template_addon` SET `PrevQuestID` = 9500210 WHERE `ID` = 9500211;
UPDATE `quest_template_addon` SET `PrevQuestID` = 9500211 WHERE `ID` = 9500212;

-- ---- Call of Fire ----------------------------------------------------------------------
UPDATE `quest_template` SET `RewardNextQuest` = 9500214, `POIx` = -5375.1, `POIy` = 303.5, `POIPriority` = 1,
  `LogDescription` = 'Speak with Smolder at the campfire in Brewnall Village in Dun Morogh.',
  `QuestDescription` = 'You have grown, $N. The earth answers you readily now, and I think the flame has noticed.$B$BFire is the hardest element for your people to hear in this frozen land, but it is here. A spirit of flame named Smolder has settled by the campfire in Brewnall Village, west of Kharanos, where the brewers never let the fire go out.$B$BSeek it out and listen well. And keep your beard out of the way.',
  `QuestCompletionLog` = ''
WHERE `ID` = 9500213;

UPDATE `quest_template` SET `RewardNextQuest` = 9500215, `POIx` = -5333.5, `POIy` = -230.3, `POIPriority` = 1,
  `LogDescription` = 'Take the Ritual Torch from the Frostmane Seers on Shimmer Ridge and return it to Smolder in Brewnall Village.',
  `QuestDescription` = 'One of my kin, Hauteur, has let pride burn away his sense. He has shown himself to the Frostmane trolls, and now they bow to him as a god.$B$BThis will not stand! Fire warms and fire destroys, but it does not ask to be worshipped.$B$BThe seers on Shimmer Ridge, north of Kharanos, keep the ritual torch that the trolls light in his name. Take it from them and bring it to me.',
  `QuestCompletionLog` = 'Return to Smolder at Brewnall Village in Dun Morogh.'
WHERE `ID` = 9500214;

-- The Draenei version hands out a satchel with the torch and an Orb of Returning (a teleport
-- to Emberglade). Here the quest gives the torch itself.
UPDATE `quest_template` SET `RewardNextQuest` = 9500216, `StartItem` = 23682, `POIx` = -5556.5, `POIy` = 511.5, `POIPriority` = 1,
  `LogDescription` = 'Use the Ritual Torch on the Wickerman Effigy at the troll camp outside Frostmane Hold and slay Hauteur. Return Hauteur''s Ashes and the Ritual Torch to Smolder in Brewnall Village.',
  `QuestDescription` = 'The trolls of Frostmane Hold, in the hills southwest of here, burn an effigy to Hauteur whenever he demands it. When it is lit, he comes to bask in it.$B$BTake the torch back. Go to the camp at the mouth of the hold, where the trolls keep their fire, and set the effigy alight yourself. Hauteur will come.$B$BPut him out, $N. Then bring me his ashes, and the torch with them.',
  `QuestCompletionLog` = 'Return to Smolder at Brewnall Village in Dun Morogh.'
WHERE `ID` = 9500215;

-- Copied from the last Draenei step (Velen -> Nobundo); here Smolder sends the ashes to Javad.
UPDATE `quest_template` SET `StartItem` = 23688, `RequiredItemId1` = 23688, `RequiredItemCount1` = 1,
  `LogDescription` = 'Bring Hauteur''s Ashes to Farseer Javad in Ironforge.',
  `QuestDescription` = 'I have kept back a portion of Hauteur''s ashes for you. There is still heat in them, and there always will be.$B$BTake them to Farseer Javad in Ironforge. He will work them into your fire totem, so that each time you call the flame you remember what it cost to earn it.$B$BGo well, $N. Should you pass this way in winter, come and sit by me.',
  `QuestCompletionLog` = ''
WHERE `ID` = 9500216;

UPDATE `quest_template_addon` SET `PrevQuestID` = 9500213 WHERE `ID` = 9500214;
UPDATE `quest_template_addon` SET `PrevQuestID` = 9500214, `ProvidedItemCount` = 1 WHERE `ID` = 9500215;
UPDATE `quest_template_addon` SET `PrevQuestID` = 9500215, `ProvidedItemCount` = 1 WHERE `ID` = 9500216;

-- ---- Call of Water ---------------------------------------------------------------------
-- No Potion of Water Breathing: Meltwater is at the surface.
UPDATE `quest_template` SET `RewardNextQuest` = 9500218, `StartItem` = 0, `POIx` = -5232.6, `POIy` = -3133.1, `POIPriority` = 1,
  `LogDescription` = 'Speak with Meltwater in the Loch, just off Warg Deepwater''s fishing camp in Loch Modan.',
  `QuestDescription` = 'The water has been restless in my visions, $N, and I believe it is asking for you.$B$BEvery stream in these mountains runs down to the Loch, and the spirit that gathers them there is called Meltwater. You will find her in the shallows of the western shore, just off the fishing camp of Warg Deepwater, northeast of Thelsamar.$B$BYou may have to get your feet wet.',
  `QuestCompletionLog` = ''
WHERE `ID` = 9500217;

UPDATE `quest_template` SET `RewardNextQuest` = 9500219, `POIx` = -4055.26, `POIy` = -2847.83, `POIPriority` = 1,
  `LogDescription` = 'Collect 6 Foul Essences from the Black Slimes in the Wetlands and return them to Meltwater in the Loch.',
  `QuestDescription` = 'Water gives life to everything it touches. When it is fouled, it carries death just as far.$B$BWhat goes over the dam leaves me clean, yet by the time it has crossed the marsh below, something in it has turned. Black slimes have risen in the fens of the Wetlands, east of the road that comes down from Dun Algaz. I must know what is in them.$B$BDraw out their essence and bring it to me.',
  `QuestCompletionLog` = 'Return to Meltwater in the Loch in Loch Modan.'
WHERE `ID` = 9500218;

UPDATE `quest_template` SET `RewardNextQuest` = 9500220, `POIx` = -4737.9, `POIy` = -3263.86, `POIPriority` = 1,
  `LogDescription` = 'Fill the Empty Bota Bag on top of the Stonewrought Dam, beside Chief Engineer Hinderweir VII, and return to Meltwater in the Loch.',
  `QuestDescription` = 'It is worse than I feared. If this filth reaches the sea, the currents will carry it to every shore.$B$BTo unmake it I need water that nothing has touched since it fell as snow. There is only one place where I am that pure: the lip of the Stonewrought Dam, at the north end of the Loch, in the moment before I fall.$B$BTake this bota bag. Chief Engineer Hinderweir keeps watch on top of the dam. Fill the bag there, beside him, and hurry back.',
  `QuestCompletionLog` = 'Return to Meltwater in the Loch in Loch Modan.'
WHERE `ID` = 9500219;

UPDATE `quest_template` SET `RewardNextQuest` = 9500221, `POIx` = -4055.26, `POIy` = -2847.83, `POIPriority` = 1,
  `LogDescription` = 'Use the Skin of Purest Water on the Barrel of Filth in the Wetlands marsh and slay Tel''athion the Impure. Bring the Head of Tel''athion to Meltwater in the Loch.',
  `QuestDescription` = 'I know now who is fouling the marsh. A sorcerer named Tel''athion has come over the sea to finish work he began on another shore. He brews his filth in barrels and lets it seep into the fens. The slimes are what it leaves behind.$B$BHis cache stands in the open marsh, among the slimes east of the Dun Algaz road. Pour this pure water into the barrel and it will ruin everything he has made. That will bring him out.$B$BThen put an end to it, $N.',
  `QuestCompletionLog` = 'Return to Meltwater in the Loch in Loch Modan.'
WHERE `ID` = 9500220;

UPDATE `quest_template` SET
  `LogDescription` = 'Take the Flask of Purest Water to Farseer Javad in Ironforge.',
  `QuestDescription` = 'Take this flask. It holds the purest part of me, and I give it gladly.$B$BBring it to Farseer Javad in Ironforge. He will use it to make your water totem, and when you set it down, I will be there.$B$BRemember what you have seen, $N. Water mends and water kills. Which one it does is up to whoever carries it.',
  `QuestCompletionLog` = ''
WHERE `ID` = 9500221;

UPDATE `quest_template_addon` SET `ProvidedItemCount` = 0 WHERE `ID` = 9500217;
UPDATE `quest_template_addon` SET `PrevQuestID` = 9500217 WHERE `ID` = 9500218;
UPDATE `quest_template_addon` SET `PrevQuestID` = 9500218 WHERE `ID` = 9500219;
UPDATE `quest_template_addon` SET `PrevQuestID` = 9500219 WHERE `ID` = 9500220;
UPDATE `quest_template_addon` SET `PrevQuestID` = 9500220 WHERE `ID` = 9500221;

-- ---- Call of Air -----------------------------------------------------------------------
UPDATE `quest_template` SET `RewardNextQuest` = 9500223, `POIx` = -2490.0, `POIy` = -2452.5, `POIPriority` = 1,
  `LogDescription` = 'Speak with Skirl at the southern end of the Thandol Span in the Wetlands.',
  `QuestDescription` = 'Earth, fire and water have all taken your measure, $N. Only the wind is left, and the wind does not come to anyone. You must go to it.$B$BA spirit of air called Skirl plays about the Thandol Span, the great bridge your ancestors raised at the northern edge of the Wetlands. He keeps to its southern end, where the road meets the stone.$B$BIt is a long road. I think that is rather the point.',
  `QuestCompletionLog` = ''
WHERE `ID` = 9500222;

UPDATE `quest_template` SET
  `LogDescription` = 'Return to Farseer Javad in Ironforge with the Whorl of Air.',
  `QuestDescription` = 'Air is in everything, little $r. It is in the stone of this bridge and in the water under it, and no fire burns without me. Just do not tell the others I said so.$B$BMy cousins had you slaying and fetching for them, I expect. I will not. You walked the whole wet length of this land to stand in the wind and ask politely, and that is enough for me.$B$BHere. Take a piece of me back to your farseer. And mind your hat on the way down.',
  `QuestCompletionLog` = ''
WHERE `ID` = 9500223;

UPDATE `quest_template_addon` SET `PrevQuestID` = 9500222 WHERE `ID` = 9500223;

-- ---- Turn-in text ----------------------------------------------------------------------
INSERT INTO `quest_offer_reward` (`ID`, `Emote1`, `RewardText`) VALUES
(9500210, 1, 'So. One of the mountain''s own children comes to listen at last.$B$BYour people have dug into me since before your grandfathers'' grandfathers were born. I do not mind it. A dwarf takes what is needed and shores up the tunnel behind.$B$BSit, $N. We will see whether you can hear me.'),
(9500211, 1, 'Good. The valley rests easier, and so do I.$B$BYou did not flinch from the work. That is the first thing the earth asks of a shaman: to be steady.'),
(9500212, 1, 'The spirit has judged you worthy. I had hoped it would.$B$BGive me your totem a moment... there. The crystal is bound to it. Call on the earth and it will harden the skin of those who stand beside you.$B$BThis is only the first of the elements, $N. The others will call you in their own time.'),
(9500213, 1, 'A dwarf who speaks to the fire and not only to the forge. There are few of you.$B$BI came down from the heart of the mountain long ago and found this village. They feed me well, and in return no blizzard has ever put out their hearth.$B$BSo you wish to learn the flame, $N? Then first you will help me put one out.'),
(9500214, 1, 'See how it burns and is never used up? That is Hauteur''s doing, and it is the measure of his arrogance.$B$BA flame should eat what it is given and then die, to be kindled again another day. One that will not die is no longer a flame. It is only hunger.'),
(9500215, 1, 'So he is ash. I will not pretend that it does not grieve me.$B$BBut you have seen now what the flame becomes when nothing tempers it. Remember that the next time it does as you ask and you begin to think it yours.'),
(9500216, 1, 'Hauteur''s ashes. Then Smolder asked much of you, and you did not fail.$B$BMy people learned not to judge the flame by how it looks. The same is true of those who serve it, and I think you understand that now.$B$BHere. I have bound the ashes into a totem for you. Fire will come when you call.'),
(9500217, 1, 'Welcome, child of the mountain. Come in, the water will not hurt you.$B$BI am the snow of every peak in Khaz Modan, come down at last to rest. Your people built their great dam to hold me here, and I have never minded. But something is wrong downstream, and I cannot go and see it for myself.'),
(9500218, 1, '<Meltwater recoils from the essences.>$B$BThis is no sickness of the land. Someone has made this, and made it on purpose.'),
(9500219, 1, 'Yes, this is clean. As clean as the day it fell.$B$BGive me a moment with it. I have found where the filth is coming from, and you will need this when you go there.'),
(9500220, 1, 'Then it is over, and the marsh will mend in time. Water is patient.$B$BYou have done what I could not, $N. I will not forget it.'),
(9500221, 1, 'You carry yourself with more wisdom than your years should allow, $N. I can feel that the water is pleased with you.$B$BIt is my honor to take what Meltwater has given and make your totem from it. Use it to heal. That is what she would want.'),
(9500222, 1, 'Ha! A dwarf, this far from a tavern? You must want something badly.$B$BI like this bridge. Your people built it high and left it full of holes for me to whistle through. Listen... do you hear that? That is me.'),
(9500223, 1, 'I am proud of you, $N. Four times the elements have tested you, and four times you kept on where others turn back.$B$BHere is your air totem. A shaman never truly stops learning, but the elements have each said their piece to you now. Remember what they taught you.');

INSERT INTO `quest_request_items` (`ID`, `EmoteOnComplete`, `EmoteOnIncomplete`, `CompletionText`) VALUES
(9500211, 1, 0, 'The troggs still scratch at my roots. I can feel every one of them.'),
(9500212, 1, 0, 'You have spoken with the spirit of this valley? What did it give you?'),
(9500214, 1, 0, 'You have the torch?'),
(9500215, 1, 0, 'Is it done? Does Hauteur still burn?'),
(9500216, 1, 0, 'You smell of smoke, $N. How went your meeting with the flame?'),
(9500218, 1, 0, 'Have you been down to the marsh? What did you find there?'),
(9500219, 1, 0, 'Did you fill the bag at the dam?'),
(9500220, 1, 0, 'Is the sorcerer dead?'),
(9500221, 1, 0, 'The water in my visions has grown calm. Come, tell me what you did.'),
(9500223, 1, 0, 'Back already? Your beard looks windblown.$B$B<Javad smiles.>');

-- ---- Who gives and takes them ----------------------------------------------------------
-- 9500201 Farseer Amaan (Anvilmar, this module), 23127 Farseer Javad (Ironforge).
-- Javad also starts Call of Earth, for Dwarf Shamans who have already left Coldridge Valley.
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(9500201, 9500210), (23127, 9500210), (9500210, 9500211), (9500210, 9500212),
(23127, 9500213), (9500211, 9500214), (9500211, 9500215), (9500211, 9500216),
(23127, 9500217), (9500212, 9500218), (9500212, 9500219), (9500212, 9500220), (9500212, 9500221),
(23127, 9500222), (9500213, 9500223);

INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(9500210, 9500210), (9500210, 9500211), (9500201, 9500212),
(9500211, 9500213), (9500211, 9500214), (9500211, 9500215), (23127, 9500216),
(9500212, 9500217), (9500212, 9500218), (9500212, 9500219), (9500212, 9500220), (23127, 9500221),
(9500213, 9500222), (23127, 9500223);

-- ---------------------------------------------------------------------------------------
-- One path per race
-- ---------------------------------------------------------------------------------------
-- A Dwarf Shaman who already finished a Draenei chain (they were open to dwarves until now)
-- is not offered the matching dwarf chain. Source type 19 = quest available, type 8 = quest
-- rewarded, negated.
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(19, 0, 9500210, 0, 0, 8, 0, 9451, 0, 0, 1, 0, 0, '', 'Dwarf Call of Earth: not after the Draenei Call of Earth'),
(19, 0, 9500213, 0, 0, 8, 0, 9555, 0, 0, 1, 0, 0, '', 'Dwarf Call of Fire: not after the Draenei Call of Fire'),
(19, 0, 9500217, 0, 0, 8, 0, 9509, 0, 0, 1, 0, 0, '', 'Dwarf Call of Water: not after the Draenei Call of Water'),
(19, 0, 9500222, 0, 0, 8, 0, 9554, 0, 0, 1, 0, 0, '', 'Dwarf Call of Air: not after the Draenei Call of Air');

-- And dwarves no longer get the Draenei chains (stock Earth and Fire allow every Alliance
-- race; Water, Air and Shaman Training were opened by this module's class-quest rule, which
-- no longer covers Dwarf Shamans). A dwarf partway through one can hand in the step they
-- hold but is not offered the next; the dwarf chain is, from its first step.
UPDATE `quest_template` SET `AllowableRaces` = `AllowableRaces` & ~4
WHERE `ID` IN (9421,
               9449, 9450, 9451,
               9462, 9464, 9465, 9467, 9468, 9555,
               9500, 9501, 9503, 9504, 9508, 9509, 10490,
               9547, 9551, 9552, 9553, 9554, 10491)
  AND (`AllowableRaces` & 4) <> 0;

-- Farseer Javad's stock breadcrumb to the Exodar, Call of Water (9502), allows every race, so
-- there is no bit to take off. Hide it from dwarves instead (type 16 = race mask, negated).
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`) VALUES
(19, 0, 9502, 0, 0, 16, 0, 4, 0, 0, 1, 0, 0, '', 'Call of Water (Javad -> Nobundo): not for dwarves, who have their own chain');
