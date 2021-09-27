local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local pairs = pairs

function S:WowLua()
	B.ReskinPortraitFrame(WowLuaFrame)
	B.ReskinClose(WowLuaButton_Close)
	WowLuaFrameTitle:SetPoint("TOP", 15, -5)
	WowLuaButton_Close:SetPoint("TOPRIGHT", -5 , -5)
	B.StripTextures(WowLuaFrameResizeBar)
	B.ReskinScroll(WowLuaFrameEditScrollFrameScrollBar)
	WowLuaFrameLineNumScrollFrame:DisableDrawLayer("ARTWORK")
	WowLuaFrameLineNumScrollFrame.bg = B.CreateBDFrame(WowLuaFrameLineNumScrollFrame, 0)
	WowLuaFrameLineNumScrollFrame.bg:SetPoint("TOPLEFT", -1, 3)
	WowLuaFrameLineNumScrollFrame.bg:SetPoint("BOTTOMRIGHT", -2, -2)
	WowLuaFrameEditFocusGrabber.bg = B.CreateBDFrame(WowLuaFrameEditFocusGrabber, 0)
	WowLuaFrameEditFocusGrabber.bg:SetPoint("BOTTOMRIGHT", 6, -6)
	WowLuaFrameOutput.bg = B.CreateBDFrame(WowLuaFrameOutput, 0)
	WowLuaFrameOutput.bg:SetPoint("TOPLEFT", -2, 1)
	WowLuaFrameOutput.bg:SetPoint("BOTTOMRIGHT", -20, -2)
	WowLuaFrameCommand:DisableDrawLayer("BACKGROUND")
	WowLuaButton_New:SetPoint("LEFT", -30, 5)

	local Buttons = {
		WowLuaButton_New,
		WowLuaButton_Open,
		WowLuaButton_Save,
		WowLuaButton_Undo,
		WowLuaButton_Redo,
		WowLuaButton_Delete,
		WowLuaButton_Lock,
		WowLuaButton_Unlock,
		WowLuaButton_Config,
		WowLuaButton_Previous,
		WowLuaButton_Next,
		WowLuaButton_Run,
	}

	for _, object in pairs(Buttons) do
		B.ReskinIcon(object:GetNormalTexture())
		if object:GetDisabledTexture() then
			B.ReskinIcon(object:GetDisabledTexture())
		end
		object:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	end
end

S:RegisterSkin("WowLua", S.WowLua)