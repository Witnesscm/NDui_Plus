local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local ShowUIPanel = LibStub("LibShowUIPanel-1.0").ShowUIPanel
local OLD_GetCurrentGarrTalentTreeID = C_Garrison.GetCurrentGarrTalentTreeID

local CYPHER_GARR_TYPE = 111
local CYPHER_GARR_TREE_ID = 474

function M:CypherConsole_OnLoad()
	OrderHallTalentFrame:HookScript("OnHide", function()
		_G.C_Garrison.GetCurrentGarrTalentTreeID = function(...)
			return OLD_GetCurrentGarrTalentTreeID(...)
		end
	end)
end

P:AddCallbackForAddon("Blizzard_OrderHallUI", M.CypherConsole_OnLoad)

function M:CypherConsole()
	GarrisonLandingPageMinimapButton:HookScript("OnMouseDown", function(_, btn)
		if btn == "MiddleButton" then
			if not OrderHallTalentFrame then
				OrderHall_LoadUI()
			end

			_G.C_Garrison.GetCurrentGarrTalentTreeID = function()
				return CYPHER_GARR_TREE_ID
			end

			OrderHallTalentFrame:SetGarrisonType(CYPHER_GARR_TYPE, CYPHER_GARR_TREE_ID)
			ShowUIPanel(OrderHallTalentFrame)
		end
	end)

	GarrisonLandingPageMinimapButton:HookScript("OnEnter", function()
		GameTooltip:AddLine(DB.ScrollButton..L["CypherResearchConsole"], nil, nil, nil, true)
		GameTooltip:Show()
	end)
end

M:RegisterMisc("CypherConsole", M.CypherConsole)