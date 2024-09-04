local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local T = P:GetModule("Tooltip")
local NT = B:GetModule("Tooltip")
---------------------------------
-- ElvUI_WindTools, by fang2hou
---------------------------------
local MAX_PLAYER_LEVEL = GetMaxLevelForPlayerExpansion()

local cache = {}
local compareGUID

T.RaidData = {
	[1] = {
		abbr = L["[ABBR] Nerub-ar Palace"],
		achievements = {
			{ 40267, 40271, 40275, 40279, 40283, 40287, 40291, 40295 },
			{ 40268, 40272, 40276, 40280, 40284, 40288, 40292, 40296 },
			{ 40269, 40273, 40277, 40281, 40285, 40289, 40293, 40297 },
			{ 40270, 40274, 40278, 40282, 40286, 40290, 40294, 40298 }
		}
	}
}

T.MythicPlusAchievementData = {
	[1] = {
		{ id = 20526, abbr = L["[ABBR] The War Within Keystone Hero: Season One"] },
		{ id = 20525, abbr = L["[ABBR] The War Within Keystone Master: Season One"] }
	}
}

-- https://wago.tools/db2/MapChallengeMode
T.MythicPlusMapData = {
	[2] = L["[ABBR] Temple of the Jade Serpent"],
	[165] = L["[ABBR] Shadowmoon Burial Grounds"],
	[168] = L["[ABBR] The Everbloom"],
	[198] = L["[ABBR] Darkheart Thicket"],
	[199] = L["[ABBR] Black Rook Hold"],
	[200] = L["[ABBR] Halls of Valor"],
	[206] = L["[ABBR] Neltharion's Lair"],
	[210] = L["[ABBR] Court of Stars"],
	[244] = L["[ABBR] Atal'Dazar"],
	[245] = L["[ABBR] Freehold"],
	[248] = L["[ABBR] Waycrest Manor"],
	[251] = L["[ABBR] The Underrot"],
	[353] = L["[ABBR] Siege of Boralus"],
	[375] = L["[ABBR] Mists of Tirna Scithe"],
	[376] = L["[ABBR] The Necrotic Wake"],
	[399] = L["[ABBR] Ruby Life Pools"],
	[400] = L["[ABBR] The Nokhud Offensive"],
	[401] = L["[ABBR] The Azure Vault"],
	[402] = L["[ABBR] Algeth'ar Academy"],
	[403] = L["[ABBR] Uldaman: Legacy of Tyr"],
	[404] = L["[ABBR] Neltharus"],
	[405] = L["[ABBR] Brackenhide Hollow"],
	[406] = L["[ABBR] Halls of Infusion"],
	[438] = L["[ABBR] The Vortex Pinnacle"],
	[456] = L["[ABBR] Throne of the Tides"],
	[463] = L["[ABBR] Dawn of the Infinite: Galakrond's Fall"],
	[464] = L["[ABBR] Dawn of the Infinite: Murozond's Rise"],
	[499] = L["[ABBR] Priory of the Sacred Flame"],
	[500] = L["[ABBR] The Rookery"],
	[501] = L["[ABBR] The Stonevault"],
	[502] = L["[ABBR] City of Threads"],
	[503] = L["[ABBR] Ara-Kara, City of Echoes"],
	[504] = L["[ABBR] Darkflame Cleft"],
	[505] = L["[ABBR] The Dawnbreaker"],
	[506] = L["[ABBR] Cinderbrew Meadery"],
	[507] = L["[ABBR] Grim Batol"]
}

local difficulties = {
	{ name = PLAYER_DIFFICULTY3, abbr = L["[ABBR] Raid Finder"], color = "ff8000" },
	{ name = PLAYER_DIFFICULTY1, abbr = L["[ABBR] Normal"], color = "1eff00" },
	{ name = PLAYER_DIFFICULTY2, abbr = L["[ABBR] Heroic"], color = "0070dd" },
	{ name = PLAYER_DIFFICULTY6, abbr = L["[ABBR] Mythic"], color = "a335ee" }
}

local specialAchievements = {}

function T:UpdateProgSettings(full)
	wipe(cache)

	if full then
		wipe(specialAchievements)
		for id in gmatch(T.db["AchievementList"], "%S+") do
			id = tonumber(id) or 0
			local _, name = GetAchievementInfo(id)
			if name then
				tinsert(specialAchievements, {id = id, name = name})
			end
		end
	end
end

local function GetBossKillTimes(guid, achievementID)
	local func = guid == T.myGUID and GetStatistic or GetComparisonStatistic
	return tonumber(func(achievementID), 10) or 0
end

local function GetAchievementInfoByID(guid, achievementID)
	local completed, month, day, year
	if guid == T.myGUID then
		completed, month, day, year = select(4, GetAchievementInfo(achievementID))
	else
		completed, month, day, year = GetAchievementComparisonInfo(achievementID)
	end

	local completedString = "|cff888888" .. L["Not Completed"] .. "|r"
	if completed then
		completedString = gsub(L["%month%-%day%-%year%"], "%%month%%", month)
		completedString = gsub(completedString, "%%day%%", day)
		completedString = gsub(completedString, "%%year%%", 2000 + year)
	end

	return completedString, completed
end

