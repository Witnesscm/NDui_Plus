local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local AB = P:GetModule("ActionBar")

local margin, padding = C.Bars.margin, C.Bars.padding

local SlotIDtoType = {
	[INVSLOT_HEAD] = Enum.InventoryType.IndexHeadType,
	[INVSLOT_NECK] = Enum.InventoryType.IndexNeckType,
	[INVSLOT_SHOULDER] = Enum.InventoryType.IndexShoulderType,
	[INVSLOT_BODY] = Enum.InventoryType.IndexBodyType,
	[INVSLOT_CHEST] = Enum.InventoryType.IndexChestType,
	[INVSLOT_WAIST] = Enum.InventoryType.IndexWaistType,
	[INVSLOT_LEGS] = Enum.InventoryType.IndexLegsType,
	[INVSLOT_FEET] = Enum.InventoryType.IndexFeetType,
	[INVSLOT_WRIST] = Enum.InventoryType.IndexWristType,
	[INVSLOT_HAND]= Enum.InventoryType.IndexHandType,
	[INVSLOT_FINGER1]= Enum.InventoryType.IndexFingerType,
	[INVSLOT_FINGER2]= Enum.InventoryType.IndexFingerType,
	[INVSLOT_TRINKET1]= Enum.InventoryType.IndexTrinketType,
	[INVSLOT_TRINKET2]= Enum.InventoryType.IndexTrinketType,
	[INVSLOT_BACK]= Enum.InventoryType.IndexCloakType,
}

function AB:RuneButton_Update(info)
	self.icon:SetTexture(info.iconTexture)
	self.skillLineAbilityID = info.skillLineAbilityID
end

local function ClearTimers(object)
	if object.delayTimer then
		P:CancelTimer(object.delayTimer)
		object.delayTimer = nil
	end
end

