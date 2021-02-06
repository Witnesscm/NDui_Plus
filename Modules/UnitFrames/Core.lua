local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = _G.oUF or ns.oUF
local UF = P:RegisterModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

function UF:SetTag(frame)
	local name = frame.nameText
	local mystyle = frame.mystyle
	local colorStr = UF.db["NameColor"] and frame.Health.colorClass and "" or "[color]"
	if name then
		if mystyle == "player" then
			frame:Tag(name, " "..colorStr.."[name]")
		elseif mystyle == "target" then
			frame:Tag(name, "[fulllevel] "..colorStr.."[name][afkdnd]")
		elseif mystyle == "focus" then
			frame:Tag(name, colorStr.."[name][afkdnd]")
		elseif mystyle == "nameplate" then
			frame:Tag(name, "[nplevel][name]")
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

function UF:SetNameTextHook()
	hooksecurefunc(NUF, "CreateHealthText", function(self, frame)
		UF:SetTag(frame)
	end)
end

function UF:SetupNameText()
	UF:SetNameTextHook()
	UF:UpdateNameText()
	hooksecurefunc(NUF, "UpdateTextScale", UF.UpdateNameText)
	hooksecurefunc(NUF, "UpdateRaidTextScale", UF.UpdateNameText)
end

function UF:OnLogin()
	P:Delay(1, function()
		UF:SetupNameText()
		UF:SetIconsHook()
		UF:UpdateRoleTex()
		UF:UpdateUFsFader()
		UF:UpdateAurasFilter()
	end)
end