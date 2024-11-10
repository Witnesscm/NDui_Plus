local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function HandleButton(self)
	if not self then
		P.Developer_ThrowError("BtWQuests Button is nil")
		return
	end

	self:SetNormalTexture(0)
	self.bg = B.SetBD(self, .25)
	self.bg:SetInside(nil, 4, 4)
	self.bg:SetFrameLevel(self:GetFrameLevel())
	self:SetHighlightTexture(DB.bdTex)
	local hl = self:GetHighlightTexture()
	hl:SetVertexColor(DB.r, DB.g, DB.b, .25)
	hl:SetInside(self.bg)

	local Active = self.Acive or self.Active
	if Active then
		Active:SetTexture("")
	end

	local Background = self.Background
	if Background and self:GetWidth() / self:GetHeight() < 10 then
		self.Background:SetInside(self.bg)
	end

	local Cover = self.Cover
	if Cover then
		Cover:SetTexture("")
	end
end

local function ReskinItemButton(self)
	if not self.styled then
		HandleButton(self)
		self.styled = true
	end

	local Active = self.Acive or self.Active
	if not Active then return end

	if Active:IsShown() then
		self.bg:SetBackdropBorderColor(0, .7, .08)
	else
		self.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function ReskinDropMenu(self)
	local list = self.list
	if not list.bg then
		list.bg = B.SetBD(list, .7)
		list.bg:SetAllPoints()

		for _, key in pairs({"Backdrop", "MenuBackdrop"}) do
			local backdrop = list[key]
			if backdrop then
				backdrop:Hide()
				backdrop.Show = B.Dummy
			end
		end
	end

	for bu in self.buttonPool:EnumerateActive() do
		local _, _, _, x = bu:GetPoint()
		if bu:IsShown() and x then
			local check = bu.Check
			local uncheck = bu.UnCheck
			local hl = bu.Highlight

			if not bu.bg then
				bu.bg = B.CreateBDFrame(bu)
				bu.bg:ClearAllPoints()
				bu.bg:SetPoint("CENTER", check)
				bu.bg:SetSize(12, 12)
				hl:SetColorTexture(DB.r, DB.g, DB.b, .25)
			end

			bu.bg:Hide()
			hl:SetPoint("TOPLEFT", -x + C.mult, 0)
			hl:SetPoint("BOTTOMRIGHT", list:GetWidth() - bu:GetWidth() - x - C.mult, 0)
			if uncheck then uncheck:SetTexture("") end

			if not bu.notCheckable then
				local _, co = check:GetTexCoord()
				if co == 0 then
					check:SetAtlas("checkmark-minimal")
					check:SetVertexColor(DB.r, DB.g, DB.b, 1)
					check:SetSize(20, 20)
					check:SetDesaturated(true)
				else
					check:SetColorTexture(DB.r, DB.g, DB.b, .6)
					check:SetSize(10, 10)
					check:SetDesaturated(false)
				end

				check:SetTexCoord(0, 1, 0, 1)
				bu.bg:Show()
			end
		end
	end
end

local function HandledDropDown(button)
	if not button or not button.GetListFrame then
		P.Developer_ThrowError("BtWQuests Dropdown is nil")
		return
	end

	hooksecurefunc(button, "Toggle", ReskinDropMenu)
end

local function ReskinNavBar(self)
	if not self.styled then
		HandledDropDown(self.dropDown)

		self.styled = true
	end
end

local function ReskinSearchResults(self)
	local buttons = self.scrollFrame.buttons
	for _, button in ipairs(buttons) do
		if not button.styled then
			B.StripTextures(button)
			local bg = B.CreateBDFrame(button, .25)
			bg:SetInside()
			button:SetHighlightTexture(DB.bdTex)
			local hl = button:GetHighlightTexture()
			hl:SetVertexColor(DB.r, DB.g, DB.b, .25)
			hl:SetInside(bg)

			button.styled = true
		end
	end
end

