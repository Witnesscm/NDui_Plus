local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local UF = P:RegisterModule("UnitFrames")

function UF:OnLogin()
	if P.isMidnight then return end
	UF:SetupRoleIcons()
	UF:UpdateUFsFader()
end