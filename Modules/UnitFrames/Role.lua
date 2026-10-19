local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local G = P:GetModule("GUI")
local UF = P:GetModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

-- Modified from NDui
function NUF:CreateIcons(self)
	local mystyle = self.mystyle
	if mystyle == "player" then
		local combat = self:CreateTexture(nil, "OVERLAY")
		combat:SetPoint("CENTER", self, "BOTTOMLEFT")
		combat:SetSize(28, 28)
		combat:SetAtlas(DB.objectTex)
		self.CombatIndicator = combat
	elseif mystyle == "target" then
		local quest = self:CreateTexture(nil, "OVERLAY")
		quest:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 8)
		quest:SetSize(16, 16)
		self.QuestIndicator = quest
	end

	local phase = CreateFrame("Frame", nil, self)
	phase:SetSize(24, 24)
	phase:SetPoint("CENTER", self.Health)
	phase:SetFrameLevel(5)
	phase:EnableMouse(true)
	local icon = phase:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints()
	phase.Icon = icon
	self.PhaseIndicator = phase

	if C.db["UFs"]["ShowRoleMode"] ~= 2 then
		local ri = self:CreateTexture(nil, "OVERLAY")
		if mystyle == "raid" then
			ri:SetPoint("TOPRIGHT", self, 5, 5)
		else
			ri:SetPoint("TOPRIGHT", self, 0, 8)
		end
		ri:SetSize(15, 15)
		ri.damageAtlas = C.db["UFs"]["ShowRoleMode"] == 3 and ""

		if NDuiPlusDB["RoleStyle"]["Enable"] then
			local roleList = P.RoleList[NDuiPlusDB["RoleStyle"]["Index"]]
			ri.tankAtlas = roleList.TANK
			ri.healerAtlas = roleList.HEALER
			ri.damageAtlas = ri.damageAtlas or roleList.DAMAGER
		end

		self.GroupRoleIndicator = ri
	end

	local li = self:CreateTexture(nil, "OVERLAY")
	if mystyle == "raid" then
		li:SetPoint("BOTTOM", self, 0, 0)
	else
		li:SetPoint("TOPLEFT", self, 0, 8)
	end
	li:SetSize(12, 12)
	self.LeaderIndicator = li

	local ai = self:CreateTexture(nil, "OVERLAY")
	ai:SetPoint("TOPLEFT", self, -1, 8)
	ai:SetSize(12, 12)
	self.AssistantIndicator = ai

	UF:Configure_RoleIcon(self)
end

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
end

function UF:UpdateRoleIcons()
	for _, frame in pairs(oUF.objects) do
		UF:Configure_RoleIcon(frame)
	end
end