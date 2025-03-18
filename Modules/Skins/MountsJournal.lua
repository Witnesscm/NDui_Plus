local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function handleActionButton(button)
	if not button then
		P.Developer_ThrowError("button is nil")
		return
	end

	button:SetNormalTexture(0)
	button:SetPushedTexture(DB.pushedTex)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	button:GetHighlightTexture():SetInside()
	if button.IconMask then button.IconMask:Hide() end
	button.icon = button.icon or select(4, button:GetRegions())
	button.icon:SetInside()
	B.ReskinIcon(button.icon, true)
end

local function handleIconButton(button)
	if not button then
		P.Developer_ThrowError("button is nil")
		return
	end

	button.border:SetAlpha(0)
	button:SetPushedTexture(DB.pushedTex)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	button:GetHighlightTexture():SetInside()
	button.icon:SetInside()
	button.bg = B.ReskinIcon(button.icon, true)
end

local function handleIconDataButton(button)
	if not button.styled then
		handleIconButton(button)
		button.selectedTexture:SetColorTexture(1, .8, 0, .5)
		button.selectedTexture:SetInside(button.bg)

		button.styled = true
	end
end

local function toggleDropDownMenu(_, level)
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
		P.Developer_ThrowError("dropdown menu is nil")
		return
	end

	hooksecurefunc(button, "ddToggle", toggleDropDownMenu)
end

local function handledFilterButton(button)
	if not button then
		P.Developer_ThrowError("filter button is nil")
		return
	end

	B.ReskinFilterButton(button)
	button.__bg:SetPoint("TOPLEFT", 1, 0)
	button.__bg:SetPoint("BOTTOMRIGHT", -1, 0)
	handledDropDown(button)
end

local function handleCombobox(self)
	if not self then
		P.Developer_ThrowError("combobox is nil")
		return
	end

	S:Proxy("ReskinDropDown", self)
	handledDropDown(self)
end

local function updateVisibility(show)
	for _, key in ipairs({"bg", "CloseButton", "TitleContainer"}) do
		local element = _G.CollectionsJournal[key]
		if element then
			element:SetShown(show)
		end
	end
end

local function handlePetIcon(self)
	self.bg = B.ReskinIcon(self.icon)
	B.ReskinIconBorder(self.qualityBorder)
	self.levelBG:SetAlpha(0)
end

local function handlePetButton(self)
	if not self.styled then
		self.background:SetAlpha(0)
		self.bg = B.CreateBDFrame(self.background, .25)
		self.bg:SetInside(self.background)
		local hl = self:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(self.bg)
		self.selectedTexture:SetColorTexture(DB.r, DB.g, DB.b, .25)
		self.selectedTexture:SetInside(self.bg)
		handlePetIcon(self.infoFrame)

		self.styled = true
	end
end

local function handlePetList(self)
	local list = self.petSelectionList
	if list and not list.styled then
		B.StripTextures(list)
		B.SetBD(list)
		S:Proxy("ReskinClose", list.closeButton)
		S:Proxy("StripTextures", list.controlPanel)
		S:Proxy("ReskinInput", list.searchBox)
		S:Proxy("StripTextures", list.filtersPanel)
		S:Proxy("StripTextures", list.controlButtons)
		S:Proxy("StripTextures", list.petListFrame)
		handlePetButton(list.randomFavoritePet)
		handlePetButton(list.randomPet)
		handlePetButton(list.noPet)

		local buttons = list.filtersPanel and list.filtersPanel.buttons
		if buttons then
			for _, button in pairs(buttons) do
				button:SetBackdrop(nil)
				button.bg = B.CreateBDFrame(button)
				button.bg:SetInside()
				button.icon:SetInside(button.bg)
				button.icon:SetTexCoord(unpack(DB.TexCoord))
				button.highlight:SetColorTexture(1, 1, 1, .25)
				button.highlight:SetInside(button.bg)
				button:SetCheckedTexture(DB.pushedTex)
			end
		end

		local petListFrame = list.petListFrame
		if petListFrame then
			S:Proxy("ReskinTrimScroll", petListFrame.scrollBar)
			hooksecurefunc(petListFrame.scrollBox, "Update", function(self)
				self:ForEachFrame(handlePetButton)
			end)
		end

		list.styled = true
	end
