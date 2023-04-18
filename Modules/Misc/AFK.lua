local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AFK = P:RegisterModule("AFK")
--------------------------------
-- Credit: ElvUI, ElvUI_BenikUI
--------------------------------
local _G = getfenv(0)
local floor = floor

local CloseAllWindows = CloseAllWindows
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetGuildInfo = GetGuildInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local MoveViewLeftStart = MoveViewLeftStart
local MoveViewLeftStop = MoveViewLeftStop
local Screenshot = Screenshot
local SetCVar = SetCVar
local UnitCastingInfo = UnitCastingInfo
local UnitIsAFK = UnitIsAFK
local CinematicFrame = CinematicFrame
local MovieFrame = MovieFrame
local UnitLevel = UnitLevel
local FULLDATE, CALENDAR_WEEKDAY_NAMES, CALENDAR_FULLDATE_MONTH_NAMES = FULLDATE, CALENDAR_WEEKDAY_NAMES, CALENDAR_FULLDATE_MONTH_NAMES
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local GameTime_GetLocalTime = GameTime_GetLocalTime
local TIMEMANAGER_TOOLTIP_LOCALTIME = TIMEMANAGER_TOOLTIP_LOCALTIME
local LEVEL = LEVEL

_G.LibStub("AceTimer-3.0"):Embed(AFK)

local r, g, b = DB.r, DB.g, DB.b

local CAMERA_SPEED = 0.035
local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}
local printKeys = {
	PRINTSCREEN = true,
}

if IsMacClient() then
	printKeys[_G.KEY_PRINTSCREEN_MAC] = true
end

