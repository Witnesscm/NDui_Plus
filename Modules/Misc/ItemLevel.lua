local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

function M:UpdateItemlevel(button, link)
	if not button.iLvl then
		button.iLvl = B.CreateFS(button, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
	end
	button.iLvl:SetText("")

	if link then
		local name, _, rarity, level, _, _, _, _, _, _, _, classID = GetItemInfo(link)
		if name and level and rarity > 1 and (classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR) then
			local color = DB.QualityColors[rarity]
			button.iLvl:SetText(B.GetItemLevel(link))
			button.iLvl:SetTextColor(color.r, color.g, color.b)
		end
	end
end

function M:Hook_UpdateMerchantInfo()
	local numItems = GetMerchantNumItems()
	for i = 1, MERCHANT_ITEMS_PER_PAGE do
		local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + i
		if index > numItems then break end

		local button = _G["MerchantItem"..i.."ItemButton"]
		if button and button:IsShown() then
			M:UpdateItemlevel(button, GetMerchantItemLink(index))
		end
	end

	M:UpdateItemlevel(_G.MerchantBuyBackItemItemButton, GetBuybackItemLink(GetNumBuybackItems()))
end

function M:Hook_UpdateBuybackInfo()
	local numItems = GetNumBuybackItems()
	for index = 1, BUYBACK_ITEMS_PER_PAGE do
		if index > numItems then break end

		local button = _G["MerchantItem"..index.."ItemButton"]
		if button and button:IsShown() then
			M:UpdateItemlevel(button, GetBuybackItemLink(index))
		end
	end
end

function M:MerchantItemlevel()
	if not M.db["MerchantItemlevel"] then return end

	if IsAddOnLoaded("ExtVendor") then
		hooksecurefunc("ExtVendor_UpdateMerchantInfo", M.Hook_UpdateMerchantInfo)
		hooksecurefunc("ExtVendor_UpdateBuybackInfo", M.Hook_UpdateBuybackInfo)
	else
		hooksecurefunc("MerchantFrame_UpdateMerchantInfo", M.Hook_UpdateMerchantInfo)
		hooksecurefunc("MerchantFrame_UpdateBuybackInfo", M.Hook_UpdateBuybackInfo)
	end
end

M:RegisterMisc("MerchantItemlevel", M.MerchantItemlevel)