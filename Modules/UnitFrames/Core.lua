local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local UF = P:RegisterModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

local filteredStyle = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["pet"] = true,
	["tot"] = true,
	["focustarget"] = true,
	["boss"] = true,
	["arena"] = true,
	["raid"] = true,
}

function UF:SetTag(frame)
	local name = frame.nameText
	local health = frame.Health
	local mystyle = frame.mystyle
	if name and health and mystyle and filteredStyle[mystyle] then
		local colorStr = UF.db["NameColor"] and health.colorClass and "" or "[color]"

		if mystyle == "player" then
			frame:Tag(name, " "..colorStr.."[name]")
		elseif mystyle == "target" then
			frame:Tag(name, "[fulllevel] "..colorStr.."[name][afkdnd]")
		elseif mystyle == "focus" then
			frame:Tag(name, colorStr.."[name][afkdnd]")
		elseif mystyle == "arena" then
			frame:Tag(name, "[arenaspec] "..colorStr.."[name]")
		elseif mystyle == "raid" and C.db["UFs"]["SimpleMode"] and C.db["UFs"]["ShowTeamIndex"] and not frame.isPartyPet and not frame.isPartyFrame then
			frame:Tag(name, "[group]."..colorStr.."[name]")
		else
			frame:Tag(name, colorStr.."[name]")
		end

		name:UpdateTag()
	end
end

function UF:UpdateNameText()
	for _, frame in pairs(oUF.objects) do
		UF:SetTag(frame)
	end
end

function UF:SetupNameText()
	UF:UpdateNameText()

	hooksecurefunc(NUF, "CreateHealthText", function(_, frame)
		UF:SetTag(frame)
	end)

	hooksecurefunc(NUF, "UpdateHealthBarColor", function(_, frame, force)
		if force then
			UF:SetTag(frame)
		end
	end)
end

function UF:OnLogin()
	UF:SetupNameText()
	UF:SetupRoleIcons()
	UF:UpdateUFsFader()
end