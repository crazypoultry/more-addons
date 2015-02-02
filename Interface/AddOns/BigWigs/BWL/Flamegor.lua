﻿------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Flamegor"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	wingbuffet_trigger = "Flamegor begins to cast Wing Buffet",
	shadowflame_trigger = "Flamegor begins to cast Shadow Flame.",
	frenzy_trigger = "^Flamegor gains Frenzy",
	frenzyfade_trigger = "Frenzy fades from Flamegor",

	wingbuffet_message = "Wing Buffet! 25sec to next!",
	wingbuffet_warning = "3sec to Wing Buffet!",
	shadowflame_warning = "Shadow Flame incoming!",
	frenzy_message = "Frenzy - Tranq Shot!",

	wingbuffet_bar = "Wing Buffet",
	shadowflame_bar = "Shadow Flame",
	frenzy_bar = "Frenzy",

	cmd = "Flamegor",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet alert",
	wingbuffet_desc = "Warn for Wing Buffet",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn for Shadow Flame",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy alert",
	frenzy_desc = "Warn when for frenzy",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsFlamegor = BigWigs:NewModule(boss)
BigWigsFlamegor.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsFlamegor.enabletrigger = boss
BigWigsFlamegor.toggleoptions = {"wingbuffet", "shadowflame", "frenzy", "bosskill"}
BigWigsFlamegor.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsFlamegor:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "FlamegorWingBuffet2", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "FlamegorShadowflame", 10)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsFlamegor:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["wingbuffet_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "FlamegorWingBuffet2")
	        self:ScheduleRepeatingEvent("BigWigs_SendSync", "FlamegorWingBuffet2", 25, self)
	elseif msg == L["shadowflame_trigger"] then
		self:TriggerEvent("BigWigs_SendSync", "FlamegorShadowflame")
	end
end

function BigWigsFlamegor:BigWigs_RecvSync(sync)
	if sync == "FlamegorWingBuffet2" and self.db.profile.wingbuffet then
	        self:ScheduleEvent("BigWigs_SendSync", 25, "FlamegorWingBuffet2")
		self:TriggerEvent("BigWigs_Message", L["wingbuffet_message"], "Important")
		self:ScheduleEvent("BigWigs_Message", 22, L["wingbuffet_warning"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["wingbuffet_bar"], 25, "Interface\\Icons\\Spell_Fire_SelfDestruct")
	elseif sync == "FlamegorShadowflame" and self.db.profile.shadowflame then
		self:TriggerEvent("BigWigs_StartBar", self, L["shadowflame_bar"], 3, "Interface\\Icons\\Spell_Fire_Incinerate")
		self:TriggerEvent("BigWigs_Message", L["shadowflame_warning"], "Important")
	end
end

function BigWigsFlamegor:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if self.db.profile.frenzy and string.find(arg1, L["frenzy_trigger"]) then
		self:Tranq()
		self:TriggerEvent("BigWigs_Message", L["frenzy_message"], "Important", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["frenzy_bar"], 10, "Interface\\Icons\\Ability_Druid_ChallangingRoar")
	end
end

function BigWigsFlamegor:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L["frenzy_trigger"] and self.db.profile.frenzy then
		self:TriggerEvent("BigWigs_Message", L["frenzy_message"], "Important")
	end
end

function BigWigsFlamegor:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["frenzyfade_trigger"]) then
		self:Tranqoff()
	        self:TriggerEvent("BigWigs_StopBar", self, L["frenzy_bar"])
	end
end

function BigWigsFlamegor:Tranq()
            if (UnitClass("player") == "Hunter") then
                BigWigsThaddiusArrows:Direction("Tranq")
	end
end

function BigWigsFlamegor:Tranqoff()
            if (UnitClass("player") == "Hunter") then
            BigWigsThaddiusArrows:Tranqstop()
	end
end
