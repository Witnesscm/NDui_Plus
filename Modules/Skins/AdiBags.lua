local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local AdiBags

local function DisableBackdrop(self)
	self.SetBackdrop = B.Dummy
	self.SetBackdropColor = B.Dummy
	self.SetBackdropBorderColor = B.Dummy
	self.ApplyBackdrop = B.Dummy
end

local function SkinContainer(self)
	B.StripTextures(self)
	B.SetBD(self)
	DisableBackdrop(self)

	local soltButton = self.BagSlotButton
	if soltButton then
		B.ReskinIcon(soltButton:GetNormalTexture())
		soltButton:SetHighlightTexture(DB.bdTex)
		soltButton:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
		soltButton:SetCheckedTexture(DB.pushedTex)
	end

	local soltPanel = self.BagSlotPanel
	if soltPanel then
		B.StripTextures(soltPanel)
		B.SetBD(soltPanel)
		DisableBackdrop(soltPanel)
	end

	local searchBox = _G[self:GetName().."SearchBox"]
	if searchBox then
		B.ReskinInput(searchBox)
	end
end

local function SkinModuleButton(self)
	B.Reskin(self)
end

local function SkinItemButton(self)
	self:SetNormalTexture(0)
	self:SetPushedTexture(0)
	self:SetHighlightTexture(DB.bdTex)
	self:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
	self:GetHighlightTexture():SetInside()
	self.icon:SetInside()
	self.icon:SetTexCoord(unpack(DB.TexCoord))
	self.icon.SetTexCoord = B.Dummy
	self.Count:SetPoint("BOTTOMRIGHT", -1, 2)
	self.IconOverlay:SetInside()
	self.IconOverlay2:SetInside()
	P.SetupBackdrop(self)
	B.CreateBD(self, .3)
	self:SetBackdropColor(.3, .3, .3, .3)
end

local function hasItem(i)
	return i
end

local function ContainerButton_UpdateBorder(self)
	local quality
	local settings = AdiBags.db.profile
	local isQuestItem, questId, isQuestActive
	if hasItem(self.hasItem) then
		quality = AdiBags:GetContainerItemQuality(self.bag, self.slot)
		isQuestItem, questId, isQuestActive = AdiBags:GetContainerItemQuestInfo(self.bag, self.slot)
	end

	if settings.questIndicator and questId and not isQuestActive then
		self.QuestTag:Show()
	else
		self.QuestTag:Hide()
	end

	if questId or isQuestItem then
		self:SetBackdropBorderColor(.8, .8, 0)
	elseif quality and quality > -1 then
		local color = DB.QualityColors[quality]
		self:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		self:SetBackdropBorderColor(0, 0, 0)
	end
end

local function SkinContainerButton(self)
	SkinItemButton(self)
	self.Cooldown:SetInside()
	self.EmptySlotTextureFile = nil
	self.IconQuestTexture:SetTexture("")
	self.IconQuestTexture.SetTexture = B.Dummy
	self.IconBorder:SetTexture("")
	self.IconBorder.SetTexture = B.Dummy
	self.QuestTag = B.CreateFS(self, 30, "!", "system", "LEFT", 3, 0)
	self.QuestTag:Hide()
	hooksecurefunc(self, "UpdateBorder", ContainerButton_UpdateBorder)
end

function S:AdiBags()
	if not S.db["AdiBags"] then return end

	AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
	if not AdiBags then return end

	AdiBags.db.profile.modules.Masque = false

	local function hook(name, method, func, raw)
		local class = AdiBags:GetClass(name)
		local prototype = class and class.prototype
		if prototype and prototype[method] then
			if raw then
				local orig = prototype[method]
				prototype[method] = function(...)
					local obj = orig(...)
					func(obj)
					return obj
				end
			else
				hooksecurefunc(prototype, method, func)
			end
		end
	end

	local function handlePoolObjects(name, func)
		local pool = AdiBags:GetPool(name)
		if pool and pool.IterateAllObjects then
			for obj in pool:IterateAllObjects() do
				func(obj)
			end
		end
	end

	hook("Container", "OnCreate", SkinContainer)
	hook("Container", "CreateModuleButton", SkinModuleButton, true)
	hook("BagSlotButton", "OnCreate", SkinItemButton)
	hook("BankSlotButton", "OnCreate", SkinItemButton)
	hook("ItemButton", "OnCreate", SkinContainerButton)
	hook("BankItemButton", "OnCreate", SkinContainerButton)
	handlePoolObjects("ItemButton", SkinContainerButton)
	handlePoolObjects("BankItemButton", SkinContainerButton)
end

S:RegisterSkin("AdiBags", S.AdiBags)