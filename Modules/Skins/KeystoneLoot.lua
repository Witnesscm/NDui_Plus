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
	P:SecureHook("KeystoneLootRaidsFrameMixin", "OnLoad", ReskinSubFrame)
	P:SecureHook("KeystoneLootEntryFrameMixin", "OnLoad", ReskinEntryFrame)

	-- ReminderFrame
	local ReminderFrame = _G.KeystoneLootReminderFrame
	if ReminderFrame then
		B.ReskinPortraitFrame(ReminderFrame)
	end

	P:SecureHook("KeystoneLootReminderSpecMixin", "OnLoad", ReskinReminderSpec)
	P:SecureHook("KeystoneLootReminderIconMixin", "Init", ReskinReminderIcon)
end

S:RegisterSkin("KeystoneLoot", S.KeystoneLoot)