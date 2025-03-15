local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function HandleColumnButton(self)
	self:DisableDrawLayer("BACKGROUND")
	self.bg = B.CreateBDFrame(self)
	self.bg:SetPoint("TOPLEFT", 1, 0)
	self.bg:SetPoint("BOTTOMRIGHT", -4, -1)
	local hl = self:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .1)
	hl:SetAllPoints(self.bg)
end

local function ScrollBar_GetThumb(self)
	return self.Thumb
end

local function HandleTrimScroll(self)
	self.Track, self.Back, self.Forward = self:GetChildren()
	self.Thumb = self.Track:GetChildren()
	self.GetThumb = ScrollBar_GetThumb
	B.ReskinTrimScroll(self)
	self.Thumb:EnableMouse(false)
	B.StripTextures(self.Track)
	hooksecurefunc(self, "SetMinMaxValues", function()
		B.StripTextures(self.Thumb)
	end)
end

local AtlasToQuality = {
	["Green"] = Enum.ItemQuality.Uncommon,
	["Blue"] = Enum.ItemQuality.Rare,
	["Epic"] = Enum.ItemQuality.Epic,
	["Legendary"] = Enum.ItemQuality.Legendary,
}

local function updateIconBorderColorByAtlas(border, atlas)
	local atlasAbbr = atlas and strmatch(atlas, "%-(%w+)$")
	local quality = atlasAbbr and AtlasToQuality[atlasAbbr]
	local color = DB.QualityColors[quality or 1]
	border.__owner.bg:SetBackdropBorderColor(color.r, color.g, color.b)
end

local function ReskinIconBorder(self)
	self:SetAlpha(0)
	self.__owner = self:GetParent()
	hooksecurefunc(self, "SetAtlas", updateIconBorderColorByAtlas)
	self:SetAtlas(self:GetAtlas())
end

local function HandleIconButton(self)
	if self and not self.styled then
		self.icon:SetInside(nil, 2, 2)
		self.icon:RemoveMaskTexture(self.mask)
		self.bg = B.ReskinIcon(self.icon)
		ReskinIconBorder(self.border)

		self.styled = true
	end
end

local function ReskinOrderRow(self)
	HandleIconButton(self.ProductIcon)

	for _, icon in ipairs(self.Reagents) do
		HandleIconButton(icon)
	end

	for _, icon in ipairs(self.Rewards) do
		HandleIconButton(icon)
	end
end

function S:PatronOffers()
	local frame = _G.PatronOffersRoot
	if not frame then return end

	local suf = 1
	local tip = _G["NotGameTooltip"..suf]
	while tip do
		P.ReskinTooltip(tip)
		suf = suf + 1
		tip = _G["NotGameTooltip"..suf]
	end

	for _, child in pairs {frame:GetChildren()} do
		local objType = child:GetObjectType()
		if objType == "Button" then
			local text = child:GetText()
			if text and strfind(text, C_AddOns.GetAddOnMetadata("PatronOffers", "Version")) then
				B.StripTextures(child)
				B.CreateBDFrame(child, .25)
			end
			if child.Left and child.Right and child.Middle and child.Text then
				HandleColumnButton(child)
			end
		elseif objType == "ScrollBar" then
			HandleTrimScroll(child)
		end
	end

	frame:RegisterOrderCallback(function(_, row)
		ReskinOrderRow(row)
	end)

	B.StripTextures(frame)
	local bg = B.CreateBDFrame(frame,.25)
	bg:SetPoint("TOPLEFT", 3, -2)
	bg:SetPoint("BOTTOMRIGHT", 2, 2)
end

S:RegisterSkin("PatronOffers", S.PatronOffers)