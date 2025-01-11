local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function changeTextColor(text)
	if text.isSetting then return end
	text.isSetting = true

	local bu = text:GetParent()
	local itemID = bu.itemID

	if PlayerHasToy(itemID) then
		local quality = select(3, C_Item.GetItemInfo(itemID))
		if quality then
			local r, g, b = C_Item.GetItemQualityColor(quality)
			text:SetTextColor(r, g, b)
		else
			text:SetTextColor(1, 1, 1)
		end
	else
		text:SetTextColor(.5, .5, .5)
	end

	text.isSetting = nil
end

local function updateVisibility(_, show)
	local alpha = show and 0 or 1
	_G.ToyBox.iconsFrame:SetAlpha(alpha)
	_G.ToyBox.PagingFrame:SetAlpha(alpha)
end

local t, styled = 0
local function HandleToyBoxEnhanced()
	if t >= 5 or styled then
		return
	end

	if InCombatLockdown() then
		return
	end

	local frame =  _G.ToyBox.EnhancedLayer
	if not frame then
		t = t + 1
		P:Delay(.2, HandleToyBoxEnhanced)
		return
	end

	B.StripTextures(frame)
	updateVisibility(nil, frame:IsShown())
	hooksecurefunc(frame, "SetShown", updateVisibility)
	B.ReskinArrow(frame.PagingFrame.PrevPageButton, "left")
	B.ReskinArrow(frame.PagingFrame.NextPageButton, "right")

	for i = 1, 18 do
		local bu = frame["spellButton"..i]
		local ic = bu.iconTexture

		bu:SetPushedTexture(0)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu:GetHighlightTexture():SetAllPoints(ic)
		bu.cooldown:SetAllPoints(ic)
		bu.slotFrameCollected:SetTexture("")
		bu.slotFrameUncollected:SetTexture("")
		B.ReskinIcon(ic)

		hooksecurefunc(bu.name, "SetTextColor", changeTextColor)
	end

	for _, child in ipairs({_G.ToyBox:GetChildren()}) do
		local objType = child:GetObjectType()
		if objType == "Frame" and child:IsEventRegistered("TOYS_UPDATED") then
			B.StripTextures(child)
			local bg =  B.CreateBDFrame(child, .25)
			bg:SetAllPoints()
		elseif objType == "Button" and child.LockIcon then
			local texture = child.texture:GetTexture()
			B.StripTextures(child)
			child.texture:SetTexture(texture)
			child.texture:SetInside()
			child.bg = B.ReskinIcon(child.texture)
			child:SetPushedTexture(DB.pushedTex)
			child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			child:GetHighlightTexture():SetInside(child.bg)
		elseif objType == "Button" and child.ResetButton and not child.__bg then
			B.ReskinFilterButton(child)
		end
	end

	styled = true
end

function S:ToyBoxEnhanced()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not C_AddOns.IsAddOnLoaded("ToyBoxEnhanced") then return end

	_G.ToyBox:HookScript("OnShow", HandleToyBoxEnhanced)
end

S:RegisterSkin("Blizzard_Collections", S.ToyBoxEnhanced)