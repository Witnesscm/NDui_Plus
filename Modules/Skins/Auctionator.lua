local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local function reskinButtons(self, buttons)
	for _, key in ipairs(buttons) do
		local bu = self[key]
		if bu then
			B.Reskin(bu)
		end
	end
end

local function reskinItemDialog(self)
	B.StripTextures(self)
	B.SetBD(self)
	B.ReskinInput(self.SearchContainer.SearchString)
	B.ReskinCheck(self.SearchContainer.IsExact)
	P.ReskinDropDown(self.FilterKeySelector)
	reskinButtons(self, {"Finished", "Cancel", "ResetAllButton"})

	for _, key in ipairs({"LevelRange", "ItemLevelRange", "PriceRange", "CraftedLevelRange"}) do
		local minMax = self[key]
		if minMax then
			B.ReskinInput(minMax.MaxBox)
			B.ReskinInput(minMax.MinBox)
		end
	end
end

local function reskinListIcon(frame)
	if not frame.tableBuilder then return end

	for i = 1, 22 do
		local row = frame.tableBuilder.rows[i]
		if row then
			for j = 1, 4 do
				local cell = row.cells and row.cells[j]
				if cell and cell.Icon then
					if not cell.styled then
						cell.Icon.bg = B.ReskinIcon(cell.Icon)
						if cell.IconBorder then cell.IconBorder:Hide() end
						cell.styled = true
					end
					cell.Icon.bg:SetShown(cell.Icon:IsShown())
				end
			end
		end
	end
end

local function reskinListHeader(frame)
	local maxHeaders = frame.HeaderContainer:GetNumChildren()
	for i = 1, maxHeaders do
		local header = select(i, frame.HeaderContainer:GetChildren())
		if header and not header.styled then
			header:DisableDrawLayer("BACKGROUND")
			header.bg = B.CreateBDFrame(header)
			local hl = header:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .1)
			hl:SetAllPoints(header.bg)

			header.styled = true
		end

		if header.bg then
			header.bg:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2)
		end
	end

	frame.bg = B.CreateBDFrame(frame.ScrollFrame, .25)
	frame.bg:SetPoint("TOPLEFT", 16, C.mult)
	frame.ScrollFrame:SetPoint("TOPLEFT", frame.HeaderContainer, "BOTTOMLEFT", 0, -4)
	B.ReskinScroll(frame.ScrollFrame.scrollBar)

	reskinListIcon(frame)
end

local function reskinSimplePanel(frame)
	B.StripTextures(frame)
	B.SetBD(frame)

	if frame.ScrollFrame then
		B.CreateBDFrame(frame.ScrollFrame, .25)
		B.ReskinScroll(frame.ScrollFrame.ScrollBar)
	end

	if frame.CloseDialog then
		B.ReskinClose(frame.CloseDialog)
	end
end

local function reskinInput(editbox)
	P.ReskinInput(editbox, 24)
	editbox.bg:SetPoint("TOPLEFT", -2, 4)
end

local function reskinBagItem(button)
	button.IconMask:Hide()
	button.EmptySlot:Hide()
	button:SetPushedTexture("")
	button.Icon:SetInside(button, 2, 2)
	button.Highlight:SetColorTexture(1, 1, 1, .25)
	button.Highlight:SetAllPoints(button.Icon)
	button.bg = B.ReskinIcon(button.Icon)
	B.ReskinIconBorder(button.IconBorder)
	button.IconBorder:Hide()
	button.IconBorder.Show = B.Dummy
end

local function reskinBagList(frame)
	B.StripTextures(frame.SectionTitle)
	frame.titleBG = B.CreateBDFrame(frame.SectionTitle, .25)
	frame.titleBG:SetAllPoints()

	for _, bu in ipairs(frame.buttons) do
		reskinBagItem(bu)
		bu.styled = true
	end

	local origGet = frame.buttonPool.Get
	frame.buttonPool.Get = function(self)
		local button = origGet(self)
		if not button.styled then
			reskinBagItem(button)
			button.styled = true
		end
		return button
	end
end

