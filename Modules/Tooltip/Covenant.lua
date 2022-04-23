local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)
local T = P:GetModule("Tooltip")
local NT = B:GetModule("Tooltip")

local format, strsplit, strmatch, strsub = string.format, string.split, string.match, string.sub
local pairs, tonumber = pairs, tonumber

--local LibOR = LibStub("LibOpenRaid-1.0")
local LibOR

T.MemberCovenants = {}

local covenantMap = {
	[1] = "Kyrian",
	[2] = "Venthyr",
	[3] = "NightFae",
	[4] = "Necrolord",
}

-- Credit: OmniCD
local covenantAbilities = {
	[324739] = 1,
	[323436] = 1,
	[312202] = 1,
	[306830] = 1,
	[326434] = 1,
	[338142] = 1,
	[338035] = 1,
	[338018] = 1,
	[327022] = 1,
	[327037] = 1,
	[327071] = 1,
	[308491] = 1,
	[307443] = 1,
	[310454] = 1,
	[304971] = 1,
	[325013] = 1,
	[323547] = 1,
	[324386] = 1,
	[312321] = 1,
	[307865] = 1,

	[300728] = 2,
	[311648] = 2,
	[317009] = 2,
	[323546] = 2,
	[324149] = 2,
	[314793] = 2,
	[326860] = 2,
	[316958] = 2,
	[323673] = 2,
	[323654] = 2,
	[320674] = 2,
	[321792] = 2,
	[317483] = 2,
	[317488] = 2,

	[310143] = 3,
	[324128] = 3,
	[323639] = 3,
	[323764] = 3,
	[328231] = 3,
	[314791] = 3,
	[327104] = 3,
	[328622] = 3,
	[328282] = 3,
	[328620] = 3,
	[328281] = 3,
	[327661] = 3,
	[328305] = 3,
	[328923] = 3,
	[325640] = 3,
	[325886] = 3,
	[319217] = 3,

	[324631] = 4,
	[315443] = 4,
	[329554] = 4,
	[325727] = 4,
	[325028] = 4,
	[324220] = 4,
	[325216] = 4,
	[328204] = 4,
	[324724] = 4,
	[328547] = 4,
	[326059] = 4,
	[325289] = 4,
	[324143] = 4,
}

local DCLoaded

local ZT_Prefix = "ZenTracker"
local DC_Prefix = "DCOribos"
local OmniCD_Prefix = "OmniCD"
local MRT_Prefix = "EXRTADD"

local addonPrefixes = {
	[ZT_Prefix] = true,
	[DC_Prefix] = true,
	[OmniCD_Prefix] = true,
	[MRT_Prefix] = true,
}

function T:GetCovenantIcon(covenantID, size)
	local covenant = covenantMap[covenantID]
	if covenant then
		return format("|TInterface\\Addons\\"..addonName.."\\Media\\Texture\\Covenants\\%s:%d|t", covenant, size)
	end

	return ""
end

local covenantIDToName = {}
function T:GetCovenantName(covenantID)
	if not covenantIDToName[covenantID] then
		local covenantData = C_Covenants.GetCovenantData(covenantID)

		covenantIDToName[covenantID] = covenantData and covenantData.name
	end

	return covenantIDToName[covenantID] or covenantMap[covenantID]
end

function T:GetCovenantID(unit)
	local guid = UnitGUID(unit)
	if not guid then return end

	local covenantID = T.MemberCovenants[guid]
	-- if not covenantID then
	-- 	local playerInfo = LibOR.GetUnitInfo(unit)
	-- 	return playerInfo and playerInfo.covenantId
	-- end
	if not covenantID and LibOR then
		local playerInfo
		if LibOR.GetUnitInfo then
			playerInfo = LibOR.GetUnitInfo(unit)
		elseif LibOR.playerInfoManager and LibOR.playerInfoManager then
			playerInfo = LibOR.playerInfoManager.GetPlayerInfo(GetUnitName(unit, true))
		end
		return playerInfo and playerInfo.covenantId
	end

	return covenantID
end

local function msgChannel()
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		return "RAID"
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		return "PARTY"
	end
end

