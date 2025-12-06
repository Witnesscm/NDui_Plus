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
		role.__orig = role.__orig or {
			width = B:Round(role:GetWidth()),
			height = B:Round(role:GetHeight()),
			point = {role:GetPoint()}
		}
		role:ClearAllPoints()

		if UF.db["RolePos"] then
			role:SetPoint(G.Points[UF.db["RolePoint"]], frame, UF.db["RoleXOffset"], UF.db["RoleYOffset"])
			role:SetSize(UF.db["RoleSize"], UF.db["RoleSize"])
		else
			role:SetPoint(unpack(role.__orig.point))
			role:SetSize(role.__orig.width, role.__orig.height)
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

	if NUF.CreateIcons then
		hooksecurefunc(NUF, "CreateIcons", function(_, frame)
			UF:Configure_RoleIcon(frame)
		end)
	end
end