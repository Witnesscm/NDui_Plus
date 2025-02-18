local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)

do
	local function GetEncounterList(instanceID)
		EJ_SelectInstance(instanceID)
		local list = {}
		local name = EJ_GetEncounterInfoByIndex(1, instanceID)
		while name do
			tinsert(list, name)
			name = EJ_GetEncounterInfoByIndex(#list + 1, instanceID)
		end
		return list
	end

	local function GetExpansionEJTier(expansion)
		local tier = ExpansionEnumToEJTierDataTableId and ExpansionEnumToEJTierDataTableId[expansion]
		if tier then
			return tier
		end

		for i = 1, EJ_GetNumTiers() do
			if EJ_GetTierInfo(i) == _G["EXPANSION_NAME" .. expansion] then
				return i
			end
		end
	end

	local function GetLatestCategoryID()
		local categorys = GetStatisticsCategoryList()
		for i = #categorys, 1, -1 do
			local _, parent = GetCategoryInfo(categorys[i])
			if parent == 14807 then -- 地下城与团队副本
				return categorys[i]
			end
		end
	end

	-- "消灭噬灭者乌格拉克斯（随机尼鲁巴尔王宫）"
	-- "维克茜和磨轮（随机解放安德麦）",
	local function GetAchievementData(raidName)
		local data = {}
		local pattern = format("^(.-)（(.-)%s）", raidName)
		local categoryID = GetLatestCategoryID()
		local numStats = GetCategoryNumAchievements(categoryID)
		for i = 1, numStats do
			local _, skip, id = GetStatistic(categoryID, i)
			if not skip then
				local _, name = GetAchievementInfo(id)
				local boss, diff = strmatch(name, pattern)
				boss = boss and strmatch(boss, "^消灭(.*)$") or boss
				if boss then
					data[boss] = data[boss] or {}
					data[boss][diff] = { id = id, name = name }
				end
			end
		end
		return data
	end

	function P.Developer_PrintRaidData()
		local maxTier = GetExpansionEJTier(GetServerExpansionLevel())
		EJ_SelectTier(maxTier)
		for i = 5, 2, -1 do
			local raidInstID, raidName = EJ_GetInstanceByIndex(i, true)
			if raidInstID and raidName then
				_G.DEFAULT_CHAT_FRAME:AddMessage("-- " .. raidName)
				local bossList = GetEncounterList(raidInstID)
				local achievementData = GetAchievementData(raidName)
				for _, diff in ipairs({ "随机", "普通", "英雄", "史诗" }) do
					local str = "{"
					for _, bossName in ipairs(bossList) do
						local info = achievementData[bossName][diff]
						str = str .. " " .. info.id .. ","
					end
					str = gsub(str, ",$", "")
					str = str .. " },"
					_G.DEFAULT_CHAT_FRAME:AddMessage(str)
				end
			end
		end
	end
end

function P:Developer_Command(msg)
	if msg == "debug" then
		NDuiPlusDB["Debug"] = not NDuiPlusDB["Debug"]
		P:Print("debug " .. (NDuiPlusDB["Debug"] and "on" or "off"))
	elseif msg == "raid" then
		P.Developer_PrintRaidData()
	end
end