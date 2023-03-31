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

local function reskinSimplePanel(frame)
	if not frame then P:Debug("Unknown: Panel") return end

	B.StripTextures(frame)
	B.SetBD(frame)

	if frame.ScrollBar then B.ReskinTrimScroll(frame.ScrollBar) end
	if frame.CloseDialog then B.ReskinClose(frame.CloseDialog) end
end

local function reskinInput(editbox)
	if not editbox then P:Debug("Unknown: Input") return end

	P.ReskinInput(editbox, 24)
	editbox.bg:SetPoint("TOPLEFT", -2, 4)
end

local function reskinBagItem(button)
	if not button then P:Debug("Unknown: BagItem") return end

	button.EmptySlot:Hide()
	button:SetPushedTexture(P.ClearTexture)
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
		if buttonPool.creatorFunc then  -- Compatible with old version
			local origFunc = buttonPool.creatorFunc
			buttonPool.creatorFunc = function(self)
				local bu = origFunc(self)
				reskinBagItem(bu)
				return bu
			end
		else
			hooksecurefunc(buttonPool, "Acquire", function(self)
				for bu in self:EnumerateActive() do
					if not bu.styled then
						reskinBagItem(bu)
						bu.styled = true
					end
				end
			end)
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

local function reskinSearchButton(self)
	S:Proxy("Reskin", self.SearchButton)
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
			reskinButtons(ShoppingList, {"Import", "Export", "AddItem", "ManualSearch", "ExportCSV", "SortItems"})
			P.ReskinDropDown(ShoppingList.ListDropdown)
			reskinItemDialog(ShoppingList.itemDialog)
			S:Proxy("StripTextures", ShoppingList.ShoppingResultsInset)

			local exportDialog = ShoppingList.exportDialog
			if exportDialog then
				reskinSimplePanel(exportDialog)
				reskinButtons(exportDialog, {"Export", "SelectAll", "UnselectAll"})

				if exportDialog.AddToPool then -- Compatible with old version
					for _, cb in ipairs(exportDialog.checkBoxPool) do
						S:Proxy("ReskinCheck", cb.CheckBox)
					end

					hooksecurefunc(exportDialog, "AddToPool", function(self)
						S:Proxy("ReskinCheck", self.checkBoxPool[#self.checkBoxPool].CheckBox)
					end)
				else
					hooksecurefunc(exportDialog.checkBoxPool, "Acquire", function(self)
						for frame in self:EnumerateActive() do
							if not frame.styled then
								S:Proxy("ReskinCheck", frame.CheckBox)
								frame.styled = true
							end
						end
					end)
				end

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

			for _, key in ipairs({"ScrollListShoppingList", "ScrollListRecents"}) do
				local scrollList = ShoppingList[key]
				if scrollList and scrollList.ScrollBox then
					B.StripTextures(scrollList)
					B.CreateBDFrame(scrollList.ScrollBox, .25)
					S:Proxy("ReskinTrimScroll", scrollList.ScrollBar)
				end
			end

			local OneItemSearch = ShoppingList.OneItemSearch
			if OneItemSearch then
				reskinButtons(OneItemSearch, {"SearchButton", "ExtendedButton"})
				S:Proxy("ReskinInput", OneItemSearch.SearchBox)
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
				S:Proxy("Reskin", exportCSVDialog.Close)
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
			if BagListing then
				local frameMap = BagListing.frameMap
				if frameMap then
					for _, items in pairs(frameMap) do
						reskinBagList(items)
					end
				end

				S:Proxy("ReskinTrimScroll", BagListing.ScrollBar)
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

			S:Proxy("StripTextures", CancellingFrame.HistoricalPriceInset)
			S:Proxy("ReskinInput", CancellingFrame.SearchFilter)
		end

		local ConfigFrame = _G.AuctionatorConfigFrame
		if ConfigFrame then
			B.StripTextures(ConfigFrame)
			B.CreateBDFrame(ConfigFrame, .25)
			reskinButtons(ConfigFrame, {"ScanButton", "OptionsButton"})

			for _, key in ipairs({"DiscordLink", "BugReportLink", "TechnicalRoadmap"}) do
				local eb = ConfigFrame[key]
				if eb then
					S:Proxy("ReskinInput", eb.InputBox)
				end
			end
		end

		styled = true
	end)

	-- SearchButton
	if _G.AuctionatorCraftingInfoProfessionsFrameMixin then
		hooksecurefunc(_G.AuctionatorCraftingInfoProfessionsFrameMixin, "OnLoad", reskinSearchButton)
	end

	local ObjectiveTrackerFrame = _G.AuctionatorCraftingInfoObjectiveTrackerFrame
	if ObjectiveTrackerFrame then
		reskinSearchButton(ObjectiveTrackerFrame)
	elseif _G.AuctionatorCraftingInfoObjectiveTrackerFrameMixin then
		hooksecurefunc(_G.AuctionatorCraftingInfoObjectiveTrackerFrameMixin, "OnLoad", reskinSearchButton)
	end
end

S:RegisterSkin("Auctionator", S.Auctionator)