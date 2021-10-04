local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local UF = P:GetModule("UnitFrames")

local unitFrames = {
	["player"] = true,
	["pet"] = true,
}

function UF:Configure_Fader(frame)
	if UF.db["Fader"] then
		if not frame:IsElementEnabled("Fader") then
			frame:EnableElement("Fader")
		end

		frame.Fader:SetOption("Hover", UF.db["Hover"])
		frame.Fader:SetOption("Combat", UF.db["Combat"])
		frame.Fader:SetOption("PlayerTarget", UF.db["Target"])
		frame.Fader:SetOption("Focus", UF.db["Focus"])
		frame.Fader:SetOption("Health", UF.db["Health"])
		frame.Fader:SetOption("Vehicle", UF.db["Vehicle"])
		frame.Fader:SetOption("Casting", UF.db["Casting"])
		frame.Fader:SetOption("MinAlpha", UF.db["MinAlpha"])
		frame.Fader:SetOption("MaxAlpha", UF.db["MaxAlpha"])

		if frame ~= _G.oUF_Player then
			frame.Fader:SetOption("UnitTarget", UF.db["Target"])
		end

		frame.Fader:SetOption("Smooth", UF.db["Smooth"])
		frame.Fader:SetOption("Delay", UF.db["Delay"])

		frame.Fader:ClearTimers()
		frame.Fader.configTimer = P:ScheduleTimer(frame.Fader.ForceUpdate, 0.25, frame.Fader, true)
	elseif frame:IsElementEnabled("Fader") then
		frame:DisableElement("Fader")
		P:UIFrameFadeIn(frame, 1, frame:GetAlpha(), 1)
	end
end

function UF:UpdateUFsFader()
	for _, frame in pairs(oUF.objects) do
		local mystyle = frame.mystyle
		if mystyle and unitFrames[mystyle] then
			frame.Fader = frame.Fader or {}
			UF:Configure_Fader(frame)
		end
	end
end