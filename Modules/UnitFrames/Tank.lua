local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local UF = P:GetModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

local headers = {}

local function CreateTankStyle(self)
	self.mystyle = "tank"
	self.Range = {
		insideAlpha = 1, outsideAlpha = .4,
	}

	NUF:CreateHeader(self, true)
	UF:CreateHealthBar(self)
	NUF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	NUF:CreateRaidMark(self)
	NUF:CreateTargetBorder(self)
	NUF:CreatePrediction(self)
	NUF:CreateClickSets(self)
	NUF:CreateThreatBorder(self)
	NUF:CreateBuffIndicator(self)
	NUF:CreateRaidDebuffs(self)
	UF:CreateDebuffs(self)

	UF.SetUnitFrameSize(self, "Tank")
end

local function Range_Update(self)
	local element = self.Range
	local unit = strmatch(self.unit, "(.+)target$") or self.unit

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local inRange, checkedRange
	local connected = UnitIsConnected(unit)
	if(connected) then
		inRange, checkedRange = UnitInRange(unit)
		if(checkedRange and not inRange) then
			self:SetAlpha(element.outsideAlpha)
		else
			self:SetAlpha(element.insideAlpha)
		end
	else
		self:SetAlpha(element.insideAlpha)
	end

	if(element.PostUpdate) then
		return element:PostUpdate(self, inRange, checkedRange, connected)
	end
end

local function CreateTankTargetStyle(self)
	self.mystyle = "tank"
	self.isTarget = true
	self.Range = {
		insideAlpha = 1, outsideAlpha = .4,
		Override = Range_Update
	}

	NUF:CreateHeader(self)
	UF:CreateHealthBar(self)
	NUF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	NUF:CreateRaidMark(self)

	UF.SetUnitFrameSize(self, "Tank")
end

UF.TankDirections = {
	[1] = {name = L["GO_DOWN"], point = "TOP", xOffset = 0, yOffset = -5, initAnchor = "TOPLEFT"},
	[2] = {name = L["GO_UP"], point = "BOTTOM", xOffset = 0, yOffset = 5, initAnchor = "BOTTOMLEFT"},
	[3] = {name = L["GO_RIGHT"], point = "LEFT", xOffset = 5, yOffset = 0, initAnchor = "TOPLEFT"},
	[4] = {name = L["GO_LEFT"], point = "RIGHT", xOffset = -5, yOffset = 0, initAnchor = "TOPRIGHT"},
}

local TargetAnchors = {
	[1] = {point = "TOPLEFT", relPoint = "TOPRIGHT", xOffset = 6, yOffset = 0},
	[2] = {point = "BOTTOMLEFT", relPoint = "BOTTOMRIGHT", xOffset = 6, yOffset = 0},
	[3] = {point = "TOPLEFT", relPoint = "BOTTOMLEFT", xOffset = 0, yOffset = -6},
	[4] = {point = "TOPRIGHT", relPoint = "BOTTOMRIGHT", xOffset = 0, yOffset = -6},
}

function UF:SetupTankFrame()
	if not UF.db["TankFrame"] then return end

	oUF:RegisterStyle("Tank", CreateTankStyle)
	oUF:SetActiveStyle("Tank")

	local offset = 5
	local tankDirec = UF.db["TankDirec"]
	local horizon = tankDirec > 2
	local tankWidth, tankHeight = UF.db["TankWidth"], UF.db["TankHeight"]
	local tankPower = UF.db["TankPowerHeight"]
	local tankFrameHeight = tankHeight + tankPower + C.mult
	local tankMoverWidth = horizon and tankWidth*5+offset*4 or tankWidth
	local tankMoverHeight = horizon and tankFrameHeight or tankFrameHeight*5+offset*4
	local enableTarget = UF.db["TankTarget"]
	local sortData = UF.TankDirections[tankDirec]

	local tank = oUF:SpawnHeader("oUF_Tank", nil, nil,
	"showPlayer", true,
	"showSolo", true,
	"showParty", true,
	"showRaid", true,
	"oUF-initialConfigFunction", ([[
	self:SetWidth(%d)
	self:SetHeight(%d)
	]]):format(tankWidth, tankFrameHeight))
	--enableTarget and "template", enableTarget and "ELVUI_UNITTARGET")
	tank:SetAttribute("point", sortData.point)
	tank:SetAttribute("xOffset", sortData.xOffset)
	tank:SetAttribute("yOffset", sortData.yOffset)
	tinsert(headers, tank)
	RegisterStateDriver(tank, "visibility", "[group:raid] show;hide")

	if enableTarget then
		oUF:RegisterStyle("TankTarget", CreateTankTargetStyle)
		oUF:SetActiveStyle("TankTarget")

		local targetOffset = 6
		if horizon then
			tankMoverHeight = tankFrameHeight*2+targetOffset
		else
			tankMoverWidth = tankWidth*2+targetOffset
		end

		local tankTarget = oUF:SpawnHeader("oUF_TankTarget", nil, nil,
		"showPlayer", true,
		"showSolo", true,
		"showParty", true,
		"showRaid", true,
		"oUF-initialConfigFunction", ([[
		self:SetWidth(%d)
		self:SetHeight(%d)
		self:SetAttribute("unitsuffix", "target")
		]]):format(tankWidth, tankFrameHeight))
		tankTarget:SetAttribute("point", sortData.point)
		tankTarget:SetAttribute("xOffset", sortData.xOffset)
		tankTarget:SetAttribute("yOffset", sortData.yOffset)
		tinsert(headers, tankTarget)
		RegisterStateDriver(tankTarget, "visibility", "[group:raid] show;hide")

		local anchor = TargetAnchors[tankDirec]
		tankTarget:ClearAllPoints()
		tankTarget:SetPoint(anchor.point, tank, anchor.relPoint, anchor.xOffset, anchor.yOffset)
	end

	local tankMover = B.Mover(tank, L["TankFrame"], "TankFrame", {"TOPLEFT", UIParent, 35, -414}, tankMoverWidth, tankMoverHeight)
	tank:ClearAllPoints()
	tank:SetPoint(sortData.initAnchor, tankMover)

	UF:UpdateTankHeaders()
end

function UF:UpdateTankHeaders()
	for _, header in pairs(headers) do
		header:SetAttribute("roleFilter", UF.db["TankFilter"] == 1 and "TANK" or "MAINTANK")
	end
end