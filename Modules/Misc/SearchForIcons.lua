local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local module = P:RegisterModule("SearchForIcons")
-------------------------------------------
-- Credit: SearchForIcons, by BlackmassJay
-------------------------------------------
function module:MacroIcons_Search(str, isIcon)
	if InCombatLockdown() then return end

	table.wipe(module.icons)
	module.icons[1] = "INV_MISC_QUESTIONMARK"

	local id = tonumber(str)
	if not id then return end

	if isIcon then
		tinsert(module.icons, id)
		return
	end

	local itemIcon = GetItemIcon(id)
	if itemIcon then
		tinsert(module.icons, itemIcon)
	end

	local spellIcon = GetSpellTexture(id)
	if spellIcon then
		tinsert(module.icons, spellIcon)
	end
end

function module:MacroIcons_Recovery()
	if InCombatLockdown() then return end

	table.wipe(module.icons)

	for index, icon in pairs(module.backup) do
		module.icons[index] = icon
	end
end

function module:CreateSearchFrame()
	local frame = CreateFrame("Frame", "NDuiPlus_SearchForIcons")
	frame:SetSize(240, 60)

	local editbox = B.CreateEditBox(frame, 160, 20)
	editbox:SetMaxLetters(10)
	editbox.bg:SetBackdropColor(0, 0, 0, 0)
	editbox:SetPoint("TOPRIGHT", -50, -35)
	editbox:HookScript("OnEscapePressed", function(self)
		self:SetText("")
	end)

	editbox:SetScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if text ~= "" then
			module:MacroIcons_Search(self:GetText(), true)
			module:PopupFrame_Update()
		end
	end)

	editbox:HookScript("OnTextChanged", function(self)
		local text = self:GetText()
		if text == "" then
			if self.searched then
				module:MacroIcons_Recovery()
			end
		else
			module:MacroIcons_Search(text)
			self.searched = true
		end

		module:PopupFrame_Update()
	end)

	local helpInfo = B.CreateHelpInfo(frame)
	helpInfo:SetPoint("TOPRIGHT", -5, -5)
	helpInfo.title = L["SearchForIcons"]
	B.AddTooltip(helpInfo, "ANCHOR_RIGHT", L["SearchForIconsTip"], "info")

	module.frame = frame
	module.editbox = editbox
end

function module:PopupFrame_Update()
	if _G.GuildBankPopupFrame and _G.GuildBankPopupFrame:IsShown() then
		_G.GuildBankPopupFrame:Update()
		_G.GuildBankPopupFrame.ScrollFrame:SetVerticalScroll(0)
	elseif _G.MacroFrame and _G.MacroFrame:IsShown() then
		_G.MacroPopupFrame_Update()
		_G.MacroPopupScrollFrame:SetVerticalScroll(0)
	elseif _G.GearManagerDialogPopup and _G.GearManagerDialogPopup:IsShown() then
		_G.GearManagerDialogPopup_Update()
		_G.GearManagerDialogPopupScrollFrame:SetVerticalScroll(0)
	end
end

function module:MacroIcons_Update()
	if not self then return end

	module.icons = self

	local parent
	if _G.GuildBankPopupFrame and _G.GuildBankPopupFrame:IsShown() then
		parent = _G.GuildBankPopupFrame
	elseif _G.MacroPopupFrame and _G.MacroPopupFrame:IsShown() then
		parent = _G.MacroPopupFrame
	elseif _G.GearManagerDialogPopup and _G.GearManagerDialogPopup:IsShown() then
		parent = _G.GearManagerDialogPopup
	end

	if not parent then return end

	if not module.frame then
		module:CreateSearchFrame()
	end

	module.frame:ClearAllPoints()
	module.frame:SetParent(parent)
	module.frame:SetPoint("TOPRIGHT")
	module.editbox.searched = nil
	module.editbox:SetText("")

	if module.backup then
		table.wipe(module.backup)
	else
		module.backup = {}
	end

	for index, icon in pairs(module.icons) do
		module.backup[index] = icon
	end

	if not InCombatLockdown() then
		for i = GetNumSpecializations(), 1, -1 do
			local specIcon = select(4, GetSpecializationInfo(i))
			if specIcon then
				tinsert(module.icons, 2, specIcon)
			end
		end
	end
end

function module:OnLogin()
	if not NDuiPlusDB["Misc"]["SearchForIcons"] then return end

	--hooksecurefunc("GetMacroIcons", module.MacroIcons_Update)
end