local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local TT = B:GetModule("Tooltip")

local _G = getfenv(0)

local function reskinView(self)
	for i = 1, #self._buttons do
		local button = self:GetButton(i)
		if not button.styled and button:IsShown() then
			B.StripTextures(button, 0)
			P.SetupBackdrop(button)
			B.CreateBD(button, .25)

			button:SetHighlightTexture(DB.bdTex)
			local hl = button:GetHighlightTexture()
			hl:SetVertexColor(DB.r, DB.g, DB.b, .25)
			hl:SetInside()

			if button.Icon then button.Icon:SetAlpha(1) end
			if button.Checked then button.Checked:SetAlpha(1) end
			if button.Highlight then button.Highlight:SetTexture(nil) end

			button.styled = true
		end
	end
end

function S:tdBattlePetScript()
	if not IsAddOnLoaded("tdBattlePetScript") then return end
	if not NDuiPlusDB["Skins"]["tdBattlePetScript"] then return end

	local tdBattlePetScript = _G.tdBattlePetScript
	local GUI = LibStub('tdGUI-1.0')

	-- PetBattle
	local PetBattle = tdBattlePetScript:GetModule("UI.PetBattle")
	B.StripTextures(PetBattle.ArtFrame2)

	local AutoButton = PetBattle.AutoButton
	AutoButton:SetSize(42, 42)
	AutoButton:SetPoint("LEFT", PetBattle.SkipButton, "RIGHT", 3, 0)
	B.StripTextures(AutoButton)
	B.PixelIcon(AutoButton, "Interface\\Icons\\Trade_Engineering", true)
	B.CreateSD(AutoButton)
	AutoButton.HL:SetAllPoints(AutoButton)
	AutoButton:SetPushedTexture(DB.textures.pushed)

	local ScriptFrame = PetBattle.ScriptFrame
	B.StripTextures(ScriptFrame)
	B.SetBD(ScriptFrame)
	B.ReskinClose(ScriptFrame.CloseButton)

	local GridView = GUI:GetClass('GridView')
	hooksecurefunc(GridView, "UpdateItems", reskinView)

	-- MainPanel
	local MainPanel = tdBattlePetScript:GetModule("UI.MainPanel")
	B.StripTextures(MainPanel.MainPanel)
	B.SetBD(MainPanel.MainPanel)
	B.ReskinClose(MainPanel.MainPanel.CloseButton)

	local Inset = MainPanel.Content:GetParent()
	B.StripTextures(Inset)
	B.CreateBDFrame(Inset, .25)

	local EditBox = MainPanel.ScriptBox
	B.StripTextures(EditBox)
	EditBox.bg = B.CreateBDFrame(EditBox, .25)
	EditBox.bg:SetPoint("TOPLEFT", -C.mult, 0)
	EditBox.bg:SetPoint("BOTTOMRIGHT", C.mult, 0)
	B.ReskinScroll(EditBox.ScrollFrame.ScrollBar)

	local BugFrame = MainPanel.BugFrame
	B.StripTextures(BugFrame)
	BugFrame.bg = B.CreateBDFrame(BugFrame, .25)
	BugFrame.bg:SetInside()

	local NameBox = MainPanel.NameBox
	NameBox:DisableDrawLayer("BACKGROUND")
	NameBox.bg = B.CreateBDFrame(NameBox, .25)
	NameBox.bg:SetPoint("TOPLEFT", -C.mult, 0)
	NameBox.bg:SetPoint("BOTTOMRIGHT", C.mult, 0)

	B.StripTextures(MainPanel.HelpIcon)

	local ExtraButton = select(2, MainPanel.Banner:GetChildren())
	B.ReskinArrow(ExtraButton, "down")
	ExtraButton.SetNormalTexture = B.Dummy
	ExtraButton.SetHighlightTexture = B.Dummy
	ExtraButton.SetPushedTexture = B.Dummy
	ExtraButton:SetSize(24, 24)
	ExtraButton:SetPoint("RIGHT", -2, 0)
	ExtraButton:HookScript('OnClick', function(self)
		if self:GetChecked() then
			B.SetupArrow(self.__texture, "up")
		else
			B.SetupArrow(self.__texture, "down")
		end
	end)

	local ShareButton = MainPanel.ShareButton
	B.Reskin(ShareButton)
	ShareButton:SetSize(24, 24)
	ShareButton.tex = ShareButton:CreateTexture(nil, "ARTWORK")
	ShareButton.tex:SetTexture("Interface\\WorldMap\\ChatBubble_64Grey")
	ShareButton.tex:SetPoint("TOPLEFT", 0, -2)
	ShareButton.tex:SetPoint("BOTTOMRIGHT", 2, -2)

	B.Reskin(MainPanel.DebugButton)
	B.Reskin(MainPanel.DeleteButton)
	MainPanel.DeleteButton:SetPoint("BOTTOMLEFT", MainPanel.MainPanel, "BOTTOMLEFT", 3, 2)
	B.Reskin(MainPanel.SaveButton)
	MainPanel.SaveButton:SetPoint("BOTTOMRIGHT", MainPanel.MainPanel, "BOTTOMRIGHT", -5, 2)
	B.Reskin(MainPanel.BlockDialog.AcceptButton)
	B.Reskin(MainPanel.BlockDialog.CancelButton)

	local ScriptList = MainPanel.ScriptList
	B.ReskinScroll(ScriptList.scrollBar)
	
	local ListView = GUI:GetClass('ListView')
	hooksecurefunc(ListView, "UpdateItems", reskinView)

	-- Import
	local Import = tdBattlePetScript:GetModule("UI.Import")
	B.StripTextures(Import.Frame)
	B.SetBD(Import.Frame)
	B.ReskinClose(Import.Frame.CloseButton)

	B.Reskin(Import.WelcomeNextButton)
	B.StripTextures(Import.EditBox)
	B.CreateBDFrame(Import.EditBox, .25)
	B.ReskinScroll(Import.EditBox.ScrollFrame.ScrollBar)

	B.ReskinCheck(Import.CoverCheck)
	B.ReskinCheck(Import.ExtraCheck)
	B.Reskin(Import.SaveButton)
end

S:RegisterSkin("tdBattlePetScript", S.tdBattlePetScript)