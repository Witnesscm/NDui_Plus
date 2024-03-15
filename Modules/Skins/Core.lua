local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:RegisterModule("Skins")

local _G = getfenv(0)
local xpcall, pairs, type = xpcall, pairs, type

S.nonAddonsToLoad = {}
S.aceWidgets = {}
S.aceContainers = {}

function S:RegisterSkin(name, func, early)
	if not func then
		func = self[name]

		if func and type(func) == "function" then
			self.nonAddonsToLoad[name] = func
		end
	else
		if early then
			P:AddCallbackForAddonEarly(name, func)
		else
			P:AddCallbackForAddon(name, func)
		end
	end
end

function S:RegisterAceGUIWidget(name, func)
	self.aceWidgets[name] = func or self[name]
end

function S:RegisterAceGUIContainer(name, func)
	self.aceContainers[name] = func or self[name]
end

-- Call NDui skin function (Credit: ElvUI_WindTools)
function S:Proxy(funcName, object, ...)
	if not object then
		P.Developer_ThrowError(format("%s: object is nil", funcName))
		return
	end

	if not B[funcName] then
		P.Developer_ThrowError(format("B.%s is not exist", funcName))
		return
	end

	B[funcName](object, ...)
end

function S:OnLogin()
	for name, func in pairs(self.nonAddonsToLoad) do
		xpcall(func, P.ThrowError)
		self.nonAddonsToLoad[name] = nil
	end
end