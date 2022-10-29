local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local ipairs, pairs= ipairs, pairs

local function reskinButtons(self, buttons)
	for _, key in ipairs(buttons) do
		local bu = self[key]
		if bu then
			B.Reskin(bu)
		else
			P:Debug("Unknown: %s", key)
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

local function reskinListHeader(frame)
	if not frame or not frame.tableBuilder then P:Debug("Unknown: ListHeader") return end

	B.CreateBDFrame(frame.ScrollFrame, .25)
	B.ReskinScroll(frame.ScrollFrame.scrollBar)

	for _, column in ipairs(frame.tableBuilder.columns) do
		local header = column.headerFrame
		if header then
			header:DisableDrawLayer("BACKGROUND")
			header.bg = B.CreateBDFrame(header)
			header.bg:SetPoint("BOTTOMRIGHT", -2, -C.mult)
			local hl = header:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .1)
			hl:SetAllPoints(header.bg)
		end
	end

	for _, row in ipairs(frame.tableBuilder.rows) do
		local cells = row.cells
		if cells then
			for _, cell in ipairs(cells) do
				if cell.Icon then
					cell.Icon.bg = B.ReskinIcon(cell.Icon)
					if cell.IconBorder then cell.IconBorder:Hide() end
				end
			end
		end
	end
end

local function reskinSimplePanel(frame)
	if not frame then P:Debug("Unknown: Panel") return end

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
	if not editbox then P:Debug("Unknown: Input") return end

	P.ReskinInput(editbox, 24)
	editbox.bg:SetPoint("TOPLEFT", -2, 4)
end

local function reskinBagItem(button)
	if not button then P:Debug("Unknown: BagItem") return end

	button.IconMask:Hide()
	button.EmptySlot:Hide()
	button:SetPushedTexture(0)
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

	local buttons = frame.ItemContainer and frame.ItemContainer.buttons
	if buttons then
		for _, bu in ipairs(buttons) do
			reskinBagItem(bu)
			bu.styled = true
		end
	end

	local buttonPool = frame.ItemContainer and frame.ItemContainer.buttonPool
	if buttonPool then
		local origGet = buttonPool.Get
		buttonPool.Get = function(self)
			local button = origGet(self)
			if not button.styled then
				reskinBagItem(button)
				button.styled = true
			end
			return button
		end
	end
end

local function reskinMoneyInput(self)
	if not self or not self.MoneyInput then P:Debug("Unknown: MoneyInput") return end

	for _, key in ipairs({"GoldBox", "SilverBox", "CopperBox"}) do
		local box = self.MoneyInput[key]
		if box then
			reskinInput(box)
		end
	end
end