end

local function handleMountButton(self)
	if not self.bg then
		self.bg = B.CreateBDFrame(self, .25)
		self.bg:SetPoint("TOPLEFT", 4, -2)
		self.bg:SetPoint("BOTTOMRIGHT", 0, 2)
		self.background:SetAlpha(0)
		self.selectedTexture:SetAlpha(0)
		self:SetHighlightTexture(0)
		self.name:ClearAllPoints()
		self.name:SetPoint("LEFT", 10, 0)

		local dragButton = self.dragButton
		dragButton.icon:SetInside(nil, 3, 3)
		dragButton.bg = B.ReskinIcon(dragButton.icon)
		B.ReskinIconBorder(dragButton.qualityBorder, true)
		dragButton.activeTexture:SetAlpha(0)
		local hl = dragButton.highlight
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints(dragButton.bg)
	end

	if self.selectedTexture:IsShown() then
		self.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
	else
		self.bg:SetBackdropColor(0, 0, 0, .25)
	end

	if self.dragButton.activeTexture:IsShown() then
		self.dragButton.bg:SetBackdropBorderColor(1, .8, 0)
	end
end

local function handleGridMountButton(self)
	for _, bu in ipairs(self.mounts) do
		if not bu.bg then
			bu.icon:SetInside()
			bu.bg = B.ReskinIcon(bu.icon)
			B.ReskinIconBorder(bu.qualityBorder, true)
			bu.selectedTexture:SetColorTexture(1, .8, 0, .4)
			local hl = bu.highlight
			hl:SetColorTexture(1, 1, 1, .25)
			hl:SetInside(bu.bg)
		end
	end
end

