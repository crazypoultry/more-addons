﻿------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Instructor Razuvious"]
local understudy = AceLibrary("Babble-Boss-2.2")["Deathknight Understudy"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Razuvious",

	shout_cmd = "shout",
	shout_name = "Shout Alert",
	shout_desc = "Warn for disrupting shout",

	shieldwall_cmd = "shieldwall",
	shieldwall_name = "Shield Wall Timer",
	shieldwall_desc = "Show timer for shieldwall",

	startwarn = "Instructor Razuvious engaged! 25sec to shout!",

	starttrigger1 = "Stand and fight!",
	starttrigger2 = "Hah hah, I'm just getting warmed up!",
	starttrigger3 = "Show me what you've got!",
	Sundertrigger1 = "Sunder Armor fades from Instructor Razuvious",
	Sundertrigger2 = "Instructor Razuvious is afflicted by Sunder Armor",

	shouttrigger = "Disrupting Shout",
	shout10secwarn = "10 sec to Disrupting Shout",
	shout5secwarn = "5 sec to Disrupting Shout!",
	shoutwarn = "Disrupting Shout!",
	noshoutwarn = "No shout! Next in 20secs",
	shoutbar = "Disrupting Shout",

	shieldwalltrigger   = "Death Knight Understudy gains Shield Wall.",
	shieldwallbar       = "Shield Wall",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsRazuvious = BigWigs:NewModule(boss)
BigWigsRazuvious.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsRazuvious.enabletrigger = { boss }
BigWigsRazuvious.wipemobs = { understudy }
BigWigsRazuvious.toggleoptions = {"shout", "shieldwall", "bosskill"}
BigWigsRazuvious.revision = tonumber(string.sub("$Revision: 15233 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsRazuvious:OnEnable()
	self.timeShout = 30
	self.prior = nil
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Shout")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Shout")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Shout")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "Shieldwall")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", "Shieldwall")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "Shieldwall")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Shieldwall")

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")

	self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "RazuviousShout", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "RazuviousShieldwall", 5)
end

function BigWigsRazuvious:CHAT_MSG_MONSTER_YELL( msg )
	if msg == L["starttrigger1"] or msg == L["starttrigger2"] or msg == L["starttrigger3"] then
	        if (UnitClass("player") == "Warrior") then
	        BigWigsThaddiusArrows:Direction("Sunder")
	        end
		if self.db.profile.shout then
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Urgent", nil, "Alarm")
			self:ScheduleEvent("bwrazuviousshout10sec", "BigWigs_Message", 15, L["shout10secwarn"], "Attention")
	                self:Run1()
			self:ScheduleEvent("bwrazuviousshout3sec", "BigWigs_Message", 20, L["shout5secwarn"], "Urgent", nil, "Alert")
			self:TriggerEvent("BigWigs_StartBar", self, L["shoutbar"], 25, "Interface\\Icons\\Ability_Warrior_WarCry")
		end
		self:ScheduleEvent("bwrazuviousnoshout", self.noShout, self.timeShout, self )
	end
end

function BigWigsRazuvious:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["Sundertrigger1"]) and (UnitClass("player") == "Warrior") then
	        BigWigsThaddiusArrows:Direction("Sunder")
	end
end

function BigWigsRazuvious:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if string.find(msg, L["Sundertrigger2"]) and (UnitClass("player") == "Warrior") then
                BigWigsThaddiusArrows:Sunderstop()
	end
end

function BigWigsRazuvious:BigWigs_Message(text)
	if text == L["shout10secwarn"] then self.prior = nil end
end

function BigWigsRazuvious:Shieldwall( msg ) 
	if string.find(msg, L["shieldwalltrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "RazuviousShieldwall")
	end
end

function BigWigsRazuvious:Shout( msg )
	if string.find(msg, L["shouttrigger"]) and not self.prior then
		self:TriggerEvent("BigWigs_SendSync", "RazuviousShout")
	end
end

function BigWigsRazuvious:noShout()	
	self:CancelScheduledEvent("bwrazuviousnoshout")
	self:ScheduleEvent("bwrazuviousnoshout", self.noShout, self.timeShout - 5, self )
	if self.db.profile.shout then
		self:TriggerEvent("BigWigs_Message", L["noshoutwarn"], "Attention")
		self:ScheduleEvent("bwrazuviousshout10sec", "BigWigs_Message", 10, L["shout10secwarn"], "Attention")
	        self:Run2()
		self:ScheduleEvent("bwrazuviousshout3sec", "BigWigs_Message", 15, L["shout5secwarn"], "Urgent", nil, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["shoutbar"], 20, "Interface\\Icons\\Ability_Warrior_WarCry")
	end
end

function BigWigsRazuvious:BigWigs_RecvSync( sync )
	if sync == "RazuviousShout" then
		self:CancelScheduledEvent("bwrazuviousnoshout")
		self:ScheduleEvent("bwrazuviousnoshout", self.noShout, self.timeShout, self )		
		if self.db.profile.shout then
			self:TriggerEvent("BigWigs_Message", L["shoutwarn"], "Urgent", nil, "Alarm")
			self:ScheduleEvent("bwrazuviousshout10sec", "BigWigs_Message", 15, L["shout10secwarn"], "Attention")
	                self:Run1()
			self:ScheduleEvent("bwrazuviousshout3sec", "BigWigs_Message", 20, L["shout5secwarn"], "Urgent", nil, "Alert")
			self:TriggerEvent("BigWigs_StartBar", self, L["shoutbar"], 25, "Interface\\Icons\\Ability_Warrior_WarCry")
		end
		self.prior = true
	elseif sync == "RazuviousShieldwall" then
		if self.db.profile.shieldwall then
			self:TriggerEvent("BigWigs_StartBar", self, L["shieldwallbar"], 20, "Interface\\Icons\\Ability_Warrior_ShieldWall")
		end
	end
end

function BigWigsRazuvious:Run1()
            if (UnitClass("player") == "Mage") or (UnitClass("player") == "Warlock") or (UnitClass("player") == "Hunter") then
	        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Run") end, 20)
	end
end

function BigWigsRazuvious:Run2()
            if (UnitClass("player") == "Mage") or (UnitClass("player") == "Warlock") or (UnitClass("player") == "Hunter") then
	        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Run") end, 15)
	end
end


