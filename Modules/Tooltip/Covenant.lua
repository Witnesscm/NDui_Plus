local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)
local T = P:GetModule("Tooltip")
local NT = B:GetModule("Tooltip")

local strfind, format, strsplit, strmatch = string.find, string.format, string.split, string.match
local pairs, tonumber = pairs, tonumber

T.MemberCovenants = {}

local covenantMap = {
	[1] = "Kyrian",
	[2] = "Venthyr",
	[3] = "NightFae",
	[4] = "Necrolord",
}

-- Credit: Details_Covenants
local utilityMap = {
	[324739] = 1,
	[300728] = 2,
	[310143] = 3,
	[324631] = 4,
}

local abilityMap = {
	["DEATHKNIGHT"] = {
		[315443] = 4,
		[312202] = 1,
		[311648] = 2,
		[324128] = 3,
	},
	["DEMONHUNTER"] = {
		[306830] = 1,
		[329554] = 4,
		[323639] = 3,
		[317009] = 2,
	},
	["DRUID"] = {
		[338142] = 1,
		[326462] = 1,
		[326446] = 1,
		[338035] = 1,
		[338018] = 1,
		[338411] = 1,
		[326434] = 1,
		[325727] = 4,
		[323764] = 3,
		[323546] = 2,
	},
	["HUNTER"] = {
		[308491] = 1,
		[325028] = 4,
		[328231] = 3,
		[324149] = 2,
	},
	["MAGE"] = {
		[307443] = 1,
		[324220] = 4,
		[314791] = 3,
		[314793] = 2,
	},
	["MONK"] = {
		[310454] = 1,
		[325216] = 4,
		[327104] = 3,
		[326860] = 2,
	},
	["PALADIN"] = {
		[304971] = 1,
		[328204] = 4,
		[328282] = 3,
		[328620] = 3,
		[328622] = 3,
		[328281] = 3,
		[316958] = 2,
	},
	["PRIEST"] = {
		[325013] = 1,
		[324724] = 4,
		[327661] = 3,
		[323673] = 2,
	},
	["ROGUE"] = {
		[323547] = 1,
		[328547] = 4,
		[328305] = 3,
		[323654] = 2,
	},
	["SHAMAN"] = {
		[324519] = 1,
		[324386] = 1,
		[326059] = 4,
		[328923] = 3,
		[320674] = 2,
	},
	["WARLOCK"] = {
		[312321] = 1,
		[325289] = 4,
		[325640] = 3,
		[321792] = 2,
	},
	["WARRIOR"] = {
		[307865] = 1,
		[324143] = 4,
		[325886] = 3,
		[330334] = 2,
		[317349] = 2,
		[317488] = 2,
		[330325] = 2,
	},
}

local ZT_Prefix = "ZenTracker"
local DC_Prefix = "DCOribos"
local OmniCD_Prefix = "OmniCD"

local addonPrefixes = {
	[ZT_Prefix] = true,
	[DC_Prefix] = true,
	[OmniCD_Prefix] = true,
}

local function getCovenantIcon(covenantID)
	local covenant = covenantMap[covenantID]
	if covenant then
		return format("|TInterface\\Addons\\"..addonName.."\\Media\\Texture\\Covenants\\%s:14:14|t", covenant)
	end

	return ""
end

local Cache = {}
function T:AskCovenant()
	for i = 1, GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i)
		if name and name ~= DB.MyName and not Cache[name] then
			C_ChatInfo.SendAddonMessage(DC_Prefix, format("ASK:%s", name), "RAID")
			Cache[name] = true
		end
	end
end

function T:HandleAddonMessage(...)
	local prefix, msg, _, sender = ...
	sender = Ambiguate(sender, "none")
	if sender == DB.MyName then return end

	if prefix == ZT_Prefix then
		local version, type, guid, _, _, _, _, covenantID = strsplit(":", msg)
		version = tonumber(version)
		if (not T.MemberCovenants[guid]) and (version and version > 3) and (type and type == "H") then
			covenantID = tonumber(covenantID)
			if covenantID and covenantID ~= 0 then
				T.MemberCovenants[guid] = covenantID
				P:Debug("%s 盟约：%s (by ZenTracker)", sender, covenantMap[covenantID])
			end
		end
	elseif prefix == OmniCD_Prefix then
		local header, guid, body = strmatch(msg, "(.-),(.-),(.+)")
		if (not T.MemberCovenants[guid]) and (header == "INF" or header == "REQ" or header == "UPD") then
			local covenantID = select(15, strsplit(",", body))
			covenantID = tonumber(covenantID)
			if covenantID and covenantID ~= 0 then
				T.MemberCovenants[guid] = covenantID
				P:Debug("%s 盟约：%s (by OmniCD)", sender, covenantMap[covenantID])
			end
		end
	elseif prefix == DC_Prefix then
		local playerName, covenantID = strsplit(":", msg)
		if playerName == "ASK" then return end

		local guid = UnitGUID(sender)
		if guid and not T.MemberCovenants[guid] then
			covenantID = tonumber(covenantID)
			if covenantID and covenantID ~= 0 then
				T.MemberCovenants[guid] = covenantID
				P:Debug("%s 盟约：%s (by Details_Covenants)", sender, covenantMap[covenantID])
			end
		end
	end
end

function T:HandleCombatLog(...)
	local _, subEvent, _, sourceGUID, sourceName, _, _, _, _, _, _, spellID = ...
	if subEvent == "SPELL_CAST_SUCCESS" and sourceGUID and sourceName and sourceGUID ~= T.myGUID and not T.MemberCovenants[sourceGUID] then
		local englishClass = select(2, GetPlayerInfoByGUID(sourceGUID))
		local classAbilityMap = englishClass and abilityMap[englishClass]
		if classAbilityMap then
			local covenantID = classAbilityMap[spellID] or utilityMap[spellID]
			if covenantID then
				T.MemberCovenants[sourceGUID] = covenantID
				P:Debug("%s 盟约：%s (by %s)", sourceName, covenantMap[covenantID], GetSpellLink(spellID))
			end
		end
	end
end

function T:AddCovenant()
	if not T.db["Covenant"] then return end

	local _, unit = GameTooltip:GetUnit()
	if not unit then return end

	local covenantID
	if UnitIsUnit(unit, "player") then
		covenantID = C_Covenants.GetActiveCovenantID()
	else
		local guid = UnitGUID(unit)
		covenantID = guid and T.MemberCovenants[guid]
	end

	if not covenantID or covenantID == 0 then return end

	local specLine, specText
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft"..i]
		local text = line and line:GetText()
		if text and strfind(text, SPECIALIZATION) then
			specLine = line
			specText = text
			break
		end
	end

	if specLine then
		specLine:SetText(format("%s  | %s", specText, getCovenantIcon(covenantID)))
	end
end

do
	if NT.SetupSpecLevel then
		hooksecurefunc(NT, "SetupSpecLevel", T.AddCovenant)
	end
end

function T:Covenant()
	if not T.db["Covenant"] then return end

	for prefix in pairs(addonPrefixes) do
		C_ChatInfo.RegisterAddonMessagePrefix(prefix)
	end

	if not IsAddOnLoaded("Details_Covenants") then
		B:RegisterEvent("GROUP_ROSTER_UPDATE", T.AskCovenant)
	end

	B:RegisterEvent("CHAT_MSG_ADDON", T.HandleAddonMessage)
	B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", T.HandleCombatLog)
end