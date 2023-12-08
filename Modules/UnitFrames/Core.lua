local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local UF = P:RegisterModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

local unitFrames = {
	["tank"] = true
}

function UF:UpdateFrameNameTag()
	local name = self.nameText
	if not name then return end

	local mystyle = self.mystyle
	if not unitFrames[mystyle] then return end

	local colorTag = C.db["UFs"]["RCCName"] and "[color]" or ""

	if mystyle == "tank" then
		self:Tag(name, colorTag.."[name]")
	end
	name:UpdateTag()

	UF.UpdateRaidNameAnchor(self, name)
end

do
	if NUF.UpdateFrameNameTag then
		hooksecurefunc(NUF, "UpdateFrameNameTag", UF.UpdateFrameNameTag)
	end
end

function UF:UpdateFrameHealthTag()
	local hpval = self.healthValue
	if not hpval then return end

	local mystyle = self.mystyle
	if not unitFrames[mystyle] then return end

	if mystyle == "tank" then
		self:Tag(hpval, "[raidhp]")
		hpval:ClearAllPoints()
		hpval:SetPoint("BOTTOM", 0, 1)
		hpval:SetJustifyH("CENTER")
		hpval:SetScale(C.db["UFs"]["RaidTextScale"])
	end
	hpval:UpdateTag()
end

do
	if NUF.UpdateFrameHealthTag then
		hooksecurefunc(NUF, "UpdateFrameHealthTag", UF.UpdateFrameHealthTag)
	end
end

local function UpdateHealthColorByIndex(health, index)
	health.colorClass = (index == 2)
	health.colorTapping = (index == 2)
	health.colorReaction = (index == 2)
	health.colorDisconnected = (index == 2)
	health.colorSmooth = (index == 3)
	health.colorHappiness = (DB.MyClass == "HUNTER" and index == 2)
	if index == 1 then
		health:SetStatusBarColor(.1, .1, .1)
		health.bg:SetVertexColor(.6, .6, .6)
	elseif index == 4 then
		health:SetStatusBarColor(0, 0, 0, 0)
	end
end

function UF:UpdateHealthBarColor(self, force)
	local health = self.Health
	local mystyle = self.mystyle
	if mystyle == "tank" then
		UpdateHealthColorByIndex(health, C.db["UFs"]["RaidHealthColor"])
	end

	if force then
		health:ForceUpdate()
	end
end

function UF.HealthPostUpdate(element, unit, cur, max)
	local self = element.__owner
	local mystyle = self.mystyle
	local useGradient, useGradientClass
	if mystyle == "tank" then
		useGradient = C.db["UFs"]["RaidHealthColor"] > 3
		useGradientClass = C.db["UFs"]["RaidHealthColor"] == 5
	end
	if useGradient then
		self.Health.bg:SetVertexColor(self:ColorGradient(cur or 1, max or 1, 1,0,0, 1,.7,0, .7,1,0))
	end
	if useGradientClass then
		local color
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			color = self.colors.class[class]
		elseif UnitReaction(unit, "player") then
			color = self.colors.reaction[UnitReaction(unit, "player")]
		end
		if color then
			element:GetStatusBarTexture():SetGradientAlpha("HORIZONTAL", color[1],color[2],color[3], .75, 0,0,0, .25)
		end
	end
end

function UF:CreateHealthBar(self)
	local mystyle = self.mystyle
	local health = CreateFrame("StatusBar", nil, self)
	health:SetPoint("TOPLEFT", self)
	health:SetPoint("TOPRIGHT", self)
	local healthHeight
	if mystyle == "tank" then
		healthHeight = UF.db["TankHeight"]
	end
	health:SetHeight(healthHeight)
	health:SetStatusBarTexture(DB.normTex)
	health:SetStatusBarColor(.1, .1, .1)
	health:SetFrameLevel(self:GetFrameLevel() - 2)
	self.backdrop = B.SetBD(health, 0)
	if self.backdrop.__shadow then
		self.backdrop.__shadow:SetOutside(self, 4+C.mult, 4+C.mult)
		self.backdrop.__shadow:SetFrameLevel(0)
		self.backdrop.__shadow = nil
	end
	B:SmoothBar(health)

	local bg = self:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	bg:SetPoint("BOTTOMRIGHT", health)
	bg:SetTexture(DB.bdTex)
	bg:SetVertexColor(.6, .6, .6)
	bg.multiplier = .25

	self.Health = health
	self.Health.bg = bg
	self.Health.PostUpdate = UF.HealthPostUpdate

	UF:UpdateHealthBarColor(self)
end

