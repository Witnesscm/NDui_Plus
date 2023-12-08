local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local select = select

local function loadFunc()
	P:Delay(.5, function()
		local bu = _G.PlayerTalentFrame.__TalentEmuCall
		if bu then
			B.Reskin(bu)
			bu:SetPoint("RIGHT", _G.PlayerTalentFrameCloseButton, "LEFT", -22, 0)
		end
	end)
end
P:AddCallbackForAddon("Blizzard_TalentUI", loadFunc)

function S:alaTalentEmu()
	local alaPopup = _G.alaPopup
	if not alaPopup then return end		-- version check

	local menu = alaPopup.menu
	B.StripTextures(menu)
	P.ReskinTooltip(menu)

	hooksecurefunc("ToggleDropDownMenu", function(level, ...)
		level = level or 1

		if menu:IsShown() then
			for i = 1, menu:GetNumChildren() do
				local bu = select(i, menu:GetChildren())
				if bu:GetObjectType() == "Button" and bu:IsShown() and not bu.styled then
					bu:SetHighlightTexture(DB.bdTex)
					local hl = bu:GetHighlightTexture()
					hl:SetVertexColor(DB.r, DB.g, DB.b, .25)
					hl:SetPoint("TOPLEFT", - (menu:GetWidth() - bu:GetWidth()) / 2 + 2, 0)
					hl:SetPoint("BOTTOMRIGHT", (menu:GetWidth() - bu:GetWidth()) / 2 - 2, 0)
					bu.styled = true
				end
			end
		end
	end)
end

S:RegisterSkin("TalentEmu", S.alaTalentEmu)