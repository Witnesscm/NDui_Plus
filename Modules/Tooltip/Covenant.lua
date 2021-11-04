local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)
local T = P:GetModule("Tooltip")
local NT = B:GetModule("Tooltip")

local format, strsplit, strmatch = string.format, string.split, string.match
local pairs, tonumber = pairs, tonumber

T.MemberCovenants = {}

local covenantMap = {
	[1] = "Kyrian",
	[2] = "Venthyr",
	[3] = "NightFae",
	[4] = "Necrolord",
}

-- Credit: OmniCD
local utilityMap = {
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

local LibRS
local DCLoaded

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

function T:GetCovenantID(unit)
	local guid = UnitGUID(unit)
	if not guid then return end

	local covenantID = T.MemberCovenants[guid]
	if not covenantID then
		local playerInfo = LibRS and LibRS.playerInfoManager.GetPlayerInfo(GetUnitName(unit, true))
		return playerInfo and playerInfo.covenantId
	end

	return covenantID
end

local cache = {}
function T:UpdateRosterInfo()
	if not IsInGroup() then return end

	if not DCLoaded then
		for i = 1, GetNumGroupMembers() do
			local name = GetRaidRosterInfo(i)
			if name and name ~= DB.MyName and not cache[name] then
				C_ChatInfo.SendAddonMessage(DC_Prefix, format("ASK:%s", name), "RAID")
				cache[name] = true
			end
		end
	end

	if LibRS then
		LibRS.RequestAllPlayersInfo()
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
		if guid  then
			covenantID = tonumber(covenantID)
			if covenantID and (not T.MemberCovenants[guid] or T.MemberCovenants[guid] ~= covenantID) then
				T.MemberCovenants[guid] = covenantID
				P:Debug("%s 盟约：%s (by Details_Covenants)", sender, covenantMap[covenantID] or "None")
			end
		end
	end
end

function T:HandleSpellCast(unit, _, spellID)
	local covenantID = utilityMap[spellID]
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
	if not unit or not UnitExists(unit) then return end

	local covenantID
	if UnitIsUnit(unit, "player") then
		covenantID = C_Covenants.GetActiveCovenantID()
	else
		covenantID = T:GetCovenantID(unit)
	end

	if covenantID and covenantID ~= 0 then
		GameTooltip:AddLine(format(L["Covenant"], getCovenantIcon(covenantID)))
	end
end

do
	if NT.OnTooltipSetUnit then
		hooksecurefunc(NT, "OnTooltipSetUnit", T.AddCovenant)
	end
end

function T:Covenant()
	LibRS = _G.LibStub and _G.LibStub("LibRaidStatus-1.0", true)
	DCLoaded = IsAddOnLoaded("Details_Covenants")

	for prefix in pairs(addonPrefixes) do
		C_ChatInfo.RegisterAddonMessagePrefix(prefix)
	end

	T:UpdateRosterInfo()
	B:RegisterEvent("GROUP_ROSTER_UPDATE", T.UpdateRosterInfo)
	B:RegisterEvent("CHAT_MSG_ADDON", T.HandleAddonMessage)
	B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", T.HandleSpellCast)
end