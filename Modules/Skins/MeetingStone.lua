local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local TT = B:GetModule("Tooltip")
local cr, cg, cb = DB.r, DB.g, DB.b

local _G = getfenv(0)
local select, pairs, ipairs = select, pairs, ipairs

-- Credit: AddOnSkins_MeetingStone by hokohuang
local function strToPath(str)
	local path = {}
	for v in string.gmatch(str, "([^%.]+)") do 
		table.insert(path, v)
	end
	return path
end

local function getValue(pathStr, tbl)
	local keys = strToPath(pathStr) 
	local value
	for _, key in pairs(keys) do
		value = value and value[key] or tbl[key]
	end
	return value
end

local function MS_StripTextures(self)
	if self.NineSlice then self.NineSlice:Hide() end

	if self.GetNumRegions then
		for i = 1, self:GetNumRegions() do
			local region = select(i, self:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				region:SetAlpha(0)
				region:Hide()
			end
		end
	end
end

local function reskinStretchButton(bu)
	bu:SetHeight(28)
	B.Reskin(bu)
	bu.styled = true
end

local function reskinMSInput(input)
	input:DisableDrawLayer("BACKGROUND")
	P.ReskinInput(input)
	input.bg:SetPoint("TOPLEFT", 3, 0)
end

local function reskinMSButton(bu)
	if not bu then return end

	B.StripTextures(bu, 11)
	B.ReskinIcon(bu.Icon)
	bu.HL = bu:CreateTexture(nil, "HIGHLIGHT")
	bu.HL:SetColorTexture(1, 1, 1, .25)
	bu.HL:SetAllPoints(bu.Icon)
end

local function reskinPageButton(scroll)
	local left = scroll.ScrollUpButton
	local right = scroll.ScrollDownButton

	B.ReskinArrow(left, "left")
	left:SetSize(20,20)
	B.ReskinArrow(right, "right")
	right:SetSize(20,20)
	right:SetPoint("LEFT", left, "RIGHT", 10,0)
end

local function reskinButtonHL(button)
	button:SetHighlightTexture(DB.bdTex)
	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(DB.r, DB.g, DB.b, .25)
	hl:SetInside()

	button:SetCheckedTexture(DB.bdTex)
	local check = button:GetCheckedTexture()
	check:SetVertexColor(DB.r, DB.g, DB.b, .25)
	check:SetInside()
end

local function reskinGridView(self)
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

function S:MeetingStone()
	if not IsAddOnLoaded("MeetingStone") and not IsAddOnLoaded("MeetingStonePlus") then return end
	if not S.db["MeetingStone"] then return end

	local MS = LibStub("AceAddon-3.0"):GetAddon("MeetingStone")
	local MSEnv = LibStub("NetEaseEnv-1.0")._NSList[MS.baseName]
	local GUI = LibStub("NetEaseGUI-2.0")

	local Panels = {
		"MainPanel",
		--"ExchangePanel",
		"BrowsePanel.AdvFilterPanel",
		"BrowsePanel.ExSearchPanel",
	}

	local Buttons = {
		"BrowsePanel.SignUpButton",
		"CreatePanel.CreateButton",
		"CreatePanel.DisbandButton",
		"BrowsePanel.NoResultBlocker.Button",
		"RecentPanel.BatchDeleteButton",
		"BrowsePanel.RefreshFilterButton",
		"BrowsePanel.ResetFilterButton",
		"MallPanel.PurchaseButton",
	}

	local StretchButtons = {
		"BrowsePanel.AdvButton",
		"BrowsePanel.RefreshButton",
		"ManagerPanel.RefreshButton",
	}

	local Dropdowns = {
		"BrowsePanel.ActivityDropdown",
		"CreatePanel.ActivityType",
		"RecentPanel.ActivityDropdown",
		"RecentPanel.ClassDropdown",
		"RecentPanel.RoleDropdown",
	}

	local GridViews = {
		"ApplicantPanel.ApplicantList",
		"BrowsePanel.ActivityList",
		"RecentPanel.MemberList",
	}

	local EditBoxes = {
		"CreatePanel.HonorLevel",
		"CreatePanel.ItemLevel",
		"RecentPanel.SearchInput",
	}

	-- Panel
	for _, v in pairs(Panels) do
		local frame = getValue(v, MSEnv)
		if frame then 
			if frame.Inset then MS_StripTextures(frame.Inset) end
			if frame.Inset2 then MS_StripTextures(frame.Inset2) end
			if frame.PortraitFrame then frame.PortraitFrame:SetAlpha(0) end
			if frame.CloseButton then B.ReskinClose(frame.CloseButton) end

			MS_StripTextures(frame)
			B.SetBD(frame)
		end
	end

	-- BrowsePanel
	local BrowsePanel = MSEnv.BrowsePanel
	if BrowsePanel then
		for _, child in pairs({BrowsePanel:GetChildren()}) do
			if child:GetObjectType() == "CheckButton" then
				B.ReskinCheck(child)
			end
		end

		local AdvFilterPanel = BrowsePanel.AdvFilterPanel
		if AdvFilterPanel then
			AdvFilterPanel:SetPoint("TOPLEFT", MSEnv.MainPanel, "TOPRIGHT", 3, -30)

			for i = 1, AdvFilterPanel:GetNumChildren() do
				local child = select(i, AdvFilterPanel:GetChildren())
				if child:IsObjectType("Button") and not child:GetText() then
					B.ReskinClose(child)
					break
				end
			end
		end

		if BrowsePanel.filters then
			for _, box in ipairs(BrowsePanel.filters) do
				B.ReskinCheck(box.Check)
				reskinMSInput(box.MaxBox)
				reskinMSInput(box.MinBox)
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
						reskinButtonHL(button)

						button.styled = true
					end
				end
			end)
		end
	end

	-- CreatePanel
	local CreatePanel = MSEnv.CreatePanel
	if CreatePanel then
		select(1, CreatePanel:GetChildren()):Hide()

		if CreatePanel.PrivateGroup then
			B.ReskinCheck(CreatePanel.PrivateGroup)
		end

		local InfoWidget = CreatePanel.InfoWidget
		if InfoWidget then
			InfoWidget.bg = B.CreateBDFrame(InfoWidget, .25)
			InfoWidget.bg:SetPoint("TOPLEFT", C.mult, C.mult)
			InfoWidget.bg:SetPoint("BOTTOMRIGHT", -C.mult, -C.mult)
			InfoWidget.Background:SetAlpha(0)
		end

		for _, key in pairs({"MemberWidget", "MiscWidget"}) do
			local panel = CreatePanel[key]
			if panel then
				B.CreateBDFrame(panel, .25)
				panel:DisableDrawLayer("BACKGROUND")
			end
		end

		local CreateWidget = CreatePanel.CreateWidget
		if CreateWidget then
			for i = 1, CreateWidget:GetNumChildren() do
				local child = select(i, CreateWidget:GetChildren())
				child:DisableDrawLayer("BACKGROUND")
				local bg = B.CreateBDFrame(child, .25)
				bg:SetAllPoints()
			end
		end
	end

	-- ApplicantPanel
	local ApplicantPanel = MSEnv.ApplicantPanel
	if ApplicantPanel then
		local AutoInvite = ApplicantPanel.AutoInvite
		if AutoInvite then
			B.ReskinCheck(AutoInvite)
		end
	end

	-- Button
	for _, v in pairs(Buttons) do
		local button = getValue(v, MSEnv)
		if button then
			B.Reskin(button)
		end
	end

	for _, v in pairs(StretchButtons) do
		local button = getValue(v, MSEnv)
		if button then
			reskinStretchButton(button)
		end
	end

	-- Dropdown
	for _, v in pairs(Dropdowns) do
		local dropdown = getValue(v, MSEnv)
		if dropdown then
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
	end

	-- DropMenu
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

	-- Tab
	local TabView = GUI:GetClass("TabView")
	hooksecurefunc(TabView, "UpdateItems", function(self)
		for i = 1, self:GetItemCount() do
			local tab = self:GetButton(i)
			if not tab.styled then
				P.ReskinTab(tab, 4)

				if tab.Flash then
					tab.Flash:SetPoint("BOTTOMRIGHT", -4, -8)
				end

				tab.styled = true
			end
		end
	end)

	-- GridView
	for _, v in pairs(GridViews) do
		local grid = getValue(v, MSEnv)
		if grid then
			reskinGridView(grid)
		end
	end

	local ListView = GUI:GetClass("ListView")
	hooksecurefunc(ListView, "UpdateItems", function(self)
		for i = 1, #self.buttons do
			local button = self:GetButton(i)
			if not button.styled and button:IsShown() then
				B.StripTextures(button)
				P.SetupBackdrop(button)
				B.CreateBD(button, .25)
				reskinButtonHL(button)

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

	-- EditBox
	for _, v in pairs(EditBoxes) do
		local input = getValue(v, MSEnv)
		if input then
			reskinMSInput(input)
		end
	end

	-- Tooltip
	local Tooltip = GUI:GetClass("Tooltip")
	P.ReskinTooltip(Tooltip:GetGlobalTooltip())
	P.ReskinTooltip(MSEnv.MainPanel.GameTooltip)

	-- DataBroker
	local DataBroker = MSEnv.DataBroker
	DataBroker.BrokerPanel:SetBackdrop(nil)
	DataBroker.BrokerPanel:SetSize(174, 30)
	B.SetBD(DataBroker.BrokerPanel, nil, 0, 0, 0, 0)
	DataBroker.BrokerIcon:SetPoint("LEFT", 8, 0)

	-- Misc
	if MSEnv.ADDON_REGIONSUPPORT then
		local MallPanel = MS:GetModule("MallPanel", true)
		if MallPanel then
			B.Reskin(MallPanel.PurchaseButton)

			for i = 1, MallPanel:GetNumChildren() do
				local child = select(i, MallPanel:GetChildren())
				if child:IsObjectType("Button") and child.Icon and child.Text then
					reskinMSButton(child)
				end
			end
		end

		local RewardPanel = MS:GetModule("RewardPanel", true)
		if RewardPanel then
			B.Reskin(RewardPanel.ConfirmButton)
			reskinMSInput(RewardPanel.InputBox)
		end

		local WalkthroughPanel = MS:GetModule("WalkthroughPanel", true)
		if WalkthroughPanel then
			for _, key in pairs({"CategoryList", "SummaryHtml"}) do
				local widget = WalkthroughPanel[key] and WalkthroughPanel[key]:GetParent()
				if widget then
					B.StripTextures(widget)
					B.CreateBDFrame(widget, .25)

					for i = 1, widget:GetNumChildren() do
						local child = select(i, widget:GetChildren())
						if child.layoutType and child.layoutType == "InsetFrameTemplate" then
							B.StripTextures(child)
						end
					end
				end

				local scrollBar = WalkthroughPanel[key] and WalkthroughPanel[key].ScrollBar
				if scrollBar then
					B.ReskinScroll(scrollBar)
				end
			end
		end

		local ActivitiesSummary = MSEnv.ActivitiesSummary
		if ActivitiesSummary then
			B.StripTextures(ActivitiesSummary)
			B.CreateBDFrame(ActivitiesSummary.Background, .25)
			reskinMSButton(ActivitiesSummary.GiftButton)
			reskinMSButton(ActivitiesSummary.MemberButton)
			reskinMSButton(ActivitiesSummary.LeaderButton)

			local Summary = ActivitiesSummary.Summary
			B.ReskinScroll(Summary.ScrollBar)
			B.CreateBDFrame(Summary:GetParent(), .25)
		end

		local ActivitiesParent = MSEnv.ActivitiesParent
		if ActivitiesParent then
			B.StripTextures(MSEnv.ActivitiesParent)
			reskinMSButton(ActivitiesParent.ScoreButton)
			reskinMSButton(ActivitiesParent.PlayerInfoButton)
		end

		for _, key in pairs({"QuestPanel", "QuestPanel2", "QuestPanel3"}) do
			local QuestPanel = MSEnv[key]
			if QuestPanel then
				local Body = QuestPanel.Body
				if Body then
					B.StripTextures(Body)

					for _, key in pairs({"Refresh", "Join", "Ranking", "RefreshBtn"}) do
						local bu = Body[key]
						if bu then
							B.Reskin(bu)
						end
					end

					if key == "QuestPanel3" then
						B.CreateBDFrame(Body, .25)

						for _, child in pairs {Body:GetChildren()} do
							if child:GetObjectType() == "Button" and child.Icon and child.Text then
								reskinMSButton(child)
							end
						end
					end
				end

				local Summary = QuestPanel.Summary
				if Summary then
					B.StripTextures(Summary)
					B.CreateBDFrame(Summary, .25)

					for i = 1, Summary:GetNumChildren() do
						local child = select(i, Summary:GetChildren())
						if child.ScrollBar then
							B.ReskinScroll(child.ScrollBar)
							break
						end
					end
				end

				local Quests = QuestPanel.Quests
				if Quests then
					Quests:SetItemSpacing(1)
					Quests:SetItemHeight(50)
					B.ReskinScroll(Quests:GetScrollBar())

					hooksecurefunc(Quests, "UpdateItemPosition", function(self, i)
						if i == 1 then
							local button = self:GetButton(i)
							button:SetPoint("TOPLEFT", 0, -4)
							button:SetPoint("TOPRIGHT",  0, -4)
						end
					end)
				end
			end
		end
	end

	-- QuestItem
	local QuestItem = MSEnv.QuestItem
	if QuestItem then
		local origQuestItemCreate = QuestItem.Create
		QuestItem.Create = function(self, parent, ...)
			local button = origQuestItemCreate(self, parent, ...)
			B.StripTextures(button.Item)
			button.Item.bg = B.ReskinIcon(button.Item.icon)
			B.ReskinIconBorder(button.Item.IconBorder)
			B.Reskin(button.Reward)

			return button
		end
	end

	-- App
	if MSEnv.AppParent then
		B.StripTextures(MSEnv.AppParent)
		reskinPageButton(MSEnv.AppFollowQueryPanel.QueryList.ScrollBar)
		reskinPageButton(MSEnv.AppFollowPanel.FollowList.ScrollBar)
	end

	-- PlayerInfoDialog
	local PlayerInfoDialog = MSEnv.PlayerInfoDialog
	if PlayerInfoDialog then
		for i = 1, PlayerInfoDialog:GetNumChildren() do
			local child = select(i, PlayerInfoDialog:GetChildren())
			local objType = child:GetObjectType()
			if objType == "Frame" then
				B.StripTextures(child)
			elseif objType == "Button" and child.Text then
				B.Reskin(child)
			end
		end

		B.StripTextures(PlayerInfoDialog)
		B.SetBD(PlayerInfoDialog)
		B.ReskinClose(PlayerInfoDialog.CloseButton)

		for _, input in PlayerInfoDialog:IterateInputBoxes() do
			reskinMSInput(input)
		end
	end

	-- Feedback
	local Feedback = GUI.Feedback
	if Feedback then
		Feedback:HookScript("OnShow", function(self)
			if not self.styled then
				P.ReskinFrame(self)
				B.Reskin(self.SendButton)
				reskinMSInput(self.Text)
				B.CreateMF(self)

				self.styled = true
			end
		end)
	end

	-- Blocker
	for _, blocker in ipairs(MSEnv.MainPanel.blockers) do
		blocker:HookScript("OnShow", function(self)
			if not self.styled then
				for i = 1, self:GetNumChildren() do
					local child = select(i, self:GetChildren())
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

	-- MeetingStonePlus
	if _G.MeetingStone_QuickJoin then
		local AdvFilterPanel = BrowsePanel and BrowsePanel.AdvFilterPanel
		if AdvFilterPanel then
			for i = 1, AdvFilterPanel.Inset:GetNumChildren() do
				local child = select(i, AdvFilterPanel.Inset:GetChildren())
				if child.Check and not child.styled then
					B.ReskinCheck(child.Check)
				end
			end
		end

		local function reskinALFrame()
			if _G.ALFrame and not _G.ALFrame.styled then
				B.StripTextures(_G.ALFrame)
				B.SetBD(_G.ALFrame)
				B.Reskin(_G.ALFrameButton)
				_G.ALFrame.styled = true
			end
		end

		local ManagerPanel = MSEnv.ManagerPanel
		if ManagerPanel then
			for i = 1, ManagerPanel:GetNumChildren() do
				local child = select(i, ManagerPanel:GetChildren())
				if child:IsObjectType("Button") and child.Icon and child.Text and not child.styled then
					reskinStretchButton(child)
					child:HookScript("PostClick", reskinALFrame)
				end
			end
		end
	end

	-- MeetingStoneEX
	if IsAddOnLoaded("MeetingStoneEX") then
		if BrowsePanel then
			local ExSearchButton = BrowsePanel.ExSearchButton
			if ExSearchButton then
				reskinStretchButton(ExSearchButton)
			end

			local ExSearchPanel = BrowsePanel.ExSearchPanel
			if ExSearchPanel then
				ExSearchPanel:SetPoint("TOPLEFT", MSEnv.MainPanel, "TOPRIGHT", 3, -30)

				for _, child in pairs {ExSearchPanel:GetChildren()} do
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
					B.ReskinCheck(box.Check)
				end
			end
		end

		local IgnoreListPanel = MS:GetModule("IgnoreListPanel", true)
		if IgnoreListPanel then
			local IgnoreList = IgnoreListPanel.IgnoreList
			if IgnoreList then
				reskinGridView(IgnoreList)
			end

			for _, child in pairs {IgnoreListPanel:GetChildren()} do
				if child:GetObjectType() == "Button" and child.Text then
					B.Reskin(child)
				end
			end
		end
	end

	-- Handle group roles
	local MemberDisplay = MSEnv.MemberDisplay
	local origSetActivity = MemberDisplay.SetActivity
	MemberDisplay.SetActivity = function(self, activity)
		self.resultID = activity and activity.GetID and activity:GetID()
		origSetActivity(self, activity)
	end
end

S:RegisterSkin("MeetingStone", S.MeetingStone)