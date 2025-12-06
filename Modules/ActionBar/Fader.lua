local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:GetModule("ActionBar")
local Bar = B:GetModule("Actionbar")
-----------------
-- Credit: ElvUI
-----------------
local LAB = LibStub("LibActionButton-1.0-NDui")

AB.handledbuttons = {}

local function ClearTimers(object)
	if object.delayTimer then
		P:CancelTimer(object.delayTimer)
		object.delayTimer = nil
	end
end

local function DelayFadeOut(frame, timeToFade, startAlpha, endAlpha)
	ClearTimers(frame)

	if AB.db["Delay"] > 0 then
		frame.delayTimer = P:ScheduleTimer(P.UIFrameFadeOut, AB.db["Delay"], P, frame, timeToFade, startAlpha, endAlpha)
	else
		P:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	end
end

function AB:FadeBlingTexture(cooldown, alpha)
	if not cooldown then return end
	cooldown:SetBlingTexture(alpha > 0.5 and [[Interface\Cooldown\star4]] or P.Blank)
end

function AB:FadeBlings(alpha)
	for _, button in pairs(Bar.buttons) do
		AB:FadeBlingTexture(button.cooldown, alpha)
	end
end

function AB:Button_OnEnter()
	if not AB.fadeParent.mouseLock then
		ClearTimers(AB.fadeParent)
		P:UIFrameFadeIn(AB.fadeParent, .2, AB.fadeParent:GetAlpha(), 1)
		AB:FadeBlings(1)
	end
end

function AB:Button_OnLeave()
	if not AB.fadeParent.mouseLock then
		DelayFadeOut(AB.fadeParent, .38, AB.fadeParent:GetAlpha(), AB.db["Alpha"])
		AB:FadeBlings(AB.db["Alpha"])
	end
end

local function flyoutButtonAnchor(frame)
	local parent = frame:GetParent()
	local _, parentAnchorButton = parent:GetPoint()
	if not AB.handledbuttons[parentAnchorButton] then return end

	return parentAnchorButton
end

function AB:FlyoutButton_OnEnter()
	local anchor = flyoutButtonAnchor(self)
	if anchor then AB.Button_OnEnter(anchor) end
end

function AB:FlyoutButton_OnLeave()
	local anchor = flyoutButtonAnchor(self)
	if anchor then AB.Button_OnLeave(anchor) end
end

local function CanGlide()
	local isGliding, canGlide = C_PlayerInfo.GetGlidingInfo()
	return isGliding or canGlide
end

local canGlide = false
function AB:FadeParent_OnEvent(event, arg)
	if event == "PLAYER_CAN_GLIDE_CHANGED" then
		canGlide = arg
	end

	if
		(event == "ACTIONBAR_SHOWGRID") or
		(AB.db["Combat"] and UnitAffectingCombat("player")) or
		(AB.db["Target"] and UnitExists("target")) or
		(AB.db["Casting"] and (UnitCastingInfo("player") or UnitChannelInfo("player"))) or
		(AB.db["Health"] and (UnitHealth("player") ~= UnitHealthMax("player"))) or
		(AB.db["Vehicle"] and UnitHasVehicleUI("player")) or
		(AB.db["DynamicFlight"] and (canGlide or CanGlide()))
	then
		self.mouseLock = true
		ClearTimers(AB.fadeParent)
		P:UIFrameFadeIn(self, .2, self:GetAlpha(), 1)
		AB:FadeBlings(1)
	else
		self.mouseLock = false
		DelayFadeOut(self, .38, self:GetAlpha(), AB.db["Alpha"])
		AB:FadeBlings(AB.db["Alpha"])
	end
end

