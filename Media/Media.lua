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

LSM.RegisterCallback(P, "LibSharedMedia_Registered", function(_, mediatype, key)
	if mediatype == "statusbar" then
		local path = LSM:Fetch(mediatype, key)
		if path and key ~= "normTex" then
			if not P.Initialized then -- SharedMedia
				P:BuildTextureTable()
				P:ReplaceTexture()
			end
		end
	end
end)

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
		TANK = Texture.."ToxiUI\\Tank",
		HEALER = Texture.."ToxiUI\\Healer",
		DAMAGER = Texture.."ToxiUI\\DPS",
	},
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

do -- RaidTool
	local Misc = B:GetModule("Misc")
	hooksecurefunc(Misc, "RaidTool_RoleCount", function(self, frame)
		if not NDuiPlusDB["RoleStyle"]["Enable"] then return end

		if frame.roleFrame then
			local tank, _, healer, _, damager = frame.roleFrame:GetRegions()
			local roleList = P.RoleList[NDuiPlusDB["RoleStyle"]["Index"]]

			tank:SetTexCoord(0, 1, 0, 1)
			tank:SetTexture(roleList.TANK)
			healer:SetTexCoord(0, 1, 0, 1)
			healer:SetTexture(roleList.HEALER)
			damager:SetTexCoord(0, 1, 0, 1)
			damager:SetTexture(roleList.DAMAGER)
		end
	end)
end