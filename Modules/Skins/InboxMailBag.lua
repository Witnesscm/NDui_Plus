local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:InboxMailBag()
	if not S.db["InboxMailBag"] then return end

	local styled
	_G.MailFrame:HookScript("OnShow", function()
		if styled then return end

		for i = 3, _G.MailFrame.numTabs do
			local tab = _G["MailFrameTab"..i]
			B.ReskinTab(tab)
			tab:ClearAllPoints()
			tab:SetPoint("TOPLEFT", _G["MailFrameTab"..(i-1)], "TOPRIGHT", -15, 0)
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

		bu.NormalTexture:SetAlpha(0)
		bu:SetPushedTexture(0)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu.SetHighlightTexture = B.Dummy
		bu.icon:SetTexCoord(unpack(DB.TexCoord))
		bu.bg = B.CreateBDFrame(bu, .25)
		bu.qualityOverlay:SetAlpha(0)
	end

	hooksecurefunc("InboxMailbag_Update", function()
		for i = 1, num do
			local bu = _G["InboxMailbagFrameItem"..i]

			if bu.qualityOverlay:IsShown() then
				local r, g, b = bu.qualityOverlay:GetVertexColor()
				bu.bg:SetBackdropBorderColor(r, g, b)
			else
				bu.bg:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end)

	hooksecurefunc("InboxMailbag_UpdateSearchResults", function()
		for i = 1, num do
			local bu = _G["InboxMailbagFrameItem"..i]

			if bu.searchOverlay:IsShown() then
				bu.bg:SetAlpha(0.2)
			else
				bu.bg:SetAlpha(1)
			end
		end
	end)
end

S:RegisterSkin("InboxMailBag", S.InboxMailBag)