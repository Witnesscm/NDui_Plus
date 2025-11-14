local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

function S:QuestMapFrame()
	for _, tab in ipairs(_G.QuestMapFrame.TabButtons) do
		if not tab.bg then
			B.StripTextures(tab, 2)
			tab.bg = B.SetBD(tab, nil, 1, -4, -5, 4)

			tab.SelectedTexture:SetDrawLayer("BACKGROUND")
			tab.SelectedTexture:SetColorTexture(DB.r, DB.g, DB.b, .25)
			tab.SelectedTexture:SetInside(tab.bg)

			tab.HL = tab:CreateTexture(nil, "HIGHLIGHT")
			tab.HL:SetColorTexture(1, 1, 1, .25)
			tab.HL:SetInside(tab.bg)
		end
	end
end

--S:RegisterSkin("QuestMapFrame")