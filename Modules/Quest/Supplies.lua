local _, ns = ...
local B, C, L, DB, P = unpack(ns)
-----------------------
-- BetterWorldQuests
-- Author: p3lim
-----------------------
local BUTTON = "OverrideActionBarButton%d"

local locations = {
	[356465] = { -- spellID trigger for "The Weight of Stone" in Korthia
		distance = 12,
		mapID = 1961, -- Korthia
		locations = {
			{x=0.512295, y=0.659946, button=2},
			{x=0.495522, y=0.702267, button=1},
			{x=0.436255, y=0.774560, button=1},
			{x=0.457401, y=0.651537, button=2},
			{x=0.571717, y=0.738390, button=1},
			{x=0.483011, y=0.703747, button=2},
			{x=0.540073, y=0.696586, button=1},
			{x=0.438710, y=0.691987, button=1},
			{x=0.547435, y=0.680365, button=1},
			{x=0.456530, y=0.756301, button=2},
			{x=0.449992, y=0.781604, button=2},
			{x=0.553119, y=0.704497, button=2},
			{x=0.561304, y=0.736615, button=1},
			{x=0.457527, y=0.718790, button=2},
			{x=0.493594, y=0.653566, button=1},
			{x=0.556713, y=0.688418, button=1},
			{x=0.533274, y=0.686950, button=2},
			{x=0.472837, y=0.653830, button=1},
			{x=0.519417, y=0.696308, button=2},
			{x=0.509723, y=0.704670, button=1},
			{x=0.522772, y=0.665827, button=1},
			{x=0.555976, y=0.720724, button=1},
			{x=0.571639, y=0.709176, button=1},
			{x=0.437535, y=0.653663, button=2},
			{x=0.503524, y=0.656182, button=2},
			{x=0.447420, y=0.735700, button=2},
		},
	},
	-- TODO: there is one in Revendreth as well
}

local function OnUpdate(self)
	local playerPosition = C_Map.GetPlayerMapPosition(self.data.mapID, "player")
	local x, y = playerPosition:GetXY()

	local bindButton
	for _, location in next, self.data.locations do
		-- use utilities by Blizzard (MathUtil)
		local distance = CalculateDistance(location.x * 100, location.y * 100, x * 100, y * 100)
		if distance <= (self.data.distance / 100) then
			bindButton = location.button
			break
		end
	end

	if bindButton then
		SetOverrideBindingClick(self, true, "SPACE", BUTTON:format(bindButton))
		RaidNotice_AddMessage(RaidWarningFrame, L["QuestHelperTip1"], P.InfoColors)
	else
		ClearOverrideBindings(self)
	end
end

local Handler = CreateFrame("Frame")
Handler:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
Handler:SetScript("OnEvent", function(self, event, unit, _, spellID)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local locationData = locations[spellID]
		if locationData then
			for i = 1, 2 do
				RaidNotice_AddMessage(RaidWarningFrame, L["QuestHelperTip1"], P.InfoColors)
			end

			self.data = locationData
			self:RegisterEvent("UNIT_EXITED_VEHICLE")
			self:SetScript("OnUpdate", OnUpdate)
		end
	elseif event == "UNIT_EXITED_VEHICLE" then
		-- just make sure we dont deadlock
		ClearOverrideBindings(self)

		-- cleanup
		self:UnregisterEvent(event)
		self:SetScript("OnUpdate", nil)
	end
end)