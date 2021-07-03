local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local T = P:GetModule("Tooltip")
local NT = B:GetModule("Tooltip")
---------------------------------
-- ElvUI_WindTools, by fang2hou
---------------------------------
local cache = {}
local compareGUID, loadedComparison

local tiers = {
	"Castle Nathria",
	"Sanctum of Domination",
}

local levels = {
	"Mythic",
	"Heroic",
	"Normal",
	"Raid Finder"
}

local locales = {
	["Raid Finder"] = {
		short = L["[ABBR] Raid Finder"],
		full = PLAYER_DIFFICULTY3
	},
	["Normal"] = {
		short = L["[ABBR] Normal"],
		full = PLAYER_DIFFICULTY1
	},
	["Heroic"] = {
		short = L["[ABBR] Heroic"],
		full = PLAYER_DIFFICULTY2
	},
	["Mythic"] = {
		short = L["[ABBR] Mythic"],
		full = PLAYER_DIFFICULTY6
	},
	["Castle Nathria"] = {
		short = L["[ABBR] Castle Nathria"],
		full = L["Castle Nathria"]
	},
	["The Necrotic Wake"] = {
		short = L["[ABBR] The Necrotic Wake"],
		full = L["The Necrotic Wake"]
	},
	["Plaguefall"] = {
		short = L["[ABBR] Plaguefall"],
		full = L["Plaguefall"]
	},
	["Mists of Tirna Scithe"] = {
		short = L["[ABBR] Mists of Tirna Scithe"],
		full = L["Mists of Tirna Scithe"]
	},
	["Halls of Atonement"] = {
		short = L["[ABBR] Halls of Atonement"],
		full = L["Halls of Atonement"]
	},
	["Theater of Pain"] = {
		short = L["[ABBR] Theater of Pain"],
		full = L["Theater of Pain"]
	},
	["De Other Side"] = {
		short = L["[ABBR] De Other Side"],
		full = L["De Other Side"]
	},
	["Spires of Ascension"] = {
		short = L["[ABBR] Spires of Ascension"],
		full = L["Spires of Ascension"]
	},
	["Sanguine Depths"] = {
		short = L["[ABBR] Sanguine Depths"],
		full = L["Sanguine Depths"]
	},
	["Shadowlands Keystone Master: Season One"] = {
		short = L["[ABBR] Shadowlands Keystone Master: Season One"],
		full = L["Shadowlands Keystone Master: Season One"]
	},
	["Shadowlands Keystone Master: Season Two"] = {
		short = L["[ABBR] Shadowlands Keystone Master: Season Two"],
		full = L["Shadowlands Keystone Master: Season Two"]
	},
	["Sanctum of Domination"] = {
		short = L["[ABBR] Sanctum of Domination"],
		full = L["Sanctum of Domination"]
	}
}

local raidAchievements = {
	["Castle Nathria"] = {
		["Mythic"] = {
			14421,
			14425,
			14429,
			14433,
			14437,
			14441,
			14445,
			14449,
			14453,
			14457
		},
		["Heroic"] = {
			14420,
			14424,
			14428,
			14432,
			14436,
			14440,
			14444,
			14448,
			14452,
			14456
		},
		["Normal"] = {
			14419,
			14423,
			14427,
			14431,
			14435,
			14439,
			14443,
			14447,
			14451,
			14455
		},
		["Raid Finder"] = {
			14422,
			14426,
			14430,
			14434,
			14438,
			14442,
			14446,
			14450,
			14454,
			14458
		}
	},
	["Sanctum of Domination"] = {
		["Mythic"] = {
			15139,
			15143,
			15147,
			15155,
			15151,
			15159,
			15163,
			15167,
			15172,
			15176,
		},
		["Heroic"] = {
			15138,
			15142,
			15146,
			15154,
			15150,
			15158,
			15162,
			15166,
			15171,
			15175,
		},
		["Normal"] = {
			15137,
			15141,
			15145,
			15153,
			15149,
			15157,
			15161,
			15165,
			15170,
			15174,
		},
		["Raid Finder"] = {
			15136,
			15140,
			15144,
			15152,
			15148,
			15156,
			15160,
			15164,
			15169,
			15173,
		}
	}
}

