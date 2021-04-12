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
	}
}

local dungeonAchievements = {
	["The Necrotic Wake"] = 14404,
	["Plaguefall"] = 14398,
	["Mists of Tirna Scithe"] = 14395,
	["Halls of Atonement"] = 14392,
	["Theater of Pain"] = 14407,
	["De Other Side"] = 14389,
	["Spires of Ascension"] = 14401,
	["Sanguine Depths"] = 14205
}

local specialAchievements = {
	["Shadowlands Keystone Master: Season One"] = 14532
}

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
		for name, achievementID in pairs(specialAchievements) do
			local completed, month, day, year = GetAchievementInfoByID(guid, achievementID)
			local completedString = "|cff888888" .. L["Not Completed"] .. "|r"
			if completed then
				completedString = gsub(L["%month%-%day%-%year%"], "%%month%%", month)
				completedString = gsub(completedString, "%%day%%", day)
				completedString = gsub(completedString, "%%year%%", 2000 + year)
			end
			cache[guid].info.special = {}
			cache[guid].info.special[name] = completedString
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

	if T.db["ProgDungeons"] then
		cache[guid].info.mythicDungeons = {}
		cache[guid].info.mythicDungeons.total = 0

		for name, achievementID in pairs(dungeonAchievements) do
			cache[guid].info.mythicDungeons[name] = GetBossKillTimes(guid, achievementID)
			cache[guid].info.mythicDungeons.total = cache[guid].info.mythicDungeons.total + cache[guid].info.mythicDungeons[name]
		end
	end
end

function T:SetProgressionInfo(guid)
	if not cache[guid] then return end

	local updated = false

	for i = 2, GameTooltip:NumLines() do
		local leftTip = _G["GameTooltipTextLeft" .. i]
		local leftTipText = leftTip:GetText()
		local found = false

		if leftTipText then
			if T.db["ProgAchievement"] then
				for name, achievementID in pairs(specialAchievements) do
					if strfind(leftTipText, locales[name].short) then
						local rightTip = _G["GameTooltipTextRight" .. i]
						leftTip:SetText(locales[name].short .. ":")
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

			found = false

			if T.db["ProgDungeons"] then
				for name, achievementID in pairs(dungeonAchievements) do
					if strfind(leftTipText, locales[name].short) then
						local rightTip = _G["GameTooltipTextRight" .. i]
						leftTip:SetText(locales[name].short .. ":")
						rightTip:SetText(cache[guid].info.mythicDungeons[name])
						updated = true
						found = true
						break
					end

					if found then
						break
					end
				end
			end
		end
	end

	if updated then return end

	if T.db["ProgAchievement"] then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Special Achievements"])
		for name, achievementID in pairs(specialAchievements) do
			local left = format("%s:", locales[name].short)
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

	if T.db["ProgDungeons"] and cache[guid].info.mythicDungeons then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["MythicDungeons"])
		for name, achievementID in pairs(dungeonAchievements) do
			local left = format("%s:", locales[name].short)
			local right = cache[guid].info.mythicDungeons[name]
			GameTooltip:AddDoubleLine(left, right, .6, .8, 1, 1, 1, 1)
		end
		GameTooltip:AddDoubleLine(L["Total"]..":", cache[guid].info.mythicDungeons.total, .6, .8, 1, 1, 1, 1)
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
	
	T:SetProgressionInfo(guid)
end

do
	if NT.OnTooltipSetUnit then
		hooksecurefunc(NT, "OnTooltipSetUnit", T.AddProgression)
	end
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