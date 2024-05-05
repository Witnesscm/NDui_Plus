local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local M = B:GetModule("Misc")

local _G = getfenv(0)
local ipairs = ipairs

local gemSlotBlackList = {
	[16]=true, [17]=true, [18]=true,
}

local tip = B.ScanTip

function S:ItemLevel_UpdateGemInfo(link, index, slotFrame, refresh)
	if P.IsClassic() or not C.db["Misc"]["GemNEnchant"] or gemSlotBlackList[index] then return end

	tip:SetOwner(UIParent, "ANCHOR_NONE")
	tip:SetHyperlink(link)

	if not tip.slotInfo then tip.slotInfo = {} else wipe(tip.slotInfo) end

	tip.slotInfo.gems = B:InspectItemTextures()

	if next(tip.slotInfo.gems) then
		local gemStep = 1
		for i = 1, 5 do
			local texture = slotFrame["textureIcon"..i]
			local bg = texture.bg
			local gem = tip.slotInfo.gems[gemStep]
			if gem then
				texture:SetTexture(gem)
				bg:SetBackdropBorderColor(0, 0, 0)
				bg:Show()

				gemStep = gemStep + 1
			end
		end

		if not refresh then
			P:Delay(.1, S.ItemLevel_UpdateGemInfo, self, link, index, slotFrame, true)
		end
	end
end

function S:tdInspect()
	if not S.db["tdInspect"] then return end

	local tdInspect = LibStub("AceAddon-3.0"):GetAddon("tdInspect")
	local Inspect = tdInspect:GetModule("Inspect")
	local UITalentFrame = tdInspect:GetClass("UI.TalentFrame")
	local UISlotItem = tdInspect:GetClass("UI.SlotItem")
	local UIInspectFrame = tdInspect:GetClass("UI.InspectFrame")

	hooksecurefunc(tdInspect, "SetupUI", function(self)
		local InspectFrame = self.InspectFrame
		M:CreateItemString(InspectFrame, "Inspect")

		for i, tab in pairs(InspectFrame.groupTabs) do
			if i == 1 then
				tab:SetPoint("TOPLEFT", InspectFrame, "TOPRIGHT", -34, -65)
			end
			B.StripTextures(tab)
			B.ReskinIcon(tab.nt)
			tab.ct:SetTexture(DB.pushedTex)
			tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			tab:HookScript("OnEnter", function()
				GameTooltip:Show() -- fix
			end)
		end

		local PaperDoll = InspectFrame.PaperDoll
		B.ReskinCheck(PaperDoll.ToggleButton)
		PaperDoll.RaceBackground:SetAlpha(0)
		PaperDoll.LastUpdate:ClearAllPoints()
		PaperDoll.LastUpdate:SetPoint("BOTTOMLEFT", PaperDoll, "BOTTOMRIGHT", -130, 80)

		for _, slot in pairs(PaperDoll.buttons) do
			slot.IconBorder:SetTexture("")
			slot:DisableDrawLayer("BACKGROUND")
		end

		for _, item in pairs(PaperDoll.EquipFrame.buttons) do
			P.ReskinFont(item.Name)
		end

		local TalentFrame = InspectFrame.TalentFrame
		B.StripTextures(TalentFrame)

		local ScrollBar = TalentFrame.TalentFrame.ScrollBar
		if ScrollBar then
			B.ReskinScroll(ScrollBar)
		end

		local SummaryBG = TalentFrame.Summary and TalentFrame.Summary:GetParent()
		if SummaryBG then
			B.StripTextures(SummaryBG)
		end

		for i, tab in ipairs(TalentFrame.Tabs) do
			if i == 1 then
				tab:SetPoint("TOPLEFT", 70, -45)
			end
			B.ReskinTab(tab)
		end

		local GlyphFrame = InspectFrame.GlyphFrame
		B.StripTextures(GlyphFrame)
	end)

	hooksecurefunc(UIInspectFrame, "AddTab", function(self)
		B.ReskinTab(_G["InspectFrameTab".. self.numTabs])
	end)

	hooksecurefunc(UITalentFrame, "GetTalentButton", function(self, i)
		local button = self.buttons[i]
		if button and not button.styled then
			B.StripTextures(button, 1)
			B.ReskinIcon(button.icon)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			button.styled = true
		end
	end)

	hooksecurefunc(UISlotItem, "Update", function(self)
		if self.iLvlText then
			self.iLvlText:SetText("")
		end

		for i = 1, 5 do
			local texture = self["textureIcon"..i]
			if texture then
				texture:SetTexture(nil)
				texture.bg:Hide()
			end
		end

		M:ItemBorderSetColor(self, 0, 0, 0)

		local slot = self:GetID()
		local item = Inspect:GetItemLink(slot)
		if item then
			local quality, level = select(3, C_Item.GetItemInfo(item))
			if quality and quality > 1 then
				local color = DB.QualityColors[quality]
				M:ItemBorderSetColor(self, color.r, color.g, color.b)
				if C.db["Misc"]["ShowItemLevel"] and level and level > 1 and self.iLvlText then
					self.iLvlText:SetText(level)
					self.iLvlText:SetTextColor(color.r, color.g, color.b)
				end

				S:ItemLevel_UpdateGemInfo(item, slot, self)
			end
		else
			SetItemButtonTexture(self, "")
		end
	end)

	local anchored
	hooksecurefunc(UIInspectFrame, "OnShow", function()
		if anchored then return end

		_G.InspectModelFrameRotateRightButton:Hide()
		_G.InspectModelFrameRotateLeftButton:Hide()

		anchored = true
	end)
end

S:RegisterSkin("tdInspect", S.tdInspect)