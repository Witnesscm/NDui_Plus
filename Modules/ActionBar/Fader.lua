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

local blings = {}
function AB:FadeBlingTexture(cooldown, alpha)
	if not cooldown then return end

	local texture = (alpha and alpha > 0.5) and 131010 or P.Blank
	if blings[cooldown] ~= texture then
		cooldown:SetBlingTexture(texture)

		blings[cooldown] = texture
	end
end

function AB:FadeBlings(alpha)
	for _, button in pairs(Bar.buttons) do
		AB:FadeBlingTexture(button.cooldown, alpha)
	end
end

function AB:Bar_OnEnter()
	if self:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		ClearTimers(AB.fadeParent)
		P:UIFrameFadeIn(AB.fadeParent, .2, AB.fadeParent:GetAlpha(), 1)
		AB:FadeBlings(1)
	end
	AB.fadeParent.mouseover = true
end

function AB:Bar_OnLeave()
	if self:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		DelayFadeOut(AB.fadeParent, .38, AB.fadeParent:GetAlpha(), AB.db["Alpha"])
		AB:FadeBlings(AB.db["Alpha"])
	end
	AB.fadeParent.mouseover = false
end

function AB:Bar3R_OnEnter()
	local bar = self:GetParent()
	if self.mover and self.mover.isDisable == false then
		AB.Bar_OnEnter(bar)
	end
end

function AB:Bar3R_OnLeave()
	local bar = self:GetParent()
	if self.mover and self.mover.isDisable == false then
		AB.Bar_OnLeave(bar)
	end
end

function AB:Button_OnEnter()
	local bar = self:GetParent()
	AB.Bar_OnEnter(bar)
end

function AB:Button_OnLeave()
	local bar = self:GetParent()
	AB.Bar_OnLeave(bar)
end

local function SpellFlyoutAnchor(frame)
	local _, anchorButton = frame:GetPoint()
	if not AB.handledbuttons[anchorButton] then return end

	return anchorButton:GetParent()
end

function AB:SpellFlyout_OnEnter()
	local anchor = SpellFlyoutAnchor(self)
	if anchor then AB.Bar_OnEnter(anchor) end
end

function AB:SpellFlyout_OnLeave()
	local anchor = SpellFlyoutAnchor(self)
	if anchor then AB.Bar_OnLeave(anchor) end
end

function AB:FlyoutButton_OnEnter()
	local bar = self:GetParent()
	AB.SpellFlyout_OnEnter(bar)
end

function AB:FlyoutButton_OnLeave()
	local bar = self:GetParent()
	AB.SpellFlyout_OnLeave(bar)
end

function AB:MicroButton_OnEnter()
	local bar = self.__owner and self.__owner:GetParent() or self:GetParent()
	if bar then AB.Bar_OnEnter(bar) end
end

function AB:MicroButton_OnLeave()
	local bar = self.__owner and self.__owner:GetParent() or self:GetParent()
	if bar then AB.Bar_OnLeave(bar) end
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
		-- (AB.db["Health"] and (UnitHealth("player") ~= UnitHealthMax("player"))) or
		(AB.db["Vehicle"] and UnitHasVehicleUI("player")) or
		(AB.db["DynamicFlight"] and (canGlide or CanGlide()))
	then
		if not self.mouseLock then
			self.mouseLock = true
			ClearTimers(AB.fadeParent)
			P:UIFrameFadeIn(self, .2, self:GetAlpha(), 1)
			AB:FadeBlings(1)
		end
	elseif self.mouseLock then
		self.mouseLock = false
		if not self.mouseover then
			DelayFadeOut(self, .38, self:GetAlpha(), AB.db["Alpha"])
			AB:FadeBlings(AB.db["Alpha"])
		end
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

function AB:SetupActionBar()
	for key, name in pairs(NDui_ActionBar) do
		local bar = _G[name]
		if bar then
			if key == "StanceBar" then
				local hitInset = C.Bars.margin / 2
				for _, button in pairs(bar.buttons) do
					button:SetHitRectInsets(-hitInset, -hitInset, -hitInset, -hitInset)
				end
			else
				bar:HookScript("OnEnter", AB.Bar_OnEnter)
				bar:HookScript("OnLeave", AB.Bar_OnLeave)

				if bar.child then
					bar.child:HookScript("OnEnter", AB.Bar3R_OnEnter)
					bar.child:HookScript("OnLeave", AB.Bar3R_OnLeave)
				end
			end
		end
	end

	for _, button in ipairs(Bar.buttons) do
		button:HookScript("OnEnter", AB.Button_OnEnter)
		button:HookScript("OnLeave", AB.Button_OnLeave)

		AB.handledbuttons[button] = true
	end
end

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

	if AB.MicroMenu then
		AB.MicroMenu:SetParent(AB.db["MicroMenu"] and AB.fadeParent or UIParent)
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

	if LAB.flyoutHandler then
		LAB.flyoutHandler:HookScript("OnEnter", AB.SpellFlyout_OnEnter)
		LAB.flyoutHandler:HookScript("OnLeave", AB.SpellFlyout_OnLeave)
	end

	LAB:RegisterCallback("OnFlyoutButtonCreated", AB.LAB_FlyoutCreated)
end

do
	if type(Bar.MicroButton_Create) == "function" then
		hooksecurefunc(Bar, "MicroButton_Create", function(_, parent)
			if not AB.MicroMenu then
				AB.MicroMenu = parent
			end
		end)
	end
end

function AB:SetupMicroMenu()
	if not AB.MicroMenu then
		return
	end

	AB.MicroMenu:HookScript("OnEnter", AB.Bar_OnEnter)
	AB.MicroMenu:HookScript("OnLeave", AB.Bar_OnLeave)

	for _, child in pairs({ AB.MicroMenu:GetChildren() }) do
		if child ~= AB.MicroMenu.mover then
			local button = child:GetChildren() or child
			button:HookScript("OnEnter", AB.MicroButton_OnEnter)
			button:HookScript("OnLeave", AB.MicroButton_OnLeave)
		end
	end
end

function AB:GlobalFade()
	if not AB.db["GlobalFade"] then return end

	AB.fadeParent = CreateFrame("Frame", "NDuiPlus_ABFader", _G.UIParent)
	AB.fadeParent:SetAlpha(AB.db["Alpha"])
	AB.fadeParent:RegisterEvent("ACTIONBAR_SHOWGRID")
	AB.fadeParent:RegisterEvent("ACTIONBAR_HIDEGRID")
	AB.fadeParent:SetScript("OnEvent", AB.FadeParent_OnEvent)

	AB:SetupActionBar()
	AB:SetupLABFlyout()
	AB:SetupMicroMenu()
	AB:UpdateFaderSettings()
	AB:UpdateFaderState()
end