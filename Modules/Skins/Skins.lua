local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:RegisterModule("Skins")

local _G = getfenv(0)
local pcall, pairs, type = pcall, pairs, type
local tinsert = table.insert

S.nonAddonsToLoad = {}
S.aceWidgets = {}
S.aceContainers = {}

function S:RegisterSkin(name, func)
	if not func then
		func = self[name]

		if func and type(func) == "function" then
			self.nonAddonsToLoad[name] = func
		end
	else
		P:AddCallbackForAddon(name, func)
	end
end

function S:RegisterAceGUIWidget(name, func)
	self.aceWidgets[name] = func or self[name]
end

function S:RegisterAceGUIContainer(name, func)
	self.aceContainers[name] = func or self[name]
end

function S:OnLogin()
	for name, func in pairs(self.nonAddonsToLoad) do
		local _, catch = pcall(func)
		P:ThrowError(catch, format("%s Skin", name))
		self.nonAddonsToLoad[name] = nil
	end
end

-- Reskin Blizzard UIs
tinsert(C.defaultThemes, function()
	if _G.InterfaceOptionsFrameAddOnsListScrollBar then
		B.ReskinScroll(_G.InterfaceOptionsFrameAddOnsListScrollBar)
	end
end)