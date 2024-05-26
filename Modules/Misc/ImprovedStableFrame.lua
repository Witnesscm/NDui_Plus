local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")
----------------------------
-- Improved Stable Frame, by Cybeloras
----------------------------
local NUM_PER_ROW = 10
local maxSlots = NUM_PET_STABLE_PAGES * NUM_PET_STABLE_SLOTS

local function ImprovedStableFrame_Update()
	local input = _G.ISF_SearchInput:GetText()

	for i = 1, maxSlots do
		local button = _G["PetStableStabledPet"..i]
		if not input or input:trim() == "" then
			button.dimOverlay:Hide()
		else
			button.dimOverlay:Show()
		end

		local _, name, _, family, talent = GetStablePetInfo(NUM_PET_ACTIVE_SLOTS + i)
		if name then
			local matched, expected = 0, 0
			for text in input:gmatch("([^%s]+)") do
				expected = expected + 1
				text = text:trim():lower()

				if name:lower():find(text) or family:lower():find(text) or talent:lower():find(text) then
					matched = matched + 1
				end
			end

			if matched == expected then
				button.dimOverlay:Hide()
			end
		end
	end
end

local function updateBackdropColor(self)
	if not self:GetParent().bg then return end
	self:GetParent().bg:SetBackdropBorderColor(1, 1, 1)
end

local function resetBackdropColor(self)
	if not self:GetParent().bg then return end
	self:GetParent().bg:SetBackdropBorderColor(0, 0, 0)
end

function M:ImprovedStableFrame()
	if DB.MyClass ~= "HUNTER" or not M.db["ImprovedStableFrame"] then return end

	local newWidth, newHeight = 300, 204
	local oldWidth, oldHeight = PetStableFrame:GetSize()

	-- ImprovedPetStableFrame
	local frame = CreateFrame("Frame", "ImprovedPetStableFrame", PetStableFrame, "InsetFrameTemplate")
	frame:SetSize(newWidth, oldHeight + newHeight - 28)
	frame:SetPoint(PetStableFrame.Inset:GetPoint(1))

	PetStableFrame.Inset:SetPoint("TOPLEFT", frame, "TOPRIGHT")
	PetStableFrame:SetWidth(oldWidth + newWidth)
	PetStableFrame:SetHeight(oldHeight + newHeight)
	PetStableFrameModelBg:SetHeight(281 + newHeight)

	local mp1, mp2, mp3, mp4, mp5 = PetStableModelScene:GetPoint()
	PetStableModelScene:SetPoint(mp1, mp2, mp3, mp4, mp5 - 32)

	local search = CreateFrame("EditBox", "ISF_SearchInput", frame, "SearchBoxTemplate")
	search:SetPoint("TOPLEFT", 9, -3)
	search:SetPoint("RIGHT", -3, 0)
	search:SetHeight(20)
	search:HookScript("OnTextChanged", ImprovedStableFrame_Update)
	search.Instructions:SetFormattedText("%s（%s、%s、%s）", SEARCH, NAME, PET_FAMILIES, PET_TALENTS)

	PetStableNextPageButton:Hide()
	PetStablePrevPageButton:Hide()

	hooksecurefunc("PetStable_Update", ImprovedStableFrame_Update)

	-- PetStableButton
	for i = 1, maxSlots do
		local button = _G["PetStableStabledPet"..i]
		if not button then
			button = CreateFrame("Button", "PetStableStabledPet"..i, _G.PetStableFrame, "PetStableSlotTemplate", i)
		end

		button:SetScale(7/NUM_PER_ROW)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("TOPLEFT", frame, 8, -36)
		elseif i % NUM_PER_ROW == 1 then
			button:SetPoint("TOPLEFT", _G["PetStableStabledPet"..i-NUM_PER_ROW], "BOTTOMLEFT", 0, -5)
		else
			button:SetPoint("LEFT", _G["PetStableStabledPet"..i-1], "RIGHT", 5, 0)
		end

		button.dimOverlay = button:CreateTexture(nil, "OVERLAY")
		button.dimOverlay:SetColorTexture(0, 0, 0, .7)
		button.dimOverlay:SetAllPoints()
		button.dimOverlay:Hide()
	end

	if C.db["Skins"]["BlizzardSkins"] then
		B.StripTextures(frame)
		B.ReskinInput(search)
		search:SetPoint("TOPLEFT", 9, 0)
		search:SetPoint("RIGHT", -1, 0)
		PetStableStabledPet1:SetPoint("TOPLEFT", frame, 8, -24)

		for i = 1, maxSlots do
			local bu = _G["PetStableStabledPet"..i]

			bu:SetScale(1)
			bu:SetSize(24.5, 24.5)
			bu.Checked:SetTexture("")
			hooksecurefunc(bu.Checked, "Show", updateBackdropColor)
			hooksecurefunc(bu.Checked, "Hide", resetBackdropColor)

			if i > NUM_PET_STABLE_SLOTS then
				bu:SetNormalTexture(0)
				bu:SetPushedTexture(0)
				bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				bu:DisableDrawLayer("BACKGROUND")
				_G["PetStableStabledPet"..i.."IconTexture"]:SetTexCoord(unpack(DB.TexCoord))
				bu.bg = B.CreateBDFrame(bu, .25)
			elseif not bu.bg then
				for _, child in pairs {bu:GetChildren()} do
					if child.backdropInfo and child.backdropInfo.bgFile == DB.bdTex then
						bu.bg = child
						break
					end
				end
			end
		end
	end

	-- Disable page turn
	NUM_PET_STABLE_SLOTS = maxSlots
	NUM_PET_STABLE_PAGES = 1
	PetStableFrame.page = 1
end

M:RegisterMisc("ImprovedStableFrame", M.ImprovedStableFrame)