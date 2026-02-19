local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")
local S = P:GetModule("Skins")

function M:ExtMacroUI()
	if not M.db["ExtMacroUI"] then return end

	_G.MacroFrame:SetSize(535, 568)
	SetUIPanelAttribute(_G.MacroFrame, "width", 535)
	_G.MacroFrame.MacroSelector:SetSize(516, 242)
	_G.MacroFrame.MacroSelector:SetCustomStride(nil)
	_G.MacroHorizontalBarLeft:SetSize(452, 16)
	_G.MacroHorizontalBarLeft:SetPoint("TOPLEFT", 2, -308)
	_G.MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", 5, -316)
	_G.MacroFrameScrollFrame:SetSize(484, 130)
	_G.MacroFrameText:SetSize(484, 130)
	_G.MacroFrameTextBackground:SetSize(520, 140)
	_G.MacroFrameTextBackground:SetPoint("TOPLEFT", 6, -387)
end

P:AddCallbackForAddon("Blizzard_MacroUI", M.ExtMacroUI)