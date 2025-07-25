local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)

P.Version = C_AddOns.GetAddOnMetadata(addonName, "Version")
P.SupportVersion = "1.46.2"
P.isNewPatch = select(4, GetBuildInfo()) >= 11504 -- 1.15.4

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

-- Misc
P.SlotIDtoName = {
	[INVSLOT_HEAD] = HEADSLOT,
	[INVSLOT_NECK] = NECKSLOT,
	[INVSLOT_SHOULDER] = SHOULDERSLOT,
	[INVSLOT_BODY] = SHIRTSLOT,
	[INVSLOT_CHEST] = CHESTSLOT,
	[INVSLOT_WAIST] = WAISTSLOT,
	[INVSLOT_LEGS] = LEGSSLOT,
	[INVSLOT_FEET] = FEETSLOT,
	[INVSLOT_WRIST] = WRISTSLOT,
	[INVSLOT_HAND]= HANDSSLOT,
	[INVSLOT_FINGER1]= FINGER0SLOT_UNIQUE,
	[INVSLOT_FINGER2]= FINGER1SLOT_UNIQUE,
	[INVSLOT_TRINKET1]= TRINKET0SLOT_UNIQUE,
	[INVSLOT_TRINKET2]= TRINKET1SLOT_UNIQUE,
	[INVSLOT_BACK]= BACKSLOT,
	[INVSLOT_MAINHAND]= MAINHANDSLOT,
	[INVSLOT_OFFHAND]= SECONDARYHANDSLOT,
	[INVSLOT_RANGED]= RANGEDSLOT,
	[INVSLOT_TABARD]= TABARDSLOT,
}

-- Bindings
BINDING_HEADER_NDUIPLUS = C_AddOns.GetAddOnMetadata(addonName, "Title")
BINDING_NAME_NDUIPLUSTOGGLEBAG = L["Toggle OfflineBag"]