local cache = {}
function T:UpdateRosterInfo()
	if not IsInGroup() then return end

	for i = 1, GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i)
		if name and name ~= DB.MyName and not cache[name] then
			if not DCLoaded then
				C_ChatInfo.SendAddonMessage(DC_Prefix, format("ASK:%s", name), msgChannel())
			end
			C_ChatInfo.SendAddonMessage(MRT_Prefix, format("inspect\tREQ\tS\t%s", name), msgChannel())

			cache[name] = true
		end
	end

	-- LibOR.RequestAllData()
	if LibOR then
		if LibOR.RequestAllData then
			LibOR.RequestAllData()
		elseif LibOR.RequestAllPlayersInfo then
			LibOR.RequestAllPlayersInfo()
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
		if (version and version > 3) and (type and type == "H") and guid then
			covenantID = tonumber(covenantID)
			if covenantID and (not T.MemberCovenants[guid] or T.MemberCovenants[guid] ~= covenantID) then
				T.MemberCovenants[guid] = covenantID
				P:Debug("%s 盟约：%s (by ZenTracker)", sender, covenantMap[covenantID] or "None")
			end
		end
	elseif prefix == OmniCD_Prefix then
		local header, guid, body = strmatch(msg, "(.-),(.-),(.+)")
		if (header and guid and body) and (header == "INF" or header == "REQ" or header == "UPD") then
			local covenantID = select(15, strsplit(",", body))
			covenantID = tonumber(covenantID)
			if covenantID and (not T.MemberCovenants[guid] or T.MemberCovenants[guid] ~= covenantID) then
				T.MemberCovenants[guid] = covenantID
				P:Debug("%s 盟约：%s (by OmniCD)", sender, covenantMap[covenantID] or "None")
			end
		end
	elseif prefix == DC_Prefix then
		local playerName, covenantID = strsplit(":", msg)
		if playerName == "ASK" then return end

		local guid = UnitGUID(sender)
		covenantID = tonumber(covenantID)
		if covenantID and guid and (not T.MemberCovenants[guid] or T.MemberCovenants[guid] ~= covenantID) then
			T.MemberCovenants[guid] = covenantID
			P:Debug("%s 盟约：%s (by Details_Covenants)", sender, covenantMap[covenantID] or "None")
		end
	elseif prefix == MRT_Prefix then
		local modPrefix, subPrefix, soulbinds = strsplit("\t", msg)
		if (modPrefix and modPrefix == "inspect") and (subPrefix and subPrefix == "R") and (soulbinds and strsub(soulbinds, 1, 1) == "S") then
			local guid = UnitGUID(sender)
			local covenantID = select(2, strsplit(":", soulbinds))
			covenantID = tonumber(covenantID)
			if covenantID and guid and (not T.MemberCovenants[guid] or T.MemberCovenants[guid] ~= covenantID) then
				T.MemberCovenants[guid] = covenantID
				P:Debug("%s 盟约：%s (by MRT)", sender, covenantMap[covenantID] or "None")
			end
		end
	end
end

function T:HandleSpellCast(unit, _, spellID)
	local covenantID = covenantAbilities[spellID]
	if covenantID then
		local guid = UnitGUID(unit)
		if guid and (not T.MemberCovenants[guid] or T.MemberCovenants[guid] ~= covenantID) then
			T.MemberCovenants[guid] = covenantID
			P:Debug("%s 盟约：%s (by %s)", GetUnitName(unit, true), covenantMap[covenantID], GetSpellLink(spellID))
		end
	end
end

function T:AddCovenant()
	if not T.db["Covenant"] then return end

	local _, unit = GameTooltip:GetUnit()
	if not unit or not UnitIsPlayer(unit) then return end

	local covenantID
	if UnitIsUnit(unit, "player") then
		covenantID = C_Covenants.GetActiveCovenantID()
	else
		covenantID = T:GetCovenantID(unit)
	end

	if covenantID and covenantID ~= 0 then
		GameTooltip:AddLine(format(L["Covenant"], T:GetCovenantIcon(covenantID, 14)))
	end
end

do
	if NT.OnTooltipSetUnit then
		hooksecurefunc(NT, "OnTooltipSetUnit", T.AddCovenant)
	end
end

function T:Covenant()
	LibOR = _G.LibStub and _G.LibStub("LibOpenRaid-1.0", true)
	DCLoaded = IsAddOnLoaded("Details_Covenants")

	for prefix in pairs(addonPrefixes) do
		C_ChatInfo.RegisterAddonMessagePrefix(prefix)
	end

	T:UpdateRosterInfo()
	B:RegisterEvent("GROUP_ROSTER_UPDATE", T.UpdateRosterInfo)
	B:RegisterEvent("CHAT_MSG_ADDON", T.HandleAddonMessage)
	B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", T.HandleSpellCast)
end