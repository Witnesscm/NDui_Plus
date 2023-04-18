local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:ExtVendor_SkinButton(i)
	local item = _G["MerchantItem"..i]
	local name = item.Name
	local button = item.ItemButton
	local icon = button.icon
	local moneyFrame = _G["MerchantItem"..i.."MoneyFrame"]

	B.StripTextures(item)
	B.CreateBDFrame(item, .25)

	B.StripTextures(button)
	button:ClearAllPoints()
	button:SetPoint("LEFT", item, 4, 0)
	local hl = button:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside()

	icon:SetInside()
	button.bg = B.ReskinIcon(icon)
	B.ReskinIconBorder(button.IconBorder)
	button.IconOverlay:SetInside()
	button.IconOverlay2:SetInside()

	name:SetFontObject(Number12Font)
	name:SetPoint("LEFT", button, "RIGHT", 2, 9)
	moneyFrame:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)

	for j = 1, 3 do
		local currency = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j]
		local texture = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j.."Texture"]
		currency:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
		B.ReskinIcon(texture)
	end
end

function S:ExtVendor_SkinButtons()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	for i = _G.BUYBACK_ITEMS_PER_PAGE + 1, _G.MERCHANT_ITEMS_PER_PAGE do
		S:ExtVendor_SkinButton(i)
	end
end

function S:ExtVendor()
	if not S.db["ExtVendor"] then return end

	-- MerchantFrame
	B.Reskin(MerchantFrameFilterButton)
	B.ReskinInput(MerchantFrameSearchBox)

	MerchantFrameSellJunkButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	MerchantFrameSellJunkButton:SetPushedTexture(0)
	B.ReskinIcon(MerchantFrameSellJunkButtonIcon)
	S:ExtVendor_SkinButtons()

	-- ExtVendor_QVConfigFrame
	P.ReskinFrame(ExtVendor_QVConfigFrame)
	ExtVendor_QVConfigFrameDarkenBG:SetAlpha(0)
	B.Reskin(ExtVendor_QVConfigFrame_OptionContainer_SaveButton)

	local checks = {"EnableButton", "SuboptimalArmor", "AlreadyKnown", "UnusableEquip", "WhiteGear", "OutdatedGear", "OutdatedFood"}
	for _, check in pairs(checks) do
		B.ReskinCheck(_G["ExtVendor_QVConfigFrame_OptionContainer_"..check])
	end

	local buttons = {"RemoveFromBlacklistButton", "ResetBlacklistButton", "RemoveFromGlobalWhitelistButton", "ClearGlobalWhitelistButton", "RemoveFromLocalWhitelistButton", "ClearLocalWhitelistButton", "ItemDropBlacklistButton", "ItemDropGlobalWhitelistButton", "ItemDropLocalWhitelistButton"}
	for _, button in pairs(buttons) do
		B.Reskin(_G["ExtVendor_QVConfigFrame_"..button])
	end

	local frames = {"Blacklist", "GlobalWhitelist", "LocalWhitelist"}
	for _, frame in pairs(frames) do
		local frame1 = _G["ExtVendor_QVConfigFrame_"..frame]
		local frame2 = _G["ExtVendor_QVConfigFrame_"..frame.."ItemList"]
		B.StripTextures(frame1)
		local bg = B.CreateBDFrame(frame1, 0)
		bg:SetOutside(frame2)

		local scrollBar = _G["ExtVendor_QVConfigFrame_"..frame.."ItemListScrollBar"]
		B.ReskinScroll(scrollBar)
		scrollBar.trackBG:SetAlpha(0)
	end

	B.StripTextures(ExtVendor_SellJunkPopup)
	B.SetBD(ExtVendor_SellJunkPopup)
	ExtVendor_SellJunkPopupBG2:SetAlpha(0)
	B.Reskin(ExtVendor_SellJunkPopupYesButton)
	B.Reskin(ExtVendor_SellJunkPopupNoButton)
	B.Reskin(ExtVendor_SellJunkPopupDebugButton)
	B.StripTextures(ExtVendor_SellJunkPopup_JunkList)
	B.CreateBDFrame(ExtVendor_SellJunkPopup_JunkList, .25)
	B.ReskinScroll(ExtVendor_SellJunkPopup_JunkListItemListScrollBar)
	ExtVendor_SellJunkPopup_JunkListItemListScrollBar.trackBG:SetAlpha(0)
end

S:RegisterSkin("ExtVendor", S.ExtVendor)