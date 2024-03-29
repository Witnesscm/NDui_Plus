local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)

P.Version = C_AddOns.GetAddOnMetadata(addonName, "Version")
P.SupportVersion = "7.14.2"
P.isNewPatch = select(4, GetBuildInfo()) >= 100105 -- 10.1.5

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