local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")
------------------------------------
-- Credit: Narcissus, by Peterodox
------------------------------------
local fontSize = 14

if GetLocale() ~= "zhCN" and GetLocale() ~= "zhTW" then
	fontSize = 10
end

local SlotIDtoName = {
	[1] = HEADSLOT,
	[2] = NECKSLOT,
	[3] = SHOULDERSLOT,
	[4] = SHIRTSLOT,
	[5] = CHESTSLOT,
	[6] = WAISTSLOT,
	[7] = LEGSSLOT,
	[8] = FEETSLOT,
	[9] = WRISTSLOT,
	[10]= HANDSSLOT,
	[11]= FINGER0SLOT_UNIQUE,
	[12]= FINGER1SLOT_UNIQUE,
	[13]= TRINKET0SLOT_UNIQUE,
	[14]= TRINKET1SLOT_UNIQUE,
	[15]= BACKSLOT,
	[16]= MAINHANDSLOT,
	[17]= SECONDARYHANDSLOT,
	[18]= RANGEDSLOT,
	[19]= TABARDSLOT,
}

local TransmogSlotOrder = {
	INVSLOT_HEAD,
	INVSLOT_SHOULDER,
	INVSLOT_BACK,
	INVSLOT_CHEST,
	INVSLOT_BODY,
	INVSLOT_TABARD,
	INVSLOT_WRIST,
	INVSLOT_HAND,
	INVSLOT_WAIST,
	INVSLOT_LEGS,
	INVSLOT_FEET,
	INVSLOT_MAINHAND,
	INVSLOT_OFFHAND,
}

local function GenerateSource(sourceID, sourceType, itemModID, itemQuality)
	local sourceTextColorized = ""
	if sourceType == 1 then --TRANSMOG_SOURCE_BOSS_DROP
		local drops = C_TransmogCollection.GetAppearanceSourceDrops(sourceID)
		if drops and drops[1] then
			sourceTextColorized = drops[1].encounter.." ".."|cFFFFD100"..drops[1].instance.."|r|CFFf8e694"
			if itemModID == 0 then 
				sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY1
			elseif itemModID == 1 then 
				sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY2
			elseif itemModID == 3 then 
				sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY6
			elseif itemModID == 4 then
				sourceTextColorized = sourceTextColorized.." "..PLAYER_DIFFICULTY3
			end
		end
	else
		if sourceType == 2 then --quest
			sourceTextColorized = TRANSMOG_SOURCE_2
		elseif sourceType == 3 then --vendor
			sourceTextColorized = TRANSMOG_SOURCE_3
		elseif sourceType == 4 then --world drop
			sourceTextColorized = TRANSMOG_SOURCE_4
		elseif sourceType == 5 then --achievement
			sourceTextColorized = TRANSMOG_SOURCE_5
		elseif sourceType == 6 then	--profession
			sourceTextColorized = TRANSMOG_SOURCE_6
		else
			if itemQuality == 6 then
				sourceTextColorized = ITEM_QUALITY6_DESC
			elseif itemQuality == 5 then
				sourceTextColorized = ITEM_QUALITY5_DESC
			end
		end
	end

	return sourceTextColorized
end

local function GetIllusionSource(illusionID)
	local name, _, sourceText = C_TransmogCollection.GetIllusionStrings(illusionID)
	name = name and format(TRANSMOGRIFIED_ENCHANT, name)

	return name, sourceText
end

local function GetTransmogInfo(slotID, sourceID)
	local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
	if not sourceInfo or not sourceInfo.name then
		M.TransmogTextFrame.waitingOnItemData = true
		return
	end

	if sourceInfo.isHideVisual and not M.db["ShowHideVisual"] then
		return
	end

	return {
		["SlotID"] = slotID,
		["Name"] = sourceInfo.name,
		["Source"] = GenerateSource(sourceID, sourceInfo.sourceType, sourceInfo.itemModID, sourceInfo.quality)
	}
end

