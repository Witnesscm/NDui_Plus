local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local ipairs = ipairs

local r, g, b = DB.r, DB.g, DB.b

local function reskinInset(self)
	B.StripTextures(self)
	local bg = B.CreateBDFrame(self, .25)
	bg:SetPoint("TOPLEFT", 0, -5)
	bg:SetPoint("BOTTOMRIGHT", 0, 2)
end

local function updateTalentBG(self)
	local set = self:GetParent():GetParent().set

	if set and set.talents[self.id] then
		self.bg:SetBackdropColor(r, g, b, .25)
	else
		self.bg:SetBackdropColor(0, 0, 0, .25)
	end
end

local function reskinTalentRow(self)
	if not self.styled then
		self:DisableDrawLayer("BACKGROUND")
		self:DisableDrawLayer("BORDER")
		self.styled = true
	end

	for _, bu in ipairs(self.Buttons) do
		if not bu.styled then
			bu:SetHighlightTexture("")
			bu.Cover:SetAlpha(0)
			bu.Slot:SetAlpha(0)
			bu.KnownSelection:SetAlpha(0)

			B.ReskinIcon(bu.Icon)

			bu.bg = B.CreateBDFrame(bu, .25)
			bu.bg:SetPoint("TOPLEFT", 10, 0)
			bu.bg:SetPoint("BOTTOMRIGHT")

			hooksecurefunc(bu, "Update", updateTalentBG)

			bu.styled = true
		end
	end
end

local function reskinPvPTalent(self)
	for grid in self.GridPool:EnumerateActive() do
		if not grid.styled then
			reskinTalentRow(grid)
			grid.styled = true
		end
	end
end

local function reskinEssenceList(self)
	for _, button in ipairs(self.EssenceList.buttons) do
		if not button.bg then
			local bg = B.CreateBDFrame(button, .25)
			bg:SetPoint("TOPLEFT", 1, 0)
			bg:SetPoint("BOTTOMRIGHT", 0, 2)

			B.ReskinIcon(button.Icon)
			button.PendingGlow:SetTexture("")
			local hl = button:GetHighlightTexture()
			hl:SetColorTexture(r, g, b, .25)
			hl:SetInside(bg)

			button.bg = bg
		end
		button.Background:SetTexture("")

		if button:IsShown() then
			if button.PendingGlow:IsShown() then
				button.bg:SetBackdropBorderColor(1, .8, 0)
			else
				button.bg:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end
end

