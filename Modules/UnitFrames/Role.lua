local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local G = P:GetModule("GUI")
local UF = P:GetModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

function UF:Configure_RoleIcon(frame)
	local role = frame.GroupRoleIndicator
	local mystyle = frame.mystyle
	if role and mystyle == "raid" then
		local enable = UF.db["RolePos"]
		role:ClearAllPoints()
		role:SetPoint(enable and G.Points[UF.db["RolePoint"]] or "TOPRIGHT", frame, enable and UF.db["RoleXOffset"] or 5, enable and UF.db["RoleYOffset"] or 5)
		role:SetSize(enable and UF.db["RoleSize"] or 12, enable and UF.db["RoleSize"] or 12)
	end
end

function UF:UpdateRoleIcons()
	for _, frame in pairs(oUF.objects) do
		UF:Configure_RoleIcon(frame)
	end
end

function UF:SetupRoleIcons()
	UF:UpdateRoleIcons()

	hooksecurefunc(NUF, "CreateIcons", function(_, frame)
		UF:Configure_RoleIcon(frame)
	end)
end