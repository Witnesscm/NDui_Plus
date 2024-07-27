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

local tiers = {
	"Vault of the Incarnates",
	"Aberrus, the Shadowed Crucible",
	"Amirdrassil, the Dream's Hope"
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
	["Vault of the Incarnates"] = {
		short = L["[ABBR] Vault of the Incarnates"],
		full = L["Vault of the Incarnates"]
	},
	["Aberrus, the Shadowed Crucible"] = {
		short = L["[ABBR] Aberrus, the Shadowed Crucible"],
		full = L["Aberrus, the Shadowed Crucible"]
	},
	["Amirdrassil, the Dream's Hope"] = {
		short = L["[ABBR] Amirdrassil, the Dream's Hope"],
		full = L["Amirdrassil, the Dream's Hope"]
	},
	["Temple of the Jade Serpent"] = {
		short = L["[ABBR] Temple of the Jade Serpent"],
		full = L["Temple of the Jade Serpent"]
	},
	["Shadowmoon Burial Grounds"] = {
		short = L["[ABBR] Shadowmoon Burial Grounds"],
		full = L["Shadowmoon Burial Grounds"]
	},
	["Halls of Valor"] = {
		short = L["[ABBR] Halls of Valor"],
		full = L["Halls of Valor"]
	},
	["Court of Stars"] = {
		short = L["[ABBR] Court of Stars"],
		full = L["Court of Stars"]
	},
	["Ruby Life Pools"] = {
		short = L["[ABBR] Ruby Life Pools"],
		full = L["Ruby Life Pools"]
	},
	["The Nokhud Offensive"] = {
		short = L["[ABBR] The Nokhud Offensive"],
		full = L["The Nokhud Offensive"]
	},
	["The Azure Vault"] = {
		short = L["[ABBR] The Azure Vault"],
		full = L["The Azure Vault"]
	},
	["Algeth'ar Academy"] = {
		short = L["[ABBR] Algeth'ar Academy"],
		full = L["Algeth'ar Academy"]
	},
	["Neltharion's Lair"] = {
		short = L["[ABBR] Neltharion's Lair"],
		full = L["Neltharion's Lair"]
	},
	["Freehold"] = {
		short = L["[ABBR] Freehold"],
		full = L["Freehold"]
	},
	["The Underrot"] = {
		short = L["[ABBR] The Underrot"],
		full = L["The Underrot"]
	},
	["Uldaman: Legacy of Tyr"] = {
		short = L["[ABBR] Uldaman: Legacy of Tyr"],
		full = L["Uldaman: Legacy of Tyr"]
	},
	["Neltharus"] = {
		short = L["[ABBR] Neltharus"],
		full = L["Neltharus"]
	},
	["Brackenhide Hollow"] = {
		short = L["[ABBR] Brackenhide Hollow"],
		full = L["Brackenhide Hollow"]
	},
	["Halls of Infusion"] = {
		short = L["[ABBR] Halls of Infusion"],
		full = L["Halls of Infusion"]
	},
	["The Vortex Pinnacle"] = {
		short = L["[ABBR] The Vortex Pinnacle"],
		full = L["The Vortex Pinnacle"]
	},
	["The Everbloom"] = {
		short = L["[ABBR] The Everbloom"],
		full = L["The Everbloom"]
	},
	["Darkheart Thicket"] = {
		short = L["[ABBR] Darkheart Thicket"],
		full = L["Darkheart Thicket"]
	},
	["Black Rook Hold"] = {
		short = L["[ABBR] Black Rook Hold"],
		full = L["Black Rook Hold"]
	},
	["Atal'Dazar"] = {
		short = L["[ABBR] Atal'Dazar"],
		full = L["Atal'Dazar"]
	},
	["Waycrest Manor"] = {
		short = L["[ABBR] Waycrest Manor"],
		full = L["Waycrest Manor"]
	},
	["Throne of the Tides"] = {
		short = L["[ABBR] Throne of the Tides"],
		full = L["Throne of the Tides"]
	},
	["Dawn of the Infinite: Galakrond's Fall"] = {
		short = L["[ABBR] Dawn of the Infinite: Galakrond's Fall"],
		full = L["Dawn of the Infinite: Galakrond's Fall"]
	},
	["Dawn of the Infinite: Murozond's Rise"] = {
		short = L["[ABBR] Dawn of the Infinite: Murozond's Rise"],
		full = L["Dawn of the Infinite: Murozond's Rise"]
	},
	["Dragonflight Keystone Master: Season One"] = {
		short = L["[ABBR] Dragonflight Keystone Master: Season One"],
		full = L["Dragonflight Keystone Master: Season One"]
	},
	["Dragonflight Keystone Hero: Season One"] = {
		short = L["[ABBR] Dragonflight Keystone Hero: Season One"],
		full = L["Dragonflight Keystone Hero: Season One"]
	},
	["Dragonflight Keystone Master: Season Two"] = {
		short = L["[ABBR] Dragonflight Keystone Master: Season Two"],
		full = L["Dragonflight Keystone Master: Season Two"]
	},
	["Dragonflight Keystone Hero: Season Two"] = {
		short = L["[ABBR] Dragonflight Keystone Hero: Season Two"],
		full = L["Dragonflight Keystone Hero: Season Two"]
	},
	["Dragonflight Keystone Master: Season Three"] = {
		short = L["[ABBR] Dragonflight Keystone Master: Season Three"],
		full = L["Dragonflight Keystone Master: Season Three"]
	},
	["Dragonflight Keystone Hero: Season Three"] = {
		short = L["[ABBR] Dragonflight Keystone Hero: Season Three"],
		full = L["Dragonflight Keystone Hero: Season Three"]
	},
	["Dragonflight Keystone Master: Season Four"] = {
		short = L["[ABBR] Dragonflight Keystone Master: Season Four"],
		full = L["Dragonflight Keystone Master: Season Four"]
	},
	["Dragonflight Keystone Hero: Season Four"] = {
		short = L["[ABBR] Dragonflight Keystone Hero: Season Four"],
		full = L["Dragonflight Keystone Hero: Season Four"]
	}
}

