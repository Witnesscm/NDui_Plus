local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local oUF = ns.oUF
local M = P:GetModule("Misc")

local UIWidth = 680
local UINameOffset = 40
local UILevelOffset = 15
local UIRankWidth = 80
local UINoteWidth = 200

local header5, header6

local rankColor = {
	1, 0, 0,
	1, 1, 0,
	0, 1, 0
}

local function GuildInfo_Update()
	if not GuildFrame:IsShown() or not M.db["GuildExpand"] then return end

	if FriendsFrame.playerStatusFrame then
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)

		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			local guildIndex = guildOffset + i
			local button = getglobal("GuildFrameButton"..i)

			local fullName, rank, rankIndex, _, _, _, note, _, online = GetGuildRosterInfo(guildIndex)
			if (fullName and (GetGuildRosterShowOffline() or online)) then
				button.Note:SetText(note)
				button.Rank:SetText(rank)

				if online then
					local lr, lg, lb = oUF:RGBColorGradient(rankIndex, 10, unpack(rankColor))
					if lr then
						button.Rank:SetTextColor(lr, lg, lb)
					else
						button.Rank:SetTextColor(1.0, 1.0, 1.0)
					end
					button.Note:SetTextColor(1.0, 1.0, 1.0)
				else
					button.Rank:SetTextColor(0.5, 0.5, 0.5)
					button.Note:SetTextColor(0.5, 0.5, 0.5)
				end
			else
				button.Rank:SetText(nil)
				button.Note:SetText(nil)
			end
		end
	end
end

local function ToggleGuildUI(texture, init)
	local expand =  M.db["GuildExpand"]

	if not init then
		FriendsFrame.CloseButton:SetPoint("TOPRIGHT", FriendsFrame.bg, expand and 337 or -5, -5)
	end

	B.SetupArrow(texture , expand and "down" or "right")
	header5:SetShown(expand)
	header6:SetShown(expand)

	local width = expand and UIWidth or PANEL_DEFAULT_WIDTH

	GuildFrame:SetWidth(width)
	GuildFrameNotesText:SetWidth(width - 23)
	GuildStatusFrame:SetWidth(width - 38)
	GuildPlayerStatusFrame:SetWidth(width - 38)

	local nameOffset = expand and UINameOffset or 0
	local levelOffset = expand and UILevelOffset or 0

	WhoFrameColumn_SetWidth(GuildFrameColumnHeader1, 83 + nameOffset)
	WhoFrameColumn_SetWidth(GuildFrameGuildStatusColumnHeader1, 83 + nameOffset)
	WhoFrameColumn_SetWidth(GuildFrameColumnHeader3, 32 + levelOffset)
	GuildFrameColumnHeader3:SetText(expand and LEVEL or LEVEL_ABBR)

	for i = 1, GUILDMEMBERS_TO_DISPLAY do
		local button = getglobal("GuildFrameButton"..i)
		local status = getglobal("GuildFrameGuildStatusButton"..i)
		button:SetWidth(width - 40)
		button:GetHighlightTexture():SetWidth(width - 40)
		status:SetWidth(width - 40)
		status:GetHighlightTexture():SetWidth(width - 40)

		getglobal("GuildFrameButton"..i.."Name"):SetWidth(88 + nameOffset)
		getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetWidth(88 + nameOffset)
		getglobal("GuildFrameButton"..i.."Level"):SetWidth(23 + levelOffset)

		button.Rank:SetShown(expand)
		button.Note:SetShown(expand)
	end
end

function M:ExtGuildUI()
	if not M.db["ExtGuildUI"] then return end

	header5 = CreateFrame("Button", "GuildFrameColumnHeader5", GuildPlayerStatusFrame, "GuildFrameColumnHeaderTemplate")
	header5:SetPoint("LEFT", GuildFrameColumnHeader4, "RIGHT", -2, 0)
	WhoFrameColumn_SetWidth(header5, UIRankWidth)
	header5:SetText(RANK)
	header5:SetScript("OnClick", nil)
	header5:Hide()

	header6 = CreateFrame("Button", "GuildFrameColumnHeader6", GuildPlayerStatusFrame, "GuildFrameColumnHeaderTemplate")
	header6:SetPoint("LEFT", header5, "RIGHT", -2, 0)
	WhoFrameColumn_SetWidth(header6, UINoteWidth)
	header6:SetText(LABEL_NOTE)
	header6:SetScript("OnClick", nil)
	header6:Hide()

	if C.db["Skins"]["BlizzardSkins"] then
		header5.bg = B.ReskinTab(header5)
		header5.bg:SetPoint("TOPLEFT", 5, -2)
		header5.bg:SetPoint("BOTTOMRIGHT", 0, 0)
		header6.bg = B.ReskinTab(header6)
		header6.bg:SetPoint("TOPLEFT", 5, -2)
		header6.bg:SetPoint("BOTTOMRIGHT", 0, 0)
	end

	for i = 1, GUILDMEMBERS_TO_DISPLAY do
		local button = getglobal("GuildFrameButton"..i)
		local class = getglobal("GuildFrameButton"..i.."Class")

		local rank = button:CreateFontString(nil, "BORDER")
		rank:SetFontObject(GameFontHighlightSmall)
		rank:SetJustifyH("LEFT")
		rank:SetSize(UIRankWidth, 14)
		rank:SetPoint("LEFT", class, "RIGHT", -10, 0)
		button.Rank = rank

		local note = button:CreateFontString(nil, "BORDER")
		note:SetFontObject(GameFontHighlightSmall)
		note:SetJustifyH("LEFT")
		note:SetSize(UINoteWidth, 14)
		note:SetPoint("LEFT", rank, "RIGHT", -2, 0)
		button.Note = note
	end

	-- yClassColors
	hooksecurefunc("GuildStatus_Update", GuildInfo_Update)

	for _, child in pairs {FriendsFrame:GetChildren()} do
		if child.backdropInfo and child.backdropInfo.bgFile == DB.bdTex then
			FriendsFrame.bg = child
			break
		end
	end

	GuildFrame:ClearAllPoints()
	GuildFrame:SetPoint("TOPLEFT", FriendsFrame)
	GuildFrame:SetSize(338, 424)
	GuildFrame.bg = B.SetBD(GuildFrame)

	local bu = CreateFrame("Button", nil, GuildFrame)
	bu:SetPoint("TOPRIGHT", GuildFrame.bg, "TOPRIGHT", -24, -5)
	B.ReskinArrow(bu, "right")
	bu:SetScript("OnClick", function(self)
		M.db["GuildExpand"] = not M.db["GuildExpand"]
		ToggleGuildUI(self.__texture)
	end)
	ToggleGuildUI(bu.__texture, true)

	GuildFrame:HookScript("OnShow", function()
		if FriendsFrame.bg then FriendsFrame.bg:Hide() end

		if M.db["GuildExpand"] then
			FriendsFrame.CloseButton:SetPoint("TOPRIGHT", FriendsFrame.bg, 337, -5)
		end
	end)

	GuildFrame:HookScript("OnHide", function()
		if FriendsFrame.bg then FriendsFrame.bg:Show() end

		if M.db["GuildExpand"] then
			FriendsFrame.CloseButton:SetPoint("TOPRIGHT", FriendsFrame.bg, -5, -5)
		end
	end)

	-- fix scroll
	GuildListScrollFrame:SetPoint("TOPLEFT", 12, -87)
end

M:RegisterMisc("ExtGuildUI", M.ExtGuildUI)