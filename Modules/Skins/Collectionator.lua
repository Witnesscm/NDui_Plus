local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function handleRefreshButton(self)
	if not self then
		P.Developer_ThrowError("object is nil")
		return
	end

	B.Reskin(self)
	self:SetSize(22, 22)
end

local function filterButton(self)
	B.StripTextures(self)
	B.Reskin(self)
	self.__bg:SetPoint("TOPLEFT", -C.mult,  -C.mult)
	self.__bg:SetPoint("BOTTOMRIGHT", C.mult, -C.mult)
	B.SetupArrow(self.Icon, "right")
	self.Icon:SetPoint("RIGHT")
	self.Icon:SetSize(14, 14)
end

local function viewFrame(self)
	S:Proxy("ReskinInput", self.TextFilter)
	handleRefreshButton(self.RefreshButton)
	S:Proxy("StripTextures", self.ResultsListingInset)
	S:Proxy("Reskin", self.BuyCheapest and self.BuyCheapest.SkipButton)
	S:Proxy("Reskin", self.BuyCheapest and self.BuyCheapest.BuyButton)
end

local function reskinMainFrame(self)
	for _, child in pairs {self:GetChildren()} do
		local objType = child:GetObjectType()
		if objType == "Button" and child.Left and child.Right and child.Middle and child.Text then
			B.Reskin(child)
		end
	end
end

function S:Collectionator()
	P:SecureHook("CollectionatorSummaryTabFrameMixin", "OnLoad", reskinMainFrame)
	P:SecureHook("CollectionatorReplicateTabFrameMixin", "OnLoad", reskinMainFrame)
	P:SecureHook("CollectionatorPetSpeciesFilterMixin", "OnLoad", filterButton)
	P:SecureHook("CollectionatorQualityFilterMixin", "OnLoad", filterButton)
	P:SecureHook("CollectionatorArmorFilterMixin", "OnLoad", filterButton)
	P:SecureHook("CollectionatorWeaponFilterMixin", "OnLoad", filterButton)
	P:SecureHook("CollectionatorSlotFilterMixin", "OnLoad", filterButton)
	P:SecureHook("CollectionatorMountTypeFilterMixin", "OnLoad", filterButton)
	P:SecureHook("CollectionatorProfessionFilterMixin", "OnLoad", filterButton)
	P:SecureHook("CollectionatorSummaryViewMixin", "OnLoad", viewFrame)
	P:SecureHook("CollectionatorReplicateViewMixin", "OnLoad", viewFrame)
end

S:RegisterSkin("Collectionator", S.Collectionator)