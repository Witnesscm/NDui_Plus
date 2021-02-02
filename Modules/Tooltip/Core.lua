local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local T = P:RegisterModule("Tooltip")

function T:OnLogin()
	T.db = NDuiPlusDB["Tooltip"]
	T.myGUID = UnitGUID("player")
	T.myFaction = UnitFactionGroup("player")
end