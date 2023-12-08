local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local r, g, b = DB.r, DB.g, DB.b

function S:alaTrade()
	local merc = _G.__ala_meta__ and _G.__ala_meta__.merc
	if not merc then return end

	hooksecurefunc(merc, "CreateBaudAuctionFrame", function()
		local index = 1
		local col = _G["BaudAuctionFrameCol"..index]
		while col do
			col:DisableDrawLayer("BACKGROUND")
			col:GetHighlightTexture():SetColorTexture(r, g, b, .25)

			index = index + 1
			col = _G["BaudAuctionFrameCol"..index]
		end

		local scroll = merc.BaudAuctionFrameScrollBar
		if scroll then
			B.StripTextures(scroll)
			B.ReskinScroll(scroll.ScrollBar)
		end

		local progress = merc.BaudAuctionProgress
		if progress then
			B.StripTextures(progress)
			B.SetBD(progress, .7)
			progress:SetFrameLevel(progress:GetFrameLevel() + 5)
		end

		local progressBar = merc.BaudAuctionProgressBar
		if progressBar then
			B.StripTextures(progressBar)
			progressBar:SetStatusBarTexture(DB.normTex)
			B.CreateBDFrame(progressBar, .25)
		end

		local gui = merc.gui
		if not gui then return end

		for _, key in pairs({"ResetButton", "CacheAll", "configButton"}) do
			local bu = gui[key]
			if bu then
				B.Reskin(bu)
			end
		end

		local exactCheck = gui.ExactQueryCheckButton
		if exactCheck then
			B.ReskinCheck(exactCheck)
		end

		if _G.AuctionFrameAuctions_Time then
			B.ReskinDropDown(_G.AuctionFrameAuctions_Time)
		end

		local searchProgress = gui.SearchProgress
		if searchProgress then
			B.StripTextures(searchProgress)
			searchProgress:SetStatusBarTexture(DB.normTex)
			B.CreateBDFrame(searchProgress, .25)
		end
	end)
end

S:RegisterSkin("alaTrade", S.alaTrade)