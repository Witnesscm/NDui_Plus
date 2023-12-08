local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local M = B:GetModule("Misc")

local _G = getfenv(0)
local strfing = string.find

function S:tdAuction()
	if not S.db["tdAuction"] then return end

	local tdAuction = _G.LibStub("AceAddon-3.0"):GetAddon("tdAuction")

	local function reskinFunc()
		-- Browse
		local Browse = tdAuction.Browse
		B.Reskin(Browse.ResetButton)
		Browse.PrevPageButton:SetPoint("TOPLEFT", 660, -60)
		Browse.NextPageButton:SetPoint("TOPRIGHT", 65, -60)
		B.ReskinScroll(Browse.ScrollFrame.scrollBar)

		for i = 1, Browse.QualityDropDown:GetNumChildren() do
			local child = select(i, Browse.QualityDropDown:GetChildren())
			if child:GetObjectType() == "Frame" and child.pixelBorders then
				child:SetPoint("BOTTOMRIGHT", BrowseDropDownButton, "BOTTOMRIGHT")
				break
			end
		end

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

		--BrowseDropDown
		for i = 1, _G.BrowseDropDown:GetNumChildren() do
			local child = select(i, _G.BrowseDropDown:GetChildren())
			if child:GetObjectType() == "Frame" and child.backdropInfo then
				child:SetPoint("BOTTOMRIGHT", _G.BrowseDropDown.Button, "BOTTOMRIGHT")
			end
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
		P.ReskinDropDown(Sell.DurationDropDown)
		B.ReskinArrow(Sell.PriceListButton, "right")
		Sell.StackSizeEntry:SetHeight(21)
		Sell.NumStacksEntry:SetHeight(21)
		Sell.StackSizeMaxButton:SetPoint("LEFT", Sell.StackSizeEntry, "RIGHT", 2, 0)
		Sell.NumStacksMaxButton:SetPoint("LEFT", Sell.NumStacksEntry, "RIGHT", 2, 0)

		B.StripTextures(Sell.PriceList)
		B.SetBD(Sell.PriceList)
		B.ReskinClose(Sell.PriceList.Close)
		B.ReskinScroll(Sell.PriceList.ScrollFrame.scrollBar)

		for _, region in pairs {_G.AuctionsItemButton:GetRegions()} do
			if region:GetObjectType() == "Texture" then
				local texture = region.GetTextureFilePath and region:GetTextureFilePath()
				if texture and type(texture) == "string" and strfing(texture, "ItemSlot") then
					region:SetTexture("")
				end
			end
		end

		B.Reskin(tdAuction.Features.FullScanButton)
		B.Reskin(tdAuction.Features.OptionButton)
	end
	hooksecurefunc(tdAuction, "SetupUI", reskinFunc)
end

S:RegisterSkin("tdAuction", S.tdAuction)