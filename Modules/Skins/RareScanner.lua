local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local TT = B:GetModule("Tooltip")

local _G = getfenv(0)

function S:RareScanner()
	if not IsAddOnLoaded("RareScanner") then return end
	if not NDuiPlusDB["Skins"]["RareScanner"] then return end

	-- Scanner Button
	local button = _G.scanner_button
	B.StripTextures(button)
	B.Reskin(button)

	local close = button.CloseButton
	B.ReskinClose(close)
	close:SetHitRectInsets(0, 0, 0, 0)
	close:SetScale(1)
	close:ClearAllPoints()
	close:SetPoint("BOTTOMRIGHT",-5, 5)

	B.ReskinArrow(button.FilterDisabledButton, "up")
	B.ReskinArrow(button.FilterEnabledButton, "down")

	TT.ReskinTooltip(button.LootBar.LootBarToolTipComp1)
	TT.ReskinTooltip(button.LootBar.LootBarToolTipComp2)

	-- RSLoot
	hooksecurefunc(button, "LoadLootBar", function(self)
		for itemFrame in self.LootBar.itemFramesPool:EnumerateActive() do
			if not itemFrame.styled then
				B.ReskinIcon(itemFrame.Icon)
				itemFrame.HL = itemFrame:CreateTexture(nil, "HIGHLIGHT")
				itemFrame.HL:SetColorTexture(1, 1, 1, .25)
				itemFrame.HL:SetAllPoints(itemFrame.Icon)

				itemFrame.styled = true
			end
		end
	end)

	-- RSSearch
	for _, frame in ipairs(WorldMapFrame.overlayFrames) do
		local numChildren = frame:GetNumChildren()
		if frame:GetObjectType() == "Frame" and numChildren == 1 and frame.EditBox then
			frame:ClearAllPoints()
			frame:SetPoint("TOP", WorldMapFrame:GetCanvasContainer(), "TOP", 0, 0)
			frame.EditBox:DisableDrawLayer("BACKGROUND")
			B.ReskinInput(frame.EditBox, 20)
			break
		end
	end
end

S:RegisterSkin("RareScanner", S.RareScanner)