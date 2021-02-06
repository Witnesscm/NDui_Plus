local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:ls_Toasts()
	if not IsAddOnLoaded("ls_Toasts") then return end
	if not S.db["ls_Toasts"] then return end

	local LE, LC, LL = unpack(_G.ls_Toasts)
	LE:RegisterSkin("ndui", {
		name = "NDui",
		border = {
			color = {0, 0, 0},
			offset = 0,
			size = 1,
			texture = {1, 1, 1, 1},
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
		dragon = {
			hidden = true,
		},
		icon_highlight = {
			hidden = true,
		},
		bg = {
			default = {
				texture = {0.06, 0.06, 0.06, 0.8},
			},
		},
	})

	LC.db.profile.skin = "ndui"
	LC.options.args.general.args.skin.disabled = true

	local function reskinFunc()
		local index = 1
		local toast = _G["LSToast"..index]
		while toast do
			if toast.BG and not toast.styled then
				toast.BG:SetTexture(nil)
				B.SetBD(toast)
				toast.SetBackground = B.Dummy
				toast.styled = true
			end
			index = index + 1
			toast = _G["LSToast"..index]
		end
	end
	hooksecurefunc(LE, "GetToast", reskinFunc)
end

S:RegisterSkin("ls_Toasts", S.ls_Toasts)