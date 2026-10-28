local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

function S:TomTom_Reskin()
	local frame = _G.TomTomPaste
	if not frame or frame.styled then
		return
	end

	B.StripTextures(frame)
	B.SetBD(frame)
	S:Proxy("Reskin", frame.ExportButton)
	S:Proxy("Reskin", frame.CloseButton)
	S:Proxy("Reskin", frame.PasteButton)
	S:Proxy("ReskinCheck", frame.AutoCloseCheck)

	if frame.EditBox then
		frame.EditBox:HideBackdrop()
		B.CreateBDFrame(frame.EditBox, .25)
	end

	frame.styled = true
end

function S:TomTom()
	local TomTom = _G.TomTom
	if not TomTom then
		return
	end

	if type(TomTom.PasteConfigChanged) == "function" then
		hooksecurefunc(TomTom, "PasteConfigChanged", function(self)
			local button = _G["LibDBIcon10_TomTom-Paste"]
			if button and not button.isHooked then
				button:HookScript("OnClick", S.TomTom_Reskin)

				button.isHooked = true
			end
		end)
	end

	if type(SlashCmdList.TOMTOM_PASTE) == "function" then
		hooksecurefunc(SlashCmdList, "TOMTOM_PASTE", S.TomTom_Reskin)
	end
end

S:RegisterSkin("TomTom", S.TomTom, true)