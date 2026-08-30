local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local FM = P:RegisterModule("FocusMarker")

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

	FM:UpdateMacroText()
	B:RegisterEvent("READY_CHECK", FM.AnnounceFocusMarker)
end