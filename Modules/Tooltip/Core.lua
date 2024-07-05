local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local T = P:RegisterModule("Tooltip")

function T:OnLogin()
	T:SpecLevel()
end