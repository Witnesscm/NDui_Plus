local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local Zones = {
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

	hooksecurefunc("GossipFrameOptionsUpdate", function()
		local npcID = B.GetNPCID(UnitGUID("npc"))
		if npcID ~= 81205 then return end

		for i, id in ipairs(Zones) do
			local button = _G.GossipFrame.buttons[i]
			if button then
				button:SetText(GetMapNameByID(id))
			end
		end
	end)

	if not IsAddOnLoaded("Immersion") then return end

	local Titles = _G.ImmersionFrame.TitleButtons
	hooksecurefunc(Titles, "UpdateGossipOptions", function(self)
		local npcID = B.GetNPCID(UnitGUID("npc"))
		if npcID ~= 81205 then return end

		for i, id in ipairs(Zones) do
			local button = self:GetButton(self.idx - #Zones - 1 + i)
			button:SetText(GetMapNameByID(id))
		end
	end)
end

M:RegisterMisc("WormholeHelper", M.WormholeHelper)