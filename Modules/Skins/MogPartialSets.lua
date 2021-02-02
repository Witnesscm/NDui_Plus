local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

function S:MogPartialSets()
	if not IsAddOnLoaded("MogPartialSets") then return end

	B.Reskin(_G.MogPartialSetsFilterButton)
	B.StripTextures(_G.MogPartialSetsFilter)
	B.SetBD(_G.MogPartialSetsFilter)
	B.Reskin(_G.MogPartialSetsFilterOkButton)
	B.Reskin(_G.MogPartialSetsFilterRefreshButton)

	local editBox = MogPartialSetsFilterMaxMissingPiecesEditBox
	P.ReskinInput(editBox, 15 + C.mult, 15 + C.mult)
	editBox:ClearAllPoints()
	editBox:SetPoint("TOPLEFT", MogPartialSetsFilterIgnoreBracersButton, "BOTTOMLEFT", 7, -2)

	local text = MogPartialSetsFilterMaxMissingPiecesText
	text:ClearAllPoints()
	text:SetPoint("LEFT", editBox, "RIGHT", 1, 0)

	local names = {"Toggle", "OnlyFavorite", "FavoriteVariants", "IgnoreBracers"}
	for _ , name in pairs(names) do
		local check = _G["MogPartialSetsFilter"..name.."Button"]
		B.ReskinCheck(check)
		local text = _G["MogPartialSetsFilter"..name.."Text"]
		text:ClearAllPoints()
		text:SetPoint("LEFT", check, "RIGHT", 0, 0)
	end

	MogPartialSetsFilterToggleText:SetText("显示不完整套装")
	MogPartialSetsFilterOnlyFavoriteText:SetText("只显示偏好套装")
	MogPartialSetsFilterFavoriteVariantsText:SetText("偏好套装变体版")
	MogPartialSetsFilterIgnoreBracersText:SetText("忽略护腕部位")
	MogPartialSetsFilterMaxMissingPiecesText:SetText("部位缺失数量")
	MogPartialSetsFilterOkButton:SetText(OKAY)
	MogPartialSetsFilterRefreshButton:SetText(REFRESH)
end

S:RegisterSkin("MogPartialSets", S.MogPartialSets)