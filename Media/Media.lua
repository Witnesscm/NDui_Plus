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

if B.SetupUIScale then
	hooksecurefunc(B, "SetupUIScale", function()
		if not P.Initialized then
			P:BuildTextureTable()
			P:ReplaceTexture()
		end
	end)
end