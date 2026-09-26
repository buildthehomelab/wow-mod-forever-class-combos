/*
 * mod-forever-class-combo
 *
 * Unlocks additional race/class combinations. The actual work is data-driven:
 * the module ships SQL that adds playercreateinfo (start position) and action-bar
 * rows for each new combination. Starting skills and spells apply automatically,
 * because playercreateinfo_skills / playercreateinfo_spell_custom are keyed by
 * race/class BITMASKS, so a race's racials and a class's abilities already cover
 * any new pairing without extra rows.
 *
 * The client also needs a patched CharBaseInfo.dbc to offer the combinations in
 * the character-creation UI (shipped separately as a client patch).
 *
 * This WorldScript exists so the module is registered by the build (and its SQL
 * is applied); it exposes a single on/off toggle for logging.
 *
 * Released under GNU GPL v2 or (at your option) any later version.
 */

#include "Config.h"
#include "Log.h"
#include "ScriptMgr.h"

class ForeverClassComboWorldScript : public WorldScript
{
public:
    ForeverClassComboWorldScript() : WorldScript("ForeverClassCombo_WorldScript") { }

    void OnAfterConfigLoad(bool /*reload*/) override
    {
        if (sConfigMgr->GetOption<bool>("ForeverClassCombo.Announce", true))
            LOG_INFO("server.loading", "[mod-forever-class-combo] Extra race/class combinations enabled (client needs the CharBaseInfo.dbc patch).");
    }
};

void AddForeverClassComboScripts()
{
    new ForeverClassComboWorldScript();
}
