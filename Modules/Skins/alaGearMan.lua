local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local cr, cg, cb = DB.r, DB.g, DB.b

local texture_delete = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
local texture_modify = "Interface\\WorldMap\\GEAR_64GREY"

local arrowTex = {
	["up"] = P.ArrowUp,
	["down"] = P.ArrowDown,
}

local function setupArrowTex(self, direction)
	self:SetNormalTexture(arrowTex[direction])
	self:SetPushedTexture(arrowTex[direction])
	self:SetDisabledTexture(arrowTex[direction])
	self:GetNormalTexture():SetTexCoord(6 / 32, 25 / 32, 7 / 32, 24 / 32)
	self:GetPushedTexture():SetTexCoord(6 / 32, 25 / 32, 7 / 32, 24 / 32)
	self:GetDisabledTexture():SetTexCoord(6 / 32, 25 / 32, 7 / 32, 24 / 32)
end

local function reskinGearManButton(self)
	B.StripTextures(self)
	self.__bg = B.CreateBDFrame(self, .25)
	self.__bg:SetAllPoints()
	self:SetHighlightTexture(DB.bdTex)
	self:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
	self:GetHighlightTexture():SetInside()

	self.delete:SetNormalTexture(texture_delete)
	self.delete:SetPushedTexture(texture_delete)
	self.modify:SetNormalTexture(texture_modify)
	self.modify:SetPushedTexture(texture_modify)
	self.modify:SetSize(self.delete:GetWidth() + 2, self.delete:GetHeight() + 2)
	self.modify:SetPoint("BOTTOMRIGHT", -3.2, 2)
	setupArrowTex(self.up, "up")
	setupArrowTex(self.down, "down")
	self.helmet:SetSize(16, 16)
	B.ReskinRadio(self.helmet)
	self.cloak:SetSize(16, 16)
	B.ReskinRadio(self.cloak)

	self.glow_current:SetTexture(DB.bdTex)
	self.glow_current:SetVertexColor(cr, cg, cb, .25)
	self.glow_current:SetInside()

	hooksecurefunc(self, "Select", function()
		self.__bg:SetBackdropBorderColor(1, 1, 1, 1)
	end)
	hooksecurefunc(self, "Deselect", function()
		B.SetBorderColor(self.__bg)
	end)
end

local function hook_SetNormalTexture(self, texture)
	if self.settingTexture then return end
	self.settingTexture = true
	self:SetNormalTexture(0)

	if texture and texture ~= "" then
		self.Icon:SetTexture(texture)
		self.bg:Show()
	else
		self.bg:Hide()
	end
	self.settingTexture = nil
end

local function hook_SetVertexColor(self, r, g, b)
	self:GetParent().bg:SetBackdropBorderColor(r, g, b)
end
local function hook_Hide(self)
	self:GetParent().bg:SetBackdropBorderColor(0, 0, 0)
end

local function reskinPDFbutton(self)
	self.bg = B.CreateBDFrame(self)
	self.bg:SetAllPoints()

	self.Icon = self:CreateTexture(nil, "ARTWORK")
	self.Icon:SetInside()
	self.Icon:SetTexCoord(unpack(DB.TexCoord))

	hooksecurefunc(self, "SetNormalTexture", hook_SetNormalTexture)
	self:SetPushedTexture(0)
	self.SetPushedTexture = B.Dummy
	self:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

	self.glow:SetAlpha(0)
	hooksecurefunc(self.glow, "SetVertexColor", hook_SetVertexColor)
	hooksecurefunc(self.glow, "Hide", hook_Hide)
end

function S:alaGearMan()
	if not S.db["alaGearMan"] then return end

	local alaGear = _G.__ala_meta__ and _G.__ala_meta__.gear
	if not alaGear then return end

	local func = alaGear.func
	local ui = alaGear.ui

	local origCreateButton = func.gm_CreateButton
	func.gm_CreateButton = function(...)
		local button = origCreateButton(...)
		reskinGearManButton(button)

		return button
	end

	hooksecurefunc(func, "initUI", function()
		-- open
		local open = ui.open
		open:SetSize(24, 30)
		open:SetPoint("TOPRIGHT", -40, -40)
		B.Reskin(open)
		open.Icon = open:CreateTexture(nil, "ARTWORK")
		open.Icon:SetPoint("CENTER")
		open.Icon:SetSize(28, 28)
		open.Icon:SetTexture([[Interface\AddOns\NDui_Plus\Media\Texture\ui-gear]])
		open:HookScript("OnMouseDown", function(self)
			self.Icon:SetPoint("CENTER", self, "CENTER", 1, -1)
		end)
		open:HookScript("OnMouseUp", function(self)
			self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0)
		end)

		-- gearWin
		local gearWin = ui.gearWin
		B.StripTextures(gearWin)
		P.RemoveBD(gearWin)
		gearWin:ClearAllPoints()
		gearWin:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", -32, -15-C.mult)

		local bg = CreateFrame("Frame", nil, gearWin)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("TOPRIGHT")
		bg:SetHeight(422)
		bg:EnableMouse(true)
		bg:SetFrameLevel(gearWin:GetFrameLevel() - 1)
		B.SetBD(bg)

		ui.setting:SetNormalTexture(texture_modify)
		ui.setting:SetPushedTexture(texture_modify)
		ui.setting:GetPushedTexture():SetVertexColor(0.25, 0.25, 0.25, 1.0)
	end)

	hooksecurefunc(func, "pdf_CreateButton", function(index)
		local button = ui.pdf_buttons[index]
		if button then
			reskinPDFbutton(button)
		end
	end)
end

S:RegisterSkin("alaGearMan", S.alaGearMan)