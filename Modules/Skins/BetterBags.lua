local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function SkinSearchFrame(self)
	S:Proxy("StripTextures", self.frame)
	S:Proxy("SetBD", self.frame)
end

local function SkinItemButton(self)
	self:SetNormalTexture(0)
	self:SetPushedTexture(0)
	self:SetHighlightTexture(DB.bdTex)
	self:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
	self:GetHighlightTexture():SetInside()
	self.icon:SetInside()
	self.icon:SetTexCoord(unpack(DB.TexCoord))
	self.Count:SetPoint("BOTTOMRIGHT", -1, 2)
	self.bg = B.CreateBDFrame(self.icon, .25)
	self.bg:SetAllPoints()
	B.ReskinIconBorder(self.IconBorder)
	self.IconOverlay:SetInside()
	self.IconOverlay2:SetInside()
	B.SetFontSize(self.Count, 13)
end

local function SkinBagButton(self)
	if self.frame and not self.frame.styled then
		SkinItemButton(self.frame)
		if self.frame.ItemSlotBackground then
			self.frame.ItemSlotBackground:SetTexture([[Interface\Paperdoll\UI-PaperDoll-Slot-Bag]])
			self.frame.ItemSlotBackground:SetTexCoord(unpack(DB.TexCoord))
		end

		self.frame.styled = true
	end
end

local function updateQuestTag(self, isQuestItem, questID, isActive)
	if questID and not isActive then
		self.QuestTag:Show()
	else
		self.QuestTag:Hide()
	end

	if questID or isQuestItem then
		self.bg:SetBackdropBorderColor(.8, .8, 0)
	end
end

local function SkinContainerButton(self)
	if self.button and not self.button.styled then
		self.button:SetNormalTexture(0)
		self.button:SetPushedTexture(0)
		self.button:SetHighlightTexture(DB.bdTex)
		self.button:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
		self.button:GetHighlightTexture():SetInside()
		self.ilvlText:SetPoint("BOTTOMLEFT", 1, 1)
		B.SetFontSize(self.ilvlText, 13)

		self.button.styled = true
	end
end

local function SkinCurrencyItem(self)
	if not self.styled then
		self.bg = B.CreateBDFrame(self.frame, 0)
		self.bg:ClearAllPoints()
		self.bg:SetSize(self.icon:GetSize())
		self.bg:SetPoint("LEFT", 1, 0)
		self.icon:SetTexCoord(unpack(DB.TexCoord))
		self.icon:SetInside(self.bg)

		self.styled = true
	end
	self.bg:SetShown(not not self.icon:GetTexture())
end

local function SkinCurrencyItems(self)
	for _, item in pairs(self.currencyItems) do
		SkinCurrencyItem(item)
	end

	for _, item in pairs(self.iconIndex) do
		SkinCurrencyItem(item)
	end
end

local function SkinCurrencyFrame(self)
	SkinCurrencyItems(self)
	hooksecurefunc(self, "Update", SkinCurrencyItems)
end

local function SkinGrid(self)
	S:Proxy("ReskinTrimScroll", self.bar)
end

local function SkinQuestion(self)
	S:Proxy("StripTextures", self.frame)
	S:Proxy("SetBD", self.frame)
	S:Proxy("Reskin", self.yes)
	S:Proxy("Reskin", self.no)
	S:Proxy("ReskinInput", self.input)
end

local function SkinList(self)
	S:Proxy("ReskinTrimScroll", self.ScrollBar)
end

local function SkinSectionItem(self)
	if self.Expand and not self.styled then
		B.ReskinArrow(self.Expand, "left")

		self.styled = true
	end
end

local function SkinSectionConfig(self)
	if self.content and self.content.ScrollBox then
		hooksecurefunc(self.content.ScrollBox, "Update", function(self)
			self:ForEachFrame(SkinSectionItem)
		end)
	end
end

local function SkinSearchCategoryConfig(self)
	S:Proxy("ReskinInput", self.nameBox)
	S:Proxy("ReskinInput", self.queryBox)
	S:Proxy("ReskinTrimScroll", self.queryBox and self.queryBox.ScrollBar)
	S:Proxy("ReskinInput", self.priorityBox)
	S:Proxy("Reskin", self.saveButton)
	S:Proxy("Reskin", self.cancelButton)
end

