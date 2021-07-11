local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local BUTTON = "OverrideActionBarButton%d"
-----------------------
-- Rare: Escaped Wilderling
-----------------------
local RARE = "Escaped Wilderling"
local MESSAGE = "Spam <SpaceBar> to complete!"

local locale = GetLocale()
if locale == "zhCN" or locale == "zhTW" then
	RARE = "逃跑的荒蚺"
	MESSAGE = "狂按 <空格> 完成!"
end

local Handler = CreateFrame("Frame")
Handler:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Handler:RegisterEvent("PLAYER_ENTERING_WORLD")
Handler:SetScript("OnEvent", function(self, event, ...)
	if not NDuiPlusDB["Misc"]["QuestHelper"] then return end

	if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
		local mapID = C_Map.GetBestMapForUnit("player")
		if mapID and mapID == 1961 then
			self:Watch()
		else
			self:Unwatch()
		end
	elseif event == "UNIT_ENTERED_VEHICLE" then
		if GetPlayerAuraBySpellID(356137) then
			self:Control()
		else
			self:Uncontrol()
		end
	elseif event == "UNIT_EXITED_VEHICLE" then
		self:Uncontrol()
	elseif event == "CHAT_MSG_RAID_BOSS_EMOTE" then
		local msg = ...
		if strfind(msg, RARE) then
			ClearOverrideBindings(self)
			SetOverrideBindingClick(self, true, "SPACE", BUTTON:format(1))
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local _, _, spellID = ...
		if spellID == 356151 then
			ClearOverrideBindings(self)
			SetOverrideBindingClick(self, true, "SPACE", BUTTON:format(12))
		end
	end
end)

function Handler:Watch()
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
end

function Handler:Unwatch()
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
end

function Handler:Control()
	self:Message()

	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
end

function Handler:Uncontrol()
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")
	self:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")

	ClearOverrideBindings(self)
end

function Handler:Message()
	for i = 1, 2 do
		RaidNotice_AddMessage(RaidWarningFrame, MESSAGE, P.InfoColors)
	end
end