local raidAchievements = {
	["Vault of the Incarnates"] = {
		["Mythic"] = {
			16387,  -- 击败艾拉诺格（史诗化身巨龙牢窟）
			16388,  -- 击败泰洛斯（史诗化身巨龙牢窟）
			16389,  -- 击败原始议会（史诗化身巨龙牢窟）
			16390,  -- 击败瑟娜尔丝，冰冷之息（史诗化身巨龙牢窟）
			16391,  -- 击败晋升者达瑟雅（史诗化身巨龙牢窟）
			16392,  -- 击败库洛格·恐怖图腾（史诗化身巨龙牢窟）
			16393,  -- 击败巢穴守护者迪乌尔娜（史诗化身巨龙牢窟）
			16394,  -- 击败莱萨杰丝（史诗化身巨龙牢窟）
		},
		["Heroic"] = {
			16379,  -- 击败艾拉诺格（英雄化身巨龙牢窟）
			16380,  -- 击败泰洛斯（英雄化身巨龙牢窟）
			16381,  -- 击败原始议会（英雄化身巨龙牢窟）
			16382,  -- 击败瑟娜尔丝，冰冷之息（英雄化身巨龙牢窟）
			16383,  -- 击败晋升者达瑟雅（英雄化身巨龙牢窟）
			16384,  -- 击败库洛格·恐怖图腾（英雄化身巨龙牢窟）
			16385,  -- 击败巢穴守护者迪乌尔娜（英雄化身巨龙牢窟）
			16386,  -- 击败莱萨杰丝（英雄化身巨龙牢窟）
		},
		["Normal"] = {
			16371,  -- 击败艾拉诺格（普通化身巨龙牢窟）
			16372,  -- 击败泰洛斯（普通化身巨龙牢窟）
			16373,  -- 击败原始议会（普通化身巨龙牢窟）
			16374,  -- 击败瑟娜尔丝，冰冷之息（普通化身巨龙牢窟）
			16375,  -- 击败晋升者达瑟雅（普通化身巨龙牢窟）
			16376,  -- 击败库洛格·恐怖图腾（普通化身巨龙牢窟）
			16377,  -- 击败巢穴守护者迪乌尔娜（普通化身巨龙牢窟）
			16378,  -- 击败莱萨杰丝（普通化身巨龙牢窟）
		},
		["Raid Finder"] = {
			16359,  -- 击败艾拉诺格（随机化身巨龙牢窟）
			16361,  -- 击败泰洛斯（随机化身巨龙牢窟）
			16362,  -- 击败原始议会（随机化身巨龙牢窟）
			16366,  -- 击败瑟娜尔丝，冰冷之息（随机化身巨龙牢窟）
			16367,  -- 击败晋升者达瑟雅（随机化身巨龙牢窟）
			16368,  -- 击败库洛格·恐怖图腾（随机化身巨龙牢窟）
			16369,  -- 击败巢穴守护者迪乌尔娜（随机化身巨龙牢窟）
			16370,  -- 击败莱萨杰丝（随机化身巨龙牢窟）
		}
	},
	["Aberrus, the Shadowed Crucible"] = {
		["Mythic"] = {
			18219,  -- 消灭狱铸者卡扎拉（史诗亚贝鲁斯，焰影熔炉）
			18220,  -- 消灭融合体密室（史诗亚贝鲁斯，焰影熔炉）
			18221,  -- 消灭被遗忘的实验体（史诗亚贝鲁斯，焰影熔炉）
			18222,  -- 消灭扎卡利突袭（史诗亚贝鲁斯，焰影熔炉）
			18223,  -- 消灭长老莱修克（史诗亚贝鲁斯，焰影熔炉）
			18224,  -- 消灭警戒管事兹斯卡恩（史诗亚贝鲁斯，焰影熔炉）
			18225,  -- 消灭玛格莫莱克斯（史诗亚贝鲁斯，焰影熔炉）
			18226,  -- 消灭奈萨里奥的回响（史诗亚贝鲁斯，焰影熔炉）
			18227,  -- 消灭鳞长萨卡雷斯（史诗亚贝鲁斯，焰影熔炉）
		},
		["Heroic"] = {
			18210,  -- 消灭狱铸者卡扎拉（英雄亚贝鲁斯，焰影熔炉）
			18211,  -- 消灭融合体密室（英雄亚贝鲁斯，焰影熔炉）
			18212,  -- 消灭被遗忘的实验体（英雄亚贝鲁斯，焰影熔炉）
			18213,  -- 消灭扎卡利突袭（英雄亚贝鲁斯，焰影熔炉）
			18214,  -- 消灭长老莱修克（英雄亚贝鲁斯，焰影熔炉）
			18215,  -- 消灭警戒管事兹斯卡恩（英雄亚贝鲁斯，焰影熔炉）
			18216,  -- 消灭玛格莫莱克斯（英雄亚贝鲁斯，焰影熔炉）
			18217,  -- 消灭奈萨里奥的回响（英雄亚贝鲁斯，焰影熔炉）
			18218,  -- 消灭鳞长萨卡雷斯（英雄亚贝鲁斯，焰影熔炉）
		},
		["Normal"] = {
			18189,  -- 消灭狱铸者卡扎拉（普通亚贝鲁斯，焰影熔炉）
			18190,  -- 消灭融合体密室（普通亚贝鲁斯，焰影熔炉）
			18191,  -- 消灭被遗忘的实验体（普通亚贝鲁斯，焰影熔炉）
			18192,  -- 消灭扎卡利突袭（普通亚贝鲁斯，焰影熔炉）
			18194,  -- 消灭长老莱修克（普通亚贝鲁斯，焰影熔炉）
			18195,  -- 消灭警戒管事兹斯卡恩（普通亚贝鲁斯，焰影熔炉）
			18196,  -- 消灭玛格莫莱克斯（普通亚贝鲁斯，焰影熔炉）
			18197,  -- 消灭奈萨里奥的回响（普通亚贝鲁斯，焰影熔炉）
			18198,  -- 消灭鳞长萨卡雷斯（普通亚贝鲁斯，焰影熔炉）
		},
		["Raid Finder"] = {
			18180,  -- 消灭狱铸者卡扎拉（随机亚贝鲁斯，焰影熔炉）
			18181,  -- 消灭融合体密室（随机亚贝鲁斯，焰影熔炉）
			18182,  -- 消灭被遗忘的实验体（随机亚贝鲁斯，焰影熔炉）
			18183,  -- 消灭扎卡利突袭（随机亚贝鲁斯，焰影熔炉）
			18184,  -- 消灭长老莱修克（随机亚贝鲁斯，焰影熔炉）
			18185,  -- 消灭警戒管事兹斯卡恩（随机亚贝鲁斯，焰影熔炉）
			18186,  -- 消灭玛格莫莱克斯（随机亚贝鲁斯，焰影熔炉）
			18188,  -- 消灭奈萨里奥的回响（随机亚贝鲁斯，焰影熔炉）
			18187,  -- 消灭鳞长萨卡雷斯（随机亚贝鲁斯，焰影熔炉）
		}
	},
	["Amirdrassil, the Dream's Hope"] = {
		["Mythic"] = {
			19378,  -- 消灭瘤根（史诗阿梅达希尔，梦境之愿）
			19379,  -- 消灭残虐者艾姬拉（史诗阿梅达希尔，梦境之愿）
			19380,  -- 消灭沃尔科罗斯（史诗阿梅达希尔，梦境之愿）
			19381,  -- 消灭梦境议会（史诗阿梅达希尔，梦境之愿）
			19382,  -- 消灭拉罗达尔，烈焰守护者（史诗阿梅达希尔，梦境之愿）
			19383,  -- 消灭尼穆威，轮回编织者（史诗阿梅达希尔，梦境之愿）
			19384,  -- 消灭斯莫德隆（史诗阿梅达希尔，梦境之愿）
			19385,  -- 消灭丁达尔·迅贤，烈焰预言者（史诗阿梅达希尔，梦境之愿）
			19386,  -- 消灭火光之龙菲莱克（史诗阿梅达希尔，梦境之愿）
		},
		["Heroic"] = {
			19369,  -- 消灭瘤根（英雄阿梅达希尔，梦境之愿）
			19370,  -- 消灭残虐者艾姬拉（英雄阿梅达希尔，梦境之愿）
			19371,  -- 消灭沃尔科罗斯（英雄阿梅达希尔，梦境之愿）
			19372,  -- 消灭梦境议会（英雄阿梅达希尔，梦境之愿）
			19373,  -- 消灭拉罗达尔，烈焰守护者（英雄阿梅达希尔，梦境之愿）
			19374,  -- 消灭尼穆威，轮回编织者（英雄阿梅达希尔，梦境之愿）
			19375,  -- 消灭斯莫德隆（英雄阿梅达希尔，梦境之愿）
			19376,  -- 消灭丁达尔·迅贤，烈焰预言者（英雄阿梅达希尔，梦境之愿）
			19377,  -- 消灭火光之龙菲莱克（英雄阿梅达希尔，梦境之愿）
		},
		["Normal"] = {
			19360,  -- 消灭瘤根（普通阿梅达希尔，梦境之愿）
			19361,  -- 消灭残虐者艾姬拉（普通阿梅达希尔，梦境之愿）
			19362,  -- 消灭沃尔科罗斯（普通阿梅达希尔，梦境之愿）
			19363,  -- 消灭梦境议会（普通阿梅达希尔，梦境之愿）
			19364,  -- 消灭拉罗达尔，烈焰守护者（普通阿梅达希尔，梦境之愿）
			19365,  -- 消灭尼穆威，轮回编织者（普通阿梅达希尔，梦境之愿）
			19366,  -- 消灭斯莫德隆（普通阿梅达希尔，梦境之愿）
			19367,  -- 消灭丁达尔·迅贤，烈焰预言者（普通阿梅达希尔，梦境之愿）
			19368,  -- 消灭火光之龙菲莱克（普通阿梅达希尔，梦境之愿）
		},
		["Raid Finder"] = {
			19348,  -- 消灭瘤根（随机阿梅达希尔，梦境之愿）
			19352,  -- 消灭残虐者艾姬拉（随机阿梅达希尔，梦境之愿）
			19353,  -- 消灭沃尔科罗斯（随机阿梅达希尔，梦境之愿）
			19354,  -- 消灭梦境议会（随机阿梅达希尔，梦境之愿）
			19355,  -- 消灭拉罗达尔，烈焰守护者（随机阿梅达希尔，梦境之愿）
			19356,  -- 消灭尼穆威，轮回编织者（随机阿梅达希尔，梦境之愿）
			19357,  -- 消灭斯莫德隆（随机阿梅达希尔，梦境之愿）
			19358,  -- 消灭丁达尔·迅贤，烈焰预言者（随机阿梅达希尔，梦境之愿）
			19359,  -- 消灭火光之龙菲莱克（随机阿梅达希尔，梦境之愿）
		}
	}
}

