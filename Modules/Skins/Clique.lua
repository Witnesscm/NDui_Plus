local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function HandleFilterButton(self)
	if not self then
		P.Developer_ThrowError("filter button not found")
		return
	end

	B.ReskinFilterButton(self)
	if self.__texture then
		self.__texture:Hide()
	end
end

local function HandleSummaryButton(self)
	if not self then
		P.Developer_ThrowError("summary button not found")
		return
	end

	self.Background:SetAlpha(0)
	self.bg = B.CreateBDFrame(self.Background, .25)
	self.bg:SetInside()
	local hl = self.FrameHighlight
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(self.bg)
	S:Proxy("ReskinIcon", self.Icon)
end

local function UpdateSelectedTexture(self, atlas)
	if self.SelectedTexture then
		self.SelectedTexture:SetShown(not not atlas)
	end
end

local function HandleBindingButton(self)
	if not self.styled then
		self.Background:SetAlpha(0)
		self.bg = B.CreateBDFrame(self.Background, .25)
		self.bg:SetInside()
		local hl = self.FrameHighlight
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(self.bg)

		self.SelectedTexture = self:CreateTexture(nil, "BACKGROUND")
		self.SelectedTexture:SetColorTexture(DB.r, DB.g, DB.b, .25)
		self.SelectedTexture:SetInside(self.bg)
		self.SetNormalAtlas = UpdateSelectedTexture
		self.ClearNormalTexture = UpdateSelectedTexture
		self:SetPushedTexture(0)

		S:Proxy("ReskinIcon", self.Icon)
		S:Proxy("Reskin", self.DeleteButton)

		self.styled = true
	end
end

local function HandleMacroButton(self)
	if not self.styled then
		self:SetNormalTexture(0)
		self.bg = B.ReskinIcon(self:GetNormalTexture())
		self.SelectedTexture:SetColorTexture(1, .8, 0, .5)
		self.SelectedTexture:SetInside(self.bg)
		local hl = self:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(self.bg)

		self.styled = true
	end
end

local function HandlePageButton(self, direction)
	if not self then
		P.Developer_ThrowError("page button not found")
		return
	end

	self.bg:SetAlpha(0)
	self.bg = nil
	B.ReskinArrow(self, direction)
	self:SetSize(20, 20)
end

local function HandleCatalogButton(self)
	self.bg = B.ReskinIcon(self.background)
	local hl = self:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(self.bg)
end

local function ReskinSpellBookButton(self)
	local tab = self.spellbookTab
	if tab and not tab.styled then
		tab.bg:SetAlpha(0)
		tab:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
		tab:SetHighlightTexture(DB.bdTex)
		tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		B.CreateBDFrame(tab)

		tab.styled = true
	end
end

local function ReskinBindingFrame(self)
	local frame = self.ui
	if not frame or frame.styled then return end

	B.ReskinPortraitFrame(frame)
	P.ReskinTooltip(frame.tooltip)

	local BrowsePage = self.BrowsePage and self.BrowsePage.frame
	if BrowsePage then
		S:Proxy("Reskin", BrowsePage.AddButton)
		S:Proxy("Reskin", BrowsePage.EditButton)
		S:Proxy("Reskin", BrowsePage.QuickbindMode)
		S:Proxy("StripTextures", BrowsePage.background)
		S:Proxy("CreateBDFrame", BrowsePage.background, .25)
		S:Proxy("ReskinTrimScroll", BrowsePage.scrollbar)
		HandleFilterButton(BrowsePage.OptionsButton)
		S:Proxy("ReskinInput", BrowsePage.SearchBox)

		P:SecureHook(BrowsePage.scrollFrame, "Update", function(self)
			self:ForEachFrame(HandleBindingButton)
		end)
	end

	local EditPage = self.EditPage and self.EditPage.frame
	if EditPage then
		S:Proxy("Reskin", EditPage.SaveButton)
		S:Proxy("Reskin", EditPage.CancelButton)
		S:Proxy("Reskin", EditPage.RemoveRankButton)
		HandleSummaryButton(EditPage.bindSummary)
		S:Proxy("Reskin", EditPage.changeBinding)
		S:Proxy("Reskin", EditPage.editMacro)

		if self.EditPage.bindSetFrames then
			for _, checkbox in pairs(self.EditPage.bindSetFrames) do
				S:Proxy("ReskinCheck", checkbox)
			end
		end
	end

	local EditMacroPage = self.EditMacroPage and self.EditMacroPage.frame
	if EditMacroPage then
		S:Proxy("Reskin", EditMacroPage.SaveButton)
		S:Proxy("Reskin", EditMacroPage.CancelButton)
		HandleSummaryButton(EditMacroPage.bindSummary)
		EditMacroPage.background:HideBackdrop()
		EditMacroPage.bg = B.CreateBDFrame(EditMacroPage.background, .25)
		EditMacroPage.bg:SetAllPoints(EditMacroPage.background)
		EditMacroPage.EditBox:HideBackdrop()
		B.CreateBDFrame(EditMacroPage.EditBox, .25)
		S:Proxy("ReskinTrimScroll", EditMacroPage.EditBox.ScrollBar)
		S:Proxy("ReskinTrimScroll", EditMacroPage.iconScrollFrame.scrollbar)

		P:SecureHook(EditMacroPage.iconScrollFrame, "Update", function(self)
			self:ForEachFrame(HandleMacroButton)
		end)
	end

	local CatalogWindow = self.CatalogWindow and self.CatalogWindow.frame
	if CatalogWindow then
		B.StripTextures(CatalogWindow)
		B.SetBD(CatalogWindow)
		CatalogWindow:ClearAllPoints()
		CatalogWindow:SetPoint("LEFT", frame, "RIGHT", 2, 0)
		HandlePageButton(CatalogWindow.next, "right")
		HandlePageButton(CatalogWindow.prev, "left")
		S:Proxy("ReskinInput", CatalogWindow.searchBox)
		HandleFilterButton(CatalogWindow.filterButton)

		for _, button in ipairs(CatalogWindow.buttons) do
			HandleCatalogButton(button)
		end
	end

	frame.styled = true
end

function S:Clique()
	if not S.db["Clique"] then return end

	local Clique = _G.Clique
	if not Clique then return end

	P:SecureHook(Clique, "ShowSpellBookButton", ReskinSpellBookButton)

	local config = Clique.GetBindingConfig and Clique:GetBindingConfig()
	P:SecureHook(config, "InitializeLayout", ReskinBindingFrame)
end

S:RegisterSkin("Clique", S.Clique)