local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)

local LSM = LibStub("LibSharedMedia-3.0")
local Texture = "Interface\\Addons\\"..addonName.."\\Media\\Texture\\"

-- Texture
P.normTex = Texture.."normTex" -- 风行丨GG @ NGA

local textureList = {
	[addonName] = P.normTex,
}

P.TextureTable = {}

function P:BuildTextureTable()
	wipe(P.TextureTable)

	for key, path in next, LSM:HashTable("statusbar") do
		textureList[key] = path
		tinsert(P.TextureTable, {texture = path, name = key})
	end

	table.sort(P.TextureTable, function (a, b) return a.name < b.name end)
	tinsert(P.TextureTable, 1, {texture = P.normTex, name = addonName})
end

function P:ReplaceTexture()
	if not NDuiPlusDB["TexStyle"]["Enable"] then return end

	local path = textureList[NDuiPlusDB["TexStyle"]["Texture"]]
	if path then
		DB.normTex = path
	end
end

do
	-- Before NDui module loaded
	hooksecurefunc(B, "SetSmoothingAmount", function()
		if not P.Initialized then
			P:BuildTextureTable()
			P:ReplaceTexture()
		end
	end)
end

-- Role
P.RoleList = {
	[1] = {
		TANK = Texture.."LynUI\\Tank",
		HEALER = Texture.."LynUI\\Healer",
		DAMAGER = Texture.."LynUI\\DPS",
	},
	[2] = {
		TANK = Texture.."ElvUI\\Tank",
		HEALER = Texture.."ElvUI\\Healer",
		DAMAGER = Texture.."ElvUI\\DPS",
	},
	[3] = {
		TANK = Texture.."ToxiUI\\WhiteTank",
		HEALER = Texture.."ToxiUI\\WhiteHeal",
		DAMAGER = Texture.."ToxiUI\\WhiteDPS",
	},
	[4] = {
		TANK = Texture.."ToxiUI\\NewTank",
		HEALER = Texture.."ToxiUI\\NewHeal",
		DAMAGER = Texture.."ToxiUI\\NewDPS",
	},
	[5] = {
		TANK = Texture.."ToxiUI\\StylizedTank",
		HEALER = Texture.."ToxiUI\\StylizedHeal",
		DAMAGER = Texture.."ToxiUI\\StylizedDPS",
	}
}

function P:BuildRoleTable()
	local roleTable = {}
	for _, icons in ipairs(P.RoleList) do
		local str = ""
		str = str .. P.TextureString(icons.TANK, ":16:16") .. " "
		str = str .. P.TextureString(icons.HEALER, ":16:16") .. " "
		str = str .. P.TextureString(icons.DAMAGER, ":16:16") .. " "
		tinsert(roleTable, str)
	end

	return roleTable
end

local roleCache = {}
do
	hooksecurefunc(B, "ReskinSmallRole", function(icon, role)
		roleCache[icon] = role
	end)
end

local function ReskinSmallRole(icon, role)
	if role == "DPS" then role = "DAMAGER" end
	icon:SetTexCoord(0, 1, 0, 1)
	icon:SetTexture(P.RoleList[NDuiPlusDB["RoleStyle"]["Index"]][role])
end

B:RegisterEvent("PLAYER_LOGIN", function()
	if not NDuiPlusDB["RoleStyle"]["Enable"] then return end

	for icon, role in pairs(roleCache) do
		ReskinSmallRole(icon, role)
	end

	B.ReskinSmallRole = ReskinSmallRole
end)