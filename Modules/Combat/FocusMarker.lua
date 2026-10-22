local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local FM = P:RegisterModule("FocusMarker")
local M = B:GetModule("Misc")

-- Modified from NDui
local pending = {}

function M:Focuser_Setup()
	if not self or self.focuser then return end
	local name = self.GetName and self:GetName()
	if name and strmatch(name, "oUF_NPs") then return end

	if not InCombatLockdown() then
		self:SetAttribute("shift-type1", "macro")
		self:SetAttribute("macrotext", FM:GetMacroText())
		self.focuser = true
		pending[self] = nil
	else
		pending[self] = true
	end
end

function M.Focuser_OnEvent(event)
	if event == "PLAYER_REGEN_ENABLED" then
		if next(pending) then
			for frame in next, pending do
				M.Focuser_Setup(frame)
			end
		end
	else
		for _, object in next, oUF.objects do
			if not object.focuser then
				M.Focuser_Setup(object)
			end
		end
	end
end

function FM:GetMacroText()
	local lines = {"/focus mouseover"}

	if FM.db["Enable"] and FM.db["MarkerIndex"] and FM.db["MarkerIndex"] >= 1 and FM.db["MarkerIndex"] <= 8 then
		if FM.db["DisableInRaid"] then
			tAppendAll(lines, {
				"/stopmacro [group:raid]"
			})
		end
		local markerIndex = FM.db["MarkerIndex"]
		if FM.db["KeepExistingMarker"] then
			markerIndex = "~"..markerIndex
		end
		tAppendAll(lines, {
			"/tm [@focus,exists,harm,nodead] "..markerIndex
		})
	end

	return strjoin("\n", unpack(lines))
end

function FM:UpdateMacroText()
	if not FM.FocuserButton then
		return
	end

	FM.FocuserButton:SetAttribute("macrotext", FM:GetMacroText())

	for _, object in next, oUF.objects do
		if object.focuser then
			object:SetAttribute("macrotext", FM:GetMacroText())
		end
	end
end

function FM:AnnounceFocusMarker()
	if FM.db["Enable"] and FM.db["AnnounceMarker"] and FM.db["MarkerIndex"] and FM.db["MarkerIndex"] >= 1 and FM.db["MarkerIndex"] <= 8 and not IsInRaid() then
		C_ChatInfo.SendChatMessage(format(L["FocusMarkerChatAnnouncement"], FM.db["MarkerIndex"]), "PARTY")
	end
end

function FM:OnLogin()
	FM.FocuserButton = _G.FocuserButton
	if not FM.FocuserButton then
		return
	end

	FM.FocuserButton:SetAttribute("macrotext", FM:GetMacroText())
	B:RegisterEvent("READY_CHECK", FM.AnnounceFocusMarker)
end