function T:UpdateProgression(guid, faction)
	cache[guid] = cache[guid] or {}
	cache[guid].info = cache[guid].info or {}
	cache[guid].timer = GetTime()

	if T.db["ProgAchievement"] then
		cache[guid].info.special = {}

		if T.db["KeystoneMaster"] then
			for _, achievements in ipairs(T.MythicPlusAchievementData) do
				for index, achievement in ipairs(achievements) do
					local completedString, completed = GetAchievementInfoByID(guid, achievement.id)
					if completed or index == #achievements then
						cache[guid].info.special[achievement.id] = completedString
						break
					end
				end
			end
		end

		for _, achievement in ipairs(specialAchievements) do
			local completedString = GetAchievementInfoByID(guid, achievement.id)
			cache[guid].info.special[achievement.id] = completedString
		end
	end

	if T.db["ProgRaids"] then
		cache[guid].info.raids = {}
		for tier, data in ipairs(T.RaidData) do
			cache[guid].info.raids[tier] = {}
			local bosses = data.achievements
			for diff = #bosses, 1, -1 do
				local alreadyKilled = 0
				for _, achievementID in pairs(bosses[diff]) do
					if GetBossKillTimes(guid, achievementID) > 0 then
						alreadyKilled = alreadyKilled + 1
					end
				end

				if alreadyKilled > 0 then
					cache[guid].info.raids[tier][diff] = format("%d/%d", alreadyKilled, #bosses[diff])
					if alreadyKilled == #bosses[diff] then
						break
					end
				end
			end
		end
	end
end

function T:SetProgressionInfo(unit, guid)
	if not cache[guid] then return end

	if T.db["ProgAchievement"] and cache[guid].info.special and next(cache[guid].info.special) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Special Achievements"])

		if T.db["KeystoneMaster"] then
			for _, achievements in ipairs(T.MythicPlusAchievementData) do
				for _, achievement in ipairs(achievements) do
					local name = achievement.abbr or achievement.name
					local right = cache[guid].info.special[achievement.id]
					if right then
						GameTooltip:AddDoubleLine(name, right, .6, .8, 1, 1, 1, 1)
					end
				end
			end
		end

		for _, achievement in ipairs(specialAchievements) do
			local name = achievement.abbr or achievement.name
			local right = cache[guid].info.special[achievement.id]
			if right then
				GameTooltip:AddDoubleLine(name, right, .6, .8, 1, 1, 1, 1)
			end
		end
	end

	if T.db["ProgRaids"] and cache[guid].info.raids and next(cache[guid].info.raids) then
		local title = false

		for tier, data in ipairs(T.RaidData) do
			for diff = #data.achievements, 1, -1 do
				if (cache[guid].info.raids[tier][diff]) then
					if not title then
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(L["Raids"])
						title = true
					end

					local right = format("|cff%s%s|r", difficulties[diff].color, difficulties[diff].abbr).. " ".. cache[guid].info.raids[tier][diff]
					GameTooltip:AddDoubleLine(data.abbr, right, .6, .8, 1, 1, 1, 1)
				end
			end
		end
	end

	local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
	local runs = summary and summary.runs
	if T.db["ProgDungeons"] and runs and next(runs) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(CHALLENGES, L["Score (Level)"])

		for _, info in ipairs(runs) do
			local name = T.MythicPlusMapData[info.challengeModeID] or C_ChallengeMode.GetMapUIInfo(info.challengeModeID)
			local scoreColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(info.mapScore) or HIGHLIGHT_FONT_COLOR
			local levelColor = info.finishedSuccess and "|cffffffff" or "|cff888888"
			local right = format("%s (%s)", scoreColor:WrapTextInColorCode(info.mapScore), levelColor..info.bestRunLevel.."|r")
			GameTooltip:AddDoubleLine(name, right, .6, .8, 1, 1, 1, 1)
		end
	end
end

function T:GetAchievementInfo(GUID)
	if (compareGUID ~= GUID) then return end

	local unit = "mouseover"

	if UnitExists(unit) then
		local race = select(3, UnitRace(unit))
		local faction = race and C_CreatureInfo.GetFactionInfo(race).groupTag
		if faction then
			T:UpdateProgression(GUID, faction)
			GameTooltip:RefreshData()
		end
	end

	ClearAchievementComparisonUnit()

	B:UnregisterEvent(self, T.GetAchievementInfo)
end

function T:AddProgression()
	if not T.db["Progression"] then return end

	if T.db["CombatHide"] and InCombatLockdown() then return end

	if T.db["ShowByShift"] and not IsShiftKeyDown() then return end

	local unit = NT.GetUnit(self)
	if not unit or not CanInspect(unit) or not UnitIsPlayer(unit) then return end

	local level = UnitLevel(unit)
	if not NDuiPlusDB["Debug"] and not (level and level == MAX_PLAYER_LEVEL) then return end

	local guid = UnitGUID(unit)
	if not cache[guid] or (GetTime() - cache[guid].timer) > 600 then
		if guid == T.myGUID then
			T:UpdateProgression(guid, T.myFaction)
		else
			ClearAchievementComparisonUnit()

			compareGUID = guid

			if SetAchievementComparisonUnit(unit) then
				B:RegisterEvent("INSPECT_ACHIEVEMENT_READY", T.GetAchievementInfo)
			end

			return
		end
	end

	T:SetProgressionInfo(unit, guid)
end

do
	if NT.OnTooltipSetUnit then
		hooksecurefunc(NT, "OnTooltipSetUnit", T.AddProgression)
	end
end

function T:Progression()
	T:UpdateProgSettings(true)
end

-- fix error
P:AddCallbackForAddon("Blizzard_AchievementUI", function()
	local origUpdateStatusBars = _G.AchievementFrameComparison_UpdateStatusBars
	_G.AchievementFrameComparison_UpdateStatusBars = function(id)
		if id and id ~= "summary" then
			origUpdateStatusBars(id)
		end
	end
end)