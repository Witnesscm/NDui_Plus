local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function ReskinAtlas(self)
	if not self then
		P.Developer_ThrowError("atlas frame is nil")
		return
	end

	local name = self:GetName()
	B.ReskinPortraitFrame(self)
	B.ReskinDropDown(_G[name .. "DropDownType"])
	B.ReskinDropDown(_G[name .. "DropDown"])
	_G[name .. "LockButton"]:Hide()
	B.Reskin(_G[name .. "OptionsButton"])
	_G[name .. "OptionsButton"]:SetPoint("RIGHT", _G[name .. "CloseButton"], "LEFT", -5, 0)
	B.ReskinArrow(_G[name .. "PrevMapButton"], "left")
	B.ReskinArrow(_G[name .. "NextMapButton"], "right")
end

function S:Atlas()
	if not S.db["Atlas"] then return end

	local addon = LibStub("AceAddon-3.0"):GetAddon("Atlas")
	addon.db.profile.options.frames.lock = false

	ReskinAtlas(AtlasFrame)
	ReskinAtlas(AtlasFrameSmall)
	B.Reskin(AtlasSwitchButton)
	B.Reskin(AtlasSearchButton)
	B.Reskin(AtlasSearchClearButton)
	B.ReskinScroll(AtlasScrollBarScrollBar)
	B.ReskinArrow(AtlasFrameCollapseButton, "left")
	B.ReskinArrow(AtlasFrameSmallExpandButton, "right")
	B.ReskinInput(AtlasSearchEditBox)
	AtlasSearchEditBox.bg:SetPoint("TOPLEFT", -2, -4)
	AtlasSearchEditBox.bg:SetPoint("BOTTOMRIGHT", 0, 4)
end

function S:AtlasQuest()
	if not S.db["Atlas"] then return end

	local frame = _G.AtlasQuestFrame
	if not frame then return end

	B.StripTextures(frame)
	B.SetBD(frame)
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMRIGHT", AtlasFrame, "BOTTOMLEFT", -3, 0)
	B.Reskin(CLOSEbutton3)
	B.Reskin(OPTIONbutton)
	B.ReskinCheck(AQACB)
	B.ReskinCheck(AQHCB)

	hooksecurefunc("AQRIGHTOption_OnClick", function()
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", AtlasFrame, "BOTTOMRIGHT", 3, 0)
	end)

	hooksecurefunc("AQLEFTOption_OnClick", function()
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMRIGHT", AtlasFrame, "BOTTOMLEFT", -3, 0)
	end)

	hooksecurefunc("AQ_AtlasOrAlphamap", function()
		if (AQ_ShownSide == "Right") then
			frame:ClearAllPoints()
			frame:SetPoint("BOTTOMLEFT", AtlasFrame, "BOTTOMRIGHT", 3, 0)
		else
			frame:ClearAllPoints()
			frame:SetPoint("BOTTOMRIGHT", AtlasFrame, "BOTTOMLEFT", -3, 0)
		end
	end)

	local optFrame = AtlasQuestOptionFrame
	B.StripTextures(optFrame)
	B.SetBD(optFrame)
	B.CreateMF(optFrame)
	B.Reskin(AQOptionCloseButton)
	B.Reskin(AQOptionQuestQueryButton)
	B.Reskin(AQOptionClaerQuestAndQueryButton)
	B.Reskin(AQAutoshowOption)
	B.Reskin(AQLEFTOption)
	B.Reskin(AQRIGHTOption)
	B.Reskin(AQColourOption)
	B.Reskin(AQCheckQuestlogButton)
	B.Reskin(AQCompareTooltipOption)
end

S:RegisterSkin("Atlas", S.Atlas)
S:RegisterSkin("AtlasQuest", S.AtlasQuest)
