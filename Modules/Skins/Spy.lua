local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local select = select

function S:ResetSpyFont()
	for _, row in pairs(_G.Spy.MainWindow.Rows) do
		local font, fontSize = row.LeftText:GetFont()
		row.LeftText:SetFont(font, fontSize, DB.Font[3])
		row.RightText:SetFont(font, fontSize-2, DB.Font[3])
	end
end

function S:Spy()
	if not S.db["Spy"] then return end

	local Spy = _G.Spy
	local frame = _G.Spy_MainWindow
	B.StripTextures(frame)
	local bg = B.SetBD(frame)
	if not Spy.db.profile.InvertSpy then
		bg:SetPoint("TOPLEFT", 0, -10)
	else
		bg:SetPoint("TOPLEFT", 0, -30)
		bg:SetPoint("BOTTOMRIGHT", 0, -20)
	end
	if frame.TitleBar then
		B.StripTextures(frame.TitleBar)
	end
	frame.bg = bg

	Spy.db.profile.BarTexture = "normTex"
	Spy.db.profile.Font = nil
	Spy:UpdateBarTextures()

	P.ReskinFont(frame.Title)
	S:ResetSpyFont()
	hooksecurefunc(Spy, "BarsChanged", S.ResetSpyFont)

	local statsFrame = _G.SpyStatsFrame
	B.StripTextures(statsFrame)
	B.SetBD(statsFrame)
	if statsFrame.StatsFrame then
		B.StripTextures(statsFrame.StatsFrame)
	end
	_G.SpyStatsFrame_Title:SetPoint("TOP", 0, -4)

	local contentFrame = _G.SpyStatsTabFrameTabContentFrame
	B.StripTextures(contentFrame)
	if contentFrame.ContentFrame then
		B.StripTextures(contentFrame.ContentFrame)
	end

	local filter = _G.SpyStatsFilterBox
	B.StripTextures(filter)
	if filter.FilterBox then
		B.StripTextures(filter.FilterBox)
	end
	local filterBG = B.CreateBDFrame(filter, .25)
	filterBG:SetPoint("TOPLEFT", 0, -3)
	filterBG:SetPoint("BOTTOMRIGHT", 0, 1)

	B.ReskinCheck(_G.SpyStatsKosCheckbox)
	B.ReskinCheck(_G.SpyStatsWinsLosesCheckbox)
	B.ReskinCheck(_G.SpyStatsReasonCheckbox)
	B.Reskin(_G.SpyStatsRefreshButton)
	B.ReskinClose(_G.SpyStatsFrameTopCloseButton)
	_G.SpyStatsFrameTopCloseButton:SetPoint("TOPRIGHT", -6, -6)
	B.ReskinScroll(_G.SpyStatsTabFrameTabContentFrameScrollFrameScrollBar)

	local alert = _G.Spy_AlertWindow
	if alert and alert.Icon then
		B.CreateBD(alert)

		alert.Icon:SetAlpha(0)
		alert.__icon = alert:CreateTexture(nil, "ARTWORK")
		alert.__icon:SetInside(alert.Icon)
		B.ReskinIcon(alert.__icon)
		hooksecurefunc(alert.Icon, "SetBackdrop", function(self, backdrop)
			if backdrop and backdrop.bgFile then
				alert.__icon:SetTexture(backdrop.bgFile)
			end
		end)

		P.ReskinFont(alert.Title)
		P.ReskinFont(alert.Name)
		P.ReskinFont(alert.Location)
	end
end

S:RegisterSkin("Spy", S.Spy)