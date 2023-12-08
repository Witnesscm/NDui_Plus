local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local r, g, b = DB.r, DB.g, DB.b

function S:tdGUI()
	local GUI = _G.LibStub and _G.LibStub("tdGUI-1.0", true)
	if not GUI then return end

	local DropMenu = GUI:GetClass("DropMenu")
	if DropMenu then
		hooksecurefunc(DropMenu, "Open", function(self, level, ...)
			level = level or 1
			local menu = self.menuList[level]
			if menu then
				if not menu.styled then
					P.ReskinTooltip(menu)

					local scrollBar = menu.scrollBar or menu.ScrollBar
					if scrollBar then
						B.ReskinScroll(scrollBar)
					end

					menu.styled = true
				end
			end
		end)

		hooksecurefunc(DropMenu, "UpdateItems", function(self)
			for i = 1, #self._buttons do
				local bu = self:GetButton(i)
				local left, right = self:GetPadding()
				if bu:IsShown() and left and right then
					local hl = bu:GetHighlightTexture()

					if not bu.styled then
						hl:SetColorTexture(r, g, b, .25)
						bu.styled = true
					end

					hl:SetPoint("TOPLEFT", -left + C.mult, 0)
					hl:SetPoint("BOTTOMRIGHT", right - self:GetScrollBarFixedWidth()- C.mult, 0)
				end
			end
		end)
	end

	local DropMenuItem = GUI:GetClass("DropMenuItem")
	if DropMenuItem then
		hooksecurefunc(DropMenuItem, "SetHasArrow", function(self)
			B.SetupArrow(self.Arrow, "right")
			self.Arrow:SetSize(14, 14)
		end)

		hooksecurefunc(DropMenuItem, "SetCheckState", function(self, checkable, _, checked)
			local check = self.CheckBox

			if not self.bg then
				self.bg = B.CreateBDFrame(self)
				self.bg:ClearAllPoints()
				self.bg:SetPoint("CENTER", check)
				self.bg:SetSize(12, 12)

				check:SetTexture(DB.bdTex)
				check:SetVertexColor(r, g, b, .6)
				check:SetSize(10, 10)
			end

			self.bg:Hide()

			if checkable then
				if checked then
					check:Show()
				else
					check:Hide()
				end
				self.bg:Show()
			end
		end)
	end
end

S:RegisterSkin("tdGUI")