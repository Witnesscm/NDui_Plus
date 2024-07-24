local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

function S:TinyInspect()
	if not S.db["TinyInspect"] then return end

	hooksecurefunc("ShowInspectItemListFrame", function(_, parent)
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

			frame.styled = true
		end

		local icon = frame.specicon
		if icon and not icon.styled then
			icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask") --  fix
			icon.styled = true
		end
	end)
end

S:RegisterSkin("TinyInspect", S.TinyInspect)