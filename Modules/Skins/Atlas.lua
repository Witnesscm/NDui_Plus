local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function ReskinAtlas(self, small)
	if not self then
		P.Developer_ThrowError("atlas frame is nil")
		return
	end

	local name = self:GetName()
	B.ReskinPortraitFrame(self)
	_G[name .. "LockButton"]:Hide()
	S:Proxy("ReskinDropDown", _G[name .. "DropDownType"])
	S:Proxy("ReskinDropDown", _G[name .. "DropDown"])
	S:Proxy("Reskin", _G[name .. "OptionsButton"])
	S:Proxy("Reskin", _G[name .. "SwitchButton"])
	S:Proxy("ReskinDropDown", _G[name .. "SwitchDropdown"])

	local MapFrame = self.MapFrame
	if MapFrame then
		B.StripTextures(MapFrame, 0)
		local mapTexture = small and _G.AtlasMapSmall or _G.AtlasMap
		mapTexture:SetAlpha(1)
		B.CreateBDFrame(mapTexture, 0)
	end

	local PrevNextContainer = _G[name .. "PrevNextContainer"]
	if PrevNextContainer then
		S:Proxy("ReskinArrow", PrevNextContainer.PrevMap, "left")
		S:Proxy("ReskinArrow", PrevNextContainer.NextMap, "right")
	end

	for _, key in ipairs({"AdventureJournalMap", "AdventureJournal", "AtlasLoot"}) do
		local button = self[key]
		if button then
			B.StripTextures(button, 0)
			button:GetHighlightTexture():SetAlpha(1)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			B.ReskinIcon(button.Icon)
			button.Icon:SetAlpha(1)
		end
	end
end

function S:Atlas()
	if not S.db["Atlas"] then return end

	local addon = LibStub("AceAddon-3.0"):GetAddon("Atlas")
	addon.db.profile.options.frames.lock = false

	ReskinAtlas(_G.AtlasFrame)
	ReskinAtlas(_G.AtlasFrameSmall, true)
	S:Proxy("ReskinArrow", _G.AtlasFrameCollapseButton, "left")
	S:Proxy("ReskinArrow", _G.AtlasFrameSmallExpandButton, "right")

	local LFGButton = _G.AtlasFrameLFGButton
	if LFGButton then
		LFGButton:SetNormalTexture(0)
	end

	local SearchEditBox = _G.AtlasSearchEditBox
	if SearchEditBox then
		B.ReskinInput(SearchEditBox)
		SearchEditBox.bg:SetPoint("TOPLEFT", -2, -4)
		SearchEditBox.bg:SetPoint("BOTTOMRIGHT", 0, 4)
	end

	local TopInset = _G.AtlasFrameTopInset
	if TopInset then
		B.StripTextures(TopInset)
		local bg = B.CreateBDFrame(TopInset, .25)
		bg:SetInside()
	end

	local styled
	_G.AtlasFrame:HookScript("OnShow", function()
		if styled then return end

		local BottomInset = _G.AtlasFrameBottomInset
		if BottomInset then
			for _, child in pairs {BottomInset:GetChildren()} do
				if child.Back and child.Forward then
					B.ReskinTrimScroll(child)
					break
				end
			end
		end

		styled = true
	end)
end

function S:AtlasQuest()
	if not S.db["Atlas"] then return end

	local frame = _G.AtlasQuestFrame
	if not frame then return end

	B.StripTextures(frame)
	frame.bg = B.SetBD(frame, nil, 3, -1, -2, 1)
	S:Proxy("Reskin", _G.AQ_OptionsButton)
	S:Proxy("Reskin", _G.AQ_AtlasToggle)
	S:Proxy("ReskinClose", _G.AQ_SidebarClose)
	S:Proxy("ReskinCheck", _G.AQ_AllianceCheck)
	S:Proxy("ReskinCheck", _G.AQ_HordeCheck)
	S:Proxy("ReskinClose", _G.AQ_QuestClose)
	S:Proxy("ReskinCheck", _G.AQ_FinishedQuestCheck)

	local styled
	_G.AtlasQuestInsideFrame:HookScript("OnShow", function()
		if styled then return end

		for i = 1, 6 do
			local button = _G["AQ_QuestItem_" .. i]
			if button then
				button.bg = B.ReskinIcon(button.icon)
				B.ReskinIconBorder(button.qualityBorder)
				button.qualityBorder:Hide()
			end
		end

		styled = true
	end)
end

S:RegisterSkin("Atlas", S.Atlas)
S:RegisterSkin("AtlasQuest", S.AtlasQuest)