function S:BtWLoadouts()
	if not IsAddOnLoaded("BtWLoadouts") then return end

	local frame = _G.BtWLoadoutsFrame
	if not frame then return end

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.ReskinArrow(frame.OptionsButton, "down")
	frame.OptionsButton:SetPoint("RIGHT", frame.CloseButton, "LEFT", -4, 0)

	for _, tab in ipairs(frame.Tabs) do
		B.ReskinTab(tab)

		local text = tab.Text or _G[tab:GetName().."Text"]
		if text then
			text:SetPoint("CENTER", tab)
		end
	end

	for _, v in ipairs({"AddButton", "RefreshButton", "ActivateButton", "DeleteButton"}) do
		local bu = frame[v]
		if bu then
			B.Reskin(bu)
		end
	end

	local NPE = frame.NPE
	if NPE then
		B.StripTextures(NPE)
		local bg = B.CreateBDFrame(NPE, .5)
		bg:SetOutside(nil, 6, 6)
		B.Reskin(NPE.AddButton)
	end

	local SidebarInset = frame.SidebarInset
	if SidebarInset then
		reskinInset(SidebarInset)
	end

	local Sidebar = frame.Sidebar
	if Sidebar then
		B.ReskinFilterButton(frame.Sidebar.FilterButton)
		B.ReskinInput(Sidebar.SearchBox)
		B.ReskinScroll(Sidebar.Scroll.ScrollBar)
	end

	local Loadouts = frame.Loadouts
	if Loadouts then
		reskinInset(Loadouts.Inset)
		B.ReskinInput(Loadouts.Name)
		P.ReskinDropDown(Loadouts.CharacterDropDown)
		P.ReskinDropDown(Loadouts.SpecDropDown)
		B.ReskinCheck(Loadouts.Enabled)
	end

	local Talents = frame.Talents
	if Talents then
		B.StripTextures(Talents.Inset)
		P.ReskinDropDown(Talents.SpecDropDown)
		B.ReskinInput(Talents.Name)

		for _, row in ipairs(Talents.rows) do
			hooksecurefunc(row, "Update", reskinTalentRow)
		end
	end

	local PvPTalents = frame.PvPTalents
	if PvPTalents then
		B.StripTextures(PvPTalents.Inset)
		P.ReskinDropDown(PvPTalents.SpecDropDown)
		B.ReskinInput(PvPTalents.Name)

		hooksecurefunc(PvPTalents, "Update", reskinPvPTalent)
	end

	local Essences = frame.Essences
	if Essences then
		B.StripTextures(Essences.Inset)
		P.ReskinDropDown(Essences.RoleDropDown)
		B.ReskinInput(Essences.Name)
		B.ReskinScroll(Essences.EssenceList.ScrollBar)

		hooksecurefunc(Essences, "Update", reskinEssenceList)
	end

	local Soulbinds = frame.Soulbinds
	if Soulbinds then
		B.StripTextures(Soulbinds.Inset)
		P.ReskinDropDown(Soulbinds.SoulbindDropDown)
		B.ReskinInput(Soulbinds.Name)
		B.ReskinScroll(Soulbinds.Scroll.ScrollBar)
	end

	local Equipment = frame.Equipment
	if Equipment then
		B.StripTextures(Equipment.Inset)
		B.ReskinInput(Equipment.Name)

		for _, slot in ipairs(Equipment.Slots) do
			B.StripTextures(slot)
			slot.icon:SetTexCoord(unpack(DB.TexCoord))
			slot.icon:SetInside()

			slot.bg = B.CreateBDFrame(slot.icon, .25)
			slot.ignoreTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
			slot.ErrorOverlay:SetColorTexture(1, 0, 0, .5)
			slot.IconOverlay:SetAtlas("CosmeticIconFrame")
			slot.IconOverlay:SetInside()
			B.ReskinIconBorder(slot.IconBorder)
		end
	end

	local ActionBars = frame.ActionBars
	if ActionBars then
		B.StripTextures(ActionBars.Inset)
		B.ReskinInput(ActionBars.Name)

		for _, slot in ipairs(ActionBars.Slots) do
			B.StripTextures(slot)
			slot.Icon:SetTexCoord(unpack(DB.TexCoord))
			slot.Icon:SetInside()

			slot.bg = B.CreateBDFrame(slot.Icon, 0)
			slot.ignoreTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
			slot.ErrorOverlay:SetColorTexture(1, 0, 0, .5)

			local hl = slot:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .25)
			hl:SetInside()

			slot:SetPushedTexture(DB.textures.pushed)
		end
	end

	local Conditions = frame.Conditions
	if Conditions then
		reskinInset(Conditions.Inset)
		B.ReskinInput(Conditions.Name)
		B.ReskinCheck(Conditions.Enabled)

		for _, v in ipairs({"LoadoutDropDown", "CharacterDropDown", "ConditionTypeDropDown", "InstanceDropDown", "DifficultyDropDown", "BossDropDown", "AffixesDropDown", "ScenarioDropDown", "BattlegroundDropDown",}) do
			local dropDown = Conditions[v]
			if dropDown then
				P.ReskinDropDown(dropDown)
			end
		end

		local AffixesList = _G.BtWLoadoutsConditionsAffixesDropDownList
		if AffixesList then
			B.StripTextures(AffixesList)
			B.SetBD(AffixesList)
		end
	end

	local logFrame = _G.BtWLoadoutsLogFrame
	if logFrame then
		B.StripTextures(logFrame)
		B.SetBD(logFrame)
		B.ReskinClose(logFrame.CloseButton)
		B.StripTextures(logFrame.BodyInset)

		local bg = B.CreateBDFrame(logFrame.Scroll, .25)
		bg:SetPoint("BOTTOMRIGHT", -16, -3)
		B.ReskinScroll(logFrame.Scroll.ScrollBar)
	end
end

S:RegisterSkin("BtWLoadouts", S.BtWLoadouts)