--[[---------------------------------------------------------------------------------
  This is a template for the plugin/module system for CM.

  Plugins are typically used to tie CM to a specific set of unit frames, but
  can also be used to add functionality to the system through a manner of hooks.
 
  Plugins are registered with CM with a shortname that is used for all slash
  commands.  In addition they are required to have a fullname parameter that is
  used in all display messages
----------------------------------------------------------------------------------]]
local print = function(msg) if msg then DEFAULT_CHAT_FRAME:AddMessage(msg) end end
-- Create a new plugin for CM, with the shortname "test"
local Plugin = CM:NewModule("sraid")
Plugin.fullname = "sRaidFrames"
Plugin.url = "http://svn.wowace.com/root/trunk/sRaidFrames/"

-- Plugin:Test() is called anytime the mod tries to enable.  It is optional
-- but it will be checked if it exists.  Will typically be based off some global
-- or the state of the addon itself.
function Plugin:Test()
	return sRaidFrames
end

-- Plugin:OnEnable() is called if Plugin:Test() is true, and the mod hasn't been explicitly
-- disabled.  This is where you should handle all your hooks, etc.
function Plugin:OnEnable()
	sRaidFrames.UnitTooltipOld = sRaidFrames.UnitTooltip
	sRaidFrames.UnitTooltip = self.UnitToolTip
	GameTooltip.HideOld = GameTooltip.Hide
	GameTooltip.Hide = self.Hide
end

function Plugin:UnitToolTip(frame)
	CM.currentUnit = frame.unit
	self:UnitTooltipOld(frame)
end

function Plugin:Hide()
	CM.currentUnit = nil
	GameTooltip:HideOld()
end