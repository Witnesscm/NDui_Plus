local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local M = B:GetModule("Misc")

local _G = getfenv(0)
local ipairs = ipairs

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
	local UIEquipItem = tdInspect:GetClass("UI.EquipItem")

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
			if slot.subicon then
				slot.subicon:ClearAllPoints()
				slot.subicon:SetPoint("TOPRIGHT", -C.mult, -C.mult)
				slot.subicon:SetTexCoord(unpack(DB.TexCoord))
				slot.iconbg = B.CreateBDFrame(slot.subicon, 0)
				slot.iconbg:SetFrameLevel(slot.iconbg:GetFrameLevel() + 3)
			end
		end

		for _, item in pairs(PaperDoll.EquipFrame.buttons) do
			P.ReskinFont(item.Name)
			if item.RuneIcon then
				item.RuneIcon:SetSize(16, 16)
				item.iconbg = B.ReskinIcon(item.RuneIcon)
			end
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

		if self.LevelText then
			self.LevelText:SetText("")
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
				if C.db["Misc"]["ShowItemLevel"] and level and level > 1 and quality > 1 and self.iLvlText then
					self.iLvlText:SetText(level)
					self.iLvlText:SetTextColor(color.r, color.g, color.b)
				end
			end
		else
			SetItemButtonTexture(self, "")
		end

		if self.iconbg then
			self.iconbg:SetShown(not not self.subicon and self.subicon:IsShown())
		end
	end)

	hooksecurefunc(UIEquipItem, "Update", function(self)
		if not self.iconbg then return end
		self.iconbg:SetShown(not not self.RuneIcon and self.RuneIcon:IsShown())
	end)

	local anchored
	hooksecurefunc(UIInspectFrame, "OnShow", function()
		if anchored then return end

		_G.InspectModelFrameRotateRightButton:Hide()
		_G.InspectModelFrameRotateLeftButton:Hide()

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