local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local G = P:GetModule("GUI")
local UF = P:GetModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

function UF:Configure_RoleIcon(frame)
	local roleIcon = frame.GroupRoleIndicator
	local mystyle = frame.mystyle
	if roleIcon and mystyle == "raid" then
		roleIcon.__orig = roleIcon.__orig or {
			width = B:Round(roleIcon:GetWidth()),
			height = B:Round(roleIcon:GetHeight()),
			point = {roleIcon:GetPoint()}
		}
		roleIcon:ClearAllPoints()

		if UF.db["RolePos"] then
			roleIcon:SetPoint(G.Points[UF.db["RolePoint"]], frame, UF.db["RoleXOffset"], UF.db["RoleYOffset"])
			roleIcon:SetSize(UF.db["RoleSize"], UF.db["RoleSize"])
		else
			roleIcon:SetPoint(unpack(roleIcon.__orig.point))
			roleIcon:SetSize(roleIcon.__orig.width, roleIcon.__orig.height)
		end
	end

	if roleIcon and roleIcon.PostUpdate and not roleIcon.__hooked then
		hooksecurefunc(roleIcon, "PostUpdate", function(self, role)
			B.ReskinSmallRole(self, role)
		end)
		roleIcon.__hooked = true
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