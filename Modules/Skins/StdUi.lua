local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local cr, cg, cb = DB.r, DB.g, DB.b

local function Scroll_OnEnter(self)
	local thumb = self.thumb
	if not thumb then return end
	thumb.bg:SetBackdropColor(cr, cg, cb, .25)
	thumb.bg:SetBackdropBorderColor(cr, cg, cb)
end

local function Scroll_OnLeave(self)
	local thumb = self.thumb
	if not thumb then return end
	thumb.bg:SetBackdropColor(0, 0, 0, 0)
	B.SetBorderColor(thumb.bg)
end

local function DisableBackdrop(self)
	self:SetBackdrop(nil)
	self.SetBackdrop = B.Dummy
end

function S:StdUi()
	local StdUi = _G.LibStub and _G.LibStub("StdUi", true)
	if not StdUi then return end

	local origWindow = StdUi.Window
	StdUi.Window = function(...)
		local frame = origWindow(...)
		B.StripTextures(frame)
		B.SetBD(frame)

		local close = frame.closeBtn
		if close then
			close.text:SetText("")
			B.ReskinClose(close)
		end

		return frame
	end

	local origCheckbox = StdUi.Checkbox
	StdUi.Checkbox = function(...)
		local checkbox = origCheckbox(...)
		local target = checkbox.target

		target:SetBackdrop(nil)
		local bg = B.CreateBDFrame(target, 0, true)
		checkbox.bg = bg

		checkbox:SetHighlightTexture(DB.bdTex)
		local hl = checkbox:GetHighlightTexture()
		hl:SetInside(bg)
		hl:SetVertexColor(cr, cg, cb, .25)

		checkbox.checkedTexture:SetOutside(target, 4, 4)
		checkbox.checkedTexture:SetVertexColor(cr, cg, cb)
		checkbox.disabledCheckedTexture:SetOutside(target, 4, 4)

		return checkbox
	end

	local origScrollBar = StdUi.ScrollBar
	StdUi.ScrollBar = function(...)
		local scrollBar = origScrollBar(...)
		B.StripTextures(scrollBar)
		B.StripTextures(scrollBar.panel)
		scrollBar.ThumbTexture:SetAlpha(0)

		local thumb = scrollBar.thumb
		if thumb then
			B.StripTextures(thumb)
			local bg = B.CreateBDFrame(thumb, 0, true)
			bg:SetAllPoints()
			thumb.bg = bg
		end

		for _, key in pairs({"ScrollUpButton", "ScrollDownButton"}) do
			local button = scrollBar[key]
			DisableBackdrop(button)

			if key == "ScrollUpButton" then
				B.ReskinArrow(button, "up")
			else
				B.ReskinArrow(button, "down")
			end
		end

		scrollBar:HookScript("OnEnter", Scroll_OnEnter)
		scrollBar:HookScript("OnLeave", Scroll_OnLeave)

		return scrollBar
	end

	local origSquareButton = StdUi.SquareButton
	StdUi.SquareButton = function(...)
		local button = origSquareButton(...)
		DisableBackdrop(button)
		B.Reskin(button)

		return button
	end
end

S:RegisterSkin("StdUi")