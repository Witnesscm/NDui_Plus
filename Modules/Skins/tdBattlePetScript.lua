local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local function reskinDropDown(self)
	B.StripTextures(self)
	local down = self.MenuButton
	down:ClearAllPoints()
	down:SetPoint("RIGHT", -18, 0)
	B.ReskinArrow(down, "down")
	down:SetSize(20, 20)

	local bg = B.CreateBDFrame(self, 0)
	bg:ClearAllPoints()
	bg:SetPoint("LEFT")
	bg:SetPoint("TOPRIGHT", down, "TOPRIGHT")
	bg:SetPoint("BOTTOMRIGHT", down, "BOTTOMRIGHT")
	B.CreateGradient(bg)
end

function S:tdBattlePetScript()
	if not S.db["tdBattlePetScript"] then return end

	local tdBattlePetScript = _G.tdBattlePetScript or _G.PetBattleScripts
	if not tdBattlePetScript then return end

	-- PetBattle
	local PetBattle = tdBattlePetScript:GetModule("UI.PetBattle")
	if PetBattle then
		B.StripTextures(PetBattle.ArtFrame2)

		local AutoButton = PetBattle.AutoButton
		if AutoButton then
			AutoButton:SetSize(42, 42)
			AutoButton:SetPoint("LEFT", PetBattle.SkipButton, "RIGHT", 3, 0)
			B.StripTextures(AutoButton)
			B.PixelIcon(AutoButton, "Interface\\Icons\\Trade_Engineering", true)
			B.CreateSD(AutoButton)
			AutoButton.HL:SetAllPoints(AutoButton)
			AutoButton:SetPushedTexture(DB.pushedTex)
			AutoButton:SetText(SELF_CAST_AUTO)
		end

		local ScriptFrame = PetBattle.ScriptFrame
		if ScriptFrame then
			B.StripTextures(ScriptFrame)
			B.SetBD(ScriptFrame)
			B.ReskinClose(ScriptFrame.CloseButton)
		end

		hooksecurefunc(PetBattle, "PetBattleFrame_UpdatePassButtonAndTimer", function(self)
			self.SkipButton:ClearAllPoints()
			self.SkipButton:SetPoint("LEFT", PetBattleFrame.BottomFrame.ForfeitButton, "RIGHT", 3, 0)
		end)
	end

	-- MainPanel
	local MainPanel = tdBattlePetScript:GetModule("UI.MainPanel")
	if MainPanel then
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

		local ExtraButton = select(2, MainPanel.Banner:GetChildren())
		B.ReskinArrow(ExtraButton, "down")
		ExtraButton.SetNormalTexture = B.Dummy
		ExtraButton.SetHighlightTexture = B.Dummy
		ExtraButton.SetPushedTexture = B.Dummy
		ExtraButton:SetSize(24, 24)
		ExtraButton:SetPoint("RIGHT", -2, 0)
		ExtraButton:HookScript("OnClick", function(self)
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

		B.StripTextures(MainPanel.HelpIcon)
		B.ReskinScroll(MainPanel.ScriptList.scrollBar)
		B.Reskin(MainPanel.DebugButton)
		B.Reskin(MainPanel.DeleteButton)
		MainPanel.DeleteButton:SetPoint("BOTTOMLEFT", MainPanel.MainPanel, "BOTTOMLEFT", 3, 2)
		B.Reskin(MainPanel.SaveButton)
		MainPanel.SaveButton:SetPoint("BOTTOMRIGHT", MainPanel.MainPanel, "BOTTOMRIGHT", -5, 2)

		local BlockDialog = MainPanel.BlockDialog
		B.Reskin(BlockDialog.AcceptButton)
		B.Reskin(BlockDialog.CancelButton)
		B.StripTextures(BlockDialog.EditBox)
		B.CreateBDFrame(BlockDialog.EditBox, .25)
		B.ReskinScroll(BlockDialog.EditBox.ScrollFrame.ScrollBar)

		-- PetBattleScripts new element
		S:Proxy("Reskin", MainPanel.TestButton)
	end

	-- Import
	local Import = tdBattlePetScript:GetModule("UI.Import")
	if Import then
		B.StripTextures(Import.Frame)
		B.SetBD(Import.Frame)
		B.ReskinClose(Import.Frame.CloseButton)
		-- page 1
		B.Reskin(Import.WelcomeNextButton)
		B.StripTextures(Import.EditBox)
		B.CreateBDFrame(Import.EditBox, .25)
		B.ReskinScroll(Import.EditBox.ScrollFrame.ScrollBar)
		-- page 2
		reskinDropDown(Import.PluginDropdown)
		reskinDropDown(Import.KeyDropdown)
		S:Proxy("Reskin", Import.SelectorNextButton)
		-- page 3
		S:Proxy("ReskinCheck", Import.CoverCheck)
		S:Proxy("Reskin", Import.SaveButton)
		-- B.ReskinCheck(Import.ExtraCheck)
	end
end

S:RegisterSkin("tdBattlePetScript", S.tdBattlePetScript)