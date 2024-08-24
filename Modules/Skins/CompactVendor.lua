local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function onEnter(self)
	self.arrow:SetVertexColor(DB.r, DB.g, DB.b)
end

local function onLeave(self)
	self.arrow:SetVertexColor(1, 1, 1)
end

local function HandleButton(self)
	if not self.styled then
		local button = self.Quantity
		button:SetNormalTexture(0)
		button:SetHighlightTexture(0)
		local arrow = button:CreateTexture(nil, "OVERLAY")
		arrow:SetSize(14, 14)
		B.SetupArrow(arrow, "right")
		arrow:SetPoint("CENTER")
		button.arrow = arrow
		button:HookScript("OnEnter", onEnter)
		button:HookScript("OnLeave", onLeave)

		self.styled = true
	end
end

function S:CompactVendor()
	local CompactVendorFrame = _G.CompactVendorFrame
	if CompactVendorFrame then
		S:Proxy("ReskinTrimScroll", CompactVendorFrame.ScrollBar)
		S:Proxy("ReskinInput", CompactVendorFrame.Search, 22)

		hooksecurefunc(CompactVendorFrame.ScrollBox, "Update", function(self)
			self:ForEachFrame(HandleButton)
		end)
	end

	local FilterButton = _G.CompactVendorFilterButton
	if FilterButton then
		B.ReskinArrow(FilterButton, "down")
		FilterButton:SetScale(1)
		FilterButton:ClearAllPoints()
		FilterButton:SetPoint("RIGHT", _G.MerchantFrameCloseButton, "LEFT", -2, 0)
	end

	local StackSplitFrame = _G.CompactVendorFrameMerchantStackSplitFrame
	if StackSplitFrame then
		B.StripTextures(StackSplitFrame)
		B.SetBD(StackSplitFrame)
		S:Proxy("Reskin", StackSplitFrame.OkayButton)
		S:Proxy("Reskin", StackSplitFrame.CancelButton)
		S:Proxy("ReskinArrow", StackSplitFrame.LeftButton, "left")
		S:Proxy("ReskinArrow", StackSplitFrame.RightButton, "right")
	end
end

S:RegisterSkin("CompactVendor", S.CompactVendor)