local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:TinyInspect()
	if not IsAddOnLoaded("TinyInspect") then return end
	if not S.db["TinyInspect"] then return end

	hooksecurefunc("ShowInspectItemListFrame", function(_, parent)
		local frame = parent.inspectFrame
		if not frame then return end
		frame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 3, 0)

		if not frame.styled then
		    B.StripTextures(frame)
			frame:SetBackdrop(nil)
			frame.SetBackdrop = B.Dummy
        	frame:SetBackdropColor(0, 0, 0, 0)
			frame.SetBackdropColor = B.Dummy
        	frame:SetBackdropBorderColor(0, 0, 0, 0)
			frame.SetBackdropBorderColor = B.Dummy
			B.SetBD(frame)
			frame.styled = true
		end

		if frame.specicon then
			frame.specicon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask") --  fix
		end
	end)
end

S:RegisterSkin("TinyInspect", S.TinyInspect)