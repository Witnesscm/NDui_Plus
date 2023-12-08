local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local select, pairs = select, pairs
----------------------------
-- Credit: AddOnSkins_MeetingStone by hokohuang
----------------------------
local mainFrame

local function reskinDropDown(dropdown)
	B.StripTextures(dropdown)
	local down = dropdown.MenuButton
	down:ClearAllPoints()
	down:SetPoint("RIGHT", -18, 0)
	B.ReskinArrow(down, "down")
	down:SetSize(20, 20)

	local bg = B.CreateBDFrame(dropdown, 0)
	bg:SetPoint("TOPLEFT", 0, -2)
	bg:SetPoint("BOTTOMRIGHT", -18, 2)
	B.CreateGradient(bg)
end

local function reskinQRTooltip(self)
	B.StripTextures(self, 0)
	self.bg = B.SetBD(self, .7)
	B.ReskinClose(self.Close)
	self.Close:SetHitRectInsets(0, 0, 0, 0)

	if self.Image then
		self.Image:SetAlpha(1)
		self.bg:SetFrameLevel(self:GetFrameLevel())
	end
end

local imageFrameStyled
local function reskinImageFrame(self)
	if imageFrameStyled then return end

	for _, child in pairs {self:GetChildren()} do
		if child:GetObjectType() == "Frame" and child.Image and child.Close then
			reskinQRTooltip(child)
			imageFrameStyled = true
			break
		end
	end
end

local function hook_Show(self)
	self:GetParent().bg:Show()
end

local function hook_Hide(self)
	self:GetParent().bg:Hide()
end

local function reskinHeader(header)
	for i = 4, 18 do
		select(i, header.Button:GetRegions()):SetTexture("")
	end
	B.Reskin(header.Button)
	header.Button.Title:SetTextColor(1, 1, 1)
	header.Button.Title.SetTextColor = B.Dummy
	header.Button.ExpandedIcon:SetWidth(20)
	header.Button.ExpandedIcon.SetTextColor = B.Dummy
	header.Button.bg = B.ReskinIcon(header.Button.AbilityIcon)
	hooksecurefunc(header.Button.AbilityIcon, "Show", hook_Show)
	hooksecurefunc(header.Button.AbilityIcon, "Hide", hook_Hide)

	B.StripTextures(header.Overview)
	header.Overview.Text:SetTextColor(1, 1, 1)
	header.Overview.Text.SetTextColor = B.Dummy
end

local function reskinSummary(summary)
	B.StripTextures(summary.Title)
	summary.Title.Text:SetTextColor(1, 1, 1)
	summary.Title.Text.SetTextColor = B.Dummy
	summary.Overview.Text:SetTextColor(1, 1, 1)
	summary.Overview.Text.SetTextColor = B.Dummy
end

local function reskinItemButton(self)
	self:SetSize(34, 34)
	B.StripTextures(self, 0)
	self.icon:SetAlpha(1)
	self.bg = B.ReskinIcon(self.icon)
	B.ReskinIconBorder(self.IconBorder, true)
end

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

