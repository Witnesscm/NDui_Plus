local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local r, g, b = DB.r, DB.g, DB.b

local _G = getfenv(0)

function S:SkinDropDownMenu(frameName)
	local listFrame = _G[frameName]
	if not listFrame then
		P.Developer_ThrowError(format("%s is nil", frameName))
		return
	end

	if not listFrame.__bg then
		listFrame.__bg = B.SetBD(listFrame, .7)
	end

	for _, key in pairs({"Backdrop", "MenuBackdrop", "Border"}) do
		local backdrop = listFrame[key] or _G[frameName..key]
		if backdrop and not backdrop.__styled then
			backdrop:Hide()
			backdrop.Show = B.Dummy

			backdrop.__styled = true
		end
	end

	local maxButtons = _G.L_UIDROPDOWNMENU_MAXBUTTONS
	for i = 1, maxButtons do
		local bu = _G[frameName.."Button"..i]
		local _, _, _, x = bu:GetPoint()
		if bu:IsShown() and x then
			local check = _G[frameName.."Button"..i.."Check"]
			local uncheck = _G[frameName.."Button"..i.."UnCheck"]
			local hl = _G[frameName.."Button"..i.."Highlight"]
			local arrow = _G[frameName.."Button"..i.."ExpandArrow"]

			if not bu.bg then
				bu.bg = B.CreateBDFrame(bu)
				bu.bg:ClearAllPoints()
				bu.bg:SetPoint("CENTER", check)
				bu.bg:SetSize(12, 12)
				hl:SetColorTexture(r, g, b, .25)

				local arrowTex = arrow:GetNormalTexture() or arrow:GetRegions()
				if arrow and arrowTex then
					B.SetupArrow(arrowTex, "right")
					arrow:SetSize(14, 14)
				end
			end

			bu.bg:Hide()
			hl:SetPoint("TOPLEFT", -x + C.mult, 0)
			hl:SetPoint("BOTTOMRIGHT", listFrame:GetWidth() - bu:GetWidth() - x - C.mult, 0)
			if uncheck then uncheck:SetTexture("") end

			if not bu.notCheckable then
				local _, co = check:GetTexCoord()
				if co == 0 then
					check:SetAtlas("checkmark-minimal")
					check:SetVertexColor(r, g, b, 1)
					check:SetSize(20, 20)
					check:SetDesaturated(true)
				else
					check:SetColorTexture(r, g, b, .6)
					check:SetSize(10, 10)
					check:SetDesaturated(false)
				end

				check:SetTexCoord(0, 1, 0, 1)
				bu.bg:Show()
			end
		end
	end
end

local function Line_SetRadioState(self, state)
	local check = self.Radio
	check.state = state
	check:SetColorTexture(r, g, b, .6)
	check:SetSize(10, 10)
	check:SetDesaturated(false)
	check:SetShown(not not state)
end

local function Line_SetCheckedState(self, state)
	local check = self.Radio
	check:SetAtlas("checkmark-minimal")
	check:SetTexCoord(0, 1, 0, 1)
	check:SetVertexColor(r, g, b, 1)
	check:SetSize(20, 20)
	check:SetDesaturated(true)
	check:SetShown(not not state)
end

local function reskinDropDown(self)
	if self.Backdrop and not self.styled then
		self.Backdrop:SetBackdrop(nil)
		self.Backdrop.SetBackdrop = B.Dummy
		self.__bg = B.SetBD(self, .7)
		self.__bg:SetFrameLevel(self:GetFrameLevel() + 1)
		self.__bg:SetInside(self.Backdrop)

		self.styled = true
	end

	for _, line in ipairs(self.lines) do
		if not line.styled then
			local hl = line.Highlight
			hl:SetColorTexture(r, g, b, .25)
			hl:ClearAllPoints()
			hl:SetPoint("TOPLEFT", -16, 0)
			hl:SetPoint("BOTTOMRIGHT", 16, 0)

			local arrow = line.Expand
			B.SetupArrow(arrow, "right")

			local check = line.Radio
			check.bg = B.CreateBDFrame(check)
			check.bg:ClearAllPoints()
			check.bg:SetPoint("CENTER", check)
			check.bg:SetSize(12, 12)

			line.SetRadioState = Line_SetRadioState
			line.SetCheckedState = Line_SetCheckedState

			line.styled = true
		end

		line.Radio.bg:SetShown(not not line.checked)
	end
end

function S:LibUIDropDownMenu()
	-- LibUIDropDownMenu-4.0
	local LibUIDropDownMenu = LibStub("LibUIDropDownMenu-4.0", true)
	if LibUIDropDownMenu then
		hooksecurefunc(LibUIDropDownMenu, "ToggleDropDownMenu", function(_, level)
			S:SkinDropDownMenu("L_DropDownList"..(level or 1))
		end)
	end

	-- LibUIDropDownMenu-2.0
	if _G.L_ToggleDropDownMenu then
		hooksecurefunc(_G, "L_ToggleDropDownMenu", function(level)
			S:SkinDropDownMenu("L_DropDownList"..(level or 1))
		end)
	end

	-- LibDropDownMenu
	local LibDropDownMenu = LibStub("LibDropDownMenu", true)
	if LibDropDownMenu then
		hooksecurefunc(LibDropDownMenu, "ToggleDropDownMenu", function(_, level)
			S:SkinDropDownMenu("LibDropDownMenu_List"..(level or 1))
		end)
	end

	-- LibDropDown
	local LibDropDown = LibStub("LibDropDown", true)
	if LibDropDown then
		hooksecurefunc(LibDropDown, "CloseAll", function(self)
			for menu in pairs(self.dropdowns) do
				reskinDropDown(menu)
			end
		end)
	end
end

S:RegisterSkin("LibUIDropDownMenu")