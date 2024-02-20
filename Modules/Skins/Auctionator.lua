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

local function reskinInput(editbox)
	if not editbox then P:Debug("Unknown: Input") return end

	P.ReskinInput(editbox, 24)
	editbox.bg:SetPoint("TOPLEFT", -2, 4)
end

local function reskinSimplePanel(frame)
	if not frame then P:Debug("Unknown: Panel") return end

	B.StripTextures(frame)
	B.SetBD(frame)

	if frame.ScrollBar then B.ReskinTrimScroll(frame.ScrollBar) end
	if frame.CloseDialog then B.ReskinClose(frame.CloseDialog) end
end

local function reskinRefreshButton(self)
	for i = 1, self:GetNumChildren() do
		local child = select(i, self:GetChildren())
		if child.iconAtlas and child.iconAtlas == "UI-RefreshButton" then
			B.Reskin(child)
			child:SetSize(22, 22)
			break
		end
	end
end

local function reskinIconAndName(self)
	if not self then
		P:Debug("Unknown: IconAndName")
		return
	end

	self.bg = B.ReskinIcon(self.Icon)
	B.ReskinIconBorder(self.QualityBorder)
end

local function reskinItemDialog(self)
	if not self then
		P:Debug("Unknown: ItemDialog")
		return
	end

	B.StripTextures(self)
	B.SetBD(self)
	S:Proxy("ReskinInput", self.SearchContainer.SearchString)
	S:Proxy("ReskinCheck", self.SearchContainer.IsExact)
	P.ReskinDropDown(self.FilterKeySelector)
	reskinButtons(self, {"Finished", "Cancel", "ResetAllButton"})
	reskinInput(self.PurchaseQuantity.InputBox)

	for _, key in ipairs({"QualityContainer", "TierContainer", "ExpansionContainer"}) do
		local container = self[key] and self[key].DropDown
		local dropDown = container and container.DropDown
		if dropDown then
			P.ReskinDropDown(dropDown)
		end
	end

	for _, key in ipairs({"LevelRange", "ItemLevelRange", "PriceRange", "CraftedLevelRange"}) do
		local minMax = self[key]
		if minMax then
			B.ReskinInput(minMax.MaxBox)
			B.ReskinInput(minMax.MinBox)
		end
	end
end

local function reskinListIcon(self)
	if not self.tableBuilder then return end

	for _, row in ipairs(self.tableBuilder.rows) do
		local cells = row.cells
		if cells then
			for _, cell in ipairs(cells) do
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
	if not frame or not frame.tableBuilder or not frame.ScrollArea then P:Debug("Unknown: ListHeader") return end

	B.CreateBDFrame(frame.ScrollArea, .25)
	S:Proxy("ReskinTrimScroll", frame.ScrollArea.ScrollBar)

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

	if frame.UpdateTable then
		hooksecurefunc(frame, "UpdateTable", reskinListIcon)
	end
end

local function updateSelectedColor(self, r, g, b)
	self:SetColorTexture(r, g, b, .5)
end

local function reskinBagItem(button)
	if not button then P:Debug("Unknown: BagItem") return end

	button.EmptySlot:Hide()
	button:SetPushedTexture(0)
	button.Icon:SetInside(button, 2, 2)
	button.Highlight:SetColorTexture(1, 1, 1, .25)
	button.Highlight:SetAllPoints(button.Icon)
	button.bg = B.ReskinIcon(button.Icon)
	button.IconBorder.SetVertexColor = B.Dummy
	B.ReskinIconBorder(button.IconBorder, true)
	button.IconSelectedHighlight.SetVertexColor = updateSelectedColor
	button.IconSelectedHighlight:SetAllPoints(button.bg)
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

local function reskinSearchButton(self)
	S:Proxy("Reskin", self.SearchButton)
end

local function reskinCopyAndPaste(self)
	S:Proxy("ReskinInput", self.InputBox)
end

