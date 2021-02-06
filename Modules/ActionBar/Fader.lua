local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:RegisterModule("ActionBar")
local Bar = B:GetModule("Actionbar")
-----------------
-- Credit: ElvUI
-----------------
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

function AB:FadeParent_OnEvent(event)
	if UnitCastingInfo("player") or UnitChannelInfo("player") or UnitExists("target")
	or UnitAffectingCombat("player") or (UnitHealth("player") ~= UnitHealthMax("player"))
	or event == "ACTIONBAR_SHOWGRID" then
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
		end,
		events = {"PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED"}
	},
	Target = {
		enable = function(self)
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		end,
		events = {"PLAYER_TARGET_CHANGED"}
	},
	Cast = {
		enable = function(self)
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
		end,
		events = {"UNIT_SPELLCAST_START","UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_STOP"}
	},
	Health = {
		enable = function(self)
			self:RegisterUnitEvent("UNIT_HEALTH", "player")
		end,
		events = {"UNIT_HEALTH"}
	},
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
end

local NDui_ActionBar = {
	["Bar1"] = "NDui_ActionBar1",
	["Bar2"] = "NDui_ActionBar2",
	["Bar3"] = "NDui_ActionBar3",
	["Bar4"] = "NDui_ActionBar4",
	["Bar5"] = "NDui_ActionBar5",
	["CustomBar"] = "NDui_CustomBar",
	["PetBar"] = "NDui_ActionBarPet",
	["StanceBar"] = "NDui_ActionBarStance",
}

local function updateAfterCombat(event)
	AB:UpdateActionBar()
	B:UnregisterEvent(event, updateAfterCombat)
end

function AB:UpdateActionBar()
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
		end
		AB.isHooked = true
	end
end

function AB:GlobalFade()
	if not AB.db["GlobalFade"] then return end

	AB.fadeParent = CreateFrame("Frame", "NDuiPlus_Fader", _G.UIParent, "SecureHandlerStateTemplate")
	RegisterStateDriver(AB.fadeParent, "visibility", "[petbattle] hide; show")
	AB.fadeParent:SetAlpha(AB.db["Alpha"])
	AB.fadeParent:RegisterEvent("ACTIONBAR_SHOWGRID")
	AB.fadeParent:RegisterEvent("ACTIONBAR_HIDEGRID")
	AB.fadeParent:SetScript("OnEvent", AB.FadeParent_OnEvent)

	AB:UpdateFaderSettings()

	local function loadFunc(event, addon)
		AB:UpdateActionBar()
		B:UnregisterEvent(event, loadFunc)
	end
	B:RegisterEvent("PLAYER_ENTERING_WORLD", loadFunc)
end

function AB:OnLogin()	
	AB:GlobalFade()
	AB:ComboGlow()
end