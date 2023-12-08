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

local function reskinChildButtons(self)
	for _, child in pairs {self:GetChildren()} do
		if child:GetObjectType() == "Button" and child.Text then
			B.Reskin(child)
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
	if frame.Inset then frame.Inset:SetAlpha(0)end
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
	P.ReskinDropDown(self.QualityContainer.DropDown.DropDown)
	reskinButtons(self, {"Finished", "Cancel", "ResetAllButton"})
	reskinInput(self.PurchaseQuantity.InputBox)

	if self.Inset then
		self.Inset:SetAlpha(0)
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

local function reskinBuyFrame(self)
	if not self then P:Debug("Unknown: BuyFrame") return end

	if self.HistoryButton then
		B.Reskin(self.HistoryButton)
	end

	local CurrentPrices = self.CurrentPrices
	if CurrentPrices then
		reskinButtons(CurrentPrices, {"BuyButton", "CancelButton", "RefreshButton"})
		reskinListHeader(CurrentPrices.SearchResultsListing)

		local BuyDialog = CurrentPrices.BuyDialog
		if BuyDialog then
			reskinSimplePanel(BuyDialog)
			reskinButtons(BuyDialog, {"Cancel", "BuyStack"})
			B.ReskinCheck(BuyDialog.ChainBuy.CheckBox)
		end

		if CurrentPrices.Inset then CurrentPrices.Inset:SetAlpha(0) end
	end

	local HistoryPrices = self.HistoryPrices
	if HistoryPrices then
		reskinButtons(HistoryPrices, {"PostingHistoryButton", "RealmHistoryButton"})
		reskinListHeader(HistoryPrices.PostingHistoryResultsListing)
		reskinListHeader(HistoryPrices.RealmHistoryResultsListing)

		if HistoryPrices.Inset then HistoryPrices.Inset:SetAlpha(0) end
	end
end

local function reskinSearchButton(self)
	S:Proxy("Reskin", self.SearchButton)
end

local function reskinCopyAndPaste(self)
	S:Proxy("ReskinInput", self.InputBox)
end

local function reskinBagUse(self)
	S:Proxy("Reskin", self.CustomiseButton)
end

local function reskinCustomiseGroup(self)
	reskinButtons(self, {"FocusButton", "RenameButton", "DeleteButton", "HideButton", "ShiftUpButton", "ShiftDownButton"})

	for _, key in ipairs({"NumStacks", "StackSize", "Quantity"}) do
		local editbox = self.Quantity and self.Quantity[key]
		if editbox then
			P.ReskinInput(editbox)
			editbox.bg:SetPoint("TOPLEFT", -2, -2)
			editbox.bg:SetPoint("BOTTOMRIGHT", 0, 2)
		end
	end

	for _, key in ipairs({"Short", "Medium", "Long", "Default"}) do
		local radio = self.Durations and self.Durations[key]
		if radio then
			B.ReskinRadio(radio)
		end
	end

	for _, child in pairs {self:GetChildren()} do
		if child.Divider then
			child.Divider:SetAlpha(0)
			break
		end
	end
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

local function reskinBagCustomise(self)
	B.ReskinPortraitFrame(self)
	reskinChildButtons(self)
end

local function reskinBagItemButton(self)
	if not self.styled then
		reskinBagItem(self)
		self.styled = true
	end
end

