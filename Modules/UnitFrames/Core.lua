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

-- Elements
UF.smoothbars = {}
function UF:SmoothBar(bar)
	bar.smoothing = NDuiADB["SmoothBars"] and Enum.StatusBarInterpolation.ExponentialEaseOut or Enum.StatusBarInterpolation.Immediate
	UF.smoothbars[bar] = true
end

local function UpdateHealthColorByIndex(health, index)
	local useClassGradient = index == 5
	health.colorClass = (index == 2) or useClassGradient
	health.colorReaction = (index == 2) or useClassGradient
	health:SetStatusBarTexture(useClassGradient and DB.classGradientTex or DB.normTex)
	if health.SetColorTapping then
		health:SetColorTapping(index == 2)
	else
		health.colorTapping = (index == 2)
	end
	if health.SetColorDisconnected then
		health:SetColorDisconnected(index == 2)
	else
		health.colorDisconnected = (index == 2)
	end
	health.colorSmooth = (index == 3)
	if index == 1 then
		health:SetStatusBarColor(.1, .1, .1)
		health.bg:SetVertexColor(.6, .6, .6)
	elseif index == 2 or index == 3 then
		health.bg:SetVertexColor(0, 0, 0, .7)
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

local bgCurve = C_CurveUtil.CreateColorCurve()
bgCurve:SetType(Enum.LuaCurveType.Linear)
bgCurve:AddPoint(0.0, CreateColor(1, 0, 0))
bgCurve:AddPoint(0.5, CreateColor(1, .7, 0))
bgCurve:AddPoint(1, CreateColor(.7, 1, 0))

function UF.HealthPostUpdate(element, unit, cur, max)
	local self = element.__owner
	local mystyle = self.mystyle
	local useGradient
	if mystyle == "tank" then
		useGradient = C.db["UFs"]["RaidHealthColor"] > 3
	end
	if useGradient then
		local color = UnitHealthPercent(unit, true, bgCurve)
		element.bg:SetVertexColor(color:GetRGB())
	end
end

function UF:CreateHealthBar(self)
	local mystyle = self.mystyle
	local health = CreateFrame("StatusBar", nil, self)
	health:SetPoint("TOPLEFT", self)
	health:SetPoint("TOPRIGHT", self)
	UF:SmoothBar(health)
	local healthHeight
	if mystyle == "tank" then
		healthHeight = UF.db["TankHeight"]
	end
	health:SetHeight(healthHeight)
	health:SetStatusBarTexture(DB.normTex)
	health:SetStatusBarColor(.1, .1, .1)
	health:SetFrameLevel(max(self:GetFrameLevel() - 2, 0))

	self.backdrop = B.SetBD(health, 0)
	if self.backdrop.__shadow then
		self.backdrop.__shadow:SetOutside(self, 4 + C.mult, 4 + C.mult)
		self.backdrop.__shadow:SetFrameLevel(0)
		self.backdrop.__shadow = nil
	end

	local bg = self:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	bg:SetPoint("BOTTOMRIGHT", health)
	bg:SetTexture(DB.bdTex)
	bg:SetVertexColor(.6, .6, .6)

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
	UF:SmoothBar(power)
	local powerHeight
	if mystyle == "tank" then
		powerHeight = UF.db["TankPowerHeight"]
	end
	power:SetHeight(powerHeight)
	power.wasHidden = powerHeight == 0
	power:SetFrameLevel(max(self:GetFrameLevel() - 2, 0))
	power.backdrop = B.CreateBDFrame(power, 0)

	local bg = power:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg:SetVertexColor(0, 0, 0, .7)

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
			UF.UpdateRaidNameAnchor(frame, frame.nameText)
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			frame.healthValue:UpdateTag()
			if frame.powerText then frame.powerText:SetScale(scale) end
			UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
			frame.disableTooltip = C.db["UFs"]["HideTip"]
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

local RAID_DEBUFF_BLACKLIST = {
	[57723] = true, -- 筋疲力尽 / Exhaustion
	[57724] = true, -- 心满意足 / Sated
	[80354] = true, -- 时空错位 / Temporal Displacement
	[95809] = true, -- 疯狂 / Insanity
	[160455] = true, -- 疲倦 / Fatigued
	[264689] = true, -- 疲倦 / Fatigued
	[390435] = true, -- 筋疲力尽 / Exhaustion
	[26013] = true, -- 逃亡者 / Deserter
	[71041] = true, -- 地下城逃亡者 / Dungeon Deserter
	[1313593] = true, -- 逃亡者 / Deserter
	[206151] = true, -- 挑战者的负担 / Challenger's Burden
	[308312] = true, -- 限时试炼练习 / Time Trial Practice
	[1254550] = true, -- 奥术强化 / Arcane Empowerment
}

local RAID_DEBUFF_GROUPS = {
	{ -- Boss and role auras
		filter = "HARMFUL",
		candidateFilters = {
			isBossOrRoleAura = true,
			isFromPlayerOrPlayerPet = false,
		},
	},
	{ -- Other priority auras
		filter = "HARMFUL",
		candidateFilters = {
			isBossOrRoleAura = false,
			isPriorityAura = true,
			isFromPlayerOrPlayerPet = false,
		},
	},
	{ -- Dispellable auras
		filter = "HARMFUL|DISPELLABLE",
		candidateFilters = {
			isBossOrRoleAura = false,
			isPriorityAura = false,
		},
	},
	{ -- Other regular auras
		filter = "HARMFUL|!DISPELLABLE",
		candidateFilters = {
			isBossOrRoleAura = false,
			isPriorityAura = false,
			isFromPlayerOrPlayerPet = false,
			excludeSpellIDs = RAID_DEBUFF_BLACKLIST,
		},
	},
}

local function CreateAuraElement(self, options)
	local element = self:CreateAuras({
		initialAnchor = options.initialAnchor,
		growthX = options.growthX,
		growthY = options.growthY,
		layout = AnchorUtil.FlowLayoutAxis.Horizontal,
		layoutLimit = self:GetWidth(),
	})

	element.__groups = {}
	element.__value = options.value
	element.spacing = options.spacing or 0
	element.groupSpacing = options.groupSpacing
	element.fontSize = options.fontSize
	element.hideDuration = options.hideDuration
	element.sizeRatio = options.sizeRatio or 1
	element.disableMouse = options.disableMouse
	element.showDebuffBorder = options.showDebuffBorder
	element.showCount = true
	element.showDuration = false
	element.showStealableBorder = true
	element.PostCreateButton = UF.PostCreateButton
	return element
end

function UF:CreateDebuffs(self)
	local mystyle = self.mystyle
	local value = "Raid"
	local bu = CreateAuraElement(self, {
		initialAnchor = "BOTTOMRIGHT",
		growthX = "LEFT",
		growthY = "UP",
		spacing = 2,
		value = value,
		disableMouse = true,
	})
	bu.__auraType = "debuffs"
	bu:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -2, 2)

	UF:ConfigureBuffAndDebuff(bu, true)
	if mystyle == "raid" and bu.__filterType == 2 then
		for index, group in ipairs(RAID_DEBUFF_GROUPS) do
			AddAuraGroup(bu, RAID_DEBUFF_GROUP_NAME..index, group.filter, bu.num, index, group.candidateFilters, AuraContainerSortMethod.Default)
		end
	else
		AddAuraGroup(bu, "Debuffs", bu.filter, bu.num, 1)
	end
	UF:UpdateAuraContainer(self, bu)

	self.Debuffs = bu
end

function UF:OnLogin()
	-- UF:SetupTankFrame()
	UF:UpdateRoleIcons()
	UF:UpdateUFsFader()
end