function S:Auctionator()
	local Auctionator = _G.Auctionator
	if not Auctionator or not _G.AuctionatorInitalizeMainlineFrame or not _G.AuctionatorInitalizeMainlineFrame.AuctionHouseShown then return end

	local styled
	hooksecurefunc(_G.AuctionatorInitalizeMainlineFrame, "AuctionHouseShown", function()
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

		local ShoppingList = _G.AuctionatorShoppingFrame
		if ShoppingList then
			reskinListHeader(ShoppingList.ResultsListing)
			reskinButtons(ShoppingList, {"Import", "Export", "AddItem", "ManualSearch", "ExportCSV", "OneItemSearchButton", "SortItems"})

			if ShoppingList.ListDropdown then
				P.ReskinDropDown(ShoppingList.ListDropdown)
			end

			local itemDialog = ShoppingList.itemDialog
			if itemDialog then
				reskinItemDialog(itemDialog)
			end

			local exportDialog = ShoppingList.exportDialog
			if exportDialog then
				reskinSimplePanel(exportDialog)
				reskinButtons(exportDialog, {"Export", "SelectAll", "UnselectAll"})

				for _, cb in ipairs(exportDialog.checkBoxPool) do
					B.ReskinCheck(cb.CheckBox)
				end

				hooksecurefunc(exportDialog, "AddToPool", function(self)
					B.ReskinCheck(self.checkBoxPool[#self.checkBoxPool].CheckBox)
				end)
			end

			local importDialog = ShoppingList.importDialog
			if importDialog then
				reskinSimplePanel(importDialog)
				B.Reskin(importDialog.Import)
			end

			if ShoppingList.ShoppingResultsInset then
				B.StripTextures(ShoppingList.ShoppingResultsInset)
			end

			for _, key in ipairs({"ScrollListShoppingList", "ScrollListRecents"}) do
				local scrollList = ShoppingList[key]
				if scrollList and scrollList.ScrollFrame then
					B.StripTextures(scrollList)
					B.CreateBDFrame(scrollList.ScrollFrame, .25)
					B.ReskinScroll(scrollList.ScrollFrame.scrollBar)
				end
			end

			local OneItemSearchBox = ShoppingList.OneItemSearchBox
			if OneItemSearchBox then
				B.ReskinInput(OneItemSearchBox)
			end

			local OneItemSearchExtendedButton = ShoppingList.OneItemSearchExtendedButton
			if OneItemSearchExtendedButton then
				B.Reskin(OneItemSearchExtendedButton)
			end

			local TabsContainer = ShoppingList.RecentsTabsContainer
			if TabsContainer then
				for _, tab in ipairs(TabsContainer.Tabs) do
					B.ReskinTab(tab)
				end

				if ShoppingList.ScrollListShoppingList then
					TabsContainer:ClearAllPoints()
					TabsContainer:SetPoint("TOPLEFT", ShoppingList.ScrollListShoppingList, "TOPLEFT", -5, 30)
					TabsContainer:SetPoint("BOTTOMRIGHT", ShoppingList.ScrollListShoppingList, "TOPRIGHT", 0, 0)
				end
			end

			local exportCSVDialog = ShoppingList.exportCSVDialog
			if exportCSVDialog then
				reskinSimplePanel(exportCSVDialog)
				B.Reskin(exportCSVDialog.Close)
			end

			local itemHistoryDialog = ShoppingList.itemHistoryDialog
			if itemHistoryDialog then
				reskinSimplePanel(itemHistoryDialog)
				reskinListHeader(itemHistoryDialog.ResultsListing)
				reskinButtons(itemHistoryDialog, {"Close", "Dock"})
			end
		end

		local SellingFrame = _G.AuctionatorSellingFrame
		if SellingFrame then
			local SaleItemFrame = SellingFrame.SaleItemFrame
			if SaleItemFrame then
				reskinBagItem(SaleItemFrame.Icon)
				reskinInput(SaleItemFrame.Quantity.InputBox)
				reskinMoneyInput(SaleItemFrame.Price)
				reskinMoneyInput(SaleItemFrame.BidPrice)
				reskinButtons(SaleItemFrame, {"PostButton", "SkipButton", "MaxButton"})

				for _, bu in ipairs(SaleItemFrame.Duration.radioButtons) do
					B.ReskinRadio(bu.RadioButton)
				end

				for i = 1, SaleItemFrame:GetNumChildren() do
					local child = select(i, SaleItemFrame:GetChildren())
					if child.iconAtlas and child.iconAtlas == "UI-RefreshButton" then
						B.Reskin(child)
						child:SetSize(22, 22)
					end
				end
			end

			local BagListing = SellingFrame.BagListing
			if BagListing and BagListing.ScrollFrame then
				B.StripTextures(BagListing.ScrollFrame.Background)
				B.ReskinScroll(BagListing.ScrollFrame.ScrollBar)

				local frameMap = BagListing.frameMap
				if frameMap then
					for _, items in pairs(frameMap) do
						reskinBagList(items)
					end
				end
			end

			for _, key in ipairs({"BagInset", "CurrentItemInset", "HistoricalPriceInset"}) do
				local inset = SellingFrame[key]
				if inset then
					B.StripTextures(inset)
				end
			end

			reskinListHeader(SellingFrame.CurrentPricesListing)
			reskinListHeader(SellingFrame.HistoricalPriceListing)
			reskinListHeader(SellingFrame.PostingHistoryListing)

			local PricesTabsContainer = SellingFrame.PricesTabsContainer
			if PricesTabsContainer then
				for _, tab in ipairs(PricesTabsContainer.Tabs) do
					B.ReskinTab(tab)
				end
			end
		end

		local CancellingFrame = _G.AuctionatorCancellingFrame
		if CancellingFrame then
			reskinListHeader(CancellingFrame.ResultsListing)

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

			if CancellingFrame.HistoricalPriceInset then
				B.StripTextures(CancellingFrame.HistoricalPriceInset)
			end

			if CancellingFrame.SearchFilter then
				B.ReskinInput(CancellingFrame.SearchFilter)
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

	if Auctionator.CraftingInfo and Auctionator.CraftingInfo.Initialize then
		hooksecurefunc(Auctionator.CraftingInfo, "Initialize", function()
			local frame = _G.AuctionatorCraftingInfo
			if frame and frame.SearchButton and not frame.styled then
				B.Reskin(frame.SearchButton)
				frame.styled = true
			end
		end)
	end
end

S:RegisterSkin("Auctionator", S.Auctionator)