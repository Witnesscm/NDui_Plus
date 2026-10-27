local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local QF = P:RegisterModule("QuickFocus")

local modKeyList = { "shift", "ctrl", "alt" }
local unitframes = {}
local pending = {}

function QF:SetupFrame()
	if not self or self.quickFocus then
		return
	end

	local name = self.GetName and self:GetName()
	if name and strmatch(name, "oUF_NPs") then
		return
	end

	local mystyle = self.mystyle
	if mystyle and mystyle == "raid" then
		return
	end

	if not InCombatLockdown() then
		self:SetAttribute(modKeyList[QF.db["Modifier"]] .. "-type" .. QF.db["Button"], "macro")
		self:SetAttribute("macrotext", QF.MacroText)
		self.quickFocus = true
		unitframes[self] = true
		pending[self] = nil
	else
		pending[self] = true
	end
end

function QF:CreateFrameHook(name, _, template)
	if name and template == "SecureUnitButtonTemplate" then
		QF.SetupFrame(_G[name])
	end
end

function QF.OnEvent(event)
	if event == "PLAYER_REGEN_ENABLED" then
		if next(pending) then
			for frame in next, pending do
				QF.SetupFrame(frame)
			end
		end
	else
		for _, object in next, oUF.objects do
			if not object.quickFocus then
				QF.SetupFrame(object)
			end
		end
	end
end

function QF:GetMacroText()
	local lines = {"/focus mouseover"}

	if QF.db["SetMarker"] and QF.db["MarkerIndex"] and QF.db["MarkerIndex"] >= 1 and QF.db["MarkerIndex"] <= 8 then
		if QF.db["DisableInRaid"] then
			tAppendAll(lines, {
				"/stopmacro [group:raid]"
			})
		end
		local markerIndex = QF.db["MarkerIndex"]
		if QF.db["KeepExistingMarker"] then
			markerIndex = "~"..markerIndex
		end
		tAppendAll(lines, {
			"/tm [@focus,exists,harm,nodead] "..markerIndex
		})
	end

	return strjoin("\n", unpack(lines))
end

function QF:UpdateMacroText()
	local button = QF.QuickFocusButton
	if not button or InCombatLockdown() then
		return
	end

	QF.MacroText = QF:GetMacroText()
	button:SetAttribute("macrotext", QF.MacroText)

	for frame in next, unitframes do
		frame:SetAttribute("macrotext", QF.MacroText)
	end
end

function QF:AnnounceFocusMarker()
	if QF.db["SetMarker"] and QF.db["AnnounceMarker"] and QF.db["MarkerIndex"] and QF.db["MarkerIndex"] >= 1 and QF.db["MarkerIndex"] <= 8 and not IsInRaid() then
		C_ChatInfo.SendChatMessage(format(L["FocusMarkerChatAnnouncement"], QF.db["MarkerIndex"]), "PARTY")
	end
end

function QF:OnLogin()
	if not QF.db["Enable"] then return end

	QF.MacroText = QF:GetMacroText()

	local button = CreateFrame("Button", "NPQuickFocusButton", UIParent, "SecureActionButtonTemplate")
	button:SetAttribute("type*", "macro")
	button:SetAttribute("macrotext", QF.MacroText)
	button:RegisterForClicks("AnyUp", "AnyDown")
	SetOverrideBindingClick(button, true, modKeyList[QF.db["Modifier"]] .. "-BUTTON" .. QF.db["Button"], button:GetName())
	QF.QuickFocusButton = button

	hooksecurefunc("CreateFrame", QF.CreateFrameHook)
	QF:OnEvent()
	B:RegisterEvent("PLAYER_REGEN_ENABLED", QF.OnEvent)
	B:RegisterEvent("GROUP_ROSTER_UPDATE", QF.OnEvent)
	B:RegisterEvent("READY_CHECK", QF.AnnounceFocusMarker)
end