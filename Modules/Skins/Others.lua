local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local TT = B:GetModule("Tooltip")

local _G = getfenv(0)
local select, pairs, type, strfind = select, pairs, type, string.find

function S:PremadeGroupsFilter()
	if not IsAddOnLoaded("PremadeGroupsFilter") then return end

	local rebtn = LFGListFrame.SearchPanel.RefreshButton
	UsePFGButton:SetSize(32, 32)
	UsePFGButton:ClearAllPoints()
	UsePFGButton:SetPoint("RIGHT", rebtn, "LEFT", -55, 0)
	UsePFGButton.text:SetText(FILTER)
	UsePFGButton.text:SetWidth(UsePFGButton.text:GetStringWidth())

	local dialog = PremadeGroupsFilterDialog
	dialog.Defeated.Title:ClearAllPoints()
	dialog.Defeated.Title:SetPoint("LEFT", dialog.Defeated.Act, "RIGHT", 2, 0)
end

function S:WorldQuestsList()
	if not IsAddOnLoaded("WorldQuestsList") then return end

	local frame = _G["WorldQuestsListFrame"]
	B.StripTextures(frame)
	local bg = B.CreateBDFrame(frame, .8)
	B.CreateSD(bg)
	for i = 1, WorldMapFrame:GetNumChildren() do
		local child = select(i, WorldMapFrame:GetChildren())
		if child:GetObjectType() == "CheckButton" and child.text then
			B.ReskinCheck(child)
		end
	end
end

function S:TomeOfTeleportation()
	if not IsAddOnLoaded("TomeOfTeleportation") then return end

	hooksecurefunc("TeleporterOpenFrame", function()
		local frame = TeleporterFrame
		local close = TeleporterCloseButton
		if frame and not frame.styled then
			B.StripTextures(frame)
			frame.SetBackdrop = B.Dummy
			B.SetBD(frame)

			local titleBG = TeleporterTitleFrame:GetRegions()
			titleBG:SetTexture(nil)
			titleBG.SetTexture = B.Dummy

			B.ReskinClose(close)
			close:SetText("")
			close:DisableDrawLayer("BACKGROUND")
			frame.styled = true
		end

		close:SetSize(20, 20)

		local index = 0
		local button = _G["TeleporterFrameTeleporterB"..index]
		local cooldown = _G["TeleporterFrameTeleporterB"..index.."TeleporterCB0"]
		while button and cooldown do
			if not button.styled then
				B.Reskin(button)
				button.SetBackdrop = B.Dummy
				local icbg = B.ReskinIcon(button.TeleporterIcon)
				icbg:SetFrameLevel(button:GetFrameLevel())

				cooldown:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",insets = {left = 1, right = 1, top = 1, bottom = 1}})
				cooldown.SetBackdrop = B.Dummy

				button.styled = true
			end

			index = index + 1
			button = _G["TeleporterFrameTeleporterB"..index]
			cooldown = _G["TeleporterFrameTeleporterB"..index.."TeleporterCB0"]
		end
	end)
end

S:RegisterSkin("PremadeGroupsFilter", S.PremadeGroupsFilter)
S:RegisterSkin("WorldQuestsList", S.WorldQuestsList)
S:RegisterSkin("TomeOfTeleportation", S.TomeOfTeleportation)