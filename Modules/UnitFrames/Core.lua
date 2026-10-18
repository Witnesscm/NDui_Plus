local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local UF = P:RegisterModule("UnitFrames")

function UF:OnLogin()
	UF:UpdateRoleIcons()
	UF:UpdateUFsFader()
end