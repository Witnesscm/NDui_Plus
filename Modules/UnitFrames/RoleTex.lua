local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = _G.oUF or ns.oUF
local UF = P:GetModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

local defaultTex = "Interface\\LFGFrame\\LFGROLE"

function UF:UpdateRoleTex()
	for _, frame in pairs(oUF.objects) do
		local role = frame.GroupRoleIndicator
		if role then
			role:SetTexture(UF.db["RoleTex"] and P.RoleTex or defaultTex)
		end
	end
end

function UF:SetIconsHook()
	hooksecurefunc(NUF, "CreateIcons", function(self, frame)
		local role = frame.GroupRoleIndicator
		if role then
			role:SetTexture(UF.db["RoleTex"] and P.RoleTex or defaultTex)
		end
	end)
end

do -- RaidTool
	local Misc = B:GetModule("Misc")
	hooksecurefunc(Misc, "RaidTool_RoleCount", function(self, frame)
		if not NDuiPlusDB["UnitFrames"]["RoleTex"] then return end

		if frame.roleFrame then
			for i = 1, frame.roleFrame:GetNumRegions() do
				local region = select(i, frame.roleFrame:GetRegions())
				if region and region.IsObjectType and region:IsObjectType("Texture") and region.text then
					region:SetTexture(P.RoleTex)
				end
			end
		end
	end)
end