function S:Auctionator()
	if not S.db["Auctionator"] then return end

	local Auctionator = _G.Auctionator
	if not Auctionator or not _G.AuctionatorInitalizeClassicFrame or not _G.AuctionatorInitalizeClassicFrame.AuctionHouseShown then return end

	local styled
	hooksecurefunc(_G.AuctionatorInitalizeClassicFrame, "AuctionHouseShown", function()
		if styled then return end

		local SplashScreen = _G.AuctionatorSplashScreen
		if SplashScreen then
			P.ReskinFrame(SplashScreen)
			S:Proxy("ReskinTrimScroll", SplashScreen.ScrollBar)

			if SplashScreen.HideCheckbox then
				S:Proxy("ReskinCheck", SplashScreen.HideCheckbox.CheckBox)
			end

			if SplashScreen.Inset then
				SplashScreen.Inset:SetAlpha(0)
			end
		end

		local ShoppingList = _G.AuctionatorShoppingFrame
		if ShoppingList then
			reskinListHeader(ShoppingList.ResultsListing)
			reskinButtons(ShoppingList, {"ImportButton", "ExportButton", "ExportCSV", "NewListButton"})
			reskinItemDialog(ShoppingList.itemDialog)
			if ShoppingList.ShoppingResultsInset then ShoppingList.ShoppingResultsInset:SetAlpha(0) end

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
					B.CreateBDFrame(scrollList, .25)
					S:Proxy("ReskinTrimScroll", scrollList.ScrollBar)
					if scrollList.Inset then scrollList.Inset:SetAlpha(0) end
				end
			end

			local ContainerTabs = ShoppingList.ContainerTabs
			if ContainerTabs then
				for _, tab in ipairs(ContainerTabs.Tabs) do
					B.ReskinTab(tab)
					tab:SetHeight(30)
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
		end

		local BuyFrame = _G.AuctionatorBuyFrame
		if BuyFrame then
			reskinBuyFrame(BuyFrame)

			if BuyFrame.ReturnButton then
				B.Reskin(BuyFrame.ReturnButton)
			end

			for _, child in pairs {BuyFrame:GetChildren()} do
				if child.Icon then
					B.ReskinIcon(child.Icon)
				end
			end
		end

		local SellingFrame = _G.AuctionatorSellingFrame
		if SellingFrame then
			local SaleItemFrame = SellingFrame.SaleItemFrame
			if SaleItemFrame then
				reskinBagItem(SaleItemFrame.Icon)
				reskinMoneyInput(SaleItemFrame.StackPrice)
				reskinMoneyInput(SaleItemFrame.UnitPrice)
				reskinMoneyInput(SaleItemFrame.BidPrice)
				reskinButtons(SaleItemFrame, {"PostButton", "SkipButton"})

				local Duration = SaleItemFrame.Duration
				if Duration and Duration.radioButtons then
					for _, bu in ipairs(Duration.radioButtons) do
						B.ReskinRadio(bu.RadioButton)
					end
				end

				local Stacks = SaleItemFrame.Stacks
				if Stacks then
					reskinInput(Stacks.NumStacks)
					reskinInput(Stacks.StackSize)
				end
			end

			if SellingFrame.BagInset then
				SellingFrame.BagInset:SetAlpha(0)
			end

			local SellingBuyFrame = SellingFrame.BuyFrame
			if SellingBuyFrame then
				reskinBuyFrame(SellingBuyFrame)
			end
		end

		local CancellingFrame = _G.AuctionatorCancellingFrame
		if CancellingFrame then
			reskinListHeader(CancellingFrame.ResultsListing)

			for _, child in pairs {CancellingFrame:GetChildren()} do
				if child.StartScanButton and child.CancelNextButton then
					B.Reskin(child.StartScanButton)
					B.Reskin(child.CancelNextButton)
					break
				end
			end

			if CancellingFrame.HistoricalPriceInset then
				CancellingFrame.HistoricalPriceInset:SetAlpha(0)
			end

			S:Proxy("ReskinInput", CancellingFrame.SearchFilter)
		end

		local ConfigFrame = _G.AuctionatorConfigFrame
		if ConfigFrame then
			B.StripTextures(ConfigFrame)
			B.CreateBDFrame(ConfigFrame, .25)
			reskinButtons(ConfigFrame, {"ScanButton", "OptionsButton"})

			for _, child in pairs {ConfigFrame:GetChildren()} do
				if child:GetObjectType() == "Frame" and child.BorderTopRight then
					child:SetAlpha(0)
				end
			end
		end

		for _, key in ipairs({"AuctionatorPageStatusDialogFrame", "AuctionatorThrottlingTimeoutDialogFrame"}) do
			local dialog = _G[key]
			if dialog then
				B.StripTextures(dialog)
				B.SetBD(dialog)
			end
		end

		for _, tab in ipairs(_G.AuctionatorAHTabsContainer.Tabs) do
			B.ReskinTab(tab)
		end

		-- fix the duplicate tab background (NDui)
		local done
		_G.AuctionatorAHTabsContainer:HookScript("OnHide", function(self)
			if not done and C.db["Skins"]["BlizzardSkins"] then
				for _, tab in ipairs(self.Tabs) do
					tab.bg:Hide()
				end
				done = true
			end
		end)

		styled = true
	end)

	local function hook(object, method, func)
		if type(object) == "string" then
			object = _G[object]
		end
		if object and object[method] then
			hooksecurefunc(object, method, func)
		else
			P.Developer_ThrowError(format("function %s:%s does not exist", object, method))
		end
	end

	hook("AuctionatorConfigurationCopyAndPasteMixin", "OnLoad", reskinCopyAndPaste)
	hook("AuctionatorCraftingInfoFrameMixin", "OnLoad", reskinSearchButton)
	hook("AuctionatorBagUseMixin", "OnLoad", reskinBagUse)
	hook("AuctionatorGroupsViewMixin", "OnLoad", reskinBagView)
	hook("AuctionatorGroupsCustomiseMixin", "OnLoad", reskinBagCustomise)
	hook("AuctionatorGroupsViewItemMixin", "SetItemInfo", reskinBagItemButton)
	hook("AuctionatorGroupsCustomiseGroupMixin", "OnLoad", reskinCustomiseGroup)
end

S:RegisterSkin("Auctionator", S.Auctionator)