function S:MountsJournal()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local MountsJournal = _G.MountsJournal
	if not MountsJournal then return end

	P.ReskinTooltip(_G.MJTooltipModel)

	local MountsJournalFrame = _G.MountsJournalFrame
	if MountsJournalFrame.ADDON_LOADED then
		hooksecurefunc(MountsJournalFrame, "ADDON_LOADED", function(self)
			if self.useMountsJournalButton then
				B.ReskinCheck(self.useMountsJournalButton)
			end
		end)
	else
		S:Proxy("ReskinCheck", MountsJournalFrame.useMountsJournalButton)
	end

	hooksecurefunc(MountsJournalFrame, "init", function(self)
		local bgFrame = self.bgFrame
		if bgFrame then
			B.ReskinPortraitFrame(bgFrame)
			S:Proxy("ReskinClose", bgFrame.closeButton)
			S:Proxy("StripTextures", bgFrame.leftInset)
			S:Proxy("StripTextures", bgFrame.rightInset)
			S:Proxy("ReskinTrimScroll", bgFrame.leftInset and bgFrame.leftInset.scrollBar)
			handledFilterButton(bgFrame.profilesMenu)
			handledDropDown(bgFrame.summonPanelSettings)

			for _, key in ipairs({"mountSpecial", "summonButton"}) do
				S:Proxy("Reskin", bgFrame[key])
			end

			for _, key in ipairs({"DynamicFlightModeButton", "OpenDynamicFlightSkillTreeButton", "targetMount"}) do
				handleActionButton(bgFrame[key])
			end

			for _, key in ipairs({"summon1", "summon2"}) do
				handleIconButton(bgFrame[key])
			end

			for i, tab in ipairs(bgFrame.Tabs) do
				B.ReskinTab(tab)
				if i > 1 then
					tab:ClearAllPoints()
					tab:SetPoint("RIGHT", bgFrame.Tabs[i-1], "LEFT", 15, 0)
				end
			end

			local settingsBackground = bgFrame.settingsBackground
			if settingsBackground then
				B.StripTextures(settingsBackground)
				B.CreateBDFrame(settingsBackground, .25)
				for i, tab in ipairs(settingsBackground.Tabs) do
					B.ReskinTab(tab)
					if i > 1 then
						tab:ClearAllPoints()
						tab:SetPoint("TOPLEFT", settingsBackground.Tabs[i-1], "TOPRIGHT", -10, 0)
					end
				end
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
		handledFilterButton(self.filtersButton)
		handledDropDown(self.tags and self.tags.mountOptionsMenu)
		P.ReskinTooltip(_G.MountsJournalTooltip)

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
			S:Proxy("Reskin", mapSettings.existingListsToggle)
			S:Proxy("ReskinCheck", mapSettings.Flags)
			handledFilterButton(mapSettings.listFromMap)
			S:Proxy("StripTextures", mapSettings.relationMap)
			S:Proxy("CreateBDFrame", mapSettings.relationMap, 0)
			handledFilterButton(mapSettings.dnr)
		end

		local existingLists = self.existingLists
		if existingLists then
			B.StripTextures(existingLists)
			existingLists.bg = B.SetBD(existingLists)
			existingLists.bg:SetAllPoints()
			S:Proxy("ReskinInput", existingLists.searchBox)
			S:Proxy("ReskinTrimScroll", existingLists.scrollBar)

			hooksecurefunc(existingLists, "toggleInit", function(_, btn)
				if not btn.bg then
					btn.bg = B.CreateBDFrame(btn, .25, true)
					btn.bg:SetAllPoints(btn.toggle)
				end
				btn.toggle:SetAtlas(btn.category.expanded and "Soulbinds_Collection_CategoryHeader_Expand" or "Soulbinds_Collection_CategoryHeader_Collapse")
			end)
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
				S:Proxy("ReskinIcon", info.icon)
				handledDropDown(info.linkLang)
				handledDropDown(info.modelSceneSettingsButton)

				local mountDescriptionToggle = info.mountDescriptionToggle
				if mountDescriptionToggle then
					B.Reskin(mountDescriptionToggle)
					mountDescriptionToggle.__bg:SetPoint("TOPLEFT", 2, 0)
					mountDescriptionToggle.__bg:SetPoint("BOTTOMRIGHT", -2, 0)
				end

				local petSelectionBtn = info.petSelectionBtn
				if petSelectionBtn then
					B.StripTextures(petSelectionBtn)
					local bg = B.CreateBDFrame(petSelectionBtn, .25)
					petSelectionBtn.highlight:SetColorTexture(1, 1, 1, .25)
					petSelectionBtn.highlight:SetInside(bg)
					handlePetIcon(petSelectionBtn.infoFrame)
					petSelectionBtn:HookScript("OnClick", handlePetList)
				end
			end
		end

		local filtersPanel = self.filtersPanel
		if filtersPanel then
			B.StripTextures(filtersPanel)
			S:Proxy("ReskinInput", filtersPanel.searchBox)
			S:Proxy("StripTextures", filtersPanel.shownPanel)

			for _, key in ipairs({"btnToggle", "gridToggleButton"}) do
				local bu = filtersPanel[key]
				if bu then
					B.Reskin(bu)
					bu.__bg:SetInside()
				end
			end
		end

		local filtersBar = self.filtersBar
		if filtersBar then
			B.StripTextures(filtersBar)
			for _, tab in ipairs(filtersBar.tabs) do
				B.StripTextures(tab)
				local bg = B.CreateBDFrame(tab, .25)
				bg:SetPoint("TOPLEFT", 8, -3)
				bg:SetPoint("BOTTOMRIGHT", -8, 0)
				tab:SetHighlightTexture(DB.bdTex)
				local HL = tab:GetHighlightTexture()
				HL:SetColorTexture(1, 1, 1, .25)
				HL:SetInside(bg)
				B.StripTextures(tab.selected)
				local selectedBG = tab.selected:CreateTexture(nil, "BACKGROUND")
				selectedBG:SetInside(bg)
				selectedBG:SetColorTexture(DB.r, DB.g, DB.b, .25)

				for _, bu in ipairs(tab.content.childs) do
					local isSquare = B:Round(bu:GetHeight()) == B:Round(bu:GetWidth())
					bu:SetBackdrop(nil)
					bu.bg = B.CreateBDFrame(bu, .25)
					bu.bg:SetInside()
					local hl = bu:GetHighlightTexture()
					hl:SetColorTexture(1, 1, 1, .25)
					hl:SetInside(bu.bg)
					if isSquare then
						bu:SetCheckedTexture(DB.pushedTex)
					else
						local check = bu:GetCheckedTexture()
						check:SetColorTexture(DB.r, DB.g, DB.b, .25)
						check:SetInside(bu.bg)
					end
				end
			end
		end

		local modelScene = self.modelScene
		if modelScene then
			handleCombobox(modelScene.animationsCombobox)
			local modelControl = modelScene.modelControl
			if modelControl then
				B.StripTextures(modelControl)
				for _, bu in pairs({modelControl:GetChildren()}) do
					bu.bg:SetAlpha(0)
				end
			end
		end
	end)

	hooksecurefunc(MountsJournalFrame, "defaultInitMountButton", function(self, button)
		handleMountButton(button)
	end)

	hooksecurefunc(MountsJournalFrame, "gridInitMountButton", function(self, button)
		handleGridMountButton(button)
	end)

	local summonPanel = MountsJournalFrame.summonPanel
	if summonPanel then
		handleActionButton(summonPanel.summon1)
		handleActionButton(summonPanel.summon2)
	end

	local util = _G.MountsJournalUtil
	local origcreateCheckbox = util.createCheckboxChild
	util.createCheckboxChild = function(...)
		local check = origcreateCheckbox(...)
		B.ReskinCheck(check)
		return check
	end

	local origcreateCancelOk = util.createCancelOk
	util.createCancelOk = function(...)
		local cancel, ok = origcreateCancelOk(...)
		B.Reskin(cancel)
		B.Reskin(ok)
		return cancel, ok
	end

	local config = _G.MountsJournalConfig
	config:HookScript("OnShow", function(self)
		if not self.styled then
			S:Proxy("ReskinTrimScroll", self.rightPanelScroll and self.rightPanelScroll.ScrollBar)

			for _, key in ipairs({
				"leftPanel", "rightPanel", "herbGroup", "repairGroup",
				"magicBroomGroup", "underlightAnglerGroup", "petGroup"
			}) do
				S:Proxy("StripTextures", self[key])
				S:Proxy("CreateBDFrame", self[key], .25)
			end

			for _, child in pairs(self) do
				local objType = type(child) == "table" and child.GetObjectType and child:GetObjectType()
				if objType == "Button" then
					if child.Left and child.Middle and child.Right and child.Text then
						B.Reskin(child)
					elseif child.index and child.command then
						B.Reskin(child)
					elseif child.Arrow and child.Icon and child.Mask then
						handleCombobox(child)
					end
				elseif objType == "CheckButton" and child.Text then
					B.ReskinCheck(child)
				elseif objType == "EditBox" then
					child:SetBackdrop(nil)
					B.ReskinInput(child)
				end
			end

			for _, key in ipairs({"summon1Icon", "summon2Icon"}) do
				handleIconButton(self[key])
			end

			self.styled = true
		end
	end)

	config.iconData:HookScript("OnShow", function(self)
		if not self.styled then
			B.StripTextures(self)
			B.SetBD(self)
			handleIconButton(self.selectedIconBtn)
			B.ReskinInput(self.searchBox)
			handledFilterButton(self.filtersButton)
			B.ReskinTrimScroll(self.scrollBar)
			hooksecurefunc(self.scrollBox, "Update", function(self)
				self:ForEachFrame(handleIconDataButton)
			end)

			self.styled = true
		end
	end)

	local classConfig = _G.MountsJournalConfigClasses
	classConfig:HookScript("OnShow", function(self)
		if not self.styled then
			S:Proxy("ReskinTrimScroll", self.rightPanelScroll and self.rightPanelScroll.ScrollBar)
			S:Proxy("ReskinCheck", self.charCheck)

			for _, key in ipairs({"leftPanel", "rightPanel"}) do
				local panel = self[key]
				if panel then
					B.StripTextures(panel)
					local bg = B.CreateBDFrame(panel, .25)
					bg:SetAllPoints()
				end
			end

			for _, bu in ipairs({self.leftPanel:GetChildren()}) do
				if bu.key then
					B.ReskinIcon(bu.icon)
					B.ClassIconTexCoord(bu.icon, bu.key)
				end
			end

			for _, key in ipairs({"moveFallMF", "combatMF"}) do
				local editbox = self[key]
				if editbox then
					S:Proxy("Reskin", editbox.defaultBtn)
					S:Proxy("Reskin", editbox.cancelBtn)
					S:Proxy("Reskin", editbox.saveBtn)
					S:Proxy("ReskinCheck", editbox.enable)
					S:Proxy("ReskinTrimScroll", editbox.scrollBar)

					local background = editbox.background
					if background then
						B.StripTextures(background)
						local bg = B.CreateBDFrame(editbox.background, .25)
						bg:SetInside(editbox.background)
					end
				end
			end

			self.styled = true
		end
	end)

	hooksecurefunc(classConfig, "showClassSettings", function(self)
		if self.sliderPool then
			for frame in self.sliderPool:EnumerateActive() do
				if frame.slider and frame.edit and not frame.styled then
					B.ReskinSlider(frame.slider)
					frame.edit:SetBackdrop(nil)
					B.ReskinInput(frame.edit)

					frame.styled = true
				end
			end
		end

		for check in self.checkPool:EnumerateActive() do
			if not check.styled then
				B.ReskinCheck(check)
				check.styled = true
			end
		end
	end)

	local ruleConfig = _G.MountsJournalConfigRules
	ruleConfig:HookScript("OnShow", function(self)
		if not self.styled then
			handledFilterButton(self.ruleSets)
			handleCombobox(self.summons)
			S:Proxy("Reskin", self.addRuleBtn)
			S:Proxy("Reskin", self.importRuleBtn)
			S:Proxy("Reskin", self.resetRulesBtn)
			S:Proxy("ReskinInput", self.searchBox)
			S:Proxy("ReskinFilterButton", self.snippetToggle)
			S:Proxy("ReskinCheck", self.altMode)

			self.styled = true
		end
	end)

	local ruleEditor = ruleConfig.ruleEditor
	ruleEditor:HookScript("OnShow", function(self)
		if not self.styled then
			S:Proxy("StripTextures", self.bg)
			S:Proxy("StripTextures", self.panel)
			S:Proxy("SetBD", self.panel)

			self.styled = true
		end
	end)

	local snippets = _G.MountsJournalSnippets
	snippets:HookScript("OnShow", function(self)
		if not self.styled then
			B.StripTextures(self)
			B.SetBD(self, nil, 0, 0, 0, 0)
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", MountsJournalFrame.bgFrame, "TOPRIGHT", 1, 0)
			self:SetPoint("BOTTOMLEFT", MountsJournalFrame.bgFrame, "BOTTOMRIGHT", 1, 0)
			S:Proxy("Reskin", self.addSnipBtn)
			S:Proxy("Reskin", self.importBtn)
			S:Proxy("ReskinInput", self.searchBox)
			S:Proxy("StripTextures", self.bg)
			S:Proxy("ReskinTrimScroll", self.scrollBar)

			self.styled = true
		end
	end)
end

S:RegisterSkin("MountsJournal", S.MountsJournal)