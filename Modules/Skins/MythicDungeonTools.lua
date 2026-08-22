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
	if not self.styled then
		self.texture:SetInside()
		self.bg = B.ReskinIcon(self.texture)
		local hl = self:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(self.bg)
		self.selectedTexture:SetColorTexture(1, .8, 0, .5)
		self.selectedTexture:SetInside(self.bg)

		self.styled = true
	end
end

local function ReskinDungeonButtons()
	local index = 1
	local button = _G["MDTDungeonButton" .. index]
	while button do
		HandleDungeonButton(button)
		index = index + 1
		button = _G["MDTDungeonButton" .. index]
	end
end

function S:MythicDungeonTools()
	local API = _G.MythicDungeonToolsAPI
	if not API then return end

	API:RegisterUIInitializer(function()
		P.WaitFor(function()
			return not not (_G.MDTFrame and _G.MDTFrame.toolbar)
		end, function()
			local frame = _G.MDTFrame

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

			for _, key in ipairs({ "topPanelTex", "bottomPanelTex", "sidePanelTex" }) do
				local tex = frame[key]
				if tex then
					frame[key]:SetAlpha(0)
				end
			end

			local bg = B.SetBD(frame)
			if frame.navigationSidebar and frame.sidePanel then
				B.StripTextures(frame.navigationSidebar)
				bg:SetPoint("TOPLEFT", frame.navigationSidebar)
				bg:SetPoint("BOTTOMRIGHT", frame.sidePanel)
			end

			P.ReskinTooltip(_G.MDTModelTooltip)
			P.ReskinTooltip(_G.MDTPullTooltip)

			local seasonDropdown = frame.seasonSelectionGroup and frame.seasonSelectionGroup.seasonDropdown
			if seasonDropdown and seasonDropdown.events and seasonDropdown.events["OnValueChanged"] then
				hooksecurefunc(seasonDropdown.events, "OnValueChanged", function()
					P:Delay(.2, ReskinDungeonButtons)
				end)
			end
		end, 0.2)

		P.WaitFor(function()
			return not not (_G.MDTDungeonButton8)
		end, ReskinDungeonButtons, 0.5)
	end)
end

S:RegisterSkin("MythicDungeonTools", S.MythicDungeonTools)