function S:BtWQuests()
	if not S.db["BtWQuests"] then return end

	local frame = _G.BtWQuestsFrame
	if not frame then return end

	B.ReskinPortraitFrame(frame)
	S:Proxy("ReskinInput", frame.SearchBox)
	P.ReskinDropDown(frame.ExpansionDropDown)
	P.ReskinTooltip(_G.BtWQuestsTooltip)
	P.ReskinTooltip(frame.Tooltip)
	HandledDropDown(_G.BtWQuestsOptionsMenu)
	HandledDropDown(frame.CharacterDropDown)
	HandledDropDown(frame.ExpansionDropDown)

	local navBar = frame.navBar
	if navBar then
		B.ReskinNavBar(navBar)
		navBar:HookScript("OnShow", ReskinNavBar)
	end

	local SearchPreview = frame.SearchPreview
	if SearchPreview then
		B.StripTextures(SearchPreview)

		for _, preview in ipairs(SearchPreview.Results) do
			B.StyleSearchButton(preview)
		end
		S:Proxy("StyleSearchButton", SearchPreview.ShowAllResults)
	end

	local SearchResults = frame.SearchResults
	if SearchResults then
		B.StripTextures(SearchResults)
		local bg = B.SetBD(SearchResults)
		bg:SetPoint("TOPLEFT", -10, 0)
		bg:SetPoint("BOTTOMRIGHT")
		S:Proxy("ReskinClose", SearchResults.CloseButton)
		S:Proxy("ReskinScroll", SearchResults.scrollFrame and SearchResults.scrollFrame.scrollBar)

		if SearchResults.UpdateSearch then
			hooksecurefunc(SearchResults, "UpdateSearch", ReskinSearchResults)
		end
	end

	if frame.CloseButton and frame.OptionsButton and frame.CharacterDropDown then
		B.StripTextures(frame.OptionsButton)
		frame.OptionsButton.Icon = frame.OptionsButton:CreateTexture(nil, "ARTWORK")
		frame.OptionsButton.Icon:SetAllPoints()
		frame.OptionsButton.Icon:SetTexture(DB.gearTex)
		frame.OptionsButton.Icon:SetTexCoord(0, .5, 0, .5)
		frame.OptionsButton:SetHighlightTexture(DB.gearTex)
		frame.OptionsButton:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)
		frame.OptionsButton:SetSize(20, 20)
		frame.OptionsButton:SetHitRectInsets(0, 0, 0, 0)
		frame.OptionsButton:ClearAllPoints()
		frame.OptionsButton:SetPoint("RIGHT", frame.CloseButton, "LEFT", -4, 0)
		B.ReskinArrow(frame.CharacterDropDown.Button, "down")
		frame.CharacterDropDown:ClearAllPoints()
		frame.CharacterDropDown:SetPoint("RIGHT", frame.OptionsButton, "LEFT", -14, -8)
	end

	if frame.NavBack and frame.NavForward and frame.NavHere then
		B.ReskinArrow(frame.NavBack, "left")
		frame.NavBack:SetHitRectInsets(0, 0, 0, 0)
		frame.NavBack:ClearAllPoints()
		frame.NavBack:SetPoint("TOPLEFT", 61, -4)
		B.ReskinArrow(frame.NavForward, "right")
		frame.NavForward:SetHitRectInsets(0, 0, 0, 0)
		frame.NavForward:ClearAllPoints()
		frame.NavForward:SetPoint("LEFT", frame.NavBack, "RIGHT", 2, 0)
		B.ReskinArrow(frame.NavHere, "down")
		frame.NavHere:SetHitRectInsets(0, 0, 0, 0)
		frame.NavHere:ClearAllPoints()
		frame.NavHere:SetPoint("LEFT", frame.NavForward, "RIGHT", 2, 0)
	end

	local ExpansionList = frame.ExpansionList
	if ExpansionList then
		for _, expansion in ipairs(ExpansionList.Expansions) do
			expansion.bg = B.CreateBDFrame(expansion, .25)
			expansion.bg:SetPoint("TOPLEFT", 4, -4)
			expansion.bg:SetPoint("BOTTOMRIGHT", -4, 5)
			expansion.Base:SetTexture("")
			S:Proxy("ReskinCheck", expansion.AutoLoad)
			HandleButton(expansion.ViewAll)
			HandleButton(expansion.Load)
		end
	end

	local Category = frame.Category
	if Category then
		S:Proxy("ReskinScroll", Category.Scroll and Category.Scroll.ScrollBar)
	end

	local Chain = frame.Chain
	if Chain then
		S:Proxy("ReskinScroll", Chain.Scroll and Chain.Scroll.ScrollBar)
		P.ReskinTooltip(Chain.Tooltip)
	end

	hooksecurefunc(_G.BtWQuestsExpansionButtonMixin, "Set", ReskinItemButton)
	hooksecurefunc(_G.BtWQuestsCategoryGridItemMixin, "Set", ReskinItemButton)
	hooksecurefunc(_G.BtWQuestsCategoryListItemMixin, "Set", ReskinItemButton)
	hooksecurefunc(_G.BtWQuestsChainItemMixin, "Set", ReskinItemButton)
end

S:RegisterSkin("BtWQuests", S.BtWQuests)