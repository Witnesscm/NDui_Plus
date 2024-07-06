local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local T = P:GetModule("Tooltip")
local NT = B:GetModule("Tooltip")

local specPrefix = TALENT .. ": " .. DB.InfoColor
local levelPrefix = STAT_AVERAGE_ITEM_LEVEL .. ": " .. DB.InfoColor
local isPending = LFG_LIST_LOADING
local resetTime, frequency = 900, .5
local cache, currentUNIT, currentGUID = {}

local ICON_STRING = ":0:0:0:-2:64:64:5:59:5:59"
local PLAYER_NOT_FOUND_STRING = gsub(ERR_CHAT_PLAYER_NOT_FOUND_S, "%%s", "(.+)")

function T:InspectOnUpdate(elapsed)
	self.elapsed = (self.elapsed or frequency) + elapsed
	if self.elapsed > frequency then
		self.elapsed = 0
		self:Hide()
		ClearInspectPlayer()

		if currentUNIT and UnitGUID(currentUNIT) == currentGUID then
			B:RegisterEvent("INSPECT_READY", T.GetInspectInfo)
			NotifyInspect(currentUNIT)
		end
	end
end

local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", T.InspectOnUpdate)
updater:Hide()

local lastTime = 0
function T:GetInspectInfo(...)
	if self == "UNIT_INVENTORY_CHANGED" then
		local thisTime = GetTime()
		if thisTime - lastTime > .1 then
			lastTime = thisTime

			local unit = ...
			if UnitGUID(unit) == currentGUID then
				T:InspectUnit(unit, true)
			end
		end
	elseif self == "INSPECT_READY" then
		local guid = ...
		if guid == currentGUID then
			local spec = T:GetUnitSpec(currentUNIT)
			local level = T:GetUnitItemLevel(currentUNIT)
			cache[guid].spec = spec
			cache[guid].level = level
			cache[guid].getTime = GetTime()

			if spec and level then
				T:SetupSpecLevel(spec, level)
			else
				T:InspectUnit(currentUNIT, true)
			end
		end
		B:UnregisterEvent(self, T.GetInspectInfo)
	end
end

--[[
	Inspect over addon comm channel. Credit: tdInspect
]]

local ALA_PREFIX = "ATEADD"

