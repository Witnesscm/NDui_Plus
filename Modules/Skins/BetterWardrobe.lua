local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function HandleIconButton(self)
	if not self then
		P.Developer_ThrowError("IconButton is nil")
		return
	end

	local icon = self.Icon or self.Portrait
	local bg = B.ReskinIcon(icon, true)
	self:SetHighlightTexture(DB.bdTex)
	self:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
	self:GetHighlightTexture():SetInside(bg)
end

local function HandleSetsListButton(self)
	if not self.styled then
		self.Background:Hide()
		self.HighlightTexture:SetTexture("")

		local icon = self.IconFrame and self.IconFrame.Icon or self.Icon
		if icon then
			icon:SetSize(42, 42)
			B.ReskinIcon(icon)
			if self.IconCover then
				self.IconCover:SetOutside(icon)
			end
		end

		self.SelectedTexture:SetDrawLayer("BACKGROUND")
		self.SelectedTexture:SetColorTexture(DB.r, DB.g, DB.b, .25)
		self.SelectedTexture:ClearAllPoints()
		self.SelectedTexture:SetPoint("TOPLEFT", 4, -2)
		self.SelectedTexture:SetPoint("BOTTOMRIGHT", -1, 2)
		B.CreateBDFrame(self.SelectedTexture, .25)

		self.styled = true
	end
end

local function HandleSetsDetailsButton(self, index)
	if not self then
		P.Developer_ThrowError("SetsDetailsButton is nil")
		return
	end

	B.Reskin(self)
	self:SetSize(21, 21)
	self:ClearAllPoints()
	self:SetPoint("TOPRIGHT", 19-24*index, -5)
	self:SetScript("OnMouseDown", nil)
	self:SetScript("OnMouseUp", nil)

	if index == 1 and self.Icon and not self.Icon:GetAtlas() then
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
	end
end

local function HandleOutfitDropDown(self)
	if not self then
		P.Developer_ThrowError("DropDownButton is nil")
		return
	end

	B.ReskinDropDown(self)
	S:Proxy("Reskin", self.SaveButton)
end

local AtlasToColor = {
	["gold"] = {r = 1, g = .8, b = 0},
	["purple"] = DB.QualityColors[Enum.ItemQuality.Epic],
}

local function updateIconBorderColor(border, atlas)
	local atlasAbbr = atlas and strmatch(atlas, "%-(%w+)$")
	local color = atlasAbbr and AtlasToColor[atlasAbbr] or DB.QualityColors[1]
	border.__owner.bg:SetBackdropBorderColor(color.r, color.g, color.b)
end

local function resetIconBorderColor(border, texture)
	if not texture then
		border.__owner.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function iconBorderShown(border, show)
	if not show then
		resetIconBorderColor(border)
	end
end

local function HandlePreviewButton(self)
	self.Background:Hide()
	self.bg = B.CreateBDFrame(self, .25)
	self.bg:SetInside()
	self.Icon:SetTexCoord(unpack(DB.TexCoord))
	self.Icon:SetInside(self.bg)

	local IconBorder = self.IconBorder
	IconBorder:SetAlpha(0)
	IconBorder.__owner = self
	hooksecurefunc(IconBorder, "SetAtlas", updateIconBorderColor)
	IconBorder:SetAtlas(IconBorder:GetAtlas())
	hooksecurefunc(IconBorder, "Hide", resetIconBorderColor)
	hooksecurefunc(IconBorder, "SetShown", iconBorderShown)
end

