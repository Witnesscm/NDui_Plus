local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:PallyPower()
	local PallyPower = _G.PallyPower
	if not PallyPower then return end

	B.StripTextures(PallyPowerBlessingsFrame)
	B.SetBD(PallyPowerBlessingsFrame)
	B.ReskinClose(PallyPowerBlessingsFrameCloseButton)
	B.ReskinCheck(PallyPowerBlessingsFrameFreeAssign)
	B.ReskinIcon(PallyPowerBlessingsFrameAuraGroup1AuraHeaderIcon)

	local buttons = {
		"PallyPowerBlessingsFrameRefresh",
		"PallyPowerBlessingsFrameClear",
		"PallyPowerBlessingsFrameAutoAssign",
		"PallyPowerBlessingsFrameReport",
		"PallyPowerBlessingsFrameOptions",
	}
	for _, button in next, buttons do
		B.Reskin(_G[button])
	end

	for i = 1, 9 do
		local icon = _G["PallyPowerBlessingsFrameClassGroup"..i.."ClassButtonIcon"]
		if icon then
			B.ReskinIcon(icon)
		end
	end

	local function reskinIcon(icon)
		if not icon then return end
		icon:SetTexCoord(unpack(DB.TexCoord))
	end

	for i = 1, 15 do
		local frameName = "PallyPowerBlessingsFramePlayer"..i
		reskinIcon(_G[frameName.."Icon1"])
		reskinIcon(_G[frameName.."Icon2"])
		reskinIcon(_G[frameName.."Icon3"])
		reskinIcon(_G[frameName.."Icon4"])
		reskinIcon(_G[frameName.."Icon5"])
		reskinIcon(_G[frameName.."Icon6"])
		reskinIcon(_G[frameName.."AIcon1"])
		reskinIcon(_G[frameName.."AIcon2"])
		reskinIcon(_G[frameName.."AIcon3"])
		reskinIcon(_G[frameName.."CIcon1"])
		reskinIcon(_G[frameName.."CIcon2"])
		reskinIcon(_G[frameName.."Aura1Icon"])

		for cNum = 1, PALLYPOWER_MAXCLASSES do
			reskinIcon(_G[frameName.."Class"..cNum.."Icon"])
		end
	end

	local icons = {
		"PallyPowerAutoIcon",
		"PallyPowerRFIcon",
		"PallyPowerRFIconSeal",
		"PallyPowerAuraIcon",
	}
	for _, icon in next, icons do
		reskinIcon(_G[icon])
	end

	for cbNum = 1, PALLYPOWER_MAXCLASSES do
		reskinIcon(_G["PallyPowerC"..cbNum.."ClassIcon"])
		reskinIcon(_G["PallyPowerC"..cbNum.."BuffIcon"])
		for pbNum = 1, PALLYPOWER_MAXPERCLASS do
			reskinIcon(_G["PallyPowerC"..cbNum.."P"..pbNum.."BuffIcon"])
		end
	end
end

S:RegisterSkin("PallyPower", S.PallyPower)