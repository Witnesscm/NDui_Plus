local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

function S:TinyInspect()
	if not S.db["TinyInspect"] then return end

	hooksecurefunc("ShowInspectItemListFrame", function(unit, parent)
		local frame = parent.inspectFrame
		if not frame then return end
		frame:SetPoint("TOPLEFT", parent, "TOPRIGHT", C.mult*2, 0)

		if not frame.styled then
			frame:SetBackdrop(nil)
			frame.SetBackdrop = B.Dummy
			frame:SetBackdropColor(0, 0, 0, 0)
			frame.SetBackdropColor = B.Dummy
			frame:SetBackdropBorderColor(0, 0, 0, 0)
			frame.SetBackdropBorderColor = B.Dummy
			frame.GetBackdrop = function(self) return self.backdrop end
			B.SetBD(frame, nil, 0, 0, 0, 0)

			local specicon = frame.specicon
			specicon:SetSize(41, 41)
			specicon:ClearAllPoints()
			specicon:SetPoint("TOPRIGHT", -14, -14)
			specicon:SetAlpha(1)
			specicon:SetMask("Interface\\Masks\\CircleMaskScalable")
			local spectext = frame.spectext
			B.SetFontSize(spectext, 12)
			spectext:SetAlpha(1)

			local portrait = frame.portrait
			B.StripTextures(portrait, 0)
			portrait.Portrait:SetAlpha(1)
			portrait.Border = portrait:CreateTexture(nil, "BACKGROUND")
			portrait.Border:SetTexture("Interface\\Masks\\CircleMaskScalable")
			portrait.Border:SetPoint("TOPLEFT", frame.portrait.Portrait, "TOPLEFT", -3, 4)
			portrait.Border:SetPoint("BOTTOMRIGHT", frame.portrait.Portrait, "BOTTOMRIGHT", 4, -5)

			--[[
			local specicon = frame.specicon
			specicon:SetSize(35, 35)
			specicon:ClearAllPoints()
			specicon:SetPoint("TOPRIGHT", -16, -16)
			specicon:SetAlpha(.8)
			specicon:SetMask("")
			B.ReskinIcon(specicon)
			local spectext = frame.spectext
			B.SetFontSize(spectext, 12)
			spectext:SetAlpha(.8)

			local portrait = frame.portrait
			B.StripTextures(portrait, 0)
			portrait.Portrait:SetAlpha(1)
			portrait.Portrait:SetTexCoord(.14, .86, .14, .86)
			portrait.bg = B.CreateBDFrame(portrait.Portrait, 0)
			--]]

			frame.styled = true
		end

		if frame.portrait.Border then
			frame.portrait.Border:SetVertexColor(B.ClassColor(UnitClassBase(unit)))
		end
	end)
end

S:RegisterSkin("TinyInspect", S.TinyInspect)