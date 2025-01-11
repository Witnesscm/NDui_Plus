local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function updateButtonBorder(button)
	if not button.bg then return end

	button.icon:SetShown(button.index ~= nil)

	if button.selectedTexture:IsShown() then
		button.bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
	else
		button.bg:SetBackdropColor(0, 0, 0, .25)
	end

	if button.DragButton.ActiveTexture:IsShown() then
		button.icon.bg:SetBackdropBorderColor(1, .8, 0)
	else
		button.icon.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local styled
local function ReskinMJEnhanced()
	if styled then return end

	P.WaitFor(function()
		local callbacks = EventRegistry:GetCallbacksByEvent(2, "MountJournal.OnShow")
		return not callbacks["MountJournalEnhanced"]
	end, function()
		for _, child in pairs({_G.MountJournal:GetChildren()}) do
			local objType = child:GetObjectType()
			if objType == "Frame" then
				if child.staticText and child.uniqueCount then
					B.StripTextures(child)
					B.CreateBDFrame(child, .25)
				end
			elseif objType == "Button" then
				if child.texture and child.NormalTexture then
					child:SetPushedTexture(0)
					child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					B.ReskinIcon(child.texture)
					child:SetNormalTexture(0)
				elseif child:GetText() == "!" then
					B.Reskin(child)
				elseif child.Icon and child.Icon:GetAtlas() == "QuestLog-icon-setting" then
					child:DisableDrawLayer("BACKGROUND")
				end
			elseif objType == "CheckButton" and child.Icon then
				child:SetPushedTexture(0)
				child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				B.ReskinIcon(child.Icon)
				child:SetNormalTexture(0)
				child:SetCheckedTexture(DB.pushedTex)
			end
		end

		local SlotButton = _G.MountJournal.SlotButton
		if SlotButton then
			local icon = SlotButton.ItemIcon:GetTexture()
			B.StripTextures(SlotButton)
			SlotButton.bg = B.ReskinIcon(SlotButton.ItemIcon)
			SlotButton.bg:SetInside(nil, 2, 2)
			SlotButton.ItemIcon:SetTexture(icon)
			SlotButton.ItemIcon:SetInside(SlotButton.bg)
			SlotButton:SetPushedTexture(0)
			SlotButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			SlotButton:GetHighlightTexture():SetInside(SlotButton.bg)
		end

		hooksecurefunc("MountJournal_InitMountButton", updateButtonBorder)

		P.ReskinTooltip(_G.MJEMountSpecialButtonToolTip)
		P.ReskinTooltip(_G.MJEStatisticsHelpToolTip)
		P.ReskinTooltip(_G.MJEDisplayHelpToolTip)

		local controlFrame = MountJournal.MountDisplay.ModelScene.ControlFrame
		for _, child in pairs({controlFrame:GetChildren()}) do
			if child.NormalTexture then
				child.NormalTexture:SetAlpha(0)
				child.PushedTexture:SetAlpha(0)
			end
		end
	end)

	styled = true
end

function S:MountJournalEnhanced()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not C_AddOns.IsAddOnLoaded("MountJournalEnhanced") then return end

	_G.MountJournal:HookScript("OnShow", ReskinMJEnhanced)
end

P:AddCallbackForAddon("Blizzard_Collections", S.MountJournalEnhanced)