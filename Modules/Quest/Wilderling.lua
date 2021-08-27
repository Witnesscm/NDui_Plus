local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local BUTTON = "OverrideActionBarButton%d"
-----------------------
-- Rare: Escaped Wilderling
-----------------------
local Handler = CreateFrame("Frame")
Handler:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Handler:RegisterEvent("PLAYER_ENTERING_WORLD")
Handler:SetScript("OnEvent", function(self, event, ...)
	if IsAddOnLoaded("BetterWorldQuests") then return end
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
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local _, _, spellID = ...
		if spellID == 356148 then
			SetOverrideBindingClick(self, true, "SPACE", BUTTON:format(1))
		elseif spellID == 356151 then
			ClearOverrideBindings(self)
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		ClearOverrideBindings(self)
		self:UnregisterEvent(event)
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
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
end

function Handler:Uncontrol()
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")

	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		ClearOverrideBindings(self)
	end
end

function Handler:Message()
	for i = 1, 2 do
		RaidNotice_AddMessage(RaidWarningFrame, L["QuestHelperTip1"], P.InfoColors)
	end
end