local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function HandleItemButton(self)
	self.bg = B.ReskinIcon(self.Icon, true)
	B.ReskinIconBorder(self.IconBorder, true)

	if self.bg.__shadow then
		self.bg.__shadow:SetFrameLevel(self:GetFrameLevel())
	end
end

local function ReskinTabSystem(self)
	if not self.TabSystem then
		return
	end

	for _, tab in ipairs(self.TabSystem.tabs) do
		B.ReskinTab(tab)
		tab.Text:ClearAllPoints()
		tab.Text:SetPoint("CENTER")
		tab.Text.SetPoint = B.Dummy
		tab.leftPadding = -16
	end
end

local function ReskinIconButton(self)
	local frame = self.Content
	if frame and not self.styled then
		HandleItemButton(frame)
		frame.IconEmpty:SetAlpha(0)

		self.styled = true
	end
end

local function ReskinSubFrame(self)
	S:Proxy("StripTextures", self.Inset)
	S:Proxy("StripTextures", self.BorderFrame)
end

local function ReskinEntryFrame(self)
	if self.Background then
		self.Background:SetAlpha(0)
	end

	local button = self.TeleportButton
	if button then
		button.bg = B.ReskinIcon(button.Icon)
		button.IconBorder:SetAlpha(0)
		button.HL = button:CreateTexture(nil, "HIGHLIGHT")
		button.HL:SetColorTexture(1, 1, 1, .25)
		button.HL:SetInside(button.bg)
	end
end

local function ReskinReminderSpec(self)
	B.StripTextures(self)
	S:Proxy("CreateBDFrame", self.Bg, .25)
	S:Proxy("Reskin", self.LootSpecButton)
end

local function ReskinReminderIcon(self)
	if not self.styled then
		HandleItemButton(self)

		self.styled = true
	end
end

local function rowOnEnter(self)
	self.bg:SetBackdropBorderColor(DB.r, DB.g, DB.b)
end

local function rowOnLeave(self)
	self.bg:SetBackdropBorderColor(0, 0, 0)
end

local function ReskinNotificationRow(self)
	if not self.rowPool then
		return
	end

	for row in self.rowPool:EnumerateActive() do
		if not row.styled then
			B.StripTextures(row)
			row.bg = B.CreateBDFrame(row, .25)
			row:HookScript("OnEnter", rowOnEnter)
			row:HookScript("OnLeave", rowOnLeave)
			HandleItemButton(row.IconFrame)

			local button = row.WhisperButton
			B.Reskin(button)
			button.__bg:SetInside(nil, 2, 2)
			button.Icon = button:CreateTexture(nil, "ARTWORK")
			button.Icon:SetTexture([[Interface\CHATFRAME\UI-ChatWhisperIcon]])
			button.Icon:SetPoint("CENTER")
			button.Icon:SetSize(24, 24)

			row.styled = true
		end
	end
end

function S:KeystoneLoot()
	if not S.db["KeystoneLoot"] then return end

	local frame = _G.KeystoneLootFrame
	if not frame then return end

	B.ReskinPortraitFrame(frame)
	S:Proxy("ReskinDropDown", frame.SlotDropdown)
	S:Proxy("ReskinDropDown", frame.ClassDropdown)
	S:Proxy("ReskinDropDown", frame.ItemLevelDropdown)
	P:SecureHook(frame, "InitializeTabSystem", ReskinTabSystem)

	local SettingsDropdown = frame.SettingsDropdown
	if SettingsDropdown then
		SettingsDropdown:ClearAllPoints()
		SettingsDropdown:SetPoint("TOPRIGHT", -28, -6)
	end

	local CatalystFrame = frame.CatalystFrame
	if CatalystFrame then
		CatalystFrame:ClearAllPoints()
		CatalystFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, -40)
		S:Proxy("StripTextures", CatalystFrame.Border)
		CatalystFrame.bg = B.SetBD(CatalystFrame)
		CatalystFrame.bg:SetInside()
	end

	P:SecureHook("KeystoneLootLootIconButtonMixin", "Init", ReskinIconButton)
	P:SecureHook("KeystoneLootDungeonsFrameMixin", "OnLoad", ReskinSubFrame)
	P:SecureHook("KeystoneLootRaidBlockMixin", "OnLoad", ReskinSubFrame)
	P:SecureHook("KeystoneLootEntryFrameMixin", "OnLoad", ReskinEntryFrame)

	-- ReminderFrame
	local ReminderFrame = _G.KeystoneLootReminderFrame
	if ReminderFrame then
		B.ReskinPortraitFrame(ReminderFrame)
	end

	P:SecureHook("KeystoneLootReminderSpecMixin", "OnLoad", ReskinReminderSpec)
	P:SecureHook("KeystoneLootReminderIconMixin", "Init", ReskinReminderIcon)

	-- NotificationFrame
	local NotificationFrame = _G.KeystoneLootDropNotificationFrame
	if NotificationFrame then
		B.ReskinPortraitFrame(NotificationFrame)
		P:SecureHook(NotificationFrame, "Refresh", ReskinNotificationRow)
	end

	-- KSLMenu
	local KSLMenu = _G.KSLMenu
	if not KSLMenu then return end

	-- from NDui
	local menuManagerProxy = KSLMenu.GetManager()

	local backdrops = {}

	local function skinMenu(menuFrame)
		B.StripTextures(menuFrame)

		if backdrops[menuFrame] then
			menuFrame.bg = backdrops[menuFrame]
		else
			menuFrame.bg = B.SetBD(menuFrame)
			backdrops[menuFrame] = menuFrame.bg
		end

		local framelevel = menuFrame:GetFrameLevel() - 1
		menuFrame.bg:SetFrameLevel(framelevel < 0 and 0 or framelevel)

		if not menuFrame.ScrollBar.styled then
			B.ReskinTrimScroll(menuFrame.ScrollBar)
			menuFrame.ScrollBar.styled = true
		end

		for i = 1, menuFrame:GetNumChildren() do
			local child = select(i, menuFrame:GetChildren())

			local minLevel = child.MinLevel
			if minLevel and not minLevel.styled then
				B.ReskinEditBox(minLevel)
				minLevel.styled = true
			end

			local maxLevel = child.MaxLevel
			if maxLevel and not maxLevel.styled then
				B.ReskinEditBox(maxLevel)
				maxLevel.styled = true
			end
		end
	end

	local function setupMenu(manager, _, menuDescription)
		local menuFrame = manager:GetOpenMenu()
		if menuFrame then
			skinMenu(menuFrame)
			menuDescription:AddMenuAcquiredCallback(skinMenu)
		end
	end

	hooksecurefunc(menuManagerProxy, "OpenMenu", setupMenu)
	hooksecurefunc(menuManagerProxy, "OpenContextMenu", setupMenu)
end

S:RegisterSkin("KeystoneLoot", S.KeystoneLoot)