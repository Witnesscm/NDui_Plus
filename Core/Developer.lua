local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)

do
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

	local function GetExpansionCategoryID(expansion)
		local categorys = GetStatisticsCategoryList()
		for i = #categorys, 1, -1 do
			local categoryName, parent = GetCategoryInfo(categorys[i])
			if categoryName == _G["EXPANSION_NAME" .. expansion] and parent == 14807 then -- 地下城与团队副本
				return categorys[i]
			end
		end
	end

	-- "击败艾拉诺格（随机化身巨龙牢窟）"
	-- "消灭噬灭者乌格拉克斯（随机尼鲁巴尔王宫）"
	-- "维克茜和磨轮（随机解放安德麦）"
	-- "元首阿福扎恩（随机团队虚影尖塔）"
	-- "奇美鲁斯，未梦之神（随机梦境裂隙）"
	local function GetAchievementData(expansion, raidName)
		local data = {}
		local pattern = format("^.-（(.-)%s）", raidName)
		local categoryID = GetExpansionCategoryID(expansion)
		local numStats = GetCategoryNumAchievements(categoryID)
		for i = 1, numStats do
			local _, skip, id = GetStatistic(categoryID, i)
			if not skip then
				local _, name = GetAchievementInfo(id)
				local diff = strmatch(name, pattern)
				if diff then
					diff = strfind(diff, "随机") and "随机" or diff
					data[diff] = data[diff] or {}
					tinsert(data[diff], id)
				end
			end
		end
		return data
	end

	function P.Developer_PrintRaidData(expansion)
		local maxTier = GetExpansionEJTier(expansion)
		if not maxTier then
			print("无效的expansionLevel: " .. expansion)
			return
		end
		EJ_SelectTier(maxTier)
		local dataIndex = 1
		local raidInstID, raidName = EJ_GetInstanceByIndex(dataIndex, true)
		while raidInstID and raidName do
			EJ_SelectInstance(raidInstID)
			local dungeonAreaMapID = select(7, EJ_GetInstanceInfo())
			if dungeonAreaMapID and dungeonAreaMapID > 0 then -- 世界boss
				_G.DEFAULT_CHAT_FRAME:AddMessage("-- " .. raidName)
				local achievementData = GetAchievementData(expansion, raidName)
				for _, diff in ipairs({ "随机", "普通", "英雄", "史诗" }) do
					local str = "{"
					local data = achievementData[diff]
					if data then
						for _, id in ipairs(data) do
							str = str .. " " .. id .. ","
						end
						str = gsub(str, ",$", "")
						str = str .. " },"
						_G.DEFAULT_CHAT_FRAME:AddMessage(str)
					else
						print(format("未找到 %s (%s) 成就数据", raidName, diff))
					end
				end
			end

			dataIndex = dataIndex + 1
			raidInstID, raidName = EJ_GetInstanceByIndex(dataIndex, true)
		end
	end
end

function P:Developer_Command(msg)
	if msg == "debug" then
		NDuiPlusDB["Debug"] = not NDuiPlusDB["Debug"]
		P:Print("debug " .. (NDuiPlusDB["Debug"] and "on" or "off"))
	elseif strfind(msg, "^raid") then
		local expansion = strmatch(msg, "^raid%s-(%d+)")
		expansion = expansion and tonumber(expansion) or GetServerExpansionLevel()
		P.Developer_PrintRaidData(expansion)
	end
end