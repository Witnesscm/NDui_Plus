local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)

P.Version = GetAddOnMetadata(addonName, "Version")
P.SupportVersion = "6.28.0"

-- Colors
P.InfoColors = {r = .6, g = .8, b = 1}

-- Textures
local Texture = "Interface\\Addons\\"..addonName.."\\Media\\Texture\\"
P.Blank = Texture.."Blank"
P.ArrowUp = Texture.."arrow-up"
P.ArrowDown = Texture.."arrow-down"
P.BorderTex = Texture.."UI-Quickslot2"
P.RotationRightTex = Texture.."UI-RotationRight-Big-Up"
P.SwapTex = Texture.."Swap"
P.LEFT_MOUSE_BUTTON = [[|TInterface\TutorialFrame\UI-Tutorial-Frame:12:12:0:0:512:512:10:65:228:283|t]]
P.RIGHT_MOUSE_BUTTON = [[|TInterface\TutorialFrame\UI-Tutorial-Frame:12:12:0:0:512:512:10:65:330:385|t]]
P.ClearTexture = P.IsRetail() and 0 or ""

P.BarConfig = {
	icon = {
		texCoord = DB.TexCoord,
		points = {
			{"TOPLEFT", C.mult, -C.mult},
			{"BOTTOMRIGHT", -C.mult, C.mult},
		},
	},
	flyoutBorder = {file = ""},
	flyoutBorderShadow = {file = ""},
	border = {file = ""},
	normalTexture = {
		file = DB.textures.normal,
		texCoord = DB.TexCoord,
		color = {.3, .3, .3},
		points = {
			{"TOPLEFT", C.mult, -C.mult},
			{"BOTTOMRIGHT", -C.mult, C.mult},
		},
	},
	flash = {file = DB.textures.flash},
	pushedTexture = {
		file = DB.textures.pushed,
		points = {
			{"TOPLEFT", C.mult, -C.mult},
			{"BOTTOMRIGHT", -C.mult, C.mult},
		},
	},
	checkedTexture = {
		file = 0,
		points = {
			{"TOPLEFT", C.mult, -C.mult},
			{"BOTTOMRIGHT", -C.mult, C.mult},
		},
	},
	highlightTexture = {
		file = 0,
		points = {
			{"TOPLEFT", C.mult, -C.mult},
			{"BOTTOMRIGHT", -C.mult, C.mult},
		},
	},
	cooldown = {
		points = {
			{"TOPLEFT", 0, 0},
			{"BOTTOMRIGHT", 0, 0},
		},
	},
	name = {
		font = {DB.Font[1], DB.Font[2]+1, DB.Font[3]},
		points = {
			{"BOTTOMLEFT", 0, 0},
			{"BOTTOMRIGHT", 0, 0},
		},
	},
	hotkey = {
		font = {DB.Font[1], DB.Font[2]+1, DB.Font[3]},
		points = {
			{"TOPRIGHT", 0, -0.5},
			{"TOPLEFT", 0, -0.5},
		},
	},
	count = {
		font = {DB.Font[1], DB.Font[2]+1, DB.Font[3]},
		points = {
			{"BOTTOMRIGHT", 2, 0},
		},
	},
	buttonstyle = {file = ""},
}