local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local style = {
	name = "NDui",
	border = {
		color = {0, 0, 0},
		offset = 0,
		size = 1,
		texture = {1, 1, 1, 1},
	},
	title = {
		flags = DB.Font[3],
		shadow = false,
	},
	text = {
		flags = DB.Font[3],
		shadow = false,
	},
	icon = {
		tex_coords = DB.TexCoord,
	},
	icon_border = {
		color = {0, 0, 0},
		offset = 0,
		size = 1,
		texture = {1, 1, 1, 1},
	},
	icon_text_1 = {
		flags = DB.Font[3],
	},
	icon_text_2 = {
		flags = DB.Font[3],
	},
	slot = {
		tex_coords = DB.TexCoord,
	},
	slot_border = {
		color = {0, 0, 0},
		offset = 0,
		size = 1,
		texture = {1, 1, 1, 1},
	},
	glow = {
		texture = {1, 1, 1, 1},
		size = {226, 50},
	},
	shine = {
		tex_coords = {403 / 512, 465 / 512, 15 / 256, 61 / 256},
		size = {67, 50},
		point = {
			y = -1,
		},
	},
	text_bg = {
		hidden = true,
	},
	leaves = {
		hidden = true,
	},
	dragon = {
		hidden = true,
	},
	icon_highlight = {
		hidden = true,
	},
	bg = {
		default = {
			texture = "",
		},
	},
}

local function SkinToast(event, toast)
	B.SetBD(toast)
end

function S:ls_Toasts()
	if not S.db["ls_Toasts"] then return end

	local LE, LC = unpack(_G.ls_Toasts)
	LE:RegisterSkin("ndui", style)
	LE:RegisterCallback("ToastCreated", SkinToast)
	LC.db.profile.skin = "ndui"
end

function S:LSPreviewBoxCurrency(widget)
	S:Ace3_EditBox(widget)
	P.ReskinTooltip(widget.preview)
end

S:RegisterSkin("ls_Toasts", S.ls_Toasts)
S:RegisterAceGUIWidget("LSPreviewBoxCurrency")