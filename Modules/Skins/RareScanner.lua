local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local function Button_OnEnter(self)
	self.bg:SetBackdropBorderColor(DB.r, DB.g, DB.b)
end

local function Button_OnLeave(self)
	self.bg:SetBackdropBorderColor(0, 0, 0)
end

function S:RareScanner()
	if not S.db["RareScanner"] then return end

	-- Scanner Button
	local button = _G.RARESCANNER_BUTTON
	if not button then return end

	B.StripTextures(button)
	button.bg = B.SetBD(button)
	button:SetScript("OnEnter", Button_OnEnter)
	button:SetScript("OnLeave", Button_OnLeave)

	local close = button.CloseButton
	if close then
		B.ReskinClose(close, nil, nil, nil, true)
		close:SetHitRectInsets(0, 0, 0, 0)
		close:SetScale(1)
		close:ClearAllPoints()
		close:SetPoint("BOTTOMRIGHT",-5, 5)
	end

	if button.FilterEntityButton and button.UnfilterEnabledButton then
		B.ReskinArrow(button.FilterEntityButton, "down")
		B.ReskinArrow(button.UnfilterEnabledButton, "up")
	end

	P.ReskinFont(button.Title)
	P.ReskinFont(button.Description_text)

	-- LootBar
	local LootBar = button.LootBar
	if LootBar then
		for _, key in ipairs({"LootBarToolTip", "LootBarToolTipComp1", "LootBarToolTipComp2"}) do
			local tip = LootBar[key]
			if tip then
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