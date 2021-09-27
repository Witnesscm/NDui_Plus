local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function reskinView(self)
	for i = 1, #self._buttons do
		local button = self:GetButton(i)
		if not button.styled and button:IsShown() then
			B.StripTextures(button, 0)
			P.SetupBackdrop(button)
			B.CreateBD(button, .25)

			button:SetHighlightTexture(DB.bdTex)
			local hl = button:GetHighlightTexture()
			hl:SetVertexColor(DB.r, DB.g, DB.b, .25)
			hl:SetInside()

			if button.Icon then button.Icon:SetAlpha(1) end
			if button.Checked then button.Checked:SetAlpha(1) end
			if button.Highlight then button.Highlight:SetTexture(nil) end

			button.styled = true
		end
	end
end

function S:tdGUI()
	local GUI = _G.LibStub and _G.LibStub("tdGUI-1.0", true)
	if not GUI then return end

	local DropMenu = GUI:GetClass("DropMenu")
	if DropMenu then
		hooksecurefunc(DropMenu, "Constructor", P.ReskinTooltip)
		hooksecurefunc(DropMenu, "Toggle", P.ReskinTooltip)
	end

	local GridView = GUI:GetClass("GridView")
	if GridView then
		hooksecurefunc(GridView, "UpdateItems", reskinView)
	end

	local ListView = GUI:GetClass("ListView")
	if ListView then
		hooksecurefunc(ListView, "UpdateItems", reskinView)
	end
end

S:RegisterSkin("tdGUI")