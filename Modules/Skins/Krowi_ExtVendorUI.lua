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

local KrowiEVU_Index = _G.BUYBACK_ITEMS_PER_PAGE + 1

function S:ExtVendor_SkinButtons()
	if KrowiEVU_Index <= _G.MERCHANT_ITEMS_PER_PAGE then
		for i = KrowiEVU_Index, _G.MERCHANT_ITEMS_PER_PAGE do
			S:ExtVendor_SkinButton(i)
		end

		KrowiEVU_Index = _G.MERCHANT_ITEMS_PER_PAGE + 1
	end
end

local function HandleFilterButton(self)
	if not self then
		P.Developer_ThrowError("object is nil")
		return
	end

	B.ReskinFilterButton(self)

	if self.__texture then
		self.__texture:SetAlpha(0)
	end
end

function S:Krowi_ExtVendor()
	if not C.db["Skins"]["BlizzardSkins"] then return end


	local KrowiEVU = _G.KrowiEVU_MerchantItemsContainer
	if not KrowiEVU then return end

	HandleFilterButton(_G.KrowiEVU_OptionsButton)
	HandleFilterButton(_G.KrowiEVU_FilterButton)
	S:Proxy("ReskinInput", _G.KrowiEVU_SearchBox)
	S:ExtVendor_SkinButtons()
	hooksecurefunc(KrowiEVU, "LoadMaxNumItemSlots", S.ExtVendor_SkinButtons)
end

S:RegisterSkin("Krowi_ExtendedVendorUI", S.Krowi_ExtVendor)