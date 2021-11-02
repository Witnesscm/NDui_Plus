local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local pairs = pairs
local format = string.format

local function CreateStatsText(self)
	local fs = B.CreateFS(self, 12, "")
	fs:SetTextColor(.12, 1, 0)
	fs:ClearAllPoints()

	return fs
end

local statWatchList = {
	["ITEM_MOD_CR_AVOIDANCE_SHORT"] = true,		-- Avoidance
	["ITEM_MOD_CR_LIFESTEAL_SHORT"] = true,		-- Leech
	["ITEM_MOD_CR_SPEED_SHORT"] = true,			-- Speed
}

local itemCache = {}
local function GetStatsString(link)
	if not itemCache[link] then
		local text = ""
		local stats = GetItemStats(link)
		if stats then
			for stat in pairs(stats) do
				if statWatchList[stat] then
					text = text..format("%s ", _G[stat])
				end
			end
		end

		itemCache[link] = text
	end

	return itemCache[link]
end

local function ItemBuyFrame_UpdateRows(self, _, count)
	for rowIndex = 1, count do
		local row = self:GetRowByIndex(rowIndex)
		if row and row.rowData and row.cells and row.cells[4] then
			if not row.stats then
				row.stats = CreateStatsText(row)
				row.stats:SetPoint("LEFT", row.cells[4], "RIGHT")
			end

			local itemLink = row.rowData.itemLink
			row.stats:SetText(itemLink and GetStatsString(itemLink) or "")
		end
	end
end

function M:Auction_ItemStats()
	local done
	hooksecurefunc(AuctionHouseFrame.ItemBuyFrame.ItemList, "Init", function(self)
		if done then return end

		if self.tableBuilder then
			hooksecurefunc(self.tableBuilder, "Populate", ItemBuyFrame_UpdateRows)
		end

		done = true
	end)
end

function M:AuctionEnhanced()
	if not M.db["AuctionEnhanced"] then return end

	M:Auction_ItemStats()
end

P:AddCallbackForAddon("Blizzard_AuctionHouseUI", M.AuctionEnhanced)