function M:CopyMog_UpdateItemText(transmogInfoList)
	local textFrame = M.TransmogTextFrame
	wipe(textFrame.itemList)
	textFrame.waitingOnItemData = false
	textFrame.transmogInfoList = transmogInfoList

	local mainHandEnchant, offHandEnchant
	for _, slotID in ipairs(TransmogSlotOrder) do
		local transmogInfo = transmogInfoList[slotID]
		if transmogInfo then
			local appearanceID, secondaryAppearanceID, illusionID = transmogInfo.appearanceID, transmogInfo.secondaryAppearanceID, transmogInfo.illusionID
			if appearanceID and appearanceID ~= Constants.Transmog.NoTransmogID then
				local info = GetTransmogInfo(slotID, appearanceID)
				if info then
					table.insert(textFrame.itemList, info)
				end
			end

			if C_Transmog.CanHaveSecondaryAppearanceForSlotID(slotID) and secondaryAppearanceID ~= Constants.Transmog.NoTransmogID and secondaryAppearanceID ~= appearanceID then
				local info = GetTransmogInfo(slotID, secondaryAppearanceID)
				if info then
					table.insert(textFrame.itemList, info)
				end
			end

			if slotID == 16 then
				mainHandEnchant = illusionID
			elseif slotID == 17 then
				offHandEnchant = illusionID
			end
		end
	end

	if M.db["ShowIllusion"] then
		if mainHandEnchant and mainHandEnchant > 0 then
			local illusionName, sourceText = GetIllusionSource(mainHandEnchant)
			table.insert(textFrame.itemList, {["SlotID"] = 16, ["Name"] = illusionName, ["Source"] = sourceText})
		end

		if offHandEnchant and offHandEnchant > 0 then
			local illusionName, sourceText = GetIllusionSource(offHandEnchant)
			table.insert(textFrame.itemList, {["SlotID"] = 17, ["Name"] = illusionName, ["Source"] = sourceText})
		end
	end

	local texts = ""
	for _, info in ipairs(textFrame.itemList) do
		if info.Name and info.Name ~= "" then
			texts = texts .. "|cFFFFD100"..SlotIDtoName[info.SlotID]..":|r " .. info.Name
			if info.Source and info.Source ~= "" then
				texts = texts .. " |cFF40C7EB(" .. info.Source .. ")|r|r"
			end
			texts = texts .. "\n"
		end
	end

	textFrame.EditBox:SetText(strtrim(texts))
	textFrame.EditBox:HighlightText()
	textFrame:Show()
end

local function TextFrame_OnShow(self)
	self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE")
end

local function TextFrame_OnHide(self)
	self:UnregisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE")
end

local function TextFrame_OnEvent(self, event, ...)
	if event == "TRANSMOG_COLLECTION_ITEM_UPDATE" then
		if self.waitingOnItemData and self.transmogInfoList then
			M:CopyMog_UpdateItemText(self.transmogInfoList)
		end
	end
end

function M:CopyMog_CreateTextFrame()
	local textFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	textFrame:SetPoint("CENTER")
	textFrame:SetSize(400, 300)
	textFrame:SetFrameStrata("DIALOG")
	B.CreateMF(textFrame)
	B.SetBD(textFrame)

	textFrame:SetScript("OnShow", TextFrame_OnShow)
	textFrame:SetScript("OnHide", TextFrame_OnHide)
	textFrame:SetScript("OnEvent", TextFrame_OnEvent)
	textFrame:Hide()

	textFrame.Header = B.CreateFS(textFrame, 14, L["Transmog"], true, "TOP", 0, -5)

	local close = CreateFrame("Button", nil, textFrame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", textFrame)
	B.ReskinClose(close)
	textFrame.Close = close

	local scrollArea = CreateFrame("ScrollFrame", nil, textFrame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 10, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", -28, 10)
	B.ReskinScroll(scrollArea.ScrollBar)

	local editBox = CreateFrame("EditBox", nil, textFrame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(true)
	editBox:SetFont(STANDARD_TEXT_FONT, 14, "")
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(scrollArea:GetHeight())
	editBox:SetScript("OnEscapePressed", function() textFrame:Hide() end)
	scrollArea:SetScrollChild(editBox)
	textFrame.EditBox = editBox

	return textFrame
end

local function CreateCopyButton(parent)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(50, 20)
	button:SetText(L["Transmog"])
	button.Text:SetFont(STANDARD_TEXT_FONT, fontSize, "OUTLINE")
	button.Text:SetTextColor(DB.r, DB.g, DB.b)
	B.Reskin(button)
	parent.CopyButton = button

	return button
end

function M:CopyMog_CreatePlayerButton()
	local button = CreateCopyButton(_G.PaperDollFrame)
	button:SetPoint("BOTTOMLEFT", 5, 6)
	button:SetScript("OnClick", function()
		local playerActor = _G.CharacterModelScene:GetPlayerActor()
		if not playerActor then
			return
		end

		local transmogInfoList = playerActor:GetItemTransmogInfoList()
		if not transmogInfoList then
			return
		end

		M:CopyMog_UpdateItemText(transmogInfoList)
	end)
end

function M:CopyMog_CreateInspectButton()
	local button = CreateCopyButton(_G.InspectPaperDollFrame)
	button:SetPoint("BOTTOMLEFT", 5, 6)
	button:SetScript("OnClick", function()
		local transmogInfoList = C_TransmogCollection.GetInspectItemTransmogInfoList()
		if not transmogInfoList then
			return
		end

		M:CopyMog_UpdateItemText(transmogInfoList)
	end)
end

function M:CopyMog()
	if not M.db["CopyMog"] then return end

	M.TransmogTextFrame = M:CopyMog_CreateTextFrame()
	M.TransmogTextFrame.itemList = {}
	M.TransmogTextFrame.waitingOnItemData = false

	M:CopyMog_CreatePlayerButton()
	P:AddCallbackForAddon("Blizzard_InspectUI", M.CopyMog_CreateInspectButton)
end

M:RegisterMisc("CopyMog", M.CopyMog)