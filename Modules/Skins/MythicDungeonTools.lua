local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

function S:MythicDungeonTools_UI()
	P.ReskinTooltip(_G.MDTTooltip)
end

S:RegisterSkin("MythicDungeonTools_UI", S.MythicDungeonTools_UI)