function S:MeetingHorn()
	if not S.db["MeetingHorn"] then return end

	local MeetingHorn = LibStub("AceAddon-3.0"):GetAddon("MeetingHorn", true)
	if not MeetingHorn then return end

	mainFrame = _G.MeetingHornMainPanel or MeetingHorn.MainPanel
	if not mainFrame then return end
	B.ReskinPortraitFrame(mainFrame)
	mainFrame.PortraitFrame:SetAlpha(0)

	for _, tab in ipairs(mainFrame.Tabs) do
		B.ReskinTab(tab)
		local text = tab.Text or _G[tab:GetName().."Text"]
		if text then
			text:SetPoint("CENTER", tab)
		end
	end

	local Dropdowns = {
		"Browser.Activity",
		"Browser.Mode",
		"Browser.Quick",
		"Manage.Creator.Activity",
		"Manage.Creator.Mode",
		"Recent.Instance",
		"Encounter.Instance",
		"Challenge.Left.Groups",
	}

	local Headers = {
		"Browser",
		"Manage.Applicant",
	}

	local ScrollBars = {
		"Browser.ActivityList.scrollBar",
		"Manage.Applicant.ApplicantList.scrollBar",
		"Options.Filters.FilterList.scrollBar",
		"FeedBack.EditBox.ScrollFrame.ScrollBar",
		"Manage.Creator.Comment.ScrollFrame.ScrollBar",
		"Manage.Chat.ChatFrame.scrollBar",
		"Quest.Body.Quests.scrollBar",
	}

	local Panels = {
		"Browser",
		"Manage.Creator",
		"Manage.Chat.ChatBg",
		"Manage.Creator.Comment",
		"Manage.Applicant",
		"Help",
		"Options.Options",
		"Options.Filters",
		"Recent.Left",
		"Recent.Right",
	}

	local Buttons = {
		"Browser.Reset",
		"Browser.Refresh",
		"Browser.ApplyLeaderBtn",
		"Browser.RechargeBtn",
		"Manage.Creator.CreateButton",
		"Manage.Creator.CloseButton",
		"Manage.Creator.RecruitButton",
		"Options.Filters.Add",
		"Options.Filters.Import",
		"Options.Filters.Export",
		"FeedBack.AcceptButton",
		"FeedBack.CancelButton",
		"Recent.Invite",
	}

	for _, v in pairs(Dropdowns) do
		local dropdown = getValue(v, mainFrame)
		if dropdown then
			reskinDropDown(dropdown)
		end
	end

	for _, v in pairs(Headers) do
		local headerParent = getValue(v, mainFrame)
		if headerParent then
			local index = 1
			local header = headerParent["Header"..index]
			while header do
				header:DisableDrawLayer("BACKGROUND")
				local bg = B.CreateBDFrame(header, .25)
				bg:SetPoint("BOTTOMRIGHT", -2, C.mult)
				header:SetHighlightTexture(DB.bdTex)
				local hl = header:GetHighlightTexture()
				hl:SetVertexColor(DB.r, DB.g, DB.b, .25)
				hl:SetInside()
				index = index + 1
				header = headerParent["Header"..index]
			end
		end
	end

	for _, v in pairs(ScrollBars) do
		local scrollBar = getValue(v, mainFrame)
		if scrollBar then
			B.ReskinScroll(scrollBar)
		end
	end

	for _, v in pairs(Panels) do
		local panel = getValue(v, mainFrame)
		if panel then
			panel:DisableDrawLayer("BACKGROUND")
			panel:DisableDrawLayer("BORDER")
			local bg = B.CreateBDFrame(panel, .25)
			bg:SetPoint("TOPLEFT", 0, 0)
			bg:SetPoint("BOTTOMRIGHT", 0, 0)
		end
	end

	for _, v in pairs(Buttons) do
		local button = getValue(v, mainFrame)
		if button then
			B.Reskin(button)
			if button.LeftSeparator then button.LeftSeparator:SetAlpha(0) end
			if button.RightSeparator then button.RightSeparator:SetAlpha(0) end
		end
	end

	local input = getValue("Browser.Input", mainFrame)
	if input then
		B.ReskinInput(input)
	end

	local ListView = MeetingHorn:GetClass("UI.ListView")
	hooksecurefunc(ListView, "GetButton", function(self, index)
		local button = self._buttons[index]
		if button and not button.styled then
			B.StripTextures(button, 0)
			button:SetHighlightTexture(DB.bdTex)
			local hl = button:GetHighlightTexture()
			hl:SetVertexColor(DB.r, DB.g, DB.b, .25)
			hl:SetInside()

			if button.Icon then
				button.Icon:SetAlpha(1)
			end

			if button.Signup then
				B.Reskin(button.Signup)
				button.Signup:SetSize(60, 20)
			end

			if button.QRIcon then
				button.QRIcon:HookScript("PostClick", function()
					local tooltip = mainFrame.Browser and mainFrame.Browser.QRTooltip
					if tooltip and not tooltip.styled then
						reskinQRTooltip(tooltip)
						tooltip.styled = true
					end
				end)
			end

			if button.Text and button.Creature then
				button.Text:SetTextColor(1, 1, 1)
				button.Text.SetTextColor = B.Dummy
				button.Creature:SetPoint("TOPLEFT", 0, -8)
				P.SetupBackdrop(button)
				B.CreateBD(button, .25)
				B.CreateGradient(button)
			end

			button.styled = true
		end
	end)

	-- Browser
	local Browser = mainFrame.Browser
	if Browser then
		for _, key in ipairs({"ApplyLeaderBtn", "RechargeBtn",}) do
			local bu = Browser[key]
			if bu then
				bu:HookScript("PostClick", reskinImageFrame)
			end
		end

		local progressBar = Browser.ProgressBar
		if progressBar then
			B.StripTextures(progressBar)
			progressBar:SetStatusBarTexture(DB.normTex)
			progressBar:DisableDrawLayer("BACKGROUND")
			B.CreateBDFrame(progressBar, .25)
		end
	end

	-- Encounter
	local Encounter = mainFrame.Encounter
	if Encounter then
		B.StripTextures(Encounter)
		B.StripTextures(Encounter.ZoneButton)
		B.Reskin(Encounter.ZoneButton)

		B.ReskinScroll(Encounter.BossList.scrollBar)
		Encounter.BossList.scrollBar.trackBG:SetAlpha(0)
		B.ReskinScroll(Encounter.Panel1.ScrollBar)
		B.ReskinScroll(Encounter.Panel2.ScrollBar)

		Encounter.BossTitle:SetTextColor(1, 1, 1)
		Encounter.Panel1.Overview.Text:SetTextColor(1, 1, 1)
		Encounter.Panel2.Overview.Text:SetTextColor(1, 1, 1)
		B.ReskinInput(Encounter.Panel3.Url)

		for i, tab in ipairs(Encounter.Tabs) do
			local bg = B.SetBD(tab)
			bg:SetInside(tab, 2, 2)
			tab:SetNormalTexture(0)
			tab:SetPushedTexture(0)
			tab:SetDisabledTexture(0)
			local hl = tab:GetHighlightTexture()
			hl:SetColorTexture(DB.r, DB.g, DB.b, .2)
			hl:SetInside(bg)

			if i == 1 then
				tab:SetPoint("TOPLEFT", Encounter, "TOPRIGHT", 7, -35)
			else
				tab:SetPoint("TOPLEFT", Encounter.Tabs[i-1], "BOTTOMLEFT", 0, 2)
			end
		end

		local LookFall = Encounter.LookFall
		if LookFall then
			LookFall:HookScript("PostClick", reskinImageFrame)
		end
	end

	local EncounterInfo = MeetingHorn:GetClass("UI.EncounterInfo")
	local origEncounterInfoCreate = EncounterInfo.Create
	EncounterInfo.Create = function(self, parent)
		local header = origEncounterInfoCreate(self, parent)
		reskinHeader(header)
		return header
	end

	local EncounterInfoSummary = MeetingHorn:GetClass("UI.EncounterInfoSummary")
	local origEncounterInfoSummaryCreate = EncounterInfoSummary.Create
	EncounterInfoSummary.Create = function(self, parent)
		local summary = origEncounterInfoSummaryCreate(self, parent)
		reskinSummary(summary)
		return summary
	end

	-- Challenge
	local Challenge = mainFrame.Challenge
	if Challenge then
		B.StripTextures(Challenge.Left)
		B.StripTextures(Challenge.Summary)
		B.CreateBDFrame(Challenge.Summary, .25)

		local Body = Challenge.Body
		Body:DisableDrawLayer("BORDER")
		B.CreateBDFrame(Body, .25)
		B.Reskin(Body.WebButton)
		B.Reskin(Body.UpdateButton)
		B.Reskin(Body.Reward.Exchange)

		for i = 1, Body.Reward:GetNumRegions() do
			local region = select(i, Body.Reward:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("FontString") then
				region:SetTextColor(1, 1, 1)
			end
		end

		local progressBar = Body.ProgressBar
		B.StripTextures(progressBar)
		progressBar:SetStatusBarTexture(DB.normTex)
		progressBar:DisableDrawLayer("BACKGROUND")
		B.CreateBDFrame(progressBar, .25)

		local UIChallenge = MeetingHorn:GetClass("UI.Challenge")
		hooksecurefunc(UIChallenge, "GetChallengeButton", function(self, i)
			local button = self.challengeButtons[i]
			if button and not button.styled then
				button.bg:SetAlpha(0)
				B.Reskin(button)
				button.styled = true
			end
		end)
	end

	-- Quest
	local Quest = mainFrame.Quest
	if Quest then
		local Body = Quest.Body
		if Body then
			B.StripTextures(Body)
			B.CreateBDFrame(Body, .25)
			if Body.Refresh then B.Reskin(Body.Refresh) end
		end

		local Summary = Quest.Summary
		if Summary then
			B.StripTextures(Summary)
			B.CreateBDFrame(Summary, .25)

			for _, child in pairs {Summary:GetChildren()} do
				if child.ScrollBar then
					B.ReskinScroll(child.ScrollBar)
					break
				end
			end
		end
	end

	-- QuestItem
	local QuestItem = MeetingHorn:GetClass("UI.QuestItem")
	if QuestItem then
		hooksecurefunc(QuestItem, "SetQuest", function(self)
			if not self.itemStyled then
				P.SetupBackdrop(self)
				B.CreateBD(self, .25)

				if self.Reward then
					B.Reskin(self.Reward)
				end

				for index, item in ipairs(self.Items) do
					reskinItemButton(item)

					if index > 1 then
						item:ClearAllPoints()
						item:SetPoint("LEFT", self.Items[index-1], "RIGHT", 4, 0)
					end
				end

				self.itemStyled = true
			end
		end)
	end

	-- GoodLeader
	local GoodLeader = mainFrame.GoodLeader
	if GoodLeader then
		for _, v in ipairs({"First.Footer", "First.Header", "First.Inset", "Result.Info", "Result.Raids", "Result.Score"}) do
			local subFrame = getValue(v, GoodLeader)
			if subFrame then
				B.StripTextures(subFrame)
				subFrame.bg = B.CreateBDFrame(subFrame, .25)
				subFrame.bg:SetInside()

				if v == "First.Header" then
					local ApplyLeaderBtn = subFrame.ApplyLeaderBtn
					if ApplyLeaderBtn then
						B.Reskin(ApplyLeaderBtn)
						ApplyLeaderBtn:HookScript("PostClick", reskinImageFrame)
					end
				end
			end
		end

		local instances = GoodLeader.Result.Raids.instances
		if instances then
			for _, button in ipairs(instances) do
				button:HideBackdrop()
				B.CreateBDFrame(button.Image, 0)
			end
		end
	end

	local GradePanel = MeetingHorn:GetClass("UI.GradePanel")
	if GradePanel then
		hooksecurefunc(GradePanel, "OnShow", function(self)
			if not self.styled then
				B.StripTextures(self, 0)
				self.Logo:SetAlpha(1)
				local bg = B.SetBD(self)
				bg:SetInside()

				B.StripTextures(self.QrCodeFrame)
				local qrBG = B.SetBD(self.QrCodeFrame)
				qrBG:SetInside()

				B.Reskin(self.Commit)
				B.Reskin(self.Cancel)

				self.styled = true
			end
		end)
	end

	-- Announcement
	local Announcement = mainFrame.Announcement
	if Announcement then
		local loading = Announcement.loading
		if loading then
			B.StripTextures(loading)
			B.SetBD(loading, .8)
		end

		local container = Announcement.container
		if container then
			for _, region in pairs {container:GetRegions()} do
				if region:GetObjectType() == "FontString" then
					region:SetTextColor(1, 1, 1)
				end
			end
		end
	end

	-- MissionGuidance
	local MissionGuidance = mainFrame.MissionGuidance
	if MissionGuidance then
		B.StripTextures(MissionGuidance)
		B.CreateBDFrame(MissionGuidance, .25)
		B.ReskinScroll(MissionGuidance.MissionGuidanceScrollFrame.ScrollBar)
	end

	if IsAddOnLoaded("tdInspect") then  -- Credit: tdUI
		local tdInspect = LibStub("AceAddon-3.0"):GetAddon("tdInspect")
		local Browser = MeetingHorn:GetClass("UI.Browser")
		local Inspect = tdInspect:GetModule("Inspect")

		local origCreateActivityMenu = Browser.CreateActivityMenu
		Browser.CreateActivityMenu = function(self, activity)
			local r = origCreateActivityMenu(self, activity)
			tinsert(r, 3, {
				text = INSPECT,
				func = function()
					Inspect:Query(nil, activity:GetLeader())
				end,
			})
			return r
		end
	end

	local DataBroker = _G.MeetingHornDataBroker
	if DataBroker then
		DataBroker:DisableDrawLayer("BACKGROUND")
		DataBroker:SetSize(158, 32)
		B.SetBD(DataBroker, nil, C.mult, -C.mult, -C.mult, C.mult)
		DataBroker.Text:SetPoint("CENTER", 16, 0)
		local logo = DataBroker:CreateTexture(nil, "ARTWORK")
		logo:SetTexture("Interface\\AddOns\\MeetingHorn\\Media\\Logo2")
		logo:SetSize(30, 30)
		logo:SetPoint("LEFT", 12, 0)
	end
end

S:RegisterSkin("MeetingHorn", S.MeetingHorn)