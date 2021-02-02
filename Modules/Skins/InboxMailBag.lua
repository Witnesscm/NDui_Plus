local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:InboxMailBag()
	if not IsAddOnLoaded("InboxMailBag") then return end
	if not NDuiPlusDB["Skins"]["InboxMailBag"] then return end

	local function delayFunc()
		local index = 3
		while _G['MailFrameTab'..index] do
			B.ReskinTab(_G["MailFrameTab"..index])
			index = index + 1
		end
	end
	C_Timer.After(.5, delayFunc)
	B.ReskinCheck(InboxMailbagFrameItemGroupStacksCheckBox)
	B.ReskinInput(InboxMailbagFrameItemSearchBox)
	B.ReskinScroll(InboxMailbagFrameScrollFrameScrollBar)
	InboxMailbagFrameScrollFrame:GetRegions():Hide()
	B.StripTextures(InboxMailbagFrame)

	local num = _G.BAGITEMS_ICON_DISPLAYED or 42

	for i = 1, num do
		local bu = _G["InboxMailbagFrameItem"..i]

		bu:SetNormalTexture("")
		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu.SetHighlightTexture = B.Dummy
		bu.icon:SetTexCoord(.08, .92, .08, .92)
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