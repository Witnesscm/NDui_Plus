local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local r, g, b = DB.r, DB.g, DB.b

local _G = getfenv(0)

local function reskinDropDown(self)
	B.StripTextures(self)
	local down = self.button
	B.ReskinArrow(down, "down")
	down:SetSize(20, 20)

	local bg = B.CreateBDFrame(self, 0)
	bg:ClearAllPoints()
	bg:SetPoint("LEFT", 2, 0)
	bg:SetPoint("TOPRIGHT", down, "TOPRIGHT")
	bg:SetPoint("BOTTOMRIGHT", down, "BOTTOMRIGHT")
	B.CreateGradient(bg)
end

local function reskinCatFrame(self)
	local index = 1
	local frame = _G["AtlasLoot-DropDown-CatFrame"..index]
	while frame do
		if not frame.__bg then
			B.StripTextures(frame)
			frame.__bg = B.SetBD(frame, .7)
		end

		for i = 1, #frame.buttons do
			local bu = frame.buttons[i]
			local _, _, _, x = bu:GetPoint()
			if bu:IsShown() and x then
				local check = bu.check
				local hl = bu:GetHighlightTexture()

				if not bu.bg then
					bu.bg = B.CreateBDFrame(bu)
					bu.bg:ClearAllPoints()
					bu.bg:SetPoint("CENTER", check)
					bu.bg:SetSize(12, 12)
					hl:SetColorTexture(r, g, b, .25)

					check:SetColorTexture(r, g, b, .6)
					check:SetSize(10, 10)
					check:SetDesaturated(false)
				end

				bu.bg:Hide()
				check:Hide()
				hl:ClearAllPoints()
				hl:SetPoint("TOP")
				hl:SetPoint("BOTTOM")
				hl:SetPoint("LEFT", frame.__bg,"LEFT")
				hl:SetPoint("RIGHT", frame.__bg,"RIGHT")

				if self.par.selectable then
					local co = check:GetTexCoord()
					if co == 0 then
						check:Show()
					end

					bu.bg:Show()
					bu.label:ClearAllPoints()
					bu.label:SetPoint("LEFT", check, "RIGHT", 4, 0)
				end
			end
		end

		index = index + 1
		frame = _G["AtlasLoot-DropDown-CatFrame"..index]
	end
end

local function reskinSelectFrame(self)
	local frame = self.frame
	B.StripTextures(frame)
	local bg = B.CreateBDFrame(frame, .25)
	bg:SetAllPoints()

	hooksecurefunc(self, "Update", function()
		for i = 1, #self.buttons do
			local button = self.buttons[i]
			if not button.styled then
				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(r, g, b, .25)
				hl:SetOutside(nil, 4)

				button.styled = true
			end
		end
	end)
end

local function reskinSelectMenu(self)
	local frame = self.selectionFrame
	if frame and not frame.styled then
		B.StripTextures(frame, 0)
		B.SetBD(frame, .7)

		for _, button in ipairs(frame.buttons) do
			if button.icon then
				B.ReskinIcon(button.icon)
			else
				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(r, g, b, .25)
				hl:SetAllPoints()
			end
		end

		frame.styled = true
	end
end

local gold = {r = 1, g = .84, b = 0}

local function updateIconBorderColor(self, quality)
	local color = quality == "gold" and gold or DB.QualityColors[quality or 1]
	if color then
		self.__owner.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		self.__owner.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function updateAchievementColor(self, set)
	if set then
		if self:GetDesaturation() == 1 then
			self.__owner.bg:SetBackdropBorderColor(.5, .5, .5)
		else
			self.__owner.bg:SetBackdropBorderColor(gold.r, gold.g, gold.b)
		end
	else
		self.__owner.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function resetIconBorderColor(self)
	self.__owner.bg:SetBackdropBorderColor(0, 0, 0)
end

local function updateIconTexCoord(self, left, right, top, bottom)
	if self.isCutting then return end
	self.isCutting = true

	if left == 0 and right == 1 and top == 0 and bottom == 1 then
		self:SetTexCoord(unpack(DB.TexCoord))
	end

	self.isCutting = nil
end

local function reskinIconBorder(self)
	self:SetAlpha(0)
	self.__owner = self:GetParent()
	if not self.__owner.bg then return end
	hooksecurefunc(self, "SetQualityBorder", updateIconBorderColor)
	hooksecurefunc(self, "SetAchievementBorder", updateAchievementColor)
	hooksecurefunc(self, "Hide", resetIconBorderColor)
end

local function reskinSecButton(self)
	self.icon:SetInside()
	self.bg = B.ReskinIcon(self.icon)
	hooksecurefunc(self.icon, "SetTexCoord", updateIconTexCoord)
	reskinIconBorder(self.overlay)
	self.count:ClearAllPoints()
	self.count:SetPoint("BOTTOMRIGHT", self.icon, "BOTTOMRIGHT", -1, 1)
	self.count:SetFont(unpack(DB.Font))
	local hl = self:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(self.bg)
end

local function reskinItemButton(self)
	self.icon:ClearAllPoints()
	self.icon:SetPoint("LEFT", 2, 0)
	self.icon:SetSize(24, 24)
	self.bg = B.ReskinIcon(self.icon)
	hooksecurefunc(self.icon, "SetTexCoord", updateIconTexCoord)
	reskinIconBorder(self.overlay)
	self:GetHighlightTexture():SetColorTexture(r, g, b, .25)
	self.count:ClearAllPoints()
	self.count:SetPoint("BOTTOMRIGHT", self.icon, "BOTTOMRIGHT", -1, 1)
	self.count:SetFont(unpack(DB.Font))
	reskinSecButton(self.secButton)
