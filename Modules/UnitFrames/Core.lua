local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local UF = P:RegisterModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

function UF:OnLogin()
	UF:SetupRoleIcons()
	UF:UpdateUFsFader()
end