-- https://wago.tools/db2/MapChallengeMode
local mythicKeystoneDungeons = {
	[2] = "Temple of the Jade Serpent",
	[56] = "Stormstout Brewery",
	[57] = "Gate of the Setting Sun",
	[58] = "Shado-Pan Monastery",
	[59] = "Siege of Niuzao Temple",
	[60] = "Mogu'shan Palace",
	[76] = "Scholomance",
	[77] = "Scarlet Halls",
	[78] = "Scarlet Monastery",
	[161] = "Skyreach",
	[163] = "Bloodmaul Slag Mines",
	[164] = "Auchindoun",
	[165] = "Shadowmoon Burial Grounds",
	[166] = "Grimrail Depot",
	[167] = "Upper Blackrock Spire",
	[168] = "The Everbloom",
	[169] = "Iron Docks",
	[197] = "Eye of Azshara",
	[198] = "Darkheart Thicket",
	[199] = "Black Rook Hold",
	[200] = "Halls of Valor",
	[206] = "Neltharion's Lair",
	[207] = "Vault of the Wardens",
	[208] = "Maw of Souls",
	[209] = "The Arcway",
	[210] = "Court of Stars",
	[227] = "Return to Karazhan: Lower",
	[233] = "Cathedral of Eternal Night",
	[234] = "Return to Karazhan: Upper",
	[239] = "Seat of the Triumvirate",
	[244] = "Atal'Dazar",
	[245] = "Freehold",
	[246] = "Tol Dagor",
	[247] = "The MOTHERLODE!!",
	[248] = "Waycrest Manor",
	[249] = "Kings' Rest",
	[250] = "Temple of Sethraliss",
	[251] = "The Underrot",
	[252] = "Shrine of the Storm",
	[353] = "Siege of Boralus",
	[369] = "Operation: Mechagon - Junkyard",
	[370] = "Operation: Mechagon - Workshop",
	[375] = "Mists of Tirna Scithe",
	[376] = "The Necrotic Wake",
	[377] = "De Other Side",
	[378] = "Halls of Atonement",
	[379] = "Plaguefall",
	[380] = "Sanguine Depths",
	[381] = "Spires of Ascension",
	[382] = "Theater of Pain",
	[391] = "Tazavesh: Streets of Wonder",
	[392] = "Tazavesh: So'leah's Gambit",
	[399] = "Ruby Life Pools",
	[400] = "The Nokhud Offensive",
	[401] = "The Azure Vault",
	[402] = "Algeth'ar Academy",
	[403] = "Uldaman: Legacy of Tyr",
	[404] = "Neltharus",
	[405] = "Brackenhide Hollow",
	[406] = "Halls of Infusion",
	[438] = "The Vortex Pinnacle",
	[456] = "Throne of the Tides",
	[463] = "Dawn of the Infinite: Galakrond's Fall",
	[464] = "Dawn of the Infinite: Murozond's Rise",
	[499] = "Priory of the Sacred Flame",
	[500] = "The Rookery",
	[501] = "The Stonevault",
	[502] = "City of Threads",
	[503] = "Ara-Kara, City of Echoes",
	[504] = "Darkflame Cleft",
	[505] = "The Dawnbreaker",
	[506] = "Cinderbrew Meadery",
	[507] = "Grim Batol",
}