local function buttonOnEnter(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	if self.skillLineAbilityID then
		GameTooltip:SetEngravingRune(self.skillLineAbilityID)
	elseif self.text then
		GameTooltip:AddLine(self.text)
	end
	GameTooltip:Show()

	if self.popupBar then
		ClearTimers(self.popupBar)
		self.popupBar:Show()
	end

	if AB.fadeParent then
		AB.Button_OnEnter(self)
	end
end

local function buttonOnLeave(self)
	GameTooltip:Hide()

	if self.popupBar then
		ClearTimers(self.popupBar)
		if self.popupList then -- slot button
			self.popupBar:Hide()
		else
			self.popupBar.delayTimer = P:ScheduleTimer(self.popupBar.Hide, .5, self.popupBar)
		end
	end

	if AB.fadeParent then
		AB.Button_OnLeave(self)
	end
end

function AB:RuneBar_CreateButton(name, parent)
	local button = CreateFrame("Button", name, parent, "ActionButtonTemplate")
	button:SetHitRectInsets(-margin / 2, -margin / 2, -margin / 2, -margin / 2)
	button:RegisterForClicks("AnyUp")
	AB:StyleActionButton(button, AB.BarConfig)
	button:SetScript("OnEnter", buttonOnEnter)
	button:SetScript("OnLeave", buttonOnLeave)

	return button
end

function AB:RuneButton_OnClick()
	if InCombatLockdown() then
		P:Error(ERR_NOT_IN_COMBAT)
		return
	end

	if self.skillLineAbilityID then
		C_Engraving.CastRune(self.skillLineAbilityID)
		PickupInventoryItem(self.slotID)
		ClearCursor()
		local _, dialog = StaticPopup_Visible("REPLACE_ENCHANT")
		if dialog then
			dialog.button1:Click()
		end
	end

	self.popupBar:Hide()
end

function AB:RuneBar_Update()
	if not AB.RuneBar then return end

	C_Engraving.RefreshRunesList()

	for slotID, invType in ipairs(SlotIDtoType) do
		local runes = C_Engraving.GetRunesForCategory(invType, true)
		if runes and next(runes) then
			local buttonName = "NDuiPlus_RuneBarSlot" .. slotID
			local slot = AB.RuneBar.slotButtons[slotID]
			if not slot then
				slot = AB:RuneBar_CreateButton(buttonName, AB.RuneBar)
				slot.slotID = slotID
				slot.text = P.SlotIDtoName[slotID]
				slot.popupList = {}

				slot.popupBar = CreateFrame("Frame", buttonName .. "PopupBar", slot)
				slot.popupBar:SetFrameStrata("DIALOG")
				slot.popupBar:Hide()

				AB.RuneBar.slotButtons[slotID] = slot
			end

			local equippedInfo = C_Engraving.GetRuneForEquipmentSlot(slotID)
			if equippedInfo then
				AB.RuneButton_Update(slot, equippedInfo)
			else
				slot.icon:SetTexture(nil)
				slot.skillLineAbilityID = nil
			end

			local index = 1
			local prevButton
			for _, info in ipairs(runes) do
				if info.skillLineAbilityID ~= slot.skillLineAbilityID then
					local button = slot.popupList[index]
					if not button then
						button = AB:RuneBar_CreateButton(buttonName .. "Button" .. index, slot.popupBar)
						button.slotID = slotID
						button.popupBar = slot.popupBar
						button:HookScript("OnClick", AB.RuneButton_OnClick)

						slot.popupList[index] = button
					end

					AB.RuneButton_Update(button, info)
					button:Show()
					button:ClearAllPoints()

					if AB.db["RuneBarVertical"] then
						if not prevButton then
							button:SetPoint("RIGHT", -margin, 0)
						else
							button:SetPoint("RIGHT", prevButton, "LEFT", -margin, 0)
						end
					else
						if not prevButton then
							button:SetPoint("BOTTOM", 0, margin)
						else
							button:SetPoint("BOTTOM", prevButton, "TOP", 0, margin)
						end
					end

					prevButton = button
					index = index + 1
				end
			end

			for i = index, #slot.popupList do
				slot.popupList[i]:Hide()
			end

			local size = AB.db["RuneBarSize"]
			local num = index - 1
			local width, height = num * size + (num + 1) * margin, size + 2 * margin

			slot.popupBar:ClearAllPoints()
			if AB.db["RuneBarVertical"] then
				slot.popupBar:SetSize(width, height)
				slot.popupBar:SetPoint("RIGHT", slot, "LEFT")
			else
				slot.popupBar:SetSize(height, width)
				slot.popupBar:SetPoint("BOTTOM", slot, "TOP")
			end
		end
	end

	local numSlots = 0
	local prevButton
	for slotID in ipairs(SlotIDtoType) do
		local button = AB.RuneBar.slotButtons[slotID]
		if button then
			button:ClearAllPoints()
			if not prevButton then
				button:SetPoint("TOPLEFT", padding, -padding)
			else
				if AB.db["RuneBarVertical"] then
					button:SetPoint("TOP", prevButton, "BOTTOM", 0, -margin)
				else
					button:SetPoint("LEFT", prevButton, "RIGHT", margin, 0)
				end
			end

			numSlots = numSlots + 1
			prevButton = button
		end
	end

	AB.RuneBar_NumSlots = numSlots
	AB:RuneBar_UpdateSize()
end

function AB:RuneBar_UpdateSize()
	if not AB.RuneBar then return end

	local size = AB.db["RuneBarSize"]
	local num = AB.RuneBar_NumSlots > 0 and AB.RuneBar_NumSlots or 1
	local width, height = num * size + (num - 1) * margin + 2 * padding, size + 2 * padding

	if AB.db["RuneBarVertical"] then
		AB.RuneBar:SetSize(height, width)
		AB.RuneBar.mover:SetSize(height, width)
	else
		AB.RuneBar:SetSize(width, height)
		AB.RuneBar.mover:SetSize(width, height)
	end

	for _, slot in pairs(AB.RuneBar.slotButtons) do
		slot:SetSize(size, size)
		for _, button in ipairs(slot.popupList) do
			button:SetSize(size, size)
		end
	end
end

function AB:RuneBar_OnEquipmentChanged(slotID)
	if C_Engraving.IsEquipmentSlotEngravable(slotID) then
		AB:RuneBar_Update()
	end
end

function AB:RuneBar_Toggle()
	if not AB.RuneBar then return end

	if AB.db["RuneBar"] then
		AB:RuneBar_Update()
		B:RegisterEvent("NEW_RECIPE_LEARNED", AB.RuneBar_Update)
		B:RegisterEvent("RUNE_UPDATED", AB.RuneBar_Update)
		B:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", AB.RuneBar_OnEquipmentChanged)
		AB.RuneBar:Show()
	else
		B:UnregisterEvent("NEW_RECIPE_LEARNED", AB.RuneBar_Update)
		B:UnregisterEvent("RUNE_UPDATED", AB.RuneBar_Update)
		B:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED", AB.RuneBar_OnEquipmentChanged)
		AB.RuneBar:Hide()
	end
end

function AB:RuneBar_Init()
	if not C_Engraving.IsEngravingEnabled() then return end

	AB.RuneBar = CreateFrame("Frame", "NDuiPlus_RuneBar", UIParent)
	AB.RuneBar.slotButtons = {}
	AB.RuneBar.mover = B.Mover(AB.RuneBar, L["RuneBar"], "RuneBar", {"BOTTOMLEFT", UIParent, "BOTTOMRIGHT", -640, 24})
	AB:RuneBar_Toggle()
end