function AFK:UpdateTimer()
	local today = C_DateAndTime_GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	AFK.AFKMode.top.date:SetFormattedText(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y)

	local _, hour, minute = GameTime_GetLocalTime(true)
	AFK.AFKMode.top.time:SetFormattedText("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_LOCALTIME, hour, minute)
end

function AFK:UpdateLogOff()
	local timePassed = GetTime() - AFK.startTime
	local minutes = floor(timePassed/60)
	local neg_seconds = -timePassed % 60

	AFK.AFKMode.top.Status:SetValue(floor(timePassed))

	if minutes - 29 == 0 and floor(neg_seconds) == 0 then
		AFK:CancelTimer(AFK.logoffTimer)
	end
end

function AFK:SetAFK(status)
	if status then
		SetCVar("autoClearAFK", "1")
		CloseAllWindows()
		MoveViewLeftStart(CAMERA_SPEED)
		AFK.AFKMode:Show()
		_G.UIParent:Hide()

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo("player")
			AFK.AFKMode.bottom.guild:SetFormattedText("%s-%s", guildName, guildRankName)
		else
			AFK.AFKMode.bottom.guild:SetText(L["No Guild"])
		end

		AFK.AFKMode.top:SetHeight(0)
		AFK.AFKMode.top.anim.height:Play()
		AFK.AFKMode.bottom:SetHeight(0)
		AFK.AFKMode.bottom.anim.height:Play()

		AFK.AFKMode.bottom.model.curAnimation = "wave"
		AFK.AFKMode.bottom.model.startTime = GetTime()
		AFK.AFKMode.bottom.model.duration = 2.3
		AFK.AFKMode.bottom.model:SetUnit("player")
		AFK.AFKMode.bottom.model.isIdle = nil
		AFK.AFKMode.bottom.model:SetAnimation(67)
		AFK.AFKMode.bottom.model.idleDuration = 40

		AFK.AFKMode.bottom.name:SetFormattedText("%s - %s\n%s %s %s %s", DB.MyName, DB.MyRealm, LEVEL, UnitLevel("player"), UnitRace("player"), UnitClass("player"))
		AFK.AFKMode.top.Status:SetValue(0)

		AFK.startTime = GetTime()
		AFK.timer = AFK:ScheduleRepeatingTimer("UpdateTimer", 1)
		AFK.logoffTimer = AFK:ScheduleRepeatingTimer("UpdateLogOff", 1)

		AFK.isAFK = true
	elseif AFK.isAFK then
		_G.UIParent:Show()
		AFK.AFKMode:Hide()
		MoveViewLeftStop()

		AFK:CancelTimer(AFK.timer)
		AFK:CancelTimer(AFK.animTimer)
		AFK:CancelTimer(AFK.logoffTimer)

		AFK.isAFK = false
	end
end

function AFK.OnEvent(event, ...)
	if event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS" then
		if event ~= "UPDATE_BATTLEFIELD_STATUS" or (GetBattlefieldStatus(...) == "confirm") then
			AFK:SetAFK(false)
		end

		if event == "PLAYER_REGEN_DISABLED" then
			B:RegisterEvent("PLAYER_REGEN_ENABLED", AFK.OnEvent)
		end

		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		B:UnregisterEvent("PLAYER_REGEN_ENABLED", AFK.OnEvent)
	end

	if not AFK.db["Enable"] or (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then return end

	if UnitCastingInfo("player") then
		AFK:ScheduleTimer("OnEvent", 30)
		return
	end

	AFK:SetAFK(UnitIsAFK("player"))
end

function AFK:Toggle()
	if AFK.db["Enable"] then
		B:RegisterEvent("PLAYER_FLAGS_CHANGED", AFK.OnEvent)
		B:RegisterEvent("PLAYER_REGEN_DISABLED", AFK.OnEvent)
		B:RegisterEvent("LFG_PROPOSAL_SHOW", AFK.OnEvent)
		B:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", AFK.OnEvent)
	else
		B:UnregisterEvent("PLAYER_FLAGS_CHANGED", AFK.OnEvent)
		B:UnregisterEvent("PLAYER_REGEN_DISABLED", AFK.OnEvent)
		B:UnregisterEvent("LFG_PROPOSAL_SHOW", AFK.OnEvent)
		B:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS", AFK.OnEvent)
	end
end

local function OnKeyDown(_, key)
	if ignoreKeys[key] then return end

	if printKeys[key] then
		Screenshot()
	else
		AFK:SetAFK(false)
		AFK:ScheduleTimer("OnEvent", 60)
	end
end

function AFK:LoopAnimations()
	local NDuiPlusAFKPlayerModel = _G.NDuiPlusAFKPlayerModel
	if NDuiPlusAFKPlayerModel.curAnimation == "wave" then
		NDuiPlusAFKPlayerModel:SetAnimation(69)
		NDuiPlusAFKPlayerModel.curAnimation = "dance"
		NDuiPlusAFKPlayerModel.startTime = GetTime()
		NDuiPlusAFKPlayerModel.duration = 300
		NDuiPlusAFKPlayerModel.isIdle = false
		NDuiPlusAFKPlayerModel.idleDuration = 120
	end
end

function AFK:OnLogin()
	AFK.AFKMode = CreateFrame("Frame", "NDuiPlus_AFKFrame")
	AFK.AFKMode:SetFrameLevel(1)
	AFK.AFKMode:SetScale(_G.UIParent:GetScale())
	AFK.AFKMode:SetAllPoints(_G.UIParent)
	AFK.AFKMode:Hide()
	AFK.AFKMode:EnableKeyboard(true)
	AFK.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	AFK.AFKMode.top = B.SetBD(AFK.AFKMode)
	AFK.AFKMode.top:SetFrameLevel(0)
	AFK.AFKMode.top:ClearAllPoints()
	AFK.AFKMode.top:SetPoint("TOP", AFK.AFKMode, "TOP", 0, C.mult)
	AFK.AFKMode.top:SetWidth(GetScreenWidth() + (C.mult * 2))

	AFK.AFKMode.top.anim = CreateAnimationGroup(AFK.AFKMode.top)
	AFK.AFKMode.top.anim.height = AFK.AFKMode.top.anim:CreateAnimation("Height")
	AFK.AFKMode.top.anim.height:SetChange(GetScreenHeight() * (1 / 20))
	AFK.AFKMode.top.anim.height:SetDuration(1)
	AFK.AFKMode.top.anim.height:SetEasing("Bounce")

	AFK.AFKMode.top.time = AFK.AFKMode.top:CreateFontString(nil, "OVERLAY")
	AFK.AFKMode.top.time:SetFont(DB.Font[1], 16, DB.Font[3])
	AFK.AFKMode.top.time:SetPoint("RIGHT", AFK.AFKMode.top, "RIGHT", -20, 0)
	AFK.AFKMode.top.time:SetJustifyH("LEFT")
	AFK.AFKMode.top.time:SetTextColor(r, g, b)

	AFK.AFKMode.top.date = AFK.AFKMode.top:CreateFontString(nil, "OVERLAY")
	AFK.AFKMode.top.date:SetFont(DB.Font[1], 16, DB.Font[3])
	AFK.AFKMode.top.date:SetPoint("LEFT", AFK.AFKMode.top, "LEFT", 20, 0)
	AFK.AFKMode.top.date:SetJustifyH("RIGHT")
	AFK.AFKMode.top.date:SetTextColor(r, g, b)

	AFK.AFKMode.top.Status = CreateFrame("StatusBar", nil, AFK.AFKMode.top)
	AFK.AFKMode.top.Status:SetStatusBarTexture(DB.normTex)
	AFK.AFKMode.top.Status:SetMinMaxValues(0, 1800)
	AFK.AFKMode.top.Status:SetStatusBarColor(r, g, b, 1)
	AFK.AFKMode.top.Status:SetFrameLevel(2)
	AFK.AFKMode.top.Status:SetPoint("TOPRIGHT", AFK.AFKMode.top, "BOTTOMRIGHT", 0, 3)
	AFK.AFKMode.top.Status:SetPoint("BOTTOMLEFT", AFK.AFKMode.top, "BOTTOMLEFT", 0, 1)
	AFK.AFKMode.top.Status:SetValue(0)

	AFK.AFKMode.bottom = B.SetBD(AFK.AFKMode)
	AFK.AFKMode.bottom:SetFrameLevel(0)
	AFK.AFKMode.bottom:ClearAllPoints()
	AFK.AFKMode.bottom:SetPoint("BOTTOM", AFK.AFKMode, "BOTTOM", 0, -C.mult)
	AFK.AFKMode.bottom:SetWidth(GetScreenWidth() + (C.mult * 2))
	AFK.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 10))

	AFK.AFKMode.bottom.anim = CreateAnimationGroup(AFK.AFKMode.bottom)
	AFK.AFKMode.bottom.anim.height = AFK.AFKMode.bottom.anim:CreateAnimation("Height")
	AFK.AFKMode.bottom.anim.height:SetChange(GetScreenHeight() * (1 / 9))
	AFK.AFKMode.bottom.anim.height:SetDuration(1)
	AFK.AFKMode.bottom.anim.height:SetEasing("Bounce")

	-- AFK.AFKMode.bottom.nlogo = AFK.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	-- AFK.AFKMode.bottom.nlogo:SetSize(128, 64)
	-- AFK.AFKMode.bottom.nlogo:SetPoint("LEFT", 25, 0)
	-- AFK.AFKMode.bottom.nlogo:SetTexture(DB.logoTex)

	-- AFK.AFKMode.bottom.nlogo = B.CreateFS(AFK.AFKMode.bottom, 26, "NDui", true, "LEFT", 25, 0)
	-- AFK.AFKMode.bottom.nversion = B.CreateFS(AFK.AFKMode.bottom, 12, DB.Version, true)
	-- AFK.AFKMode.bottom.nversion:SetPoint("TOP", AFK.AFKMode.bottom.nlogo, "BOTTOM", 0, -10)
	-- AFK.AFKMode.bottom.nversion:SetTextColor(0.7, 0.7, 0.7)

	AFK.AFKMode.bottom.factionb = CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.bottom.factionb:SetPoint("BOTTOM", AFK.AFKMode.bottom, "TOP", 0, -30)
	AFK.AFKMode.bottom.factionb:SetFrameStrata("MEDIUM")
	AFK.AFKMode.bottom.factionb:SetFrameLevel(10)
	AFK.AFKMode.bottom.factionb:SetSize(220, 220)

	AFK.AFKMode.bottom.class = AFK.AFKMode.bottom.factionb:CreateTexture(nil, "OVERLAY")
	AFK.AFKMode.bottom.class:SetAllPoints()
	AFK.AFKMode.bottom.class:SetTexture("Interface\\AddOns\\NDui_Plus\\Media\\Texture\\ClassIcons\\CLASS-" .. DB.MyClass)

	AFK.AFKMode.bottom.name = AFK.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	AFK.AFKMode.bottom.name:SetFont(DB.Font[1], 18, DB.Font[3])
	AFK.AFKMode.bottom.name:SetPoint("TOP", AFK.AFKMode.bottom.factionb, "BOTTOM", 0, -5)
	AFK.AFKMode.bottom.name:SetTextColor(r, g, b)
	AFK.AFKMode.bottom.name:SetJustifyH("CENTER")

	AFK.AFKMode.bottom.guild = AFK.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	AFK.AFKMode.bottom.guild:SetFont(DB.Font[1], 16, DB.Font[3])
	AFK.AFKMode.bottom.guild:SetPoint("TOP", AFK.AFKMode.bottom.name, "BOTTOM", 0, -6)
	AFK.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)
	AFK.AFKMode.bottom.guild:SetJustifyH("CENTER")

	AFK.AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, AFK.AFKMode.bottom)
	AFK.AFKMode.bottom.modelHolder:SetSize(150, 150)
	AFK.AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", AFK.AFKMode.bottom, "BOTTOMRIGHT", -200, 220)

	AFK.AFKMode.bottom.model = CreateFrame("PlayerModel", "NDuiPlusAFKPlayerModel", AFK.AFKMode.bottom.modelHolder)
	AFK.AFKMode.bottom.model:SetPoint("CENTER", AFK.AFKMode.bottom.modelHolder, "CENTER")
	AFK.AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
	AFK.AFKMode.bottom.model:SetCamDistanceScale(4.5)
	AFK.AFKMode.bottom.model:SetFacing(6)
	AFK.AFKMode.bottom.model:SetScript("OnUpdate", function(model)
		if not model.isIdle then
			local timePassed = GetTime() - model.startTime
			if timePassed > model.duration then
				model:SetAnimation(0)
				model.isIdle = true
				AFK.animTimer = AFK:ScheduleTimer("LoopAnimations", model.idleDuration)
			end
		end
	end)

	AFK:Toggle()
end