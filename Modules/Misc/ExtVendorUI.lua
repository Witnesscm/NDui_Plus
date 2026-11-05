local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")
local S = P:GetModule("Skins")
--------------------------------
-- Credit: Extended Vendor UI
--------------------------------
local OLD_MERCHANT_ITEMS_PER_PAGE = 10

function M:ExtVendor_UpdateMerchantPositions()
	for i = 1, _G.MERCHANT_ITEMS_PER_PAGE do
		local button = _G["MerchantItem"..i]
		button:Show()
		button:ClearAllPoints()

		if (i % OLD_MERCHANT_ITEMS_PER_PAGE) == 1 then
			if (i == 1) then
				button:SetPoint("TOPLEFT", _G.MerchantFrame, "TOPLEFT", 24, -70)
			else
				button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - (OLD_MERCHANT_ITEMS_PER_PAGE - 1))], "TOPRIGHT", 12, 0)
			end
		else
			if (i % 2) == 1 then
				button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 2)], "BOTTOMLEFT", 0, -16)
			else
				button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", 12, 0)
			end
		end
	end

	if not CanMerchantRepair() then
		_G.MerchantSellAllJunkButton:ClearAllPoints()
		_G.MerchantSellAllJunkButton:SetPoint("RIGHT", _G.MerchantBuyBackItem, "LEFT", -36, 0)
	end
end

function M:ExtVendor_UpdateBuybackPositions()
	for i = 1, _G.MERCHANT_ITEMS_PER_PAGE do
		local button = _G["MerchantItem"..i]
		button:ClearAllPoints()

		if i > _G.BUYBACK_ITEMS_PER_PAGE then
			button:Hide()
		else
			if i == 1 then
				button:SetPoint("TOPLEFT", _G.MerchantFrame, "TOPLEFT", 64, -105)
			else
				if (i % 3) == 1 then
					button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 3)], "BOTTOMLEFT", 0, -30)
				else
					button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", 50, 0)
				end
			end
		end
	end
end

function M:ExtVendorUI()
	if C_AddOns.IsAddOnLoaded("Krowi_ExtendedVendorUI") then return end
	if C_AddOns.IsAddOnLoaded("CompactVendor") then return end
	if not M.db["ExtVendorUI"] then return end

	_G.MERCHANT_ITEMS_PER_PAGE = 20
	_G.MerchantFrame:SetWidth(690)

	for i = 1, _G.MERCHANT_ITEMS_PER_PAGE do
		if not _G["MerchantItem" .. i] then
			CreateFrame("Frame", "MerchantItem" .. i, _G.MerchantFrame, "MerchantItemTemplate")
			S:ExtVendor_SkinButton(i)
		end
	end

	_G.MerchantBuyBackItem:ClearAllPoints()
	_G.MerchantBuyBackItem:SetPoint("TOPLEFT", _G.MerchantItem10, "BOTTOMLEFT", 10, -20)
	_G.MerchantPrevPageButton:ClearAllPoints()
	_G.MerchantPrevPageButton:SetPoint("CENTER", _G.MerchantFrame, "BOTTOM", 30, 55)
	_G.MerchantPageText:ClearAllPoints()
	_G.MerchantPageText:SetPoint("BOTTOM", _G.MerchantFrame, "BOTTOM", 160, 50)
	_G.MerchantNextPageButton:ClearAllPoints()
	_G.MerchantNextPageButton:SetPoint("CENTER", _G.MerchantFrame, "BOTTOM", 290, 55)

	hooksecurefunc("MerchantFrame_UpdateMerchantInfo", M.ExtVendor_UpdateMerchantPositions)
	hooksecurefunc("MerchantFrame_UpdateBuybackInfo", M.ExtVendor_UpdateBuybackPositions)
end

M:RegisterPreload("ExtVendorUI", M.ExtVendorUI)