end

function S:AtlasLootClassic()
	if not S.db["AtlasLootClassic"] then return end

	local AtlasLoot = _G.AtlasLoot or _G.AtlasLootMY
	if not AtlasLoot then return end

	AtlasLoot.db.Tooltip.useGameTooltip = true

	local frame = _G["AtlasLoot_GUI-Frame"]
	B.StripTextures(frame, 0)
	frame.gameVersionLogo:SetAlpha(1)
	B.SetBD(frame)
	B.StripTextures(frame.titleFrame)
	B.ReskinClose(frame.CloseButton)
	reskinDropDown(frame.moduleSelect.frame)
	reskinDropDown(frame.subCatSelect.frame)
	frame.gameVersionButton:HookScript("OnClick", reskinSelectMenu)
	frame.moduleSelect.frame:HookScript("OnClick", reskinCatFrame)
	frame.moduleSelect.frame.button:HookScript("OnClick", reskinCatFrame)
	frame.subCatSelect.frame:HookScript("OnClick", reskinCatFrame)
	frame.subCatSelect.frame.button:HookScript("OnClick", reskinCatFrame)

	B.StripTextures(frame.contentFrame)
	B.CreateBDFrame(frame.contentFrame, .25)
	reskinSelectFrame(frame.difficulty)
	reskinSelectFrame(frame.boss)
	reskinSelectFrame(frame.extra)
	frame.contentFrame.downBG:Hide()
	frame.contentFrame.itemBG:Hide()
	B.ReskinInput(frame.contentFrame.searchBox)
	frame.contentFrame.searchBox.bg:SetPoint("TOPLEFT", -2, -6)
	frame.contentFrame.searchBox.bg:SetPoint("BOTTOMRIGHT", -2, 6)
	B.ReskinArrow(frame.contentFrame.prevPageButton, "left")
	frame.contentFrame.prevPageButton:SetSize(20, 20)
	B.ReskinArrow(frame.contentFrame.nextPageButton, "right")
	frame.contentFrame.nextPageButton:SetSize(20, 20)
	frame.contentFrame.nextPageButton:SetPoint("RIGHT", frame.contentFrame.downBG, "RIGHT", -5, 0)
	B.Reskin(frame.contentFrame.itemsButton)
	B.Reskin(frame.contentFrame.modelButton)
	B.Reskin(frame.contentFrame.soundsButton)

	local filterButton = frame.contentFrame.clasFilterButton
	B.ReskinIcon(filterButton.texture)
	filterButton.HL = filterButton:CreateTexture(nil, "HIGHLIGHT")
	filterButton.HL:SetColorTexture(1, 1, 1, .25)
	filterButton.HL:SetAllPoints(filterButton.texture)
	filterButton:HookScript("PostClick", reskinSelectMenu)

	for _, button in ipairs(AtlasLoot.GUI.ItemFrame.frame.ItemButtons) do
		reskinItemButton(button)
	end

	local Button = AtlasLoot.Button
	local origButtonCreate = Button.Create
	Button.Create = function(self)
		local bu = origButtonCreate(self)
		reskinItemButton(bu)

		return bu
	end

	local origCreateSecOnly = Button.CreateSecOnly
	Button.CreateSecOnly = function(self, ...)
		local bu = origCreateSecOnly(self, ...)
		reskinSecButton(bu.secButton)

		return bu
	end

	local Set = Button:GetType("Set")
	hooksecurefunc(Set, "ShowToolTipFrame", function()
		local tip = Set.tooltipFrame
		if tip and not tip.styled then
			tip.modelFrame:HideBackdrop()
			tip.bonusDataFrame:HideBackdrop()
			B.SetBD(tip.modelFrame)
			B.SetBD(tip.bonusDataFrame)
			tip.styled = true
		end
	end)

	local Faction = Button:GetType("Faction")
	hooksecurefunc(Faction, "ShowToolTipFrame", function()
		local tip = Faction.tooltipFrame
		if tip and not tip.styled then
			tip:HideBackdrop()
			B.SetBD(tip)
			tip.standing:HideBackdrop()
			tip.standing.bar:SetStatusBarTexture(DB.normTex)
			B.CreateBDFrame(tip.standing.bar, .25)
			tip.styled = true
		end
	end)

	local Item = Button:GetType("Item")
	hooksecurefunc(Item, "ShowQuickDressUp", function()
		local tip = Item.previewTooltipFrame
		if tip and not tip.styled then
			tip:HideBackdrop()
			B.SetBD(tip)
			tip.styled = true
		end
	end)

	hooksecurefunc(Button, "ExtraItemFrame_GetFrame", function()
		local secButton1 = _G.AtlasLoot_SecButton_1_container
		local extraFrame = secButton1 and secButton1:GetParent()
		if extraFrame and not extraFrame.styled then
			extraFrame:SetBackdrop({bgFile = DB.bdTex, edgeFile = DB.bdTex, edgeSize = 1})
			extraFrame:SetBackdropColor(.5, .5, .5, .9)
			extraFrame:SetBackdropBorderColor(.6, .6, .6, .9)
			extraFrame.styled = true
		end
	end)
end

S:RegisterSkin("AtlasLootClassic", S.AtlasLootClassic)
S:RegisterSkin("AtlasLootMY", S.AtlasLootClassic)