local dungeons = {
	[375] = "Mists of Tirna Scithe",
	[376] = "The Necrotic Wake",
	[377] = "De Other Side",
	[378] = "Halls of Atonement",
	[379] = "Plaguefall",
	[380] = "Sanguine Depths",
	[381] = "Spires of Ascension",
	[382] = "Theater of Pain",
}

local specialAchievements = {}

function T:UpdateProgSettings(full)
	wipe(cache)

	if full then
		wipe(specialAchievements)
		if T.db["KeystoneMaster"] then
			tinsert(specialAchievements, {id = 14532, name = "Shadowlands Keystone Master: Season One"})
			tinsert(specialAchievements, {id = 15078, name = "Shadowlands Keystone Master: Season Two"})
		end

		for id in gmatch(T.db["AchievementList"], "%S+") do
			id = tonumber(id) or 0
			local _, name = GetAchievementInfo(id)
			if name then
				tinsert(specialAchievements, {id = id, name = name})
			end
		end
	end
end

local function GetLevelColoredString(level, short)
	local color = "ff8000"

	if level == "Mythic" then
		color = "a335ee"
	elseif level == "Heroic" then
		color = "0070dd"
	elseif level == "Normal" then
		color = "1eff00"
	end

	if short then
		return "|cff" .. color .. locales[level].short .. "|r"
	else
		return "|cff" .. color .. locales[level].full .. "|r"
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
	return completed, month, day, year
end

function T:UpdateProgression(guid, faction)
	cache[guid] = cache[guid] or {}
	cache[guid].info = cache[guid].info or {}
	cache[guid].timer = GetTime()

	if T.db["ProgAchievement"] then
		cache[guid].info.special = {}

		for _, achievement in ipairs(specialAchievements) do
			local completed, month, day, year = GetAchievementInfoByID(guid, achievement.id)
			local completedString = "|cff888888" .. L["Not Completed"] .. "|r"
			if completed then
				completedString = gsub(L["%month%-%day%-%year%"], "%%month%%", month)
				completedString = gsub(completedString, "%%day%%", day)
				completedString = gsub(completedString, "%%year%%", 2000 + year)
			end

			cache[guid].info.special[achievement.name] = completedString
		end
	end

	if T.db["ProgRaids"] then
		cache[guid].info.raids = {}
		for _, tier in ipairs(tiers) do
			cache[guid].info.raids[tier] = {}
			local bosses = raidAchievements[tier]
			if bosses.separated then
				bosses = bosses[faction]
			end

			for _, level in ipairs(levels) do
				local alreadyKilled = 0
				for _, achievementID in pairs(bosses[level]) do
					if GetBossKillTimes(guid, achievementID) > 0 then
						alreadyKilled = alreadyKilled + 1
					end
				end

				if alreadyKilled > 0 then
					cache[guid].info.raids[tier][level] = format("%d/%d", alreadyKilled, #bosses[level])
					if alreadyKilled == #bosses[level] then
						break
					end
				end
			end
		end
	end
end

function T:SetProgressionInfo(unit, guid)
	if not cache[guid] then return end

	local updated = false

	for i = 2, GameTooltip:NumLines() do
		local leftTip = _G["GameTooltipTextLeft" .. i]
		local leftTipText = leftTip:GetText()
		local found = false

		if leftTipText then
			if T.db["ProgAchievement"] then
				for _, achievement in ipairs(specialAchievements) do
					local name = achievement.name
					local nameStr = locales[name] and locales[name].short or name
					if strfind(leftTipText, nameStr) then
						local rightTip = _G["GameTooltipTextRight" .. i]
						leftTip:SetText(nameStr .. ":")
						rightTip:SetText(cache[guid].info.special[name])
						updated = true
						found = true
						break
					end
					if found then
						break
					end
				end
			end

			found = false

			if T.db["ProgRaids"] then
				for _, tier in ipairs(tiers) do
					for _, level in ipairs(levels) do
						if strfind(leftTipText, locales[tier].short) then
							local rightTip = _G["GameTooltipTextRight" .. i]
							leftTip:SetText(format("%s:", locales[tier].short))
							rightTip:SetText(GetLevelColoredString(level, true) .. " " .. cache[guid].info.raids[tier][level])
							updated = true
							found = true
							break
						end
					end

					if found then
						break
					end
				end
			end
		end
	end

	if updated then return end

	if T.db["ProgAchievement"] and cache[guid].info.special then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Special Achievements"])
		for _, achievement in ipairs(specialAchievements) do
			local name = achievement.name
			local nameStr = locales[name] and locales[name].short or name
			local left = format("%s:", nameStr)
			local right = cache[guid].info.special[name]
			GameTooltip:AddDoubleLine(left, right, .6, .8, 1, 1, 1, 1)
		end
	end

	if T.db["ProgRaids"] and next(cache[guid].info.raids) then
		local title = false

		for _, tier in ipairs(tiers) do
			for _, level in ipairs(levels) do
				if (cache[guid].info.raids[tier][level]) then
					if not title then
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(L["Raids"])
						title = true
					end

					local left = format("%s:", locales[tier].short)
					local right = GetLevelColoredString(level, true) .. " " .. cache[guid].info.raids[tier][level]
					GameTooltip:AddDoubleLine(left, right, .6, .8, 1, 1, 1, 1)
				end
			end
		end
	end

	local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
	local runs = summary and summary.runs
	if T.db["ProgDungeons"] and runs and next(runs) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["MythicDungeons"], L["Score (Level)"])

		for _, info in ipairs(runs) do
			local name = dungeons[info.challengeModeID] and locales[dungeons[info.challengeModeID]].short or C_ChallengeMode.GetMapUIInfo(info.challengeModeID)
			local left = format("%s:", name)
			local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(info.mapScore) or HIGHLIGHT_FONT_COLOR
			local right = format("%s (%d)", color:WrapTextInColorCode(info.mapScore), info.bestRunLevel)
			GameTooltip:AddDoubleLine(left, right, .6, .8, 1, 1, 1, 1)
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
			_G.GameTooltip:SetUnit(unit)
		end
	end

	ClearAchievementComparisonUnit()

	B:UnregisterEvent(self, T.GetAchievementInfo)