function S:BetterBags()
	if not S.db["BetterBags"] then return end

	local BetterBags = LibStub("AceAddon-3.0"):GetAddon("BetterBags")
	if not BetterBags then return end

	local ItemFrame = BetterBags:GetModule("ItemFrame")
	local Themes = BetterBags:GetModule("Themes")
	local SearchBox = BetterBags:GetModule("SearchBox")
	local Database = BetterBags:GetModule("Database")
	local SearchCategoryConfig = BetterBags:GetModule("SearchCategoryConfig")

	local function hook(name, method, func)
		local module = BetterBags:GetModule(name)
		if module and module[method] then
			local orig = module[method]
			module[method] = function(...)
				local obj = orig(...)
				func(obj)
				return obj
			end
		else
			P.Developer_ThrowError(format("BetterBags: %s:%s does not exist", name, method))
		end
	end

	hook("SearchBox", "Create", SkinSearchFrame)
	hook("BagButton", "Create", SkinBagButton)
	hook("ItemFrame", "Create", SkinContainerButton)
	hook("Currency", "Create", SkinCurrencyFrame)
	hook("Grid", "Create", SkinGrid)
	hook("Question", "_OnCreate", SkinQuestion)
	hook("List", "Create", SkinList)
	hook("SectionConfig", "Create", SkinSectionConfig)

	if SearchCategoryConfig then
		P:Delay(.5, SkinSearchCategoryConfig, SearchCategoryConfig)
	end

	-- tooltip
	hooksecurefunc(ItemFrame, "OnEnable", function(self)
		P.ReskinTooltip(self.emptyItemTooltip)
	end)

	-- register theme
	local decoratorFrames = {}
	local itemButtons = {}
	local tabs = {}

	local theme = {
		Name = "NDui",
		Description = "NDui Theme for BetterBags",
		Available = true,
		DisableMasque = true,
		Portrait = function(frame)
			local decoration = decoratorFrames[frame:GetName()]
			if not decoration then
				decoration = CreateFrame("Frame", frame:GetName() .. "ThemeNDui", frame)
				decoration:SetAllPoints()
				decoration:SetFrameLevel(frame:GetFrameLevel() - 1)
				decoration.CloseButton = CreateFrame("Button", frame:GetName() .. "CloseButton", decoration)
				decoration.CloseButton:SetScript("OnClick", function()
					frame.Owner:Hide()
				end)
				decoration.CloseButton:SetPoint("TOPRIGHT", decoration, "TOPRIGHT", -4, -4)
				decoration.CloseButton:SetSize(24, 24)
				decoration.CloseButton:SetFrameLevel(1001)
				B.ReskinClose(decoration.CloseButton)

				local searchBox = SearchBox:CreateBox(frame.Owner.kind, decoration)
				searchBox.frame:SetPoint("TOPLEFT", decoration, "TOPLEFT", 12, -40)
				searchBox.frame:SetPoint("BOTTOMRIGHT", decoration, "TOPRIGHT", -12, -60)
				S:Proxy("ReskinInput", searchBox.textBox)
				decoration.search = searchBox

				local title = decoration:CreateFontString(nil, "OVERLAY", "GameFontWhite")
				title:SetPoint("TOP", decoration, "TOP", 0, 0)
				title:SetHeight(30)
				decoration.title = title

				if Themes.titles[frame:GetName()] then
					decoration.title:SetText(Themes.titles[frame:GetName()])
				end

				local bagButton = Themes.SetupBagButton(frame.Owner, decoration)
				B.StripTextures(bagButton)
				B.Reskin(bagButton)
				bagButton:SetSize(32, 32)
				bagButton:ClearAllPoints()
				bagButton:SetPoint("TOPLEFT", decoration, "TOPLEFT", 6, -6)
				bagButton.Icon = bagButton:CreateTexture(nil, "ARTWORK")
				bagButton.Icon:SetTexture([[Interface\Icons\INV_Misc_Bag_07]])
				bagButton.Icon:SetInside()
				bagButton.Icon:SetTexCoord(unpack(DB.TexCoord))
				B.StripTextures(decoration)
				B.SetBD(decoration)
				decoratorFrames[frame:GetName()] = decoration
			else
				decoration:Show()
			end
		end,
		Simple = function(frame)
			local decoration = decoratorFrames[frame:GetName()]
			if not decoration then
				decoration = CreateFrame("Frame", frame:GetName() .. "ThemeNDui", frame)
				decoration:SetAllPoints()
				decoration:SetFrameLevel(frame:GetFrameLevel() - 1)
				decoration.CloseButton = CreateFrame("Button", frame:GetName() .. "CloseButton", decoration)
				decoration.CloseButton:SetScript("OnClick", function()
					frame:Hide()
				end)
				decoration.CloseButton:SetPoint("TOPRIGHT", decoration, "TOPRIGHT", -4, -4)
				decoration.CloseButton:SetSize(24, 24)
				decoration.CloseButton:SetFrameLevel(1001)
				B.ReskinClose(decoration.CloseButton)

				local title = decoration:CreateFontString(nil, "OVERLAY", "GameFontWhite")
				title:SetPoint("TOP", decoration, "TOP", 0, 0)
				title:SetHeight(30)
				decoration.title = title

				if Themes.titles[frame:GetName()] then
					decoration.title:SetText(Themes.titles[frame:GetName()])
				end

				B.StripTextures(decoration)
				B.SetBD(decoration)
				decoratorFrames[frame:GetName()] = decoration
			else
				decoration:Show()
			end
		end,
		Flat = function(frame)
			local decoration = decoratorFrames[frame:GetName()]
			if not decoration then
				decoration = CreateFrame("Frame", frame:GetName() .. "ThemeNDui", frame)
				decoration:SetAllPoints()
				decoration:SetFrameLevel(frame:GetFrameLevel() - 1)
				B.StripTextures(decoration)
				B.SetBD(decoration)
				decoratorFrames[frame:GetName()] = decoration
			else
				decoration:Show()
			end
		end,
		Opacity = B.Dummy,
		Reset = function()
			for _, frame in pairs(decoratorFrames) do
				frame:Hide()
			end
			for _, button in pairs(itemButtons) do
				button:Hide()
			end
			for _, tab in pairs(tabs) do
				tab:Hide()
			end
		end,
		SectionFont = function(font)
			font:SetFontObject("GameFontNormal")
		end,
		SetTitle = function(frame, title)
			local decoration = decoratorFrames[frame:GetName()]
			if decoration then
				decoration.title:SetText(title)
			end
		end,
		ToggleSearch = function(frame, shown)
			local decoration = decoratorFrames[frame:GetName()]
			if decoration then
				decoration.search:SetShown(shown)
			end
		end,
		ItemButton = function(item)
			local buttonName = item.button:GetName()
			local button = itemButtons[buttonName]
			if button then
				button:Show()
				return button
			end
			button = Themes.CreateBlankItemButtonDecoration(item.frame, "NDui", buttonName)
			button:Show()
			SkinItemButton(button)
			if button.Cooldown then
				button.Cooldown:SetInside()
			end
			if button.ItemSlotBackground then
				button.ItemSlotBackground:SetAlpha(0)
			end
			if button.IconQuestTexture then
				button.IconQuestTexture:SetAlpha(0)
				button.QuestTag = B.CreateFS(button, 30, "!", "system", "LEFT", 3, 0)
				button.UpdateQuestItem = updateQuestTag
			end
			itemButtons[buttonName] = button
			return button
		end,
		Tab = function(tab)
			local tabName = tab:GetName()
			local decoration = tabs[tabName]
			if decoration then
				decoration:Show()
				return decoration
			end
			decoration = Themes.CreateDefaultTabDecoration(tab)
			B.ReskinTab(decoration)
			tabs[tabName] = decoration
			return decoration
		end
	}
	Themes:RegisterTheme("ndui", theme)

	-- load theme
	Database:SetTheme("ndui")

	-- [BetterBags fix] update quest tag when accept/abandon
	B:RegisterEvent("UNIT_QUEST_LOG_CHANGED", function()
		for _, bag in pairs(BetterBags.Bags) do
			local view = bag.views and bag.views[Database:GetBagView(bag.kind)]
			if view then
				for _, item in pairs(view.itemsByBagAndSlot) do
					if item.kind and item.data then
						local button = Themes:GetItemButton(nil, item)
						local questInfo = C_Container.GetContainerItemQuestInfo(item.data.bagid, item.data.slotid)
						button:UpdateQuestItem(questInfo.isQuestItem, questInfo.questID, questInfo.isActive)
					end
				end
			end
		end
	end)
end

S:RegisterSkin("BetterBags", S.BetterBags, true)