function S:Auctionator()
	if not IsAddOnLoaded("Auctionator") then return end

	local styled
	hooksecurefunc(_G.Auctionator.Events, "OnAuctionHouseShow", function()
		if styled then return end

		local SplashScreen = _G.AuctionatorSplashScreen
		if SplashScreen then
			P.ReskinFrame(SplashScreen)
			B.ReskinScroll(SplashScreen.ScrollFrame.ScrollBar)
			B.ReskinCheck(SplashScreen.HideCheckbox.CheckBox)
		end

		for _, tab in ipairs(_G.AuctionatorAHTabsContainer.Tabs) do
			B.ReskinTab(tab)
		end

		local ShoppingList = _G.AuctionatorShoppingListFrame
		if ShoppingList then
			reskinListHeader(ShoppingList.ResultsListing)
			P.ReskinDropDown(ShoppingList.ListDropdown)
			reskinButtons(ShoppingList, {"CreateList", "DeleteList", "Rename", "Import", "Export", "AddItem", "ManualSearch", "ExportCSV"})
			reskinItemDialog(ShoppingList.addItemDialog)
			reskinItemDialog(ShoppingList.editItemDialog)

			reskinSimplePanel(ShoppingList.exportDialog)
			reskinButtons(ShoppingList.exportDialog, {"Export", "SelectAll", "UnselectAll"})

			for _, cb in ipairs(ShoppingList.exportDialog.checkBoxPool) do
				B.ReskinCheck(cb.CheckBox)
			end
			hooksecurefunc(ShoppingList.exportDialog, "AddToPool", function(self)
				B.ReskinCheck(self.checkBoxPool[#self.checkBoxPool].CheckBox)
			end)

			B.StripTextures(ShoppingList.ShoppingResultsInset)
			reskinSimplePanel(ShoppingList.importDialog)
			B.Reskin(ShoppingList.importDialog.Import)

			B.StripTextures(ShoppingList.ScrollList)
			B.CreateBDFrame(ShoppingList.ScrollList.ScrollFrame, .25)
			B.ReskinScroll(ShoppingList.ScrollList.ScrollFrame.scrollBar)

			reskinSimplePanel(ShoppingList.exportCSVDialog)
			B.Reskin(ShoppingList.exportCSVDialog.Close)
			reskinSimplePanel(ShoppingList.itemHistoryDialog)
			reskinListHeader(ShoppingList.itemHistoryDialog.ResultsListing)
			B.Reskin(ShoppingList.itemHistoryDialog.Close)
		end

		local SellingFrame = _G.AuctionatorSellingFrame
		if SellingFrame then
			local itemFrame = SellingFrame.SaleItemFrame
			reskinBagItem(itemFrame.Icon)
			reskinInput(itemFrame.Quantity.InputBox)
			reskinInput(itemFrame.Price.MoneyInput.GoldBox)
			reskinInput(itemFrame.Price.MoneyInput.SilverBox)
			reskinButtons(itemFrame, {"PostButton", "SkipButton", "MaxButton"})

			for _, bu in ipairs(itemFrame.Duration.radioButtons) do
				B.ReskinRadio(bu.RadioButton)
			end

			for i = 1, itemFrame:GetNumChildren() do
				local child = select(i, itemFrame:GetChildren())
				if child.iconAtlas and child.iconAtlas == "UI-RefreshButton" then
					B.Reskin(child)
					child:SetSize(22, 22)
				end
			end

			B.StripTextures(SellingFrame.BagInset)
			B.StripTextures(SellingFrame.BagListing.ScrollFrame.Background)
			B.ReskinScroll(SellingFrame.BagListing.ScrollFrame.ScrollBar)

			for _, key in ipairs({"Favourites", "WeaponItems", "ArmorItems", "ContainerItems", "GemItems", "EnhancementItems", "ConsumableItems", "GlyphItems", "TradeGoodItems", "RecipeItems", "BattlePetItems", "QuestItems", "MiscItems"}) do
				local items = SellingFrame.BagListing.ScrollFrame.ItemListingFrame[key]
				if items then
					reskinBagList(items)
				end
			end

			B.StripTextures(SellingFrame.CurrentItemInset)
			reskinListHeader(SellingFrame.CurrentItemListing)
			B.StripTextures(SellingFrame.HistoricalPriceInset)
			reskinListHeader(SellingFrame.HistoricalPriceListing)
			reskinListHeader(SellingFrame.PostingHistoryListing)

			for _, tab in ipairs(SellingFrame.HistoryTabsContainer.Tabs) do
				B.ReskinTab(tab)
			end
		end

		local CancellingFrame = _G.AuctionatorCancellingFrame
		if CancellingFrame then
			B.StripTextures(CancellingFrame.HistoricalPriceInset)
			reskinListHeader(CancellingFrame.ResultsListing)
			B.ReskinInput(CancellingFrame.SearchFilter)

			for i = 1, CancellingFrame:GetNumChildren() do
				local child = select(i, CancellingFrame:GetChildren())
				if child.iconAtlas and child.iconAtlas == "UI-RefreshButton" then
					B.Reskin(child)
					child:SetSize(22, 22)
				elseif child.StartScanButton and child.CancelNextButton then
					B.Reskin(child.StartScanButton)
					B.Reskin(child.CancelNextButton)
				end
			end
		end

		local ConfigFrame = _G.AuctionatorConfigFrame
		if ConfigFrame then
			B.StripTextures(ConfigFrame)
			B.CreateBDFrame(ConfigFrame, .25)
			reskinButtons(ConfigFrame, {"ScanButton", "OptionsButton"})

			for _, key in ipairs({"DiscordLink", "BugReportLink", "TechnicalRoadmap"}) do
				local eb = ConfigFrame[key]
				if eb then
					B.ReskinInput(eb.InputBox)
				end
			end
		end

		styled = true
	end)
end

S:RegisterSkin("Auctionator", S.Auctionator)