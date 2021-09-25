local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:RegisterModule("Misc")

local _G = getfenv(0)
local strmatch, format, tonumber, select, tinsert = string.match, string.format, tonumber, select, tinsert

M.MiscList = {}

function M:RegisterMisc(name, func)
	if not M.MiscList[name] then
		M.MiscList[name] = func
	end
end

function M:OnLogin()
	for name, func in next, M.MiscList do
		if name and type(func) == "function" then
			local _, catch = pcall(func)
			P:ThrowError(catch, format("%s Misc", name))
		end
	end
end

-- DoubleClick to swap specialization.
function M:DoubleClickSpecSwap()
	for i = 1, GetNumSpecializations() do
		local button = _G["PlayerTalentFrameSpecializationSpecButton"..i]
		button:HookScript("OnDoubleClick", function() 
			if i ~= GetSpecialization() then SetSpecialization(i) end
		end)

		button:HookScript("OnEnter", function() 
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(DB.LeftButton..L["QuickSpecSwap"], .6, .8, 1)
			GameTooltip:Show()
		end)
	end
end

P:AddCallbackForAddon("Blizzard_TalentUI", M.DoubleClickSpecSwap)

-- Hides the Talent popup notifications. Credit: HideTalentAlert
function M:HideTalentAlert()
	if not M.db["HideTalentAlert"] then return end

	_G.HelpTip:HideAll(UIParent)
	function _G.MainMenuMicroButton_AreAlertsEnabled()
		return false
	end
end

M:RegisterMisc("HideTalentAlert", M.HideTalentAlert)