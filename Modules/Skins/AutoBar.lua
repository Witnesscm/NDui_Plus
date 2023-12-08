local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local AB = P:GetModule("ActionBar")

local _G = getfenv(0)

local function reskinButton(self)
	local button = self.frame
	if button then
		AB:StyleActionButton(button, AB.BarConfig)
	end
end

function S:AutoBar()
	if not S.db["AutoBar"] then return end

	hooksecurefunc(_G.AutoBar.Class.Button.prototype, "CreateButtonFrame", reskinButton)
	hooksecurefunc(_G.AutoBar.Class.PopupButton.prototype, "CreateButtonFrame", reskinButton)
end

S:RegisterSkin("AutoBarClassic", S.AutoBar)
S:RegisterSkin("AutoBarBCC", S.AutoBar)
S:RegisterSkin("AutoBarWrath", S.AutoBar)