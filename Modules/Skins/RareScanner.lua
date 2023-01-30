local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:RareScanner()
	if not S.db["RareScanner"] then return end

	-- Scanner Button
	local button = _G.scanner_button
	if not button then return end

	B.StripTextures(button)
	B.Reskin(button)

	local close = button.CloseButton
	if close then
		B.ReskinClose(close)
		close:SetHitRectInsets(0, 0, 0, 0)
		close:SetScale(1)
		close:ClearAllPoints()
		close:SetPoint("BOTTOMRIGHT",-5, 5)
	end

	if button.FilterEntityButton and button.UnfilterEnabledButton then
		B.ReskinArrow(button.FilterEntityButton, "down")
		B.ReskinArrow(button.UnfilterEnabledButton, "up")
	end

	-- LootBar
	local LootBar = button.LootBar
	if LootBar then
		for _, key in ipairs({"LootBarToolTipComp1", "LootBarToolTipComp2"}) do
			local tip = LootBar[key]
			if tip then
				P.ReskinTooltip(tip)
				P.ReskinTooltip(tip)
			end
		end

		local itemFramesPool = button.LootBar.itemFramesPool
		if itemFramesPool and itemFramesPool.ShowIfReady then
			hooksecurefunc(itemFramesPool, "ShowIfReady", function(self)
				for itemFrame in self:EnumerateActive() do
					if not itemFrame.styled then
						B.ReskinIcon(itemFrame.Icon)
						itemFrame.HL = itemFrame:CreateTexture(nil, "HIGHLIGHT")
						itemFrame.HL:SetColorTexture(1, 1, 1, .25)
						itemFrame.HL:SetAllPoints(itemFrame.Icon)

						itemFrame.styled = true
					end
				end
			end)
		end
	end

	-- RSSearch
	for _, child in pairs({_G.WorldMapFrame:GetChildren()}) do
		if child:GetObjectType() == "Frame" and child.EditBox and child.RefreshPOIs then
			child:ClearAllPoints()
			child:SetPoint("TOP", _G.WorldMapFrame:GetCanvasContainer(), "TOP", 0, 0)
			child.EditBox:DisableDrawLayer("BACKGROUND")
			B.ReskinInput(child.EditBox, 20)
			break
		end
	end
end

function S:LibQTip_RS()
	local LibQTip = _G.LibStub and _G.LibStub("LibQTip-1.0RS", true)
	if not LibQTip then return end

	local origAcquire = LibQTip.Acquire
	LibQTip.Acquire = function(...)
		local tooltip = origAcquire(...)
		P.ReskinTooltip(tooltip)

		return tooltip
	end
end

S:RegisterSkin("RareScanner", S.RareScanner)
S:RegisterSkin("LibQTip_RS")