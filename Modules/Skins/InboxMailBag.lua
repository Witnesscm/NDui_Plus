local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:InboxMailBag()
	if not S.db["InboxMailBag"] then return end

	local styled
	_G.MailFrame:HookScript("OnShow", function()
		if styled then return end

		local index = 3
		while _G["MailFrameTab"..index] do
			B.ReskinTab(_G["MailFrameTab"..index])
			index = index + 1
		end

		styled = true
	end)

	B.ReskinCheck(InboxMailbagFrameItemGroupStacksCheckBox)
	B.ReskinInput(InboxMailbagFrameItemSearchBox)
	B.ReskinScroll(InboxMailbagFrameScrollFrameScrollBar)
	B.StripTextures(InboxMailbagFrame)

	local num = _G.BAGITEMS_ICON_DISPLAYED or 42

	for i = 1, num do
		local bu = _G["InboxMailbagFrameItem"..i]

		bu:SetNormalTexture(0)
		bu:SetPushedTexture(0)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu.bg = B.ReskinIcon(bu.icon)
		B.ReskinIconBorder(bu.qualityOverlay)
		bu.Count:ClearAllPoints()
		bu.Count:SetPoint("BOTTOMRIGHT", -1, 2)
		B.SetFontSize(bu.Count, 13)
		hooksecurefunc(bu.searchOverlay, "Show", function()
			bu.bg:SetAlpha(.2)
		end)
		hooksecurefunc(bu.searchOverlay, "Hide", function()
			bu.bg:SetAlpha(1)
		end)
	end
end

S:RegisterSkin("InboxMailBag", S.InboxMailBag)