end

function T:AddProgression()
	if not T.db["Progression"] then return end

	if InCombatLockdown() then return end

	if T.db["ShowByShift"] and not IsShiftKeyDown() then return end

	local unit = NT.GetUnit(self)
	if not unit or not CanInspect(unit) or not UnitIsPlayer(unit) then return end

	local level = UnitLevel(unit)
	if not (level and level == MAX_PLAYER_LEVEL) then return end

	if not IsAddOnLoaded("Blizzard_AchievementUI") then
		AchievementFrame_LoadUI()
	end

	local guid = UnitGUID(unit)
	if not cache[guid] or (GetTime() - cache[guid].timer) > 600 then
		if guid == T.myGUID then
			T:UpdateProgression(guid, T.myFaction)
		else
			ClearAchievementComparisonUnit()

			if not loadedComparison and select(2, IsAddOnLoaded("Blizzard_AchievementUI")) then
				_G.AchievementFrame_DisplayComparison(unit)
				HideUIPanel(_G.AchievementFrame)
				ClearAchievementComparisonUnit()
				loadedComparison = true
			end

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
	T.myGUID = UnitGUID("player")
	T.myFaction = UnitFactionGroup("player")

	T:UpdateProgSettings(true)
end

local function loadFunc(event, addon)  -- fix
	if addon == "Blizzard_AchievementUI" then
		local method = "AchievementFrameComparison_UpdateStatusBars"
		if _G[method] then
			P:RawHook(method, function(id)
				if id and id ~= "summary" then
					P.hooks[method](id)
                end
             end)
		end
		B:UnregisterEvent(event, loadFunc)
	end
end
B:RegisterEvent("ADDON_LOADED", loadFunc)