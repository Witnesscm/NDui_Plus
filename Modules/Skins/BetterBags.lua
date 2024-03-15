local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function SkinBagFrame(self)
	local frame = self.frame
	if not frame then return end

	B.StripTextures(frame)
	B.SetBD(frame)
	S:Proxy("ReskinClose", frame.CloseButton)

	local portrait = frame.PortraitContainer
	if portrait then
		B.StripTextures(portrait)
		local button = portrait:GetChildren()
		if button then
			B.StripTextures(button)
			B.Reskin(button)
			button:SetSize(32, 32)
			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -6)
			button.Icon = button:CreateTexture(nil, "ARTWORK")
			button.Icon:SetTexture([[Interface\Icons\INV_Misc_Bag_07]])
			button.Icon:SetInside()
			button.Icon:SetTexCoord(unpack(DB.TexCoord))
		end
	end

	local searchBox = self.searchBox and self.searchBox.frame
	if searchBox then
		searchBox:ClearAllPoints()
		searchBox:SetPoint("TOP", 0, -6)
	end
end

local function SkinSearchBox(self)
	S:Proxy("ReskinInput", self.textBox)
end

local function SkinSearchFrame(self)
	S:Proxy("StripTextures", self.frame)
	S:Proxy("SetBD", self.frame)
end

local function SkinBagSlots(self)
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
		self.frame.ItemSlotBackground:SetTexture([[Interface\Paperdoll\UI-PaperDoll-Slot-Bag]])
		self.frame.ItemSlotBackground:SetTexCoord(unpack(DB.TexCoord))

		self.frame.styled = true
	end
end

local function updateQuestTag(self, isQuestItem, questID, isActive)
	if questID and not isActive then
		self.QuestTag:Show()
	else
		self.QuestTag:Hide()
	end
end

local function SkinContainerButton(self)
	if self.button and not self.button.styled then
		SkinItemButton(self.button)
		self.button.Cooldown:SetInside()
		self.button.IconQuestTexture:SetAlpha(0)
		self.button.ItemSlotBackground:SetAlpha(0)
		self.button.QuestTag = B.CreateFS(self.button, 30, "!", "system", "LEFT", 3, 0)
		hooksecurefunc(self.button, "UpdateQuestItem", updateQuestTag)
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
	S:Proxy("StripTextures", self.frame)
	S:Proxy("SetBD", self.frame)
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

function S:BetterBags()
	if not S.db["BetterBags"] then return end

	local BetterBags = LibStub("AceAddon-3.0"):GetAddon("BetterBags")
	if not BetterBags then return end

	local function hook(name, method, func)
		local module = BetterBags:GetModule(name)
		if module and module[method]then
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

	hook("BagFrame", "Create", SkinBagFrame)
	hook("Search", "CreateBox", SkinSearchBox)
	hook("Search", "Create", SkinSearchFrame)
	hook("BagSlots", "CreatePanel", SkinBagSlots)
	hook("BagButton", "Create", SkinBagButton)
	hook("ItemFrame", "Create", SkinContainerButton)
	hook("Currency", "Create", SkinCurrencyFrame)
	hook("Grid", "Create", SkinGrid)
	hook("Question", "_OnCreate", SkinQuestion)
end

S:RegisterSkin("BetterBags", S.BetterBags, true)