local Ala = {}
do
	local __base64, __debase64 = {}, {}
	do
		for i = 0, 9 do
			__base64[i] = tostring(i)
		end
		__base64[10] = "-"
		__base64[11] = "="
		for i = 0, 25 do
			__base64[i + 1 + 11] = strchar(i + 65)
		end
		for i = 0, 25 do
			__base64[i + 1 + 11 + 26] = strchar(i + 97)
		end
		for i = 0, 63 do
			__debase64[__base64[i]] = i
		end
	end

	local __classList = {
		11, -- DRUID
		3, -- HUNTER
		8, -- MAGE
		2, -- PALADIN
		5, -- PRIEST
		4, -- ROGUE
		7, -- SHAMAN
		9, -- WARLOCK
		1, -- WARRIOR
		6, -- DEATHKNIGHT
		10, -- MONK
		12 -- DEAMONHUNTER
	}

	local CMD_LEN_V1 = 6
	local CLIENT_MAJOR = floor(select(4, GetBuildInfo()) / 10000)
	local LIB_MAJOR = 2
	local COMM_QUERY_PREFIX = "!Q" .. __base64[CLIENT_MAJOR] .. __base64[LIB_MAJOR]

	local __zero = setmetatable({[0] = "", [1] = "0"}, {
		__index = function(t, i)
			assert(type(i) == "number")
			t[i] = strrep("0", i)
			return t[i]
		end
	})

	local _colon = setmetatable({[0] = "", [1] = ":"}, {
		__index = function(tbl, key)
			local str = strrep(":", key)
			tbl[key] = str
			return str
		end
	})

	local function DecodeNumber(code)
		local isnegative = false
		if strsub(code, 1, 1) == "^" then
			code = strsub(code, 2)
			isnegative = true
		end
		local v = nil
		local n = #code
		if n == 1 then
			v = __debase64[code]
		else
			v = 0
			for i = n, 1, -1 do
				v = v * 64 + __debase64[strsub(code, i, i)]
			end
		end
		return isnegative and -v or v
	end

	local function DecodeItem(code)
		if code == "^" then
			return
		end

		local item = "item:"
		local data = strsplittable(":", code)
		if not data[1] then
			return
		end
		local id = DecodeNumber(data[1])
		if not id then
			return
		end
		item = item .. id
		for i = 2, #data do
			local v = data[i]
			if #v > 1 then
				item = item .. _colon[__debase64[strsub(v, 1, 1)]] .. DecodeNumber(strsub(v, 2))
			else
				item = item .. _colon[__debase64[v]]
			end
		end
		return item
	end

	function Ala:DecodeEquipmentV1(code)
		local data = strsplittable("+", code)
		if not data[3] then
			return
		end

		local equips = {}
		for i = 2, #data, 2 do
			local slot, link = tonumber(data[i]), data[i + 1]
			local id = tonumber(link:match("item:(%d+)"))

			if id then
				equips[slot] = link
			else
				equips[slot] = false
			end
		end
		return equips
	end

	function Ala:DecodeEquipmentV2(code)
		local data = strsplittable("+", code)
		if not data[2] then
			return
		end
		local equips = {}
		local start = __debase64[data[1]] - 2
		local num = #data
		for i = 2, num do
			local slot = start + i
			local item = DecodeItem(data[i])
			equips[slot] = item or false
		end
		return equips
	end

	function Ala:DecodeTalentV1(code)
		local len = #code
		local data = ""

		local raw = 0
		local magic = 1
		local nChar = 0
		for index = 1, len do
			local c = strsub(code, index, index)
			if c == ":" then
				--
			elseif __debase64[c] then
				raw = raw + __debase64[c] * magic
				magic = magic * 64
				nChar = nChar + 1
			else

			end
			if c == ":" or nChar == 5 or index == len then
				magic = 1
				nChar = 0
				local n = 0
				while raw > 0 do
					local val = raw % 6
					data = data .. val
					raw = (raw - val) / 6
					n = n + 1
				end
				if n < 11 then
					data = data .. __zero[11 - n]
				end
			end
		end
		return data
	end

	function Ala:RecvEquipmentV1(code)
		local c = strsplit("#", code)
		local equips = self:DecodeEquipmentV1(c)
		if not equips then
			return
		end
		return {equips = equips}
	end

	function Ala:RecvTalentV1(code)
		local classIndex = __debase64[strsub(code, 1, 1)]
		if not classIndex then
			return
		end
		local class = __classList[classIndex]
		if not class then
			return
		end

		local level = __debase64[strsub(code, -2, -2)] + __debase64[strsub(code, -1, -1)] * 64
		local talent = self:DecodeTalentV1(strsub(code, 2, -3))
		local result = {class = class, level = level}

		if talent then
			result.numGroups = 1
			result.activeGroup = 1
			result.talents = {talent}
		end

		return result
	end

	function Ala:RecvCommV1(msg)
		local cmd = strsub(msg, 1, CMD_LEN_V1)
		if cmd == "_repeq" or cmd == "_r_equ" or cmd == "_r_eq3" then
			return self:RecvEquipmentV1(strsub(msg, CMD_LEN_V1 + 1, -1))
		elseif cmd == "_reply" or cmd == "_r_tal" then
			return self:RecvTalentV1(strsub(msg, CMD_LEN_V1 + 1, -1))
		end
	end

	local _RecvBuffer = {}

	function Ala:RecvPacket(msg, sender)
		local num = __debase64[strsub(msg, 5, 5)] + __debase64[strsub(msg, 6, 6)] * 64
		local index = __debase64[strsub(msg, 7, 7)] + __debase64[strsub(msg, 8, 8)] * 64
		local buffer = _RecvBuffer[sender] or {}
		_RecvBuffer[sender] = buffer
		buffer[index] = strsub(msg, 9)
		for i = 1, num do
			if not buffer[i] then
				return
			end
		end
		_RecvBuffer[sender] = nil
		return table.concat(buffer)
	end

	function Ala:RecvTalentV2Step2(code)
		local classIndex = __debase64[strsub(code, 1, 1)]
		if not classIndex then
			return
		end
		local class = __classList[classIndex]
		if not class then
			return
		end
		local level = __debase64[strsub(code, 2, 2)] + __debase64[strsub(code, 3, 3)] * 64
		local numGroups = tonumber(__debase64[strsub(code, 4, 4)])
		if not numGroups then
			return
		end
		local activeGroup = tonumber(__debase64[strsub(code, 5, 5)])
		if not activeGroup then
			return
		end
		local lenTal1 = tonumber(__debase64[strsub(code, 6, 6)])
		if not lenTal1 then
			return
		end
		local code1 = strsub(code, 7, lenTal1 + 6)

		assert(lenTal1 == #code1)

		if numGroups < 2 then
			return {
				class = class,
				level = level,
				numGroups = 1,
				activeGroup = activeGroup,
				talents = {self:DecodeTalentV1(code1)}
			}
		else
			local lenTal2 = tonumber(__debase64[strsub(code, 7 + lenTal1, 7 + lenTal1)])
			if not lenTal2 then
				return
			end
			local code2 = strsub(code, lenTal1 + 8, lenTal1 + lenTal2 + 7)

			assert(lenTal2 == #code2)

			return {
				class = class,
				level = level,
				numGroups = 2,
				activeGroup = activeGroup,
				talents = {self:DecodeTalentV1(code1), self:DecodeTalentV1(code2)}
			}
		end
	end

	function Ala:RecvTalentV2(code)
		if strsub(code, 1, 2) ~= "!T" then
			return
		end
		local clientMajor = __debase64[strsub(code, 3, 3)]
		if clientMajor ~= CLIENT_MAJOR then
			return
		end
		local protoVersion = __debase64[strsub(code, 4, 4)]
		if protoVersion == 1 then
			return self:RecvTalentV1(strsub(code, 5))
		elseif protoVersion == 2 then
			return self:RecvTalentV2Step2(strsub(code, 5))
		end
	end

	function Ala:RecvEquipmentV2Step2(code)
		local equips = self:DecodeEquipmentV2(code)
		if not equips then
			return
		end
		return {equips = equips}
	end

	function Ala:RecvEquipmentV2(code)
		if strsub(code, 1, 2) ~= "!E" then
			return
		end
		local clientMajor = __debase64[strsub(code, 3, 3)]
		if clientMajor ~= CLIENT_MAJOR then
			return
		end
		local protoVersion = __debase64[strsub(code, 4, 4)]
		if protoVersion == 1 then
			return self:RecvEquipmentV1(strsub(code, 5))
		elseif protoVersion == 2 then
			return self:RecvEquipmentV2Step2(strsub(code, 5))
		end
	end

	function Ala:RecvRune(code)
		if strsub(code, 1, 2) ~= "!N" then
			return false
		end
		local clientMajor = __debase64[strsub(code, 3, 3)]
		if clientMajor ~= CLIENT_MAJOR then
			return
		end

		local runes = {}
		local val = strsplittable("+", strsub(code, 5))
		for i = 1, #val do
			local slot, id, icon = strsplit(":", val[i])
			slot = slot and __debase64[slot] or nil
			id = id and DecodeNumber(id) or nil
			icon = icon and DecodeNumber(icon) or nil
			if slot ~= nil and id ~= nil then
				runes[slot] = {slot = slot, spellId = id, icon = icon}
			end
		end
		return {runes = runes}
	end

	local function merge(dst, src)
		if not dst then
			return src
		end
		if not src then
			return dst
		end
		for k, v in pairs(src) do
			dst[k] = v
		end
		return dst
	end

	function Ala:RecvCommV2(msg, sender)
		if not msg then
			return
		end
		if strsub(msg, 1, 2) == "!P" then
			return self:RecvCommV2(self:RecvPacket(msg, sender))
		end

		local _
		local pos = 1
		local code
		local v2_ctrl_code
		local len = #msg
		local r
		while pos < len do
			_, pos, code, v2_ctrl_code = strfind(msg, "((![^!])[^!]+)", pos)
			if v2_ctrl_code == "!T" then
				r = merge(r, self:RecvTalentV2(code))
			elseif v2_ctrl_code == "!E" then
				r = merge(r, self:RecvEquipmentV2(code))
			end
		end
		if r then
			r.v2 = true
		end
		return r
	end

	function Ala:RecvComm(msg, channel, sender)
		if channel ~= "WHISPER" then
			return
		end
		local p = strsub(msg, 1, 1)
		if p == "_" then
			return self:RecvCommV1(msg)
		elseif p == "!" then
			return self:RecvCommV2(msg, sender)
		end
	end

	function Ala:PackQuery(queryEquip, queryTalent, queryGlyph, queryRune)
		return COMM_QUERY_PREFIX ..
			(queryTalent and "T" or "") .. (queryGlyph and "G" or "") .. ((queryEquip or queryRune) and "E" or "")
	end
end

local TalentTabData = {}
do
	local CURRENT
	local LOCAL_INDEX = {}

	local function DefineLocalIndexs(val)
		for i, locale in ipairs(strsplittable("/", val)) do
			LOCAL_INDEX[locale] = i
		end
	end

	local function CreateClass(classFileName)
		CURRENT = {}
		TalentTabData[classFileName] = CURRENT
	end

	local function CreateTab(tabId, numTalents, bg, icon)
		tinsert(CURRENT, {tabId = tabId, numTalents = numTalents, bg = bg, icon = icon, talents = {}})
	end

	local function SetTabName(names)
		local tab = CURRENT[#CURRENT]
		local locale = GetLocale()
		local index = LOCAL_INDEX[locale] or LOCAL_INDEX.enUS
		tab.name = strsplittable("/", names)[index]
	end

	local D, C, T, N = DefineLocalIndexs, CreateClass, CreateTab, SetTabName
	D "enUS/koKR/frFR/deDE/zhCN/zhTW/esES/ruRU/ptBR/itIT"
	C "WARRIOR"
	T(161, 31, "WarriorArms", 132292)
	N "Arms/무기/Armes/Waffen/武器/武器/Armas/Оружие/Armas/Arms"
	T(164, 27, "WarriorFury", 132347)
	N "Fury/분노/Fureur/Furor/狂怒/狂怒/Furia/Неистовство/Fúria/Fury"
	T(163, 27, "WarriorProtection", 134952)
	N "Protection/방어/Protection/Schutz/防护/防護/Protección/Защита/Proteção/Protection"
	C "PALADIN"
	T(382, 26, "PaladinHoly", 135920)
	N "Holy/신성/Sacré/Heilig/神圣/神聖/Sagrado/Свет/Sagrado/Holy"
	T(383, 26, "PaladinProtection", 135893)
	N "Protection/보호/Protection/Schutz/防护/防護/Protección/Защита/Proteção/Protection"
	T(381, 26, "PaladinCombat", 135873)
	N "Retribution/징벌/Vindicte/Vergeltung/惩戒/懲戒/Reprensión/Воздаяние/Retribuição/Retribution"
	C "HUNTER"
	T(361, 26, "HunterBeastMastery", 132164)
	N "Beast Mastery/야수/Maîtrise des bêtes/Tierherrschaft/野兽控制/野獸控制/Bestias/Повелитель зверей/Domínio das Feras/Beast Mastery"
	T(363, 27, "HunterMarksmanship", 132222)
	N "Marksmanship/사격/Précision/Treffsicherheit/射击/射擊/Puntería/Стрельба/Precisão/Marksmanship"
	T(362, 28, "HunterSurvival", 132215)
	N "Survival/생존/Survie/Überleben/生存/生存/Supervivencia/Выживание/Sobrevivência/Survival"
	C "ROGUE"
	T(182, 27, "RogueAssassination", 132292)
	N "Assassination/암살/Assassinat/Meucheln/奇袭/刺殺/Asesinato/Ликвидация/Assassinato/Assassination"
	T(181, 28, "RogueCombat", 132090)
	N "Combat/전투/Combat/Kampf/战斗/戰鬥/Combate/Бой/Combate/Combat"
	T(183, 28, "RogueSubtlety", 132320)
	N "Subtlety/잠행/Finesse/Täuschung/敏锐/敏銳/Sutileza/Скрытность/Subterfúgio/Subtlety"
	C "PRIEST"
	T(201, 28, "PriestDiscipline", 135987)
	N "Discipline/수양/Discipline/Disziplin/戒律/戒律/Disciplina/Послушание/Disciplina/Discipline"
	T(202, 27, "PriestHoly", 237542)
	N "Holy/신성/Sacré/Heilig/神圣/神聖/Sagrado/Свет/Sagrado/Holy"
	T(203, 27, "PriestShadow", 136207)
	N "Shadow/암흑/Ombre/Schatten/暗影/暗影/Sombra/Тьма/Sombra/Shadow"
	C "DEATHKNIGHT"
	T(398, 28, "DeathKnightBlood", 135770)
	N "Blood/혈기/Sang/Blut/鲜血/血魄/Sangre/Кровь/Sangue/Blood"
	T(399, 29, "DeathKnightFrost", 135773)
	N "Frost/냉기/Givre/Frost/冰霜/冰霜/Escarcha/Лед/Gelo/Frost"
	T(400, 31, "DeathKnightUnholy", 135775)
	N "Unholy/부정/Impie/Unheilig/邪恶/穢邪/Profano/Нечестивость/Profano/Unholy"
	C "SHAMAN"
	T(261, 25, "ShamanElementalCombat", 136048)
	N "Elemental/정기/Elémentaire/Elementar/元素/元素/Elemental/Стихии/Elemental/Elemental"
	T(263, 29, "ShamanEnhancement", 136051)
	N "Enhancement/고양/Amélioration/Verstärk/增强/增強/Mejora/Совершенствование/Aperfeiçoamento/Enhancement"
	T(262, 26, "ShamanRestoration", 136052)
	N "Restoration/복원/Restauration/Wiederherst/恢复/恢復/Restauración/Восстановление/Restauração/Restoration"
	C "MAGE"
	T(81, 30, "MageArcane", 135932)
	N "Arcane/비전/Arcanes/Arkan/奥术/秘法/Arcano/Тайная магия/Arcano/Arcane"
	T(41, 28, "MageFire", 135810)
	N "Fire/화염/Feu/Feuer/火焰/火焰/Fuego/Огонь/Fogo/Fire"
	T(61, 28, "MageFrost", 135846)
	N "Frost/냉기/Givre/Frost/冰霜/冰霜/Escarcha/Лед/Gelo/Frost"
	C "WARLOCK"
	T(302, 28, "WarlockCurses", 136145)
	N "Affliction/고통/Affliction/Gebrechen/痛苦/痛苦/Aflicción/Колдовство/Suplício/Affliction"
	T(303, 27, "WarlockSummoning", 136172)
	N "Demonology/악마/Démonologie/Dämonologie/恶魔学识/惡魔學識/Demonología/Демонология/Demonologia/Demonology"
	T(301, 26, "WarlockDestruction", 136186)
	N "Destruction/파괴/Destruction/Zerstörung/毁灭/毀滅/Destrucción/Разрушение/Destruição/Destruction"
	C "DRUID"
	T(283, 28, "DruidBalance", 136096)
	N "Balance/조화/Equilibre/Gleichgewicht/平衡/平衡/Equilibrio/Баланс/Equilíbrio/Balance"
	T(281, 30, "DruidFeralCombat", 132276)
	N "Feral Combat/야성/Combat farouche/Wilder Kampf/野性战斗/野性戰鬥/Combate feral/Сила зверя/Combate Feral/Feral Combat"
	T(282, 27, "DruidRestoration", 136041)
	N "Restoration/회복/Restauration/Wiederherst/恢复/恢復/Restauración/Восстановление/Restauração/Restoration"
end

local GetClassFileName = P.Memorize(function(classId)
	if not classId then
		return
	end
	local classInfo = C_CreatureInfo.GetClassInfo(classId)
	return classInfo and classInfo.classFile
end)

function T:GetRemoteSpec(db)
	local talentData = TalentTabData[GetClassFileName(db.class)]
	local data = db.talents[db.activeGroup]
	data = data:gsub("[^%d]+", "")

	local specName, specIcon = NONE
	local higher = 0
	local points = {}
	local index = 1
	for i = 1, #talentData do
		local pointsSpent = 0
		for j = 1, talentData[i].numTalents do
			local point = tonumber(data:sub(index, index)) or 0
			pointsSpent = pointsSpent + point
			index = index + 1
		end

		if pointsSpent > higher then
			higher = pointsSpent
			specName = talentData[i].name
			specIcon = talentData[i].icon
		end

		points[i] = pointsSpent
	end

	if specIcon and T.db["TalentIcon"] then
		specName = format("%s %s", P.TextureString(specIcon, ICON_STRING), specName)
	end

	return T.db["TalentPoints"] and format("%s (%d/%d/%d)", specName, points[1], points[2], points[3]) or specName
end

function T:GetRemoteItemLevel(db)
	local ilvl, total, mainhand, offhand, ranged = 0, 0, 0, 0, 0
	local delay

	for i = 1, 18 do
		if i ~= 4 then
			local item = db.equips[i]
			if item then
				local name, _, _, level = GetItemInfo(item)
				if not name or not level then
					local id = tonumber(item:match("item:(%d+)"))
					if id then
						T.waitingItems[id] = true
						delay = true
					end
				else
					if i < 16 then
						total = total + level
					elseif i == 16 then
						mainhand = level
					elseif i == 17 then
						offhand = level
					elseif i == 18 then
						ranged = level
					end
				end
			end
		end
	end

	if not delay then
		if mainhand > 0 and offhand > 0 then
			total = total + mainhand + offhand
		elseif offhand > 0 and ranged > 0 then
			total = total + offhand + ranged
		else
			total = total + max(mainhand, offhand, ranged) * 2
		end
		ilvl = total / 16

		if ilvl > 0 then ilvl = format("%.1f", ilvl) end
	else
		ilvl = nil
		T.waitingUnits[db.name] = true
	end

	return ilvl
end

function T:WaitItemLevel(id, ok)
	if not ok then
		return
	end

	if not T.waitingItems[id] then
		return
	else
		T.waitingItems[id] = nil
	end

	if not next(T.waitingItems) then
		for name in pairs(T.waitingUnits) do
			T.waitingUnits[name] = nil
			local db = T:BuildCharacterDb(name)
			if db.guid and cache[db.guid] then
				local spec = cache[db.guid].spec
				local level = T:GetRemoteItemLevel(db)
				cache[db.guid].level = level
				if currentUNIT and T:GetFullName(GetUnitName(currentUNIT, true)) == name then
					T:SetupSpecLevel(spec, level)
				end
			end
		end
	end
end

function T:CanBlizzardInspect(unit)
	if not unit then
		return false
	end
	if UnitIsDeadOrGhost("player") then
		return false
	end
	if UnitIsDeadOrGhost(unit) then
		return false
	end
	if not CheckInteractDistance(unit, 1) then
		return false
	end
	if not CanInspect(unit) then
		return false
	end
	return true
end

function T:CanOurInspect(unit)
	if not unit then
		return false
	end
	if UnitName(unit) == UNKNOWNOBJECT then
		return false
	end
	if UnitFactionGroup(unit) ~= T.myFaction then
		return false
	end
	return true
end

function T:GetFullName(name, realm)
	if not name then
		return
	end
	if name:find("-", nil, true) then
		return name
	end

	if not realm or realm == "" then
		realm = GetNormalizedRealmName()
	end
	return name .. "-" .. realm
end

function T:BuildCharacterDb(name)
	self.userCache[name] = self.userCache[name] or { name = name }
	return self.userCache[name]
end

function T:OnAlaCommand(msg, channel, sender)
	local data = Ala:RecvComm(msg, channel, sender)
	if not data then
		return
	end

	local name = T:GetFullName(sender)
	local db = T:BuildCharacterDb(name)

	if data.class then
		db.class = data.class
	end
	if data.equips then
		db.equips = db.equips or {}
		for k, v in pairs(data.equips) do
			db.equips[k] = v or nil
		end
	end
	if data.talents then
		db.talents = data.talents
		db.numGroups = data.numGroups or 1
		db.activeGroup = data.activeGroup or 1
	end

	if db.guid and db.class and db.talents and db.equips then
		local spec = T:GetRemoteSpec(db)
		local level = T:GetRemoteItemLevel(db)
		cache[db.guid].spec = spec
		cache[db.guid].level = level
		cache[db.guid].getTime = GetTime()
		T:SetupSpecLevel(spec, level)
	end
end

function T:SetupSpecLevel(spec, level)
	local _, unit = GameTooltip:GetUnit()
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local specLine, levelLine
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft" .. i]
		local text = line:GetText()
		if text and strfind(text, specPrefix) then
			specLine = line
		elseif text and strfind(text, levelPrefix) then
			levelLine = line
		end
	end

	spec = specPrefix .. (spec or isPending)
	if specLine then
		specLine:SetText(spec)
	else
		GameTooltip:AddLine(spec)
	end

	level = levelPrefix .. (level or isPending)
	if levelLine then
		levelLine:SetText(level)
	else
		GameTooltip:AddLine(level)
	end
	GameTooltip:Show()
end

function T:GetUnitItemLevel(unit)
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local ilvl, total, mainhand, offhand, ranged = 0, 0, 0, 0, 0
	local delay

	for i = 1, 18 do
		if i ~= 4 then
			local itemTexture = GetInventoryItemTexture(unit, i)

			if itemTexture then
				local itemLink = GetInventoryItemLink(unit, i)

				if not itemLink then
					delay = true
				else
					local _, _, quality, level = GetItemInfo(itemLink)
					if (not quality) or (not level) then
						delay = true
					else
						if i < 16 then
							total = total + level
						elseif i == 16 then
							mainhand = level
						elseif i == 17 then
							offhand = level
						elseif i == 18 then
							ranged = level
						end
					end
				end
			end
		end
	end

	if not delay then
		if mainhand > 0 and offhand > 0 then
			total = total + mainhand + offhand
		elseif offhand > 0 and ranged > 0 then
			total = total + offhand + ranged
		else
			total = total + max(mainhand, offhand, ranged) * 2
		end
		ilvl = total / 16

		if ilvl > 0 then ilvl = format("%.1f", ilvl) end
	else
		ilvl = nil
	end

	return ilvl
end

function T:GetUnitSpec(unit)
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local isInspect = unit ~= "player"
	local talentGroup = GetActiveTalentGroup(isInspect)

	local specName, specIcon = NONE
	local higher = 0
	local points = {}
	for i = 1, 3 do
		local name, icon, point = GetTalentTabInfo(i, isInspect, false, talentGroup)

		if point > higher then
			higher = point
			specName = name
			specIcon = icon
		end

		points[i] = point
	end

	if specIcon and T.db["TalentIcon"] then
		specName = format("%s %s", P.TextureString(specIcon, ICON_STRING), specName)
	end

	return T.db["TalentPoints"] and format("%s (%d/%d/%d)", specName, points[1], points[2], points[3]) or specName
end

function T:InspectUnit(unit, forced)
	local spec, level

	if UnitIsUnit(unit, "player") then
		spec = self:GetUnitSpec("player")
		level = self:GetUnitItemLevel("player")
		self:SetupSpecLevel(spec, level)
	else
		if UnitGUID(unit) ~= currentGUID then return end

		local currentDB = cache[currentGUID]
		spec = currentDB.spec
		level = currentDB.level
		self:SetupSpecLevel(spec, level)

		if T:CanBlizzardInspect(unit) then
			if IsShiftKeyDown() then forced = true end
			if spec and level and not forced and (GetTime() - currentDB.getTime < resetTime) then
				updater.elapsed = frequency
				return
			end
			if InspectFrame and InspectFrame:IsShown() then return end

			self:SetupSpecLevel()
			updater:Show()
		elseif T:CanOurInspect(unit) then
			if spec and level and (GetTime() - currentDB.getTime < resetTime) then
				return
			end

			local name = T:GetFullName(GetUnitName(unit, true))
			local db = T:BuildCharacterDb(name)
			db.guid = db.guid or UnitGUID(unit)

			if not db.lastTime or GetTime() - db.lastTime > 60 then
				P:SendCommMessage(ALA_PREFIX, Ala:PackQuery(true, true, false, false), "WHISPER", name)
				db.lastTime = GetTime()
			end
		end
	end
end

function T:AddSpecLevel()
	if not T.db["SpecLevel"] then return end

	local unit = NT.GetUnit(self)
	if not unit or not UnitIsPlayer(unit) then return end

	currentUNIT, currentGUID = unit, UnitGUID(unit)
	if not cache[currentGUID] then cache[currentGUID] = {} end

	T:InspectUnit(unit)
end

do
	if NT.OnTooltipSetUnit then
		hooksecurefunc(NT, "OnTooltipSetUnit", T.AddSpecLevel)
	end
end

function T:ClearInspectCache()
	wipe(cache)
	wipe(T.userCache)
end

function T:ErrorFilter(_, msg)
	local name = strmatch(msg, PLAYER_NOT_FOUND_STRING)
	local db = name and T:BuildCharacterDb(name)
	if db and db.lastTime and GetTime() - db.lastTime < 5 then
		return true
	end
	return false
end

function T:SpecLevel()
	T.userCache = {}
	T.waitingItems = {}
	T.waitingUnits = {}
	T.myFaction = UnitFactionGroup("player")
	P:RegisterComm(ALA_PREFIX, T.OnAlaCommand)
	B:RegisterEvent("UNIT_INVENTORY_CHANGED", T.GetInspectInfo)
	B:RegisterEvent("GET_ITEM_INFO_RECEIVED", T.WaitItemLevel)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", T.ErrorFilter)
end