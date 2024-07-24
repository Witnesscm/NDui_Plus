local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

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

function S:MythicDungeonTools()
	local MDT = _G.MDT
	if not MDT then return end

	local styled
	hooksecurefunc(MDT, "Async", function(_, _, name)
		if name ~= "showInterface" or styled then return end

		P:Delay(1, function()
			local frame = MDT.main_frame
			if not frame then return end

			local closeButton = frame.closeButton
			if closeButton then
				B.ReskinClose(closeButton, frame.sidePanel, -7, -7)
				closeButton:SetSize(20, 20)
			end

			local maximize = frame.maximizeButton
			if maximize then
				B.ReskinMinMax(maximize)
				maximize.MaximizeButton:SetSize(20, 20)
				maximize.MinimizeButton:SetSize(20, 20)
			end

			for _, key in pairs(Buttons) do
				local button = frame[key] and frame[key].frame
				if button and button.__bg and button.__gradient then
					button:HookScript("OnEnter", P.Button_OnEnter)
					button:HookScript("OnLeave", P.Button_OnLeave)
				end
			end

			local progressBar = frame.sidePanel and frame.sidePanel.ProgressBar and frame.sidePanel.ProgressBar.Bar
			if progressBar then
				B.StripTextures(progressBar)
				progressBar:SetStatusBarTexture(DB.normTex)
				B.CreateBDFrame(progressBar, .25)
			end

			for _, key in ipairs({"topPanelTex", "bottomPanelTex", "sidePanelTex"}) do
				frame[key]:SetAlpha(0)
			end

			local bg = B.SetBD(frame)
			bg:SetPoint("TOPLEFT", frame.topPanel)
			bg:SetPoint("BOTTOMRIGHT", frame.sidePanel)

			P.ReskinTooltip(MDT.tooltip)
			P.ReskinTooltip(MDT.pullTooltip)

			styled = true
		end)
	end)

	local enemyStyled
	hooksecurefunc(MDT, "ShowEnemyInfoFrame", function()
		if enemyStyled then return end

		local frame = MDT.EnemyInfoFrame

		local modelDummyIcon = frame.modelDummyIcon
		if modelDummyIcon and modelDummyIcon.image and modelDummyIcon.image.bg then
			modelDummyIcon.image.bg:Hide()
		end

		for _, key in ipairs({"midContainer", "rightContainer"}) do
			local container = frame[key]
			if container and container.children then
				for _, child in ipairs(container.children) do
					if child.type == "Icon" and child.image and child.image.bg then
						child.image.bg:Hide()
					end
				end
			end
		end

		enemyStyled = true
	end)
end

S:RegisterSkin("MythicDungeonTools", S.MythicDungeonTools)