local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function reskinSummonButton(button)
	if not button then
		P.Developer_ThrowError("button is nil")
		return
	end

	button.border:SetAlpha(0)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	button:GetHighlightTexture():SetInside()
	button.icon:SetInside()
	B.ReskinIcon(button.icon, true)
end

local function reskinDropDownMenu(_, level)
	local LibSFDropDown = LibStub("LibSFDropDown-1.5", true)
	if not LibSFDropDown then return end

	local menu = LibSFDropDown:GetMenu(level or 1)

	if not menu.__bg then
		menu.__bg = B.SetBD(menu, .7)
	end

	for _, backdrop in pairs(menu.styles) do
		backdrop:SetAlpha(0)
	end
end

local function handledDropDown(button)
	if not button or not button.ddToggle then
		return
	end

	hooksecurefunc(button, "ddToggle", reskinDropDownMenu)
end

local function updateVisibility(show)
	for _, key in ipairs({"bg", "CloseButton", "TitleContainer"}) do
		local element = _G.CollectionsJournal[key]
		if element then
			element:SetShown(show)
		end
	end
end

function S:MountsJournal()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local MountsJournal = _G.MountsJournal
	if not MountsJournal then return end

	local MountsJournalFrame = _G.MountsJournalFrame
	hooksecurefunc(MountsJournalFrame, "init", function(self)
		--MountsJournalBackground
		local bgFrame = self.bgFrame
		if bgFrame then
			B.ReskinPortraitFrame(bgFrame)
			S:Proxy("ReskinClose", bgFrame.closeButton)
			S:Proxy("StripTextures", bgFrame.leftInset)
			S:Proxy("StripTextures", bgFrame.rightInset)

			for _, key in ipairs({"btnConfig", "mountSpecial", "summonButton"}) do
				S:Proxy("Reskin", bgFrame[key])
			end

			for _, key in ipairs({"DynamicFlightModeButton", "OpenDynamicFlightSkillTreeButton"}) do
				local button = bgFrame[key]
				if button then
					button:SetNormalTexture(0)
					button:SetPushedTexture(DB.pushedTex)
					button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					button:GetHighlightTexture():SetInside()
					button.texture = button.texture or select(4, button:GetRegions())
					button.texture:SetInside()
					B.ReskinIcon(button.texture, true)
				end
			end

			for _, key in ipairs({"summon1", "summon2"}) do
				reskinSummonButton(bgFrame[key])
			end

			local profilesMenu = bgFrame.profilesMenu
			if profilesMenu then
				B.ReskinFilterButton(profilesMenu)
				handledDropDown(profilesMenu)
			end

			hooksecurefunc(bgFrame, "StopMovingOrSizing", function()
				bgFrame:ClearAllPoints()
				bgFrame:SetPoint("TOPLEFT")
			end)

			updateVisibility(not bgFrame:IsShown())
			bgFrame:HookScript("OnShow", function ()
				updateVisibility(false)
			end)
			bgFrame:HookScript("OnHide", function()
				updateVisibility(true)
			end)
		end

		S:Proxy("StripTextures", self.mountCount)
		S:Proxy("CreateBDFrame", self.mountCount, .25)
		S:Proxy("ReskinNavBar", self.navBar)
		S:Proxy("ReskinCheck", self.useMountsJournalButton)

		local worldMap = self.worldMap
		if worldMap then
			B.StripTextures(worldMap)
			local bg = B.CreateBDFrame(worldMap, .25)
			bg:SetOutside(worldMap.ScrollContainer.Child)
		end

		local mapSettings = self.mapSettings
		if mapSettings then
			B.StripTextures(mapSettings)
			S:Proxy("StripTextures", mapSettings.mapControl)
			S:Proxy("Reskin", mapSettings.CurrentMap)

			local ndr = mapSettings.dnr
			if ndr then
				B.ReskinFilterButton(ndr)
				handledDropDown(ndr)
			end
		end

		local mountDisplay = self.mountDisplay
		if mountDisplay then
			B.StripTextures(mountDisplay)
			B.CreateBDFrame(mountDisplay, .25)

			if mountDisplay.shadowOverlay then
				mountDisplay.shadowOverlay:SetAlpha(0)
			end

			local info = mountDisplay.info
			if info then
				B.ReskinIcon(info.icon)

				local petSelectionBtn = info.petSelectionBtn
				if petSelectionBtn then
					B.StripTextures(petSelectionBtn)
					B.CreateBDFrame(petSelectionBtn, .25)
				end
			end
		end

		local filtersPanel = self.filtersPanel
		if filtersPanel then
			B.StripTextures(filtersPanel)
		end
	end)

	local summonPanel = MountsJournal.summonPanel
	if summonPanel then
		B.StripTextures(summonPanel)
		B.SetBD(summonPanel)
		reskinSummonButton(summonPanel.summon1)
		reskinSummonButton(summonPanel.summon2)
		handledDropDown(summonPanel.contextMenu)
	end
end
S:RegisterSkin("MountsJournal", S.MountsJournal)