local function reskinBagView(self)
	S:Proxy("ReskinTrimScroll", self.ScrollBar)

	hooksecurefunc(self, "UpdateFromExisting", function()
		for bu in self.groupPool:EnumerateActive() do
			if not bu.styled then
				B.StripTextures(bu.GroupTitle)
				local bg = B.CreateBDFrame(bu.GroupTitle, .25)
				bg:SetAllPoints()

				bu.styled = true
			end
		end
	end)
end

local function reskinBagItemButton(self)
	if not self.styled then
		reskinBagItem(self)
		self.styled = true
	end
end

local function reskinPopout(self)
	if self.Border then
		B.StripTextures(self.Border)
		B.SetBD(self.Border, .7, 5, -2, -5, 20)
	end
end

local function reskinPopoutEntry(self)
	if self.HighlightBGTex then
		B.StripTextures(self.HighlightBGTex)
	end
	self.HL = self:CreateTexture(nil, "HIGHLIGHT")
	self.HL:SetAllPoints()
	self.HL:SetColorTexture(DB.r, DB.g, DB.b, .25)
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
			S:Proxy("ReskinTrimScroll", SplashScreen.ScrollBar)

			if SplashScreen.HideCheckbox then
				S:Proxy("ReskinCheck", SplashScreen.HideCheckbox.CheckBox)
			end
		end

		for _, tab in ipairs(_G.AuctionatorAHTabsContainer.Tabs) do
			B.ReskinTab(tab)
		end

		local ShoppingList = _G.AuctionatorShoppingFrame
		if ShoppingList then
			reskinListHeader(ShoppingList.ResultsListing)
			reskinButtons(ShoppingList, {"ImportButton", "ExportButton", "ExportCSV", "NewListButton"})
			reskinItemDialog(ShoppingList.itemDialog)
			S:Proxy("StripTextures", ShoppingList.ShoppingResultsInset)

			local SearchOptions = ShoppingList.SearchOptions
			if SearchOptions then
				reskinButtons(SearchOptions, {"AddToListButton", "MoreButton", "ResetSearchStringButton", "SearchButton"})
				S:Proxy("ReskinInput", SearchOptions.SearchString)
			end

			local exportDialog = ShoppingList.exportDialog
			if exportDialog then
				reskinSimplePanel(exportDialog)
				reskinButtons(exportDialog, {"Export", "SelectAll", "UnselectAll"})

				hooksecurefunc(exportDialog.checkBoxPool, "Acquire", function(self)
					for frame in self:EnumerateActive() do
						if not frame.styled then
							S:Proxy("ReskinCheck", frame.CheckBox)
							frame.styled = true
						end
					end
				end)

				local copyTextDialog = exportDialog.copyTextDialog
				if copyTextDialog then
					reskinSimplePanel(copyTextDialog)
					S:Proxy("Reskin", copyTextDialog.Close)
				end
			end

			local importDialog = ShoppingList.importDialog
			if importDialog then
				reskinSimplePanel(importDialog)
				S:Proxy("Reskin", importDialog.Import)
			end

			for _, key in ipairs({"ListsContainer", "RecentsContainer"}) do
				local scrollList = ShoppingList[key]
				if scrollList and scrollList.ScrollBox then
					B.StripTextures(scrollList)
					local bg = B.CreateBDFrame(scrollList, .25)
					bg:SetAllPoints()
					S:Proxy("ReskinTrimScroll", scrollList.ScrollBar)
				end
			end

			local ContainerTabs = ShoppingList.ContainerTabs
			if ContainerTabs then
				for _, tab in ipairs(ContainerTabs.Tabs) do
					B.ReskinTab(tab)
					tab.bg:SetInside()
					tab:SetSize(102, 30)
				end
			end

			local exportCSVDialog = ShoppingList.exportCSVDialog
			if exportCSVDialog then
				reskinSimplePanel(exportCSVDialog)
				S:Proxy("Reskin", exportCSVDialog.Close)
			end

			local itemHistoryDialog = ShoppingList.itemHistoryDialog
			if itemHistoryDialog then
				reskinSimplePanel(itemHistoryDialog)
				reskinListHeader(itemHistoryDialog.ResultsListing)
				reskinButtons(itemHistoryDialog, {"Close", "Dock"})
			end

			for _, frameName in ipairs({"AuctionatorBuyCommodityFrame", "AuctionatorBuyItemFrame"}) do
				local buyFrame = _G[frameName]
				if buyFrame then
					B.StripTextures(buyFrame)
					S:Proxy("Reskin", buyFrame.BackButton)
					reskinRefreshButton(buyFrame)
					reskinIconAndName(buyFrame.IconAndName)

					local DetailsContainer = buyFrame.DetailsContainer
					if DetailsContainer then
						S:Proxy("Reskin", DetailsContainer.BuyButton)
						reskinInput(DetailsContainer.Quantity)
					end

					for _, key in ipairs({"QuantityCheckConfirmationDialog", "FinalConfirmationDialog"}) do
						local dialog = buyFrame[key]
						if dialog then
							reskinSimplePanel(dialog)
							reskinButtons(dialog, {"AcceptButton", "CancelButton"})
							if dialog.QuantityInput then reskinInput(dialog.QuantityInput) end
						end
					end

					local ResultsListing = buyFrame.ResultsListing
					if ResultsListing then
						reskinListHeader(ResultsListing)
					end

					local BuyDialog = buyFrame.BuyDialog
					if BuyDialog then
						B.StripTextures(BuyDialog)
						B.SetBD(BuyDialog)
						reskinButtons(BuyDialog, {"Buy", "Cancel"})
						reskinIconAndName(BuyDialog.IconAndName)
					end
				end
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
				reskinRefreshButton(SaleItemFrame)

				for _, bu in ipairs(SaleItemFrame.Duration.radioButtons) do
					B.ReskinRadio(bu.RadioButton)
				end
			end

			for _, key in ipairs({"BagInset", "HistoricalPriceInset"}) do
				S:Proxy("StripTextures", SellingFrame[key])
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
			reskinRefreshButton(CancellingFrame)

			for _, child in pairs {CancellingFrame:GetChildren()} do
				if child.StartScanButton and child.CancelNextButton then
					B.Reskin(child.StartScanButton)
					B.Reskin(child.CancelNextButton)
					break
				end
			end

			S:Proxy("StripTextures", CancellingFrame.HistoricalPriceInset)
			S:Proxy("ReskinInput", CancellingFrame.SearchFilter)
		end

		local ConfigFrame = _G.AuctionatorConfigFrame
		if ConfigFrame then
			B.StripTextures(ConfigFrame)
			B.CreateBDFrame(ConfigFrame, .25)
			reskinButtons(ConfigFrame, {"ScanButton", "OptionsButton"})
		end

		styled = true
	end)

	local function hook(object, method, func)
		if _G[object] and _G[object][method] then
			hooksecurefunc(_G[object], method, func)
		else
			P.Developer_ThrowError(format("function %s:%s does not exist", object, method))
		end
	end

	local ObjectiveTrackerFrame = _G.AuctionatorCraftingInfoObjectiveTrackerFrame
	if ObjectiveTrackerFrame then
		reskinSearchButton(ObjectiveTrackerFrame)
	else
		hook("AuctionatorCraftingInfoObjectiveTrackerFrameMixin", "OnLoad", reskinSearchButton)
	end

	hook("AuctionatorConfigurationCopyAndPasteMixin", "OnLoad", reskinCopyAndPaste)
	hook("AuctionatorCraftingInfoProfessionsFrameMixin", "OnLoad", reskinSearchButton)
	hook("AuctionatorGroupsViewMixin", "OnLoad", reskinBagView)
	hook("AuctionatorGroupsViewItemMixin", "SetItemInfo", reskinBagItemButton)
	hook("AuctionatorSelectionPopoutMixin", "OnLoad", reskinPopout)
	hook("AuctionatorSelectionPopoutEntryMixin", "OnLoad", reskinPopoutEntry)
end

S:RegisterSkin("Auctionator", S.Auctionator)