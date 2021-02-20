local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local TT = B:GetModule("Tooltip")

function S:MythicDungeonTools()
	if not IsAddOnLoaded("MythicDungeonTools") and not IsAddOnLoaded("DungeonTools") then return end

	local MDT = _G.MDT or _G.DungeonTools
	if not MDT then return end

	local Buttons = {
		"sidePanelNewButton",
		"sidePanelRenameButton",
		"sidePanelImportButton",
		"sidePanelExportButton",
		"sidePanelDeleteButton",
		"LinkToChatButton",
		"ClearPresetButton",
		"LiveSessionButton",
		"MDIButton",
	}

	local styled
	hooksecurefunc(MDT, "ShowInterface", function()
		if styled then return end

		local frame = MDT.main_frame
		frame.HelpButton.Ring:Hide()

		local closeButton = frame.closeButton
		B.ReskinClose(closeButton, frame.sidePanel, -7, -7)
		closeButton:SetSize(20, 20)

		local maximize = frame.maximizeButton
		B.ReskinMinMax(maximize)
		maximize.MaximizeButton:SetSize(20, 20)
		maximize.MinimizeButton:SetSize(20, 20)

		for _, v in pairs(Buttons) do
			local button = frame[v] and frame[v].frame
			if button and button.__bg and button.__gradient then
				button:HookScript("OnEnter", P.Button_OnEnter)
				button:HookScript("OnLeave", P.Button_OnLeave)
			end
		end

		local progressBar = frame.sidePanel.ProgressBar.Bar
		B.StripTextures(progressBar)
		progressBar:SetStatusBarTexture(DB.normTex)
		B.CreateBDFrame(progressBar, .25)

		styled = true
	end)
end

S:RegisterSkin("MythicDungeonTools", S.MythicDungeonTools)