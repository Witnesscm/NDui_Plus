local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)

function P:Developer_Command(msg)
	if msg == "debug" then
		NDuiPlusDB["Debug"] = not NDuiPlusDB["Debug"]
		P:Print("debug " .. (NDuiPlusDB["Debug"] and "on" or "off"))
	end
end