local keystoneAchievements ={
	[1] = {
		{id = 16650, name = "Dragonflight Keystone Hero: Season One"},
		{id = 16649, name = "Dragonflight Keystone Master: Season One"}
	},
	[2] = {
		{id = 17845, name = "Dragonflight Keystone Hero: Season Two"},
		{id = 17844, name = "Dragonflight Keystone Master: Season Two"}
	},
	[3] = {
		{id = 19012, name = "Dragonflight Keystone Hero: Season Three"},
		{id = 19011, name = "Dragonflight Keystone Master: Season Three"}
	},
	[4] = {
		{id = 19783, name = "Dragonflight Keystone Hero: Season Four"},
		{id = 19782, name = "Dragonflight Keystone Master: Season Four"}
	}
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
			for _, achievements in ipairs(keystoneAchievements) do
				for index, achievement in ipairs(achievements) do
					local completedString, completed = GetAchievementInfoByID(guid, achievement.id)
					if completed or index == #achievements then
						cache[guid].info.special[achievement.name] = completedString
						break
					end
				end
			end
		end

		for _, achievement in ipairs(specialAchievements) do
			local completedString = GetAchievementInfoByID(guid, achievement.id)
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

	if T.db["ProgAchievement"] and cache[guid].info.special and next(cache[guid].info.special) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Special Achievements"])

		if T.db["KeystoneMaster"] then
			for _, achievements in ipairs(keystoneAchievements) do
				for _, achievement in ipairs(achievements) do
					local name = achievement.name
					local nameStr = locales[name] and locales[name].short or name
					local completedStr = cache[guid].info.special[name]
					if completedStr then
						GameTooltip:AddDoubleLine(nameStr, completedStr, .6, .8, 1, 1, 1, 1)
					end
				end
			end
		end

		for _, achievement in ipairs(specialAchievements) do
			local name = achievement.name
			local nameStr = locales[name] and locales[name].short or name
			local completedStr = cache[guid].info.special[name]
			GameTooltip:AddDoubleLine(nameStr, completedStr, .6, .8, 1, 1, 1, 1)
		end
	end

	if T.db["ProgRaids"] and cache[guid].info.raids and next(cache[guid].info.raids) then
		local title = false

		for _, tier in ipairs(tiers) do
			for _, level in ipairs(levels) do
				if (cache[guid].info.raids[tier][level]) then
					if not title then
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(L["Raids"])
						title = true
					end

					local right = GetLevelColoredString(level, true) .. " " .. cache[guid].info.raids[tier][level]
					GameTooltip:AddDoubleLine(locales[tier].short, right, .6, .8, 1, 1, 1, 1)
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
			local name = mythicKeystoneDungeons[info.challengeModeID] and locales[mythicKeystoneDungeons[info.challengeModeID]] and locales[mythicKeystoneDungeons[info.challengeModeID]].short or C_ChallengeMode.GetMapUIInfo(info.challengeModeID)
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