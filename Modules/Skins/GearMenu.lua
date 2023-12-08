local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local fontScale = .37

local function UpdateTexture(slot)
	local texture = slot.itemTexture
	if texture and slot.bg then
		texture:SetTexCoord(unpack(DB.TexCoord))
		texture:SetInside(slot.bg)
	end
end

local function reskinGear(slot)
	if slot.SetBackdrop then
		slot:SetBackdrop(nil)
		slot.SetBackdrop = B.Dummy
	end

	slot.bg = B.SetBD(slot)
	slot.bg:SetInside()

	if slot.cooldownOverlay then slot.cooldownOverlay:SetInside(slot.bg) end
	if slot.highlightFrame then slot.highlightFrame:SetAlpha(0) end

	local hl= slot:CreateTexture(nil, "HIGHLIGHT")
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(slot.bg)

	slot:SetHighlightTexture(0)
	slot:SetNormalTexture(0)
	slot:SetPushedTexture(0)

	UpdateTexture(slot)
end

function S:GearMenu()
	if not S.db["GearMenu"] then return end

	local rggm = _G.rggm

	if not rggm then return end
	if not rggm.themeCoordinator then return end -- version check

	local origCreateGearSlot = rggm.themeCoordinator.CreateGearSlot
	rggm.themeCoordinator.CreateGearSlot = function (...)
		local slot = origCreateGearSlot(...)
		if slot then
			reskinGear(slot)

			return slot
		end
	end

	local origCreateChangeSlot = rggm.themeCoordinator.CreateChangeSlot
	rggm.themeCoordinator.CreateChangeSlot = function (...)
		local slot = origCreateChangeSlot(...)
		if slot then
			reskinGear(slot)

			return slot
		end
	end

	local origCreateTrinketSlot = rggm.themeCoordinator.CreateTrinketSlot
	rggm.themeCoordinator.CreateTrinketSlot = function (...)
		local slot = origCreateTrinketSlot(...)
		if slot then
			reskinGear(slot)

			return slot
		end
	end

	hooksecurefunc(rggm.themeCoordinator, "UpdateSlotTextureAttributes", UpdateTexture)

	local origCreateKeyBindingText = rggm.gearBar.CreateKeyBindingText
	rggm.gearBar.CreateKeyBindingText = function(slot, size)
		local keybinding = origCreateKeyBindingText(slot, size)
		keybinding:SetFont(DB.Font[1], size * fontScale, DB.Font[3])

		return keybinding
	end

	local function SetKeyBindingFont(slot, size)
		slot.keyBindingText:SetFont(DB.Font[1], size * fontScale, DB.Font[3])
	end
	hooksecurefunc(rggm.gearBar, "UpdateGearSlotKeyBindingTextSize", SetKeyBindingFont)
end

S:RegisterSkin("GearMenu", S.GearMenu)