local options = {
	Combat = {
		enable = function(self)
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterUnitEvent("UNIT_FLAGS", "player")
		end,
		events = {"PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "UNIT_FLAGS"}
	},
	Target = {
		enable = function(self)
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		end,
		events = {"PLAYER_TARGET_CHANGED"}
	},
	Casting = {
		enable = function(self)
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
		end,
		events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP"}
	},
	Health = {
		enable = function(self)
			self:RegisterUnitEvent("UNIT_HEALTH", "player")
		end,
		events = {"UNIT_HEALTH"}
	},
	Vehicle = {
		enable = function(self)
			self:RegisterEvent("UNIT_ENTERED_VEHICLE")
			self:RegisterEvent("UNIT_EXITED_VEHICLE")
			self:RegisterEvent("VEHICLE_UPDATE")
		end,
		events = {"UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "VEHICLE_UPDATE"}
	},
	DynamicFlight = {
		enable = function(self)
			self:RegisterEvent("PLAYER_CAN_GLIDE_CHANGED")
		end,
		events = {"PLAYER_CAN_GLIDE_CHANGED"}
	}
}

function AB:UpdateFaderSettings()
	for key, option in pairs(options) do
		if AB.db[key] then
			if option.enable then
				option.enable(AB.fadeParent)
			end
		else
			if option.events and next(option.events) then
				for _, event in ipairs(option.events) do
					AB.fadeParent:UnregisterEvent(event)
				end
			end
		end
	end

	AB.FadeParent_OnEvent(AB.fadeParent)
end

local NDui_ActionBar = {
	["Bar1"] = "NDui_ActionBar1",
	["Bar2"] = "NDui_ActionBar2",
	["Bar3"] = "NDui_ActionBar3",
	["Bar4"] = "NDui_ActionBar4",
	["Bar5"] = "NDui_ActionBar5",
	["Bar6"] = "NDui_ActionBar6",
	["Bar7"] = "NDui_ActionBar7",
	["Bar8"] = "NDui_ActionBar8",
	["PetBar"] = "NDui_ActionBarPet",
	["StanceBar"] = "NDui_ActionBarStance",
}

local function updateAfterCombat(event)
	AB:UpdateFaderState()
	B:UnregisterEvent(event, updateAfterCombat)
end

function AB:UpdateFaderState()
	if InCombatLockdown() then
		B:RegisterEvent("PLAYER_REGEN_ENABLED", updateAfterCombat)
		return
	end

	for key, name in pairs(NDui_ActionBar) do
		local bar = _G[name]
		if bar then
			bar:SetParent(AB.db[key] and AB.fadeParent or UIParent)
		end
	end

	if not AB.isHooked then
		for _, button in ipairs(Bar.buttons) do
			button:HookScript("OnEnter", AB.Button_OnEnter)
			button:HookScript("OnLeave", AB.Button_OnLeave)

			AB.handledbuttons[button] = true
		end

		AB.isHooked = true
	end
end

function AB:SetupFlyoutButton(button)
	button:HookScript("OnEnter", AB.FlyoutButton_OnEnter)
	button:HookScript("OnLeave", AB.FlyoutButton_OnLeave)
end

function AB:LAB_FlyoutCreated(button)
	AB:SetupFlyoutButton(button)
end

function AB:SetupLABFlyout()
	for _, button in next, LAB.FlyoutButtons do
		AB:SetupFlyoutButton(button)
	end

	LAB:RegisterCallback("OnFlyoutButtonCreated", AB.LAB_FlyoutCreated)
end

function AB:GlobalFade()
	if not AB.db["GlobalFade"] then return end
	if P.isMidnight then return end

	AB.fadeParent = CreateFrame("Frame", "NDuiPlus_Fader", _G.UIParent, "SecureHandlerStateTemplate")
	RegisterStateDriver(AB.fadeParent, "visibility", "[petbattle] hide; show")
	AB.fadeParent:SetAlpha(AB.db["Alpha"])
	AB.fadeParent:RegisterEvent("ACTIONBAR_SHOWGRID")
	AB.fadeParent:RegisterEvent("ACTIONBAR_HIDEGRID")
	AB.fadeParent:SetScript("OnEvent", AB.FadeParent_OnEvent)

	AB:UpdateFaderSettings()
	AB:UpdateFaderState()
	AB:SetupLABFlyout()
end