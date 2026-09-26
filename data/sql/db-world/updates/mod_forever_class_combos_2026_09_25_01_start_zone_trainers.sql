-- Class trainers in the start zones that have none for the new combos.
-- Each is a copy of a capital trainer of that class (same spell list, gossip and model) with
-- its own name, standing 2.5 yd to the left of an existing trainer in the start zone.
-- Idempotent: clears the module's range (9500200-9500202) first.
--
--   entry/guid  new trainer                   copied from                      stands beside
--   9500200     Brannoc Stoneshield (Hunter)  5517  Thorfin Stoneshield (SW)   79964 Llane Beshere, Northshire
--   9500201     Farseer Amaan (Shaman)        23127 Farseer Javad (IF)         403   Bromos Grummner, Anvilmar
--   9500202     Champion Aeldris Dawnrose     20406 Champion Cyssa Dawnrose    28469 Dark Cleric Duesten, Deathknell
--               (Paladin)                           (UC)

DELETE FROM `creature`                 WHERE `guid`       BETWEEN 9500200 AND 9500202;
DELETE FROM `creature_default_trainer` WHERE `CreatureId` BETWEEN 9500200 AND 9500202;
DELETE FROM `npc_trainer`              WHERE `ID`         BETWEEN 9500200 AND 9500202;
DELETE FROM `creature_template_model`  WHERE `CreatureID` BETWEEN 9500200 AND 9500202;
DELETE FROM `creature_template`        WHERE `entry`      BETWEEN 9500200 AND 9500202;

-- Templates. Assignments run left to right, so name is set before entry changes.
DROP TEMPORARY TABLE IF EXISTS `tmp_fr_template`;
CREATE TEMPORARY TABLE `tmp_fr_template` SELECT * FROM `creature_template` WHERE `entry` IN (5517, 23127, 20406);
UPDATE `tmp_fr_template` SET
  `name`       = CASE `entry` WHEN 5517 THEN 'Brannoc Stoneshield' WHEN 23127 THEN 'Farseer Amaan' WHEN 20406 THEN 'Champion Aeldris Dawnrose' END,
  `AIName`     = '',
  `ScriptName` = '',
  `entry`      = CASE `entry` WHEN 5517 THEN 9500200 WHEN 23127 THEN 9500201 WHEN 20406 THEN 9500202 END;
INSERT INTO `creature_template` SELECT * FROM `tmp_fr_template`;
DROP TEMPORARY TABLE `tmp_fr_template`;

-- Models
DROP TEMPORARY TABLE IF EXISTS `tmp_fr_model`;
CREATE TEMPORARY TABLE `tmp_fr_model` SELECT * FROM `creature_template_model` WHERE `CreatureID` IN (5517, 23127, 20406);
UPDATE `tmp_fr_model` SET `CreatureID` = CASE `CreatureID` WHEN 5517 THEN 9500200 WHEN 23127 THEN 9500201 WHEN 20406 THEN 9500202 END;
INSERT INTO `creature_template_model` SELECT * FROM `tmp_fr_model`;
DROP TEMPORARY TABLE `tmp_fr_model`;

-- Spell lists: point at the same trainer as the original (plus any legacy npc_trainer rows)
INSERT INTO `creature_default_trainer` (`CreatureId`, `TrainerId`)
SELECT CASE `CreatureId` WHEN 5517 THEN 9500200 WHEN 23127 THEN 9500201 WHEN 20406 THEN 9500202 END, `TrainerId`
FROM `creature_default_trainer` WHERE `CreatureId` IN (5517, 23127, 20406);

DROP TEMPORARY TABLE IF EXISTS `tmp_fr_npc_trainer`;
CREATE TEMPORARY TABLE `tmp_fr_npc_trainer` SELECT * FROM `npc_trainer` WHERE `ID` IN (5517, 23127, 20406);
UPDATE `tmp_fr_npc_trainer` SET `ID` = CASE `ID` WHEN 5517 THEN 9500200 WHEN 23127 THEN 9500201 WHEN 20406 THEN 9500202 END;
INSERT INTO `npc_trainer` SELECT * FROM `tmp_fr_npc_trainer`;
DROP TEMPORARY TABLE `tmp_fr_npc_trainer`;

-- Spawns: copy the neighbour's spawn row, move 2.5 yd to its left, keep its facing.
-- id is set before guid changes; position uses the unchanged orientation.
DROP TEMPORARY TABLE IF EXISTS `tmp_fr_spawn`;
CREATE TEMPORARY TABLE `tmp_fr_spawn` SELECT * FROM `creature` WHERE `guid` IN (79964, 403, 28469);
UPDATE `tmp_fr_spawn` SET
  `position_x`      = `position_x` - 2.5 * SIN(`orientation`),
  `position_y`      = `position_y` + 2.5 * COS(`orientation`),
  `equipment_id`    = 0,
  `MovementType`    = 0,
  `wander_distance` = 0,
  `id`              = CASE `guid` WHEN 79964 THEN 9500200 WHEN 403 THEN 9500201 WHEN 28469 THEN 9500202 END,
  `guid`            = CASE `guid` WHEN 79964 THEN 9500200 WHEN 403 THEN 9500201 WHEN 28469 THEN 9500202 END;
INSERT INTO `creature` SELECT * FROM `tmp_fr_spawn`;
DROP TEMPORARY TABLE `tmp_fr_spawn`;
