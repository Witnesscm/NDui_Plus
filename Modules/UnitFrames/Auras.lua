local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local UF = P:GetModule("UnitFrames")
local NUF = B:GetModule("UnitFrames")

local filteredStyle = {
	["target"] = true,
	["focus"] = true,
	["tot"] = true,
}

function UF.CustomFilter(element, unit, button, name, _, _, _, _, _, caster, isStealable, _, spellID, _, _, _, nameplateShowAll)
	if not name then return end

	button.isFriend = unit and UnitIsFriend("player", unit) and not UnitCanAttack("player", unit)

	if spellID == 209859 then
		element.bolster = element.bolster + 1
		if not element.bolsterIndex then
			element.bolsterIndex = button
			return true
		end
	elseif (not button.isFriend and button.isDebuff and not button.isPlayer) then
		return false
	else
		return true
	end
end

function UF:UpdateAurasFilter()
	for _, frame in pairs(oUF.objects) do
		if frame.Auras and filteredStyle[frame.mystyle] then
			frame.Auras.CustomFilter = UF.db["OnlyPlayerDebuff"] and UF.CustomFilter or NUF.CustomFilter
			frame.Auras:ForceUpdate()
		end
	end
end