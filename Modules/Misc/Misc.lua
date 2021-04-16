local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:RegisterModule("Misc")

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

-- Credit: ElvUI_WindTools
function M:PauseToSlash()
	if not M.db["PauseToSlash"] then return end

	hooksecurefunc("ChatEdit_OnTextChanged", function(self, userInput)
		local text = self:GetText()
		if userInput then
			if text == "、" then
				self:SetText("/")
			end
		end
	end)
end

function M:HookSpecButton()
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

function M:TalentUI_Load(addon)
	if addon == "Blizzard_TalentUI" then
		M:HookSpecButton()
		B:UnregisterEvent(self, M.TalentUI_Load)
	end
end

function M:DoubleClickSpecSwap()
	if IsAddOnLoaded("Blizzard_TalentUI") then
		M:HookSpecButton()
	else
		B:RegisterEvent("ADDON_LOADED", M.TalentUI_Load)
	end
end

-- Credit: HideTalentAlert
function M:HideTalentAlert()
	if not M.db["HideTalentAlert"] then return end

	HelpTip:HideAll(UIParent)
	P:RawHook("MainMenuMicroButton_AreAlertsEnabled", function()
		return false
	end)
end

M:RegisterMisc("PauseToSlash", M.PauseToSlash)
M:RegisterMisc("DoubleClickSpecSwap", M.DoubleClickSpecSwap)
M:RegisterMisc("HideTalentAlert", M.HideTalentAlert)