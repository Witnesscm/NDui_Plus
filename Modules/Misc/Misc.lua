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

function M.DU_CreateButton(name, frame, label, width, height, point, relativeTo, relativePoint, xOffset, yOffset)
	local name = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	name:SetSize(width, height)
	name:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
	name:SetText(label)
	name:RegisterForClicks("AnyUp")
	name:SetHitRectInsets(0, 0, 0, 0)
	B.Reskin(name)

	return name
end

function M:DressUp()
	if not M.db["DressUp"] then return end

	local OneNake = M.DU_CreateButton("DressUpOneNake", DressUpFrame, WEAPON, 75, 22, "RIGHT", DressUpFrameResetButton, "LEFT", -2, 0)
	OneNake:SetScript("OnClick", function()
		local playerActor = DressUpFrame.ModelScene:GetPlayerActor()
		if not playerActor then return end

		for i = 16, 19 do
			playerActor:UndressSlot(i)
		end
	end)

	local AllNake = M.DU_CreateButton("DressUpAllNake", DressUpFrame, ALL, 75, 22, "RIGHT", OneNake, "LEFT", -2, 0)
	AllNake:SetScript("OnClick", function()
		local playerActor = DressUpFrame.ModelScene:GetPlayerActor()
		if not playerActor then return end

		for i = 1, 19 do
			playerActor:UndressSlot(i)
		end
	end)

	hooksecurefunc(DressUpFrame.ModelScene, "TransitionToModelSceneID", function(self, modelSceneID, ...)
		local isPlayerModel = modelSceneID == 290
		OneNake:SetShown(isPlayerModel)
		AllNake:SetShown(isPlayerModel)
	end)
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
	end
end

function M:TalentUI_Load(addon)
	if addon == "Blizzard_TalentUI" then
		M:HookSpecButton()
		B:UnregisterEvent(self, M.TalentUI_Load)
	end
end

function M:DoubleClickSpecSwap()
	if not M.db["QuickSpecSwap"] then return end

	if IsAddOnLoaded("Blizzard_TalentUI") then
		M:HookSpecButton()
	else
		B:RegisterEvent("ADDON_LOADED", M.TalentUI_Load)
	end
end

M:RegisterMisc("DressUp", M.DressUp)
M:RegisterMisc("PauseToSlash", M.PauseToSlash)
M:RegisterMisc("DoubleClickSpecSwap", M.DoubleClickSpecSwap)