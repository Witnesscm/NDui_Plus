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

local function GetILvlTextColor(level)
	if level >= 150 then
		return 1, .5, 0
	elseif level >= 115 then
		return .63, .2, .93
	elseif level >= 80 then
		return 0, .43, .87
	elseif level >= 45 then
		return .12, 1, 0
	else
		return 1, 1, 1
	end
end

local function GetItemSlotLevel(itemLink)
	local level
	if itemLink then
		level = select(4, C_Item.GetItemInfo(itemLink))
	end
	return tonumber(level) or 0
end

function S:tdInspect()
	if not S.db["tdInspect"] then return end

	local tdInspect = LibStub("AceAddon-3.0"):GetAddon("tdInspect")
	local Inspect = tdInspect:GetModule("Inspect")
	local UITalentFrame = tdInspect:GetClass("UI.TalentFrame")
	local UISlotItem = tdInspect:GetClass("UI.SlotItem")
	local UIInspectFrame = tdInspect:GetClass("UI.InspectFrame")
	local UIPaperDoll = tdInspect:GetClass("UI.PaperDoll")

	hooksecurefunc(tdInspect, "SetupUI", function()
		B.ReskinCheck(InspectPaperDollFrame.ToggleButton)
		InspectPaperDollFrame.RaceBackground:SetAlpha(0)
		InspectPaperDollFrame.LastUpdate:ClearAllPoints()
		InspectPaperDollFrame.LastUpdate:SetPoint("BOTTOMLEFT", InspectPaperDollFrame, "BOTTOMRIGHT", -130, 80) 

		local slots = {
			"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
			"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
			"SecondaryHand", "Tabard", "Ranged",
		}

		for i = 1, #slots do
			local slot = _G["Inspect"..slots[i].."Slot"]

			slot.IconBorder:SetTexture("")
			slot:DisableDrawLayer("BACKGROUND")

			if slot.RuneIcon then
				local bg = B.ReskinIcon(slot.RuneIcon)
				bg:SetFrameLevel(4)
			end
		end

		M:CreateItemString(_G.InspectFrame, "Inspect")

		local talentFrame = _G.InspectFrame.TalentFrame
		B.StripTextures(talentFrame)

		for i, tab in ipairs(talentFrame.Tabs) do
			if i == 1 then
				tab:SetPoint("TOPLEFT", 70, -45)
			end
			B.ReskinTab(tab)
		end

		local scrollBar = talentFrame.TalentFrame.ScrollBar
		if scrollBar then
			B.ReskinScroll(scrollBar)
		end

		local bottomFrame = talentFrame.Summary and talentFrame.Summary:GetParent()
		if bottomFrame then
			B.StripTextures(bottomFrame)
		end

		local equipButtons = InspectPaperDollFrame.EquipFrame.buttons
		for _, item in pairs(equipButtons) do
			P.ReskinFont(item.Name)
		end
	end)

	hooksecurefunc(UIInspectFrame, "AddTab", function(self)
		B.ReskinTab(_G["InspectFrameTab".. _G.InspectFrame.numTabs])
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
			if quality then
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

	local done
	hooksecurefunc(UITalentFrame, "Update", function()
		if done then return end
		for _, button in ipairs(_G.InspectFrame.TalentFrame.TalentFrame.buttons) do
			B.StripTextures(button, 1)
			B.ReskinIcon(button.icon)
			local hl = button:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .25)
		end
		done = true
	end)

	local anchored
	hooksecurefunc(UIInspectFrame, "OnShow", function()
		if anchored then return end

		InspectModelFrameRotateRightButton:Hide()
		InspectModelFrameRotateLeftButton:Hide()

		anchored = true
	end)

	-- Inspect iLvl
	hooksecurefunc(UIPaperDoll, "Update", function()
		if not M.InspectILvl then return end

		local total, level = 0
		for index = 1, 15 do
			if index ~= 4 then
				level = GetItemSlotLevel(Inspect:GetItemLink(index))
				if level > 0 then
					total = total + level
				end
			end
		end

		local mainhand = GetItemSlotLevel(Inspect:GetItemLink(16))
		local offhand = GetItemSlotLevel(Inspect:GetItemLink(17))
		local ranged = GetItemSlotLevel(Inspect:GetItemLink(18))

		if mainhand > 0 and offhand > 0 then
			total = total + mainhand + offhand
		elseif offhand > 0 and ranged > 0 then
			total = total + offhand + ranged
		else
			total = total + max(mainhand, offhand, ranged) * 2
		end

		local average = B:Round(total/16, 1)
		M.InspectILvl:SetText(average)
		M.InspectILvl:SetTextColor(GetILvlTextColor(average))
		M.InspectILvl:SetFormattedText("iLvl %s", M.InspectILvl:GetText())
	end)
end

S:RegisterSkin("tdInspect", S.tdInspect)