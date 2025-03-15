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

local function HandleDungeonButton(self)
	self.texture:SetInside()
	self.bg = B.ReskinIcon(self.texture)
	local hl = self:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(self.bg)
	self.selectedTexture:SetColorTexture(1, .8, 0, .5)
	self.selectedTexture:SetInside(self.bg)
end

function S:MythicDungeonTools()
	local MDT = _G.MDT
	if not MDT then return end

	local styled
	hooksecurefunc(MDT, "Async", function(_, _, name)
		if name ~= "showInterface" or styled then return end

		P.WaitFor(function()
			return not not (MDT.tooltip and MDT.pullTooltip)
		end, function()
			local frame = MDT.main_frame
			if not frame then return end

			local closeButton = frame.closeButton
			if closeButton then
				B.ReskinClose(closeButton, frame.sidePanel, -7, -7)
				closeButton:SetSize(18, 18)
			end

			local maximize = frame.maximizeButton
			if maximize then
				B.ReskinMinMax(maximize)
				maximize.MaximizeButton:SetSize(18, 18)
				maximize.MinimizeButton:SetSize(18, 18)
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
		end)

		styled = true
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

	local dungeonIndex = 1
	hooksecurefunc(MDT, "UpdateDungeonDropDown", function()
		local button = _G["MDTDungeonButton"..dungeonIndex]
		while button do
			HandleDungeonButton(button)
			dungeonIndex = dungeonIndex + 1
			button = _G["MDTDungeonButton"..dungeonIndex]
		end
	end)
end

S:RegisterSkin("MythicDungeonTools", S.MythicDungeonTools)