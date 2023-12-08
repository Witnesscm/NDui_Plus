local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local tinsert, ipairs = table.insert, ipairs

-- Compatible with MerInspect, alaGearMan, CharacterStatsTBC.

local addonFrames = {}

local lastTime = 0
function S:UpdatePanelsPosition(force)
	if (not force and GetTime() - lastTime < .1) then return end

	local offset = 0
	for _, panels in ipairs(addonFrames) do
		local frame = panels.frame
		if frame:IsShown() then
			if panels.order == 3 then
				frame:SetPoint("TOPLEFT", _G.PaperDollFrame, "TOPRIGHT", -33 + offset, -15)
			else
				frame:SetPoint("TOPLEFT", _G.PaperDollFrame, "TOPRIGHT", -32 + offset, -15-C.mult)
			end
			offset = offset + frame:GetWidth() + 3
		end
	end

	lastTime = GetTime()
end

-- MerInspect
function S:CharacterPanel_MerInspect()
	local LibItemInfo = _G.LibStub("LibItemInfo.1000", true)
	if LibItemInfo and _G.ShowInspectItemListFrame then
		local ilevel, _, maxLevel = LibItemInfo:GetUnitItemLevel("player")
		local inspectFrame = _G.ShowInspectItemListFrame("player", _G.PaperDollFrame, ilevel, maxLevel)

		tinsert(addonFrames, {frame = inspectFrame, order = 3})

		hooksecurefunc("ShowInspectItemListFrame", function(unit, parent, ...)
			if unit and unit == "player" and parent and parent:GetName() == "PaperDollFrame" then
				S:UpdatePanelsPosition(true)
			end
		end)
	end
end

-- CharacterStatsTBC
function S:CharacterPanel_CharacterStatsTBC()
	local sideStatsFrame = _G.CSC_SideStatsFrame
	if sideStatsFrame then
		sideStatsFrame:SetHeight(422)
		sideStatsFrame:ClearAllPoints()
		sideStatsFrame:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", -32, -15-C.mult)

		tinsert(addonFrames, {frame = sideStatsFrame, order = 2})
	end
end

-- alaGearMan
function S:CharacterPanel_alaGearMan()
	local AGM_FUNC = _G.AGM_FUNC
	if not AGM_FUNC or not AGM_FUNC.initUI then return end

	hooksecurefunc(AGM_FUNC, "initUI", function()
		local ALA = _G.__ala_meta__
		if not ALA then return end

		local gearWin = ALA.gear and ALA.gear.ui.gearWin
		if gearWin then
			tinsert(addonFrames, {frame = gearWin, order = 1})
		end
	end)
end

function S:CharacterPanel()
	local done
	_G.PaperDollFrame:HookScript("OnShow", function()
		if not done then
			table.sort(addonFrames, function(a, b)
				return a.order < b.order
			end)

			for _, panels in ipairs(addonFrames) do
				panels.frame:HookScript("OnShow", S.UpdatePanelsPosition)
				panels.frame:HookScript("OnHide", S.UpdatePanelsPosition)
			end

			done = true
		end

		S:UpdatePanelsPosition()
	end)
end

--S:RegisterSkin("MerInspect", S.CharacterPanel_MerInspect)
--S:RegisterSkin("alaGearMan", S.CharacterPanel_alaGearMan)
--S:RegisterSkin("CharacterStatsTBC", S.CharacterPanel_CharacterStatsTBC)
--S:RegisterSkin("CharacterPanel")