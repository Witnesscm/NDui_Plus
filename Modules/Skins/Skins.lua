local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:RegisterModule("Skins")

S.SkinList = {}

function S:RegisterSkin(name, func)
	if not S.SkinList[name] then
		S.SkinList[name] = func
	end
end

function S:OnLogin()
	for name, func in next, S.SkinList do
		if name and type(func) == "function" then
			local _, catch = pcall(func)
			P:ThrowError(catch, format("%s Skin", name))
		end
	end

	self:tdGUI()
end

-- Reskin Blizzard UIs
tinsert(C.defaultThemes, function()
	B.ReskinScroll(InterfaceOptionsFrameAddOnsListScrollBar)
end)

function S:tdGUI()
	local GUI = LibStub and LibStub('tdGUI-1.0', true)
	local DropMenu = GUI and GUI:GetClass("DropMenu")

	if DropMenu then
		hooksecurefunc(DropMenu, "Constructor", P.ReskinTooltip)
		hooksecurefunc(DropMenu, "Toggle", P.ReskinTooltip)
	end
end