local function UpdatePowerColorByIndex(power, index)
	power.colorPower = (index == 2) or (index == 5)
	power.colorClass = (index ~= 2)
	power.colorReaction = (index ~= 2)
	if power.SetColorTapping then
		power:SetColorTapping(index ~= 2)
	else
		power.colorTapping = (index ~= 2)
	end
	if power.SetColorDisconnected then
		power:SetColorDisconnected(index ~= 2)
	else
		power.colorDisconnected = (index ~= 2)
	end
	power.colorHappiness = (DB.MyClass == "HUNTER" and index ~= 2)
end

function UF:UpdatePowerBarColor(self, force)
	local power = self.Power
	local mystyle = self.mystyle
	if mystyle == "tank" then
		UpdatePowerColorByIndex(power, C.db["UFs"]["RaidHealthColor"])
	end

	if force then
		power:ForceUpdate()
	end
end

function UF:CreatePowerBar(self)
	local mystyle = self.mystyle
	local power = CreateFrame("StatusBar", nil, self)
	power:SetStatusBarTexture(DB.normTex)
	power:SetPoint("BOTTOMLEFT", self)
	power:SetPoint("BOTTOMRIGHT", self)
	local powerHeight
	if mystyle == "tank" then
		powerHeight = UF.db["TankPowerHeight"]
	end
	power:SetHeight(powerHeight)
	power.wasHidden = powerHeight == 0
	power:SetFrameLevel(self:GetFrameLevel() - 2)
	power.backdrop = B.CreateBDFrame(power, 0)
	B:SmoothBar(power)

	local bg = power:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25

	self.Power = power
	self.Power.bg = bg

	UF:UpdatePowerBarColor(self)
end

function UF:UpdateRaidNameAnchor(name)
	name:ClearAllPoints()
	name:SetWidth(self:GetWidth()*.95)
	name:SetJustifyH("CENTER")
	if C.db["UFs"]["RaidHPMode"] == 1 then
		name:SetPoint("CENTER")
	else
		name:SetPoint("TOP", 0, -3)
	end
end

function UF:UpdateRaidTextScale()
	local scale = C.db["UFs"]["RaidTextScale"]
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "tank" then
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			frame.healthValue:UpdateTag()
			if frame.powerText then frame.powerText:SetScale(scale) end
			UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
		end
	end
end

do
	if NUF.UpdateRaidTextScale then
		hooksecurefunc(NUF, "UpdateRaidTextScale", UF.UpdateRaidTextScale)
	end
end

function UF:SetUnitFrameSize(unit)
	local width = UF.db[unit.."Width"]
	local healthHeight = UF.db[unit.."Height"]
	local powerHeight = UF.db[unit.."PowerHeight"]
	local height = powerHeight == 0 and healthHeight or healthHeight + powerHeight + C.mult
	if not InCombatLockdown() then self:SetSize(width, height) end
	self.Health:SetHeight(healthHeight)
	self.Power:SetHeight(powerHeight)
	self.Power.wasHidden = powerHeight == 0
end

function UF:CheckPowerBar()
	if not self.Power then return end

	if self.Power.wasHidden then
		if self:IsElementEnabled("Power") then
			self:DisableElement("Power")
			if self.powerText then self.powerText:Hide() end
		end
	else
		if not self:IsElementEnabled("Power") then
			self:EnableElement("Power")
			self.Power:ForceUpdate()
			if self.powerText then self.powerText:Show() end
		end
	end
end

function UF:UpdateTankSize()
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "tank" then
			UF.SetUnitFrameSize(frame, "Tank")
			UF.CheckPowerBar(frame)
		end
	end
end

function UF:CreateDebuffs(self)
	local mystyle = self.mystyle
	local bu = CreateFrame("Frame", nil, self)
	bu.spacing = 3
	bu.initialAnchor = "TOPRIGHT"
	bu["growth-x"] = "LEFT"
	bu["growth-y"] = "DOWN"
	bu.tooltipAnchor = "ANCHOR_BOTTOMLEFT"
	bu.showDebuffType = true
	if mystyle == "tank" then
		bu.initialAnchor = "BOTTOMLEFT"
		bu["growth-x"] = "RIGHT"
		bu:SetPoint("BOTTOMLEFT", self.Health, C.mult, C.mult)
		bu.num = C.db["UFs"]["ShowRaidDebuff"] and 3 or 0
		bu.size = C.db["UFs"]["RaidDebuffSize"]
		bu.CustomFilter = NUF.RaidDebuffFilter
		bu.disableMouse = true
		bu.fontSize = C.db["UFs"]["RaidDebuffSize"]-2
	end

	NUF:UpdateAuraContainer(self, bu, bu.num)
	bu.PostCreateIcon = NUF.PostCreateIcon
	bu.PostUpdateIcon = NUF.PostUpdateIcon

	self.Debuffs = bu
end

function UF:OnLogin()
	UF:SetupTankFrame()
	UF:UpdateUFsFader()
end