local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local TT = B:GetModule("Tooltip")
local cr, cg, cb = DB.r, DB.g, DB.b

local _G = getfenv(0)
local pairs = pairs
----------------------------
-- Credit: AddOnSkins_MeetingStone by hokohuang
----------------------------
local function strToPath(str)
	local path = {}
	for v in string.gmatch(str, "([^\.]+)") do 
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

local function reskinButton(bu)
	bu:SetHeight(28)
	B.Reskin(bu)
	bu.styled = true
end

local function reskinMSInput(input)
	input:DisableDrawLayer("BACKGROUND")
	P.ReskinInput(input)
	input.bg:SetPoint("TOPLEFT", 3, 0)
end

local function reskinMSButtons(frame)
	for i = 1, frame:GetNumChildren() do
		local child = select(i, frame:GetChildren())
		if child:IsObjectType("Button") and child.Icon and child.Text then
			B.StripTextures(child, 11)
			B.ReskinIcon(child.Icon)
			child.HL = child:CreateTexture(nil, "HIGHLIGHT")
			child.HL:SetColorTexture(1, 1, 1, .25)
			child.HL:SetAllPoints(child.Icon)
		end
	end
end

local function reskinPageButton(scroll)
	local left = scroll.ScrollUpButton
	local right = scroll.ScrollDownButton

	B.ReskinArrow(left, "left")
	left:SetSize(20,20)
	B.ReskinArrow(right, "right")
	right:SetSize(20,20)
	right:SetPoint('LEFT', left, 'RIGHT', 10,0)
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

function S:MeetingStone()
	if not IsAddOnLoaded("MeetingStone") and not IsAddOnLoaded("MeetingStonePlus") then return end
	if not NDuiPlusDB["Skins"]["MeetingStone"] then return end

	local MS = LibStub('AceAddon-3.0'):GetAddon('MeetingStone')
	local MSEnv = LibStub("NetEaseEnv-1.0")._NSList[MS.baseName]
	local GUI = LibStub("NetEaseGUI-2.0")

	local Panels = {
		"MainPanel",
		--"ExchangePanel",
		"BrowsePanel.AdvFilterPanel",
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
		"RecentPanel.MemberList"
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
	local AdvFilter = BrowsePanel.AdvFilterPanel
	AdvFilter:SetPoint('TOPLEFT', MSEnv.MainPanel, 'TOPRIGHT', 3, -30)

	for i = 1, AdvFilter:GetNumChildren() do
		local child = select(i, AdvFilter:GetChildren())
		if child:IsObjectType("Button") and not child:GetText() then
			B.ReskinClose(child)
			break
		end
	end

	for i, box in ipairs(BrowsePanel.filters) do
		B.ReskinCheck(box.Check)
		reskinMSInput(box.MaxBox)
		reskinMSInput(box.MinBox)
		box.styled = true
	end

	local AutoCompleteFrame = BrowsePanel.AutoCompleteFrame
	B.StripTextures(AutoCompleteFrame)
	B.ReskinScroll(AutoCompleteFrame:GetScrollBar())

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

	-- CreatePanel
	local CreatePanel = MSEnv.CreatePanel
	select(1, CreatePanel:GetChildren()):Hide()
	B.ReskinCheck(CreatePanel.PrivateGroup)

	local infoBG = B.CreateBDFrame(CreatePanel.InfoWidget, .25)
	infoBG:SetPoint("TOPLEFT", C.mult, C.mult)
	infoBG:SetPoint("BOTTOMRIGHT", -C.mult, -C.mult)
	CreatePanel.InfoWidget.Background:SetAlpha(0)

	B.CreateBDFrame(CreatePanel.MemberWidget, .25)
	CreatePanel.MemberWidget:DisableDrawLayer("BACKGROUND")
	B.CreateBDFrame(CreatePanel.MiscWidget, .25)
	CreatePanel.MiscWidget:DisableDrawLayer("BACKGROUND")

	local CreateWidget = CreatePanel.CreateWidget
	for i = 1, CreateWidget:GetNumChildren() do
		local child = select(i, CreateWidget:GetChildren())
		child:DisableDrawLayer("BACKGROUND")
		local bg = B.CreateBDFrame(child, .25)
		bg:SetAllPoints()
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
			reskinButton(button)
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
	local DropMenu = GUI:GetClass('DropMenu')
	hooksecurefunc(DropMenu, "Open", function(self, level, ...)
		level = level or 1
		local menu = self.menuList[level]
		if menu and not menu.styled then
			P.ReskinTooltip(menu)
			local scrollBar = menu.GetScrollBar and menu:GetScrollBar()
			if scrollBar then
				B.ReskinScroll(scrollBar)
			end
		end
	end)

	local DropMenuItem = GUI:GetClass('DropMenuItem')
	hooksecurefunc(DropMenuItem, "SetHasArrow", function(self)
		B.SetupArrow(self.Arrow, "right")
		self.Arrow:SetSize(14, 14)
	end)

	-- Tab
	local TabView = GUI:GetClass('TabView')
	hooksecurefunc(TabView, "UpdateItems", function(self)
		for i = 1, self:GetItemCount() do
			local tab = self:GetButton(i)
			if not tab.styled then
				P.ReskinTab(tab, 4)
				tab.styled = true
			end
		end
	end)

	-- GridView
	for _, v in pairs(GridViews) do
		local grid = getValue(v, MSEnv)
		if grid and not grid.styled then  
			for _, button in pairs(grid.sortButtons) do
				B.StripTextures(button, 0)
				button.Arrow:SetAlpha(1)
				local bg = B.CreateBDFrame(button, .25)
				bg:SetPoint("TOPLEFT", C.mult, C.mult)
				bg:SetPoint("BOTTOMRIGHT", -C.mult, -C.mult)
			end
			B.ReskinScroll(grid:GetScrollBar())
			grid.styled = true
		end
	end

	local ListView = GUI:GetClass('ListView')
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
	local Tooltip = GUI:GetClass('Tooltip')
	P.ReskinTooltip(Tooltip:GetGlobalTooltip())
	P.ReskinTooltip(MSEnv.MainPanel.GameTooltip)

	-- DataBroker
	local BrokerPanel = MSEnv.DataBroker.BrokerPanel
	local BrokerIcon = MSEnv.DataBroker.BrokerIcon
	BrokerPanel:SetBackdrop(nil)
	BrokerPanel:SetSize(174, 30)
	B.SetBD(BrokerPanel, nil, 0, 0, 0, 0)
	BrokerIcon:SetPoint('LEFT', 8, 0)

	-- Misc
	if MSEnv.ADDON_REGIONSUPPORT then
		local MallPanel = MS:GetModule('MallPanel')
		B.Reskin(MallPanel.PurchaseButton)
		reskinMSButtons(MallPanel)

		local RewardPanel = MS:GetModule('RewardPanel')
		B.Reskin(RewardPanel.ConfirmButton)
		RewardPanel.InputBox:DisableDrawLayer("BACKGROUND")
		B.ReskinInput(RewardPanel.InputBox)

		B.StripTextures(MSEnv.ActivitiesParent)
		reskinMSButtons(MSEnv.ActivitiesParent)
		B.ReskinScroll(MSEnv.ActivitiesSummary.Summary.ScrollBar)

		local WalkthroughPanel = MS:GetModule('WalkthroughPanel', true)
		if WalkthroughPanel then
			B.ReskinScroll(WalkthroughPanel.SummaryHtml.ScrollBar)
		end
	end

	-- App
	B.StripTextures(MSEnv.AppParent)
	reskinPageButton(MSEnv.AppFollowQueryPanel.QueryList.ScrollBar)
	reskinPageButton(MSEnv.AppFollowPanel.FollowList.ScrollBar)

	if not MeetingStone_QuickJoin then return end  -- version check

	B.ReskinCheck(MeetingStone_QuickJoin)

	for i = 1, AdvFilter.Inset:GetNumChildren() do
		local child = select(i, AdvFilter.Inset:GetChildren())
		if child.Check and not child.styled then
			B.ReskinCheck(child.Check)
		end
	end

	local function reskinALFrame()
		if ALFrame and not ALFrame.styled then
			B.StripTextures(ALFrame)
			B.SetBD(ALFrame)
			B.Reskin(ALFrameButton)
			ALFrame.styled = true
		end
	end

	local ManagerPanel = MSEnv.ManagerPanel
	for i = 1, ManagerPanel:GetNumChildren() do
		local child = select(i, ManagerPanel:GetChildren())
		if child:IsObjectType("Button") and child.Icon and child.Text and not child.styled then
			reskinButton(child)
			child:HookScript("PostClick", reskinALFrame)
		end
	end
end

S:RegisterSkin("MeetingStone", S.MeetingStone)