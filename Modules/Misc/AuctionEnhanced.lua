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
		local stats = C_Item.GetItemStats(link)
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

function M:Auction_ItemStats()
	hooksecurefunc(_G.AuctionHouseTableExtraInfoMixin, "Populate", function(self, rowData)
		if not self.stats then
			self.stats = CreateStatsText(self)
			self.stats:SetPoint("LEFT", self, "RIGHT")
		end

		local itemLink = rowData and rowData.itemLink
		self.stats:SetText(itemLink and GetStatsString(itemLink) or "")
	end)
end

function M:AuctionEnhanced()
	if not M.db["AuctionEnhanced"] then return end

	M:Auction_ItemStats()
end

P:AddCallbackForAddon("Blizzard_AuctionHouseUI", M.AuctionEnhanced)