local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local WormholeNPC = 81205

local WormholeZones = {
	[1] = 542,
	[2] = 535,
	[3] = 539,
	[4] = 550,
	[5] = 543,
	[6] = 525,
}

local mapIDToName = {}
local function GetMapNameByID(mapID)
	if not mapIDToName[mapID] then
		local mapInfo =  C_Map.GetMapInfo(mapID)
		mapIDToName[mapID] = mapInfo and mapInfo.name
	end

	return mapIDToName[mapID]
end

function M:WormholeHelper()
	if not M.db["WormholeHelper"] then return end

	hooksecurefunc(_G.GossipFrame, "Update", function(self)
		local npcID = B.GetNPCID(UnitGUID("npc"))
		if npcID ~= WormholeNPC then return end

		for _, button in self.GreetingPanel.ScrollBox:EnumerateFrames() do
			local data = button.GetElementData and button:GetElementData()
			local id = data and data.index and WormholeZones[data.index]
			if id then
				button:SetText(GetMapNameByID(id))
			end
		end
	end)

	if not C_AddOns.IsAddOnLoaded("Immersion") then return end

	local Titles = _G.ImmersionFrame.TitleButtons
	hooksecurefunc(Titles, "UpdateGossipOptions", function(self)
		local npcID = B.GetNPCID(UnitGUID("npc"))
		if npcID ~= WormholeNPC then return end

		for i, id in ipairs(WormholeZones) do
			local button = self.Buttons[self.idx - #WormholeZones - 1 + i]
			if button then
				button:SetText(GetMapNameByID(id))
			end
		end
	end)
end

M:RegisterMisc("WormholeHelper", M.WormholeHelper)