local function ReskinCollectionFrame()
	local frame = _G.BetterWardrobeCollectionFrame
	if not frame then return end

	S:Proxy("ReskinInput", frame.searchBox)
	HandleIconButton(frame.AlteredFormSwapButton)
	S:Proxy("ReskinFilterButton", frame.FilterButton)
	S:Proxy("ReskinDropDown", frame.ClassDropdown)
	S:Proxy("ReskinDropDown", frame.SortDropdown)
	S:Proxy("ReskinDropDown", frame.SavedOutfitDropDown)
	S:Proxy("ReskinFilterButton", frame.TransmogOptionsButton)

	for i, tab in ipairs(frame.Tabs) do
		B.ReskinTab(tab)

		if i > 1 then
			tab:ClearAllPoints()
			tab:SetPoint("LEFT", frame.Tabs[i-1], "RIGHT", -10, 0)
		end
	end

	local progressBar = frame.progressBar
	if progressBar then
		B.StripTextures(progressBar)
		progressBar:SetStatusBarTexture(DB.normTex)
		B.CreateBDFrame(progressBar, .25)
	end

	-- ItemsCollectionFrame
	local ItemsCollectionFrame = frame.ItemsCollectionFrame
	if ItemsCollectionFrame then
		B.StripTextures(ItemsCollectionFrame)
		S:Proxy("ReskinCheck", ItemsCollectionFrame.ApplyOnClickCheckbox)
		S:Proxy("ReskinDropDown", ItemsCollectionFrame.WeaponDropdown)

		local PagingFrame = ItemsCollectionFrame.PagingFrame
		if PagingFrame then
			S:Proxy("ReskinArrow", PagingFrame.PrevPageButton, "left")
			S:Proxy("ReskinArrow", PagingFrame.NextPageButton, "right")
		end
	end

	-- SetsCollectionFrame
	local SetsCollectionFrame = frame.SetsCollectionFrame
	if SetsCollectionFrame then
		S:Proxy("StripTextures", SetsCollectionFrame.LeftInset)
		S:Proxy("StripTextures", SetsCollectionFrame.RightInset)
		S:Proxy("CreateBDFrame", SetsCollectionFrame.Model, .25)

		local ListContainer = SetsCollectionFrame.ListContainer
		if ListContainer and ListContainer.ScrollBox then
			S:Proxy("ReskinTrimScroll", ListContainer.ScrollBar)
			hooksecurefunc(ListContainer.ScrollBox, "Update", function(self)
				self:ForEachFrame(HandleSetsListButton)
			end)
		end

		local DetailsFrame = SetsCollectionFrame.DetailsFrame
		if DetailsFrame then
			HandleSetsDetailsButton(DetailsFrame.BW_OpenDressingRoomButton, 1)
			HandleSetsDetailsButton(DetailsFrame.BW_LinkSetButton, 2)
			HandleSetsDetailsButton(DetailsFrame.BW_SetsHideSlotButton, 3)
			S:Proxy("ReskinDropDown", DetailsFrame.VariantSetsDropdown)
			DetailsFrame.ModelFadeTexture:Hide()
			DetailsFrame.IconRowBackground:Hide()
		end

		hooksecurefunc(SetsCollectionFrame, "SetItemFrameQuality", function(_, itemFrame)
			local ic = itemFrame.Icon
			if not ic.bg then
				ic.bg = B.ReskinIcon(ic)
			end
			itemFrame.IconBorder:SetTexture("")

			local altItem = itemFrame.AltItem
			if altItem and not altItem.styled then
				S:Proxy("SetupArrow", itemFrame.AltItem.AltIconLeft, "left")
				S:Proxy("SetupArrow", itemFrame.AltItem.AltIconRight, "right")
				altItem.styled = true
			end

			if itemFrame.collected then
				local quality = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID).quality
				local color = DB.QualityColors[quality or 1]
				ic.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				ic.bg:SetBackdropBorderColor(0, 0, 0)
			end
		end)
	end

	-- SetsTransmogFrame
	local SetsTransmogFrame = frame.SetsTransmogFrame
	if SetsTransmogFrame then
		B.StripTextures(SetsTransmogFrame)

		local PagingFrame = SetsTransmogFrame.PagingFrame
		if PagingFrame then
			S:Proxy("ReskinArrow", PagingFrame.PrevPageButton, "left")
			S:Proxy("ReskinArrow", PagingFrame.NextPageButton, "right")
		end
	end
end

local function ReskinCollectionList()
	local frame = _G.BW_ColectionListFrame
	if not frame then return end

	HandleIconButton(frame.CollectionListButton)
end

local function ReskinCollectionDropdown()
	local button = _G.BW_CollectionListOptionsButton
	if button then
		B.Reskin(button)
		button:SetSize(21, 22)
	end

	S:Proxy("ReskinDropDown", _G.BW_CollectionList_Dropdown)
end

local function ReskinTransmogVendorUI()
	local prev
	for _, key in ipairs({"BW_LoadQueueButton", "BW_RandomizeButton", "BW_SlotHideButton"}) do
		local bu = _G[key]
		if bu then
			B.Reskin(bu)
			bu:SetSize(21, 21)
			bu:ClearAllPoints()
			if not prev then
				bu:SetPoint("LEFT", _G.WardrobeTransmogFrame.OutfitDropdown.SaveButton, "RIGHT", 4, 0)
			else
				bu:SetPoint("LEFT", prev, "RIGHT", 4, 0)
			end
			prev = bu
		end
	end

	HandleOutfitDropDown(_G.BetterWardrobeTMOutfitDropDown)
end

function S:BetterWardrobe()
	local BetterWardrobe = LibStub("AceAddon-3.0"):GetAddon("BetterWardrobe")
	if not BetterWardrobe then return end

	hooksecurefunc(BetterWardrobe.Init, "LoadModules", ReskinCollectionFrame)
	hooksecurefunc(BetterWardrobe.Init, "initCollectionList", ReskinCollectionList)
	hooksecurefunc(BetterWardrobe.CollectionList, "CreateDropdown", ReskinCollectionDropdown)
	hooksecurefunc(BetterWardrobe.Init, "BuildTransmogVendorUI", ReskinTransmogVendorUI)

	-- DressingRoomFrame
	local DressingRoomFrame = _G.BW_DressingRoomFrame
	if DressingRoomFrame then
		local PreviewButtonFrame = DressingRoomFrame.PreviewButtonFrame
		if PreviewButtonFrame and PreviewButtonFrame.Slots then
			for _, button in ipairs(PreviewButtonFrame.Slots) do
				HandlePreviewButton(button)
			end
		end

		local prev
		for _, key in ipairs({
			"BW_DressingRoomSettingsButton", "BW_DressingRoomExportButton", "BW_DressingRoomTargetButton",
			"BW_DressingRoomPlayerButton", "BW_DressingRoomGearButton", "BW_DressingRoomUndressButton",
			"BW_DressingRoomUndoButton"
		}) do
			local bu = DressingRoomFrame[key]
			if bu then
				B.Reskin(bu)
				bu:SetSize(25, 25)
				bu:ClearAllPoints()
				if not prev then
					bu:SetPoint("BOTTOMLEFT", 10, 31)
				else
					bu:SetPoint("LEFT", prev, "RIGHT", 4, 0)
				end
				prev = bu
			end
		end

		HandleOutfitDropDown(DressingRoomFrame.OutfitDropDown)
		HandleIconButton(DressingRoomFrame.BW_DressingRoomSwapFormButton)
	end

	-- Misc
	local WardrobeOutfitEditFrame = _G.BetterWardrobeOutfitEditFrame
	if WardrobeOutfitEditFrame then
		B.StripTextures(WardrobeOutfitEditFrame)
		B.SetBD(WardrobeOutfitEditFrame)
		S:Proxy("Reskin", WardrobeOutfitEditFrame.AcceptButton)
		S:Proxy("Reskin", WardrobeOutfitEditFrame.CancelButton)
		S:Proxy("Reskin", WardrobeOutfitEditFrame.DeleteButton)

		local EditBox = WardrobeOutfitEditFrame.EditBox
		if EditBox then
			EditBox:DisableDrawLayer("BACKGROUND")
			B.ReskinInput(EditBox, 22)
		end
	end
end

S:RegisterSkin("BetterWardrobe", S.BetterWardrobe)