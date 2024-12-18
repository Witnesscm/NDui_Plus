local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local M = B:GetModule("Misc")

local _G = getfenv(0)

function S:tdAuction()
	if not S.db["tdAuction"] then return end

	local tdAuction = _G.LibStub("AceAddon-3.0"):GetAddon("tdAuction")
	hooksecurefunc(tdAuction, "SetupUI", function()
		-- Browse
		local Browse = tdAuction.Browse
		B.Reskin(Browse.ResetButton)
		Browse.PrevPageButton:SetPoint("TOPLEFT", 660, -60)
		Browse.NextPageButton:SetPoint("TOPRIGHT", 65, -60)
		B.ReskinScroll(Browse.ScrollFrame.scrollBar)

		for _, tab in ipairs(Browse.sortButtons) do
			tab:DisableDrawLayer("BACKGROUND")
			tab:GetHighlightTexture():SetColorTexture(DB.r, DB.g, DB.b, .25)
		end

		for _, button in ipairs(Browse.ScrollFrame.buttons) do
			B.ReskinIcon(button.Icon)
		end

		local ExactCheckButton = Browse.ExactCheckButton
		if ExactCheckButton then
			B.ReskinCheck(ExactCheckButton)
		end

		-- FullScan
		local FullScan = tdAuction.FullScan
		B.StripTextures(FullScan)
		B.SetBD(FullScan, .7)
		B.ReskinClose(FullScan.CloseButton)
		B.Reskin(FullScan.ExecButton)
		FullScan.Blocker:SetAlpha(0)

		-- Sell
		local Sell = tdAuction.Sell
		B.ReskinDropDown(Sell.DurationDropDown)
		B.ReskinDropDown(Sell.PriceDropDown)
		B.ReskinArrow(Sell.PriceListButton, "right")
		Sell.StackSizeEntry:SetHeight(21)
		Sell.NumStacksEntry:SetHeight(21)
		Sell.StackSizeMaxButton:SetPoint("LEFT", Sell.StackSizeEntry, "RIGHT", 2, 0)
		Sell.NumStacksMaxButton:SetPoint("LEFT", Sell.NumStacksEntry, "RIGHT", 2, 0)

		B.StripTextures(Sell.PriceList)
		B.SetBD(Sell.PriceList)
		B.ReskinClose(Sell.PriceList.Close)
		B.ReskinScroll(Sell.PriceList.ScrollFrame.scrollBar)

		local ItemButton = _G.AuctionsItemButton
		B.StripTextures(ItemButton)
		for _, child in pairs {ItemButton:GetChildren()} do
			if child.backdropInfo and child.backdropInfo.bgFile == DB.bdTex then
				child:SetAllPoints()
				break
			end
		end
		local hl = _G.AuctionsItemButton:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside()

		B.Reskin(tdAuction.Features.FullScanButton)
		B.Reskin(tdAuction.Features.OptionButton)
	end)
end

S:RegisterSkin("tdAuction", S.tdAuction)