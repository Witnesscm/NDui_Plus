local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local _G = getfenv(0)
----------------------------
-- Credit: Leatrix Plus
----------------------------
function M:ExtTrainerUI()
	if not M.db["ExtTrainerUI"] then return end

	if ClassTrainerFrame:GetWidth() > 700 then return end

	UIPanelWindows["ClassTrainerFrame"] = {area = "override", pushable = 1, xoffset = -16, yoffset = 12, bottomClampOverride = 140 + 12, width = 714, height = 487, whileDead = 1}

	ClassTrainerFrame:SetSize(714, 487)
	ClassTrainerNameText:ClearAllPoints()
	ClassTrainerNameText:SetPoint("TOP", ClassTrainerFrame, "TOP", 0, -18)
	ClassTrainerListScrollFrame:ClearAllPoints()
	ClassTrainerListScrollFrame:SetPoint("TOPLEFT", ClassTrainerFrame, "TOPLEFT", 25, -75)
	ClassTrainerListScrollFrame:SetSize(295, 336)

	do
		local oldSkillsDisplayed = CLASS_TRAINER_SKILLS_DISPLAYED
		for i = 1 + 1, CLASS_TRAINER_SKILLS_DISPLAYED do
			_G["ClassTrainerSkill" .. i]:ClearAllPoints()
			_G["ClassTrainerSkill" .. i]:SetPoint("TOPLEFT", _G["ClassTrainerSkill" .. (i - 1)], "BOTTOMLEFT", 0, 1)
		end

		_G.CLASS_TRAINER_SKILLS_DISPLAYED = _G.CLASS_TRAINER_SKILLS_DISPLAYED + 12
		for i = oldSkillsDisplayed + 1, CLASS_TRAINER_SKILLS_DISPLAYED do
			local button = CreateFrame("Button", "ClassTrainerSkill" .. i, ClassTrainerFrame, "ClassTrainerSkillButtonTemplate")
			button:SetID(i)
			button:Hide()
			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", _G["ClassTrainerSkill" .. (i - 1)], "BOTTOMLEFT", 0, 1)
		end

		hooksecurefunc("ClassTrainer_SetToTradeSkillTrainer", function()
			_G.CLASS_TRAINER_SKILLS_DISPLAYED = _G.CLASS_TRAINER_SKILLS_DISPLAYED + 12
			ClassTrainerListScrollFrame:SetHeight(336)
			ClassTrainerDetailScrollFrame:SetHeight(336)
		end)

		hooksecurefunc("ClassTrainer_SetToClassTrainer", function()
			_G.CLASS_TRAINER_SKILLS_DISPLAYED = _G.CLASS_TRAINER_SKILLS_DISPLAYED + 11
			ClassTrainerListScrollFrame:SetHeight(336)
			ClassTrainerDetailScrollFrame:SetHeight(336)
		end)

	end

	hooksecurefunc(_G["ClassTrainerSkillHighlightFrame"], "Show", function()
		ClassTrainerSkillHighlightFrame:SetWidth(290)
	end)

	ClassTrainerDetailScrollFrame:ClearAllPoints()
	ClassTrainerDetailScrollFrame:SetPoint("TOPLEFT", _G["ClassTrainerFrame"], "TOPLEFT", 352, -74)
	ClassTrainerDetailScrollFrame:SetSize(296, 336)
	ClassTrainerDetailScrollFrameTop:SetAlpha(0)
	ClassTrainerDetailScrollFrameBottom:SetAlpha(0)
	ClassTrainerExpandTabLeft:Hide()

	local regions = {ClassTrainerFrame:GetRegions()}
	regions[2]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Left")
	regions[2]:SetSize(512, 512)
	regions[3]:ClearAllPoints()
	regions[3]:SetPoint("TOPLEFT", regions[2], "TOPRIGHT", 0, 0)
	regions[3]:SetTexture("Interface\\QUESTFRAME\\UI-QuestLogDualPane-Right")
	regions[3]:SetSize(256, 512)
	regions[4]:Hide()
	regions[5]:Hide()
	regions[9]:Hide()
	ClassTrainerHorizontalBarLeft:Hide()

	local RecipeInset = ClassTrainerFrame:CreateTexture(nil, "ARTWORK")
	RecipeInset:SetSize(304, 361)
	RecipeInset:SetPoint("TOPLEFT", _G["ClassTrainerFrame"], "TOPLEFT", 16, -72)
	RecipeInset:SetTexture("Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg")

	local DetailsInset = ClassTrainerFrame:CreateTexture(nil, "ARTWORK")
	DetailsInset:SetSize(302, 339)
	DetailsInset:SetPoint("TOPLEFT", ClassTrainerFrame, "TOPLEFT", 348, -72)

	ClassTrainerTrainButton:ClearAllPoints()
	ClassTrainerTrainButton:SetPoint("RIGHT", ClassTrainerCancelButton, "LEFT", -1, 0)

	ClassTrainerCancelButton:SetSize(80, 22)
	ClassTrainerCancelButton:SetText(CLOSE)
	ClassTrainerCancelButton:ClearAllPoints()
	ClassTrainerCancelButton:SetPoint("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMRIGHT", -42, 54)

	ClassTrainerFrameFilterDropDown:ClearAllPoints()
	ClassTrainerFrameFilterDropDown:SetPoint("TOPLEFT", ClassTrainerFrame, "TOPLEFT", 501, -40)

	ClassTrainerMoneyFrame:ClearAllPoints()
	ClassTrainerMoneyFrame:SetPoint("TOPLEFT", ClassTrainerFrame, "TOPLEFT", 143, -49)
	ClassTrainerGreetingText:Hide()

	if C.db["Skins"]["BlizzardSkins"] then
		regions[2]:Hide()
		regions[3]:Hide()
		RecipeInset:Hide()
		DetailsInset:Hide()
		ClassTrainerFrame:SetHeight(512)
		ClassTrainerCancelButton:ClearAllPoints()
		ClassTrainerCancelButton:SetPoint("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMRIGHT", -42, 78)

		for i = 12, 23 do
			local bu = _G["ClassTrainerSkill"..i]
			if bu then
				B.ReskinCollapse(bu)
			end
		end
	end
end

P:AddCallbackForAddon("Blizzard_TrainerUI", M.ExtTrainerUI)