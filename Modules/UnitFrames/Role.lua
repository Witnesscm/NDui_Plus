local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local G = P:GetModule("GUI")
local UF = P:GetModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

function UF:UpdateRoleIcon()
	local element = self.GroupRoleIndicator

	local role = UnitGroupRolesAssigned(self.unit)
	if(role == "TANK" or role == "HEALER" or role == "DAMAGER") then
		element:SetTexture(P.RoleList[NDuiPlusDB["RoleStyle"]["Index"]][role])
		element:Show()
	else
		element:Hide()
	end
end

function UF:Configure_RoleIcon(frame)
	local role = frame.GroupRoleIndicator
	local mystyle = frame.mystyle
	if role then
		if NDuiPlusDB["RoleStyle"]["Enable"] and not role.Override then
			role:SetTexCoord(0, 1, 0, 1)
			role.Override = UF.UpdateRoleIcon
			if role.ForceUpdate then role:ForceUpdate() end
		end

		if mystyle == "raid" then
			local enable = UF.db["RolePos"]
			role:ClearAllPoints()
			role:SetPoint(enable and G.Points[UF.db["RolePoint"]] or "TOPRIGHT", frame, enable and UF.db["RoleXOffset"] or 5, enable and UF.db["RoleYOffset"] or 5)
			role:SetSize(enable and UF.db["RoleSize"] or 12, enable and UF.db["RoleSize"] or 12)
		end
	end
end

function UF:UpdateRoleIcons()
	for _, frame in pairs(oUF.objects) do
		UF:Configure_RoleIcon(frame)
	end
end

function UF:SetupRoleIcons()
	UF:UpdateRoleIcons()

	hooksecurefunc(NUF, "CreateIcons", function(self, frame)
		UF:Configure_RoleIcon(frame)
	end)
end