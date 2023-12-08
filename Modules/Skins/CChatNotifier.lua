local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:CChatNotifier()
	local frame = _G.CCNUI_MainUI
	if not frame then return end

	B.ReskinPortraitFrame(frame)
	B.ReskinScroll(frame.scrollFrame.ScrollBar)

	local items = frame.scrollFrame.items
	for i = 1, #items do
		B.CreateBD(items[i], .25)
	end

	for _, key in pairs({"addFrame", "editFrame"}) do
		local subFrame = frame[key]
		if subFrame then
			subFrame.searchEdit:HideBackdrop()
			B.ReskinInput(subFrame.searchEdit)
			B.Reskin(subFrame.okbutton)
			B.Reskin(subFrame.backbutton)
		end
	end
end

S:RegisterSkin("CChatNotifier", S.CChatNotifier)