local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local cr, cg, cb = DB.r, DB.g, DB.b

local function HandleGridView(self)
	if not self then
		P.Developer_ThrowError("GridView is nil")
		return
	end

	for _, button in pairs(self.sortButtons) do
		B.StripTextures(button, 0)
		button.Arrow:SetAlpha(1)
		local bg = B.CreateBDFrame(button, .25)
		bg:SetPoint("TOPLEFT", C.mult, C.mult)
		bg:SetPoint("BOTTOMRIGHT", -C.mult, -C.mult)
	end

	local scrollBar = self.GetScrollBar and self:GetScrollBar()
	if scrollBar then
		B.ReskinScroll(scrollBar)
	end
end

local function HandleDropDown(dropdown)
	if not dropdown then
		P.Developer_ThrowError("dropdown is nil")
		return
	end

	B.StripTextures(dropdown)
	local down = dropdown.MenuButton
	down:ClearAllPoints()
	down:SetPoint("RIGHT", -18, 0)
	B.ReskinArrow(down, "down")
	down:SetSize(20, 20)

	local bg = B.CreateBDFrame(dropdown, 0)
	bg:ClearAllPoints()
	bg:SetPoint("LEFT", 0, 0)
	bg:SetPoint("TOPRIGHT", down, "TOPRIGHT")
	bg:SetPoint("BOTTOMRIGHT", down, "BOTTOMRIGHT")
	B.CreateGradient(bg)
end

local function HandleMSInput(input)
	if not input then
		-- P.Developer_ThrowError("object is nil")
		return
	end

	input:DisableDrawLayer("BACKGROUND")
	P.ReskinInput(input)
	input.bg:SetPoint("TOPLEFT", 3, 0)
end

local function HandleStretchButton(button)
	if not button then
		P.Developer_ThrowError("object is nil")
		return
	end

	button:SetHeight(28)
	B.Reskin(button)
	button.styled = true
end

local function HandleButtonHL(button)
	if not button then
		P.Developer_ThrowError("object is nil")
		return
	end

	button:SetHighlightTexture(DB.bdTex)
	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(cr, cg, cb, .25)
	hl:SetInside()

	button:SetCheckedTexture(DB.bdTex)
	local check = button:GetCheckedTexture()
	check:SetVertexColor(cr, cg, cb, .25)
	check:SetInside()
end

local function HandleFilterBox(box)
	if not box then
		P.Developer_ThrowError("FilterBox is nil")
		return
	end

	if box.Check then
		B.ReskinCheck(box.Check)
	end

	if box.MaxBox then
		HandleMSInput(box.MaxBox)
	end

	if box.MinBox then
		HandleMSInput(box.MinBox)
	end
end

local function ReskinAssociationWidgets(frame)
	for _, child in ipairs({ frame:GetChildren() }) do
		local objType = child:GetObjectType()
		if (objType == "Frame" or objType == "Button") and child.Button and child.Icon and child.Text then
			P.ReskinDropDown(child)
		elseif objType == "Button" and child.Left and child.Middle and child.Right and child.Text then
			B.Reskin(child)
		elseif objType == "EditBox" then
			B.ReskinInput(child)
		elseif objType == "CheckButton" then
			B.ReskinCheck(child)
		elseif child.ScrollBar then
			B.ReskinScroll(child.ScrollBar)
		end
	end
end

function S:MeetingStone()
	if not S.db["MeetingStone"] then return end

	local MS = LibStub("AceAddon-3.0"):GetAddon("MeetingStone")
	local MSEnv = LibStub("NetEaseEnv-1.0")._NSList[MS.baseName]
	local GUI = LibStub("NetEaseGUI-2.0")

	-- NetEaseGUI Elements
	local TabView = GUI:GetClass("TabView")
	hooksecurefunc(TabView, "UpdateItems", function(self)
		for i = 1, self:GetItemCount() do
			local tab = self:GetButton(i)
			if not tab.styled then
				P.ReskinTab(tab, 4)
				local fs = tab:GetFontString()
				fs:ClearAllPoints()
				fs:SetPoint("CENTER")
				fs.SetPoint = B.Dummy

				tab.styled = true
			end

			if tab.Flash then
				tab.Flash:SetPoint("BOTTOMRIGHT", -4, -8)
			end
		end
	end)

	local ListView = GUI:GetClass("ListView")
	hooksecurefunc(ListView, "UpdateItems", function(self)
		for i = 1, #self.buttons do
			local button = self:GetButton(i)
			if not button.styled and button:IsShown() then
				B.StripTextures(button)
				P.SetupBackdrop(button)
				B.CreateBD(button, .25)
				HandleButtonHL(button)

				if button.Option then
					B.Reskin(button.Option.InviteButton)
					B.Reskin(button.Option.DeclineButton)
				end

				if button.Summary then
					B.Reskin(button.Summary.CancelButton)
				end

				if button["@"] and button["@"].Check then
					B.ReskinCheck(button["@"].Check)
				end

				button.styled = true
			end
		end
	end)

	local Tooltip = GUI:GetClass("Tooltip")
	P.ReskinTooltip(Tooltip:GetGlobalTooltip())

	local DropMenu = GUI:GetClass("DropMenu")
	hooksecurefunc(DropMenu, "Open", function(self, level, ...)
		level = level or 1
		local menu = self.menuList[level]
		if menu and not menu.styled then
			P.ReskinTooltip(menu)
			local scrollBar = menu.GetScrollBar and menu:GetScrollBar()
			if scrollBar then
				B.ReskinScroll(scrollBar)
			end
			menu.styled = true
		end
	end)

	local DropMenuItem = GUI:GetClass("DropMenuItem")
	hooksecurefunc(DropMenuItem, "SetHasArrow", function(self)
		B.SetupArrow(self.Arrow, "right")
		self.Arrow:SetSize(14, 14)
	end)

	-- DataBroker
	local DataBroker = MSEnv.DataBroker
	if DataBroker then
		DataBroker.BrokerPanel:SetBackdrop(nil)
		DataBroker.BrokerPanel:SetSize(174, 30)
		B.SetBD(DataBroker.BrokerPanel, nil, 0, 0, 0, 0)
		DataBroker.BrokerIcon:SetPoint("LEFT", 8, 0)
	end

	-- MainPanel
	local MainPanel = MSEnv.MainPanel
	if MainPanel then
		B.ReskinPortraitFrame(MainPanel)
		P.ReskinTooltip(MainPanel.GameTooltip)

		if MainPanel.blockers then
			for _, blocker in ipairs(MainPanel.blockers) do
				blocker:HookScript("OnShow", function(self)
					if not self.styled then
						for _, child in pairs { self:GetChildren() } do
							if child:IsObjectType("Button") and child.Text then
								B.Reskin(child)
							elseif child.ScrollBar then
								B.ReskinScroll(child.ScrollBar)
							elseif child.btnKnow and child.Header then
								B.Reskin(child.btnKnow)
								select(2, child:GetRegions()):SetTextColor(1, 1, 1)
							end
						end

						self.styled = true
					end
				end)
			end
		end
	end

	-- BrowsePanel
	local BrowsePanel = MSEnv.BrowsePanel
	if BrowsePanel then
		for _, child in pairs({ BrowsePanel:GetChildren() }) do
			if child:GetObjectType() == "CheckButton" then
				B.ReskinCheck(child)
			end
		end

		HandleGridView(BrowsePanel.ActivityList)
		S:Proxy("Reskin", BrowsePanel.SignUpButton)
		S:Proxy("Reskin", BrowsePanel.NoResultBlocker and BrowsePanel.NoResultBlocker.Button)
		HandleDropDown(BrowsePanel.ActivityDropdown)
		HandleStretchButton(BrowsePanel.RefreshButton)
		HandleStretchButton(BrowsePanel.AdvButton)


		local AdvFilterPanel = BrowsePanel.AdvFilterPanel
		if AdvFilterPanel then
			B.StripTextures(AdvFilterPanel)
			B.SetBD(AdvFilterPanel)
			AdvFilterPanel:ClearAllPoints()
			AdvFilterPanel:SetPoint("TOPLEFT", MSEnv.MainPanel, "TOPRIGHT", 3, -30)

			for _, child in pairs { AdvFilterPanel:GetChildren() } do
				if child:IsObjectType("Button") then
					if child.Left and child.Middle and child.Right and child.Text then
						B.Reskin(child)
					else
						B.ReskinClose(child)
					end
				end
			end
		end

		if BrowsePanel.filters then
			for _, box in ipairs(BrowsePanel.filters) do
				HandleFilterBox(box)
				box.styled = true
			end
		end

		local AutoCompleteFrame = BrowsePanel.AutoCompleteFrame
		if AutoCompleteFrame then
			B.StripTextures(AutoCompleteFrame)

			local scrollBar = AutoCompleteFrame.GetScrollBar and AutoCompleteFrame:GetScrollBar()
			if scrollBar then
				B.ReskinScroll(scrollBar)
			end

			hooksecurefunc(AutoCompleteFrame, "UpdateItems", function(self)
				for i = 1, #self.buttons do
					local button = self:GetButton(i)
					if not button.styled and button:IsShown() then
						B.StripTextures(button)
						P.SetupBackdrop(button)
						B.CreateBD(button, .5)
						HandleButtonHL(button)

						button.styled = true
					end
				end
			end)
		end

		local ExSearchButton = BrowsePanel.ExSearchButton
		if ExSearchButton then
			HandleStretchButton(ExSearchButton)
		end

		local ExSearchPanel = BrowsePanel.ExSearchPanel
		if ExSearchPanel then
			B.StripTextures(ExSearchPanel)
			B.SetBD(ExSearchPanel)
			ExSearchPanel:ClearAllPoints()
			ExSearchPanel:SetPoint("TOPLEFT", MSEnv.MainPanel, "TOPRIGHT", 3, 0)

			for _, child in pairs { ExSearchPanel:GetChildren() } do
				if child:GetObjectType() == "Button" then
					if child:GetText() then
						B.Reskin(child)
					else
						B.ReskinClose(child)
					end
				end
			end
		end

		local dungeons = BrowsePanel.MD
		if dungeons then
			for _, box in ipairs(dungeons) do
				HandleFilterBox(box)
			end
		end
	end

	-- DealBrowsePanel
	local DealBrowsePanel = MSEnv.DealBrowsePanel
	if DealBrowsePanel then
		HandleGridView(DealBrowsePanel.ActivityList)
		S:Proxy("Reskin", DealBrowsePanel.SignUpButton)
		S:Proxy("Reskin", DealBrowsePanel.NoResultBlocker and DealBrowsePanel.NoResultBlocker.Button)
		HandleDropDown(DealBrowsePanel.ActivityDropdown)

		for _, child in pairs({ DealBrowsePanel:GetChildren() }) do
			if child:GetObjectType() == "Button" and child.SetTextures then
				HandleStretchButton(child)
			end
		end
	end

	-- ManagerPanel
	local ManagerPanel = MSEnv.ManagerPanel
	if ManagerPanel then
		S:Proxy("Reskin", ManagerPanel.RefreshButton)
	end

	-- CreatePanel
	local CreatePanel = MSEnv.CreatePanel
	if CreatePanel then
		S:Proxy("ReskinCheck", CreatePanel.PrivateGroup)
		S:Proxy("ReskinCheck", CreatePanel.CrossFactionGroup)
		S:Proxy("ReskinCheck", CreatePanel.ConventionGroup)
		S:Proxy("ReskinCheck", CreatePanel.DealGroup)
		S:Proxy("Reskin", CreatePanel.DisbandButton)
		S:Proxy("Reskin", CreatePanel.CreateButton)
		HandleMSInput(CreatePanel.ItemLevel)
		HandleMSInput(CreatePanel.Score)
		HandleMSInput(CreatePanel.GameInstanceLevel)
		HandleMSInput(CreatePanel.PriceItemLevel)
		HandleMSInput(CreatePanel.PriceNumber)
		HandleDropDown(CreatePanel.ActivityType)
		HandleDropDown(CreatePanel.PlayStyleWidget and CreatePanel.PlayStyleWidget.Dropdown)
		HandleDropDown(CreatePanel.GameLevelingType)
		HandleDropDown(CreatePanel.AddLevelType)
		HandleDropDown(CreatePanel.TeamLevelingType)
		HandleFilterBox(CreatePanel.TeamLevelingBox)

		for _, child in pairs { CreatePanel:GetChildren() } do
			local numRegions = child:GetNumRegions()
			local numChildren = child:GetNumChildren()
			local objType = child:GetObjectType()
			if objType == "Frame" and numRegions == 3 and numChildren == 0 then
				B.StripTextures(child)
			elseif objType == "CheckButton" then
				B.ReskinCheck(child)
			end
		end

		local InfoWidget = CreatePanel.InfoWidget
		if InfoWidget then
			InfoWidget.bg = B.CreateBDFrame(InfoWidget, .25)
			InfoWidget.bg:SetPoint("TOPLEFT", C.mult, C.mult)
			InfoWidget.bg:SetPoint("BOTTOMRIGHT", -C.mult, -C.mult)
			InfoWidget.Background:SetAlpha(0)
		end

		for _, key in pairs({ "MemberWidget", "MiscWidget" }) do
			local panel = CreatePanel[key]
			if panel then
				B.CreateBDFrame(panel, .25)
				panel:DisableDrawLayer("BACKGROUND")
			end
		end

		local CreateWidget = CreatePanel.CreateWidget
		if CreateWidget then
			for _, child in pairs { CreateWidget:GetChildren() } do
				child:DisableDrawLayer("BACKGROUND")
				local bg = B.CreateBDFrame(child, .25)
				bg:SetAllPoints()
			end
		end
	end

	-- ApplicantPanel
	local ApplicantPanel = MSEnv.ApplicantPanel
	if ApplicantPanel then
		HandleGridView(ApplicantPanel.ApplicantList)

		local AutoInvite = ApplicantPanel.AutoInvite
		if AutoInvite then
			B.ReskinCheck(AutoInvite)
		end
	end

	-- LocomotiveIntroduce
	local LocomotiveIntroduce = MSEnv.LocomotiveIntroduce
	if LocomotiveIntroduce then
		for _, child in ipairs({ LocomotiveIntroduce:GetChildren() }) do
			if child:GetObjectType() == "Frame" and child.backdropInfo and child.backdropInfo.bgFile == "Interface\\Tooltips\\UI-Tooltip-Background" then
				child:HideBackdrop()
				child.bg = B.CreateBDFrame(child, .25)
				child.bg:SetInside(nil, 2, 2)
			end
		end
	end

	-- AssociationPanel
	local AssociationPanel = MSEnv.AssociationPanel
	if AssociationPanel then
		HandleDropDown(AssociationPanel.ActivityDropdown)
		S:Proxy("ReskinCheck", AssociationPanel.filtrateCount)
		HandleStretchButton(AssociationPanel.RefreshButton)
		HandleGridView(AssociationPanel.IgnoreList)
		S:Proxy("Reskin", AssociationPanel.RecruitIgnore)
		S:Proxy("Reskin", AssociationPanel.AddAssociationIgnore)
		S:Proxy("Reskin", AssociationPanel.nextPageButton)
		S:Proxy("Reskin", AssociationPanel.firstPageButton)
		S:Proxy("Reskin", AssociationPanel.AddAssociationProposer)

		for _, child in ipairs({ AssociationPanel:GetChildren() }) do
			if child:GetObjectType() == "EditBox" then
				B.ReskinInput(child)
			end
		end

		local suggestionDropdown = AssociationPanel.suggestionDropdown
		if suggestionDropdown then
			B.StripTextures(suggestionDropdown)

			for _, child in ipairs({ suggestionDropdown:GetChildren() }) do
				if child:GetObjectType() == "ScrollFrame" and child.ScrollBar then
					B.CreateBDFrame(child, .25)
					B.ReskinScroll(child.ScrollBar)
					break
				end
			end
		end

		if AssociationPanel.CreateRecruitmentWindow then
			hooksecurefunc(AssociationPanel, "CreateRecruitmentWindow", function(self)
				if self.recruitmentFrame and not self.recruitmentFrame.styled then
					P.ReskinFrame(self.recruitmentFrame)
					ReskinAssociationWidgets(self.recruitmentFrame)

					if self.recruitmentFrame.settingsFrame then
						ReskinAssociationWidgets(self.recruitmentFrame.settingsFrame)
					end

					self.recruitmentFrame.styled = true
				end
			end)
		end
	end

	-- RecentPanel
	local RecentPanel = MSEnv.RecentPanel
	if RecentPanel then
		HandleDropDown(RecentPanel.ActivityDropdown)
		HandleDropDown(RecentPanel.ClassDropdown)
		HandleDropDown(RecentPanel.RoleDropdown)
		HandleMSInput(RecentPanel.SearchInput)
		S:Proxy("Reskin", RecentPanel.BatchDeleteButton)
		HandleGridView(RecentPanel.MemberList)
	end

	-- IgnoreListPanel
	local IgnoreListPanel = MSEnv.IgnoreListPanel
	if IgnoreListPanel then
		HandleGridView(IgnoreListPanel.IgnoreList)

		for _, child in pairs { IgnoreListPanel:GetChildren() } do
			if child:GetObjectType() == "Button" and child.Text then
				B.Reskin(child)
			end
		end
	end
end

S:RegisterSkin("MeetingStone", S.MeetingStone)