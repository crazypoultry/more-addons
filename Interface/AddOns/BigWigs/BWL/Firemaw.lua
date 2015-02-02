﻿------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Firemaw"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	wingbuffet_trigger = "Firemaw begins to cast Wing Buffet",
	shadowflame_trigger = "Firemaw begins to cast Shadow Flame.",
        flame_trigger = "afflicted by Flame Buffet",

	wingbuffet_message = "Wing Buffet! 30sec to next!",
	wingbuffet_warning = "3sec to Wing Buffet!",
	shadowflame_warning = "Shadow Flame Incoming!",

	wingbuffet_bar = "Wing Buffet",
	shadowflame_bar = "Shadow Flame",
	flamebuffet_bar = "Flame Buffet",

	cmd = "Firemaw",


	flamebuffet_cmd = "flamebuffet",
	flamebuffet_name = "Flame Buffet alert",
	flamebuffet_desc = "Warn for Flame Buffet next proc",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet alert",
	wingbuffet_desc = "Warn for Wing Buffet",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn for Shadow Flame",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsFiremaw = BigWigs:NewModule(boss)
BigWigsFiremaw.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsFiremaw.enabletrigger = boss
BigWigsFiremaw.toggleoptions = {"wingbuffet", "flamebuffet", "shadowflame", "bosskill"}
BigWigsFiremaw.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsFiremaw:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "FiremawWingBuffet2", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "FiremawShadowflame", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsFiremaw:Event(msg)
	if string.find(msg, L["flame_trigger"]) and self.db.profile.flamebuffet then
		self:TriggerEvent("BigWigs_StartBar", self, L["flamebuffet_bar"], 5, "Interface\\Icons\\Spell_Fire_Fireball")
	end
end

function BigWigsFiremaw:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["wingbuffet_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "FiremawWingBuffet2")
	elseif msg == L["shadowflame_trigger"] then 
		self:TriggerEvent("BigWigs_SendSync", "FiremawShadowflame")
	end
end

function BigWigsFiremaw:BigWigs_RecvSync(sync)
	if sync == "FiremawWingBuffet2" and self.db.profile.wingbuffet then
	        self:ScheduleEvent("BigWigs_SendSync", 25, "FiremawWingBuffet2")
		self:TriggerEvent("BigWigs_Message", L["wingbuffet_message"], "Important")
		self:ScheduleEvent("BigWigs_Message", 22, L["wingbuffet_warning"], "Important", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["wingbuffet_bar"], 25, "Interface\\Icons\\Spell_Fire_SelfDestruct")
	elseif sync == "FiremawShadowflame" and self.db.profile.shadowflame then
		self:TriggerEvent("BigWigs_StartBar", self, L["shadowflame_bar"], 3, "Interface\\Icons\\Spell_Fire_Incinerate")
		self:TriggerEvent("BigWigs_Message", L["shadowflame_warning"], "Important")
	end
end


