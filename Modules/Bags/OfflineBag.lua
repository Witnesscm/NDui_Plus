local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)
local module = P:RegisterModule("Bags")

local strfind = string.find
----------------------------
-- Credit: tdBag2
----------------------------
local GetContainerNumSlots = GetContainerNumSlots or C_Container.GetContainerNumSlots

local BAGS = {0, 1, 2, 3, 4}
local BANKS = {-1, 5, 6, 7, 8, 9, 10, 11}
local KEYS = {-2}
local PlayerDB
local Owner, Owners
local bagFrame, bankFrame, keyringFrame, SelectorDropMenu
local atBank
local ItemButtons = {}
local dataCache = {}
local GenerateName = P.NameGenerator(addonName.."_BagSlot")

local function SetupCache()
	NDuiPlusBAGDB = NDuiPlusBAGDB or {}
	NDuiPlusBAGDB[DB.MyRealm] = NDuiPlusBAGDB[DB.MyRealm] or {}
	NDuiPlusBAGDB[DB.MyRealm][DB.MyName] = NDuiPlusBAGDB[DB.MyRealm][DB.MyName] or {}
	PlayerDB = NDuiPlusBAGDB[DB.MyRealm][DB.MyName]
	PlayerDB.name = DB.MyName
	PlayerDB.class = DB.MyClass

	Owner = DB.MyName
	Owners = {DB.MyName}
	for k in pairs(NDuiPlusBAGDB[DB.MyRealm]) do
		if k ~= DB.MyName then
			tinsert(Owners, k)
		end
	end

	for _, bag in ipairs(BAGS) do
		ItemButtons[bag] = {}
	end

	for _, bag in ipairs(BANKS) do
		ItemButtons[bag] = {}
	end

	for _, bag in ipairs(KEYS) do
		ItemButtons[bag] = {}
	end
end

local function parseItem(link, count, timeout)
	if link then
		if link:find("0:0:0:0:0:%d+:%d+:%d+:0:0") then
			link = link:match("|H%l+:(%d+)")
		else
			link = link:match("|H%l+:([%d:]+)")
		end

		count = count and count > 1 and count or nil
		if count or timeout then
			link = link .. ";" .. (count or "")
		end
		if timeout then
			link = link .. ";" .. timeout
		end

		return link
	end
end

local function getInfo(itemData)
	if not dataCache[itemData] then
		local data = {}
		local link, count, timeout = strsplit(";", itemData)
		data.link = "item:" .. link
		data.count = tonumber(count)
		data.id = tonumber(link:match("^(%d+)"))
		data.icon = C_Item.GetItemIconByID(data.id)
		data.timeout = tonumber(timeout)

		local name, itemLink, quality, level, _, _, _, _, _, _, _, classID  = C_Item.GetItemInfo(data.link)
		if name then
			data.name = name
			data.link = itemLink
			data.quality = quality
			data.level = level
			data.classID = classID
		else
			data.noCache = true
		end

		dataCache[itemData] = data
	end

	return dataCache[itemData]
end

local function getOwnerDB(owner)
	return NDuiPlusBAGDB[DB.MyRealm][owner]
end

local function SaveBag(bag)
	local size = GetContainerNumSlots(bag)
	local items
	if size > 0 then
		items = {}
		items.size = size

		for slot = 1, size do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info then
				items[slot] = parseItem(info.hyperlink, info.stackCount)
			end
		end
	end

	PlayerDB[bag] = items
end

local function UpdateBag(_, bag)
	if bag <= NUM_BAG_SLOTS then
		SaveBag(bag)
	end
end

local function SaveMoney()
	PlayerDB.money = GetMoney()
end

local function UpdateAllDB()
	for _, bag in ipairs(BAGS) do
		SaveBag(bag)
	end

	for _, bag in ipairs(KEYS) do
		SaveBag(bag)
	end

	SaveMoney()
end

local function Bank_Opened()
	atBank = true
end

local function Bank_Closed()
	if atBank then
		for _, bag in ipairs(BANKS) do
			SaveBag(bag)
		end
		atBank = nil
	end
end

local function ItemButton_OnEnter(self)
	if self.info and self.info.link then
		P.AnchorTooltip(self)
		GameTooltip:SetHyperlink(self.info.link)
		GameTooltip:Show()
	end
end

local function ItemButton_OnClick(self)
	if self.info and self.info.link and not self.info.noCache then
		HandleModifiedItemClick(self.info.link)
	end
end

local function ItemButton_LoadInfo(self, itemData)
	self.info = getInfo(itemData)
	if not self.info then return end

	self.Icon:SetTexture(self.info.icon)

	if self.info.count and self.info.count > 1 then
		self.Count:SetText(self.info.count > 1e3 and "*" or self.info.count)
	else
		self.Count:SetText("")
	end
end

local iLvlClassIDs = {
	[Enum.ItemClass.Armor] = true,
	[Enum.ItemClass.Weapon] = true,
}

local function IsItemHasLevel(info)
	return info.quality and info.quality > 1 and info.classID and iLvlClassIDs[info.classID]
end

local function ItemButton_UpdateItem(self)
	if not self.info or self.info.noCache then return end

	if self.info.quality and self.info.quality > -1 then
		local color = DB.QualityColors[self.info.quality]
		self:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		self:SetBackdropBorderColor(0, 0, 0)
	end

	self.iLvl:SetText("")
	if C.db["Bags"]["BagsiLvl"] and IsItemHasLevel(self.info) then
		local level = self.info.level
		if level and level > C.db["Bags"]["iLvlToShow"] then
			local color = DB.QualityColors[self.info.quality]
			self.iLvl:SetText(level)
			self.iLvl:SetTextColor(color.r, color.g, color.b)
		end
	end
end

local function ItemButton_UpdateInfo(self)
	if not self.info.noCache then return end

	local name, link, quality, level, _, _, _, _, _, _, _, classID = C_Item.GetItemInfo(self.info.link)
	if name then
		self.info.name = name
		self.info.link = link
		self.info.quality = quality
		self.info.level = level
		self.info.classID = classID
		self.info.noCache = nil
		P:Debug(name)
	end

	ItemButton_UpdateItem(self)
end

local function ItemButton_Update(self, itemData)
	ItemButton_LoadInfo(self, itemData)
	ItemButton_UpdateItem(self)
end

local function ItemButton_Free(self)
	self:Hide()
	self.Icon:SetTexture(nil)
	self.info = nil
	self.Count:SetText("")
	self.iLvl:SetText("")
	self:SetBackdropBorderColor(0, 0, 0)
end

local function UpdateItemButtonInfo(_, itemId)
	for _, buttons in pairs(ItemButtons) do
		for _, itemButton in pairs(buttons) do
			if itemButton:IsShown() and itemButton.info and itemButton.info.id and itemButton.info.id == itemId then
				itemButton:UpdateInfo()
			end
		end
	end
end

local function CreateItemButton(bag, slot)
	local name = GenerateName()
	local button = CreateFrame("Button", name, nil, "ItemButtonTemplate")
	local iconSize = module.db["IconSize"]

	button:SetNormalTexture(0)
	button:SetPushedTexture(0)
	button:SetHighlightTexture(DB.bdTex)
	button:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
	button:GetHighlightTexture():SetInside()
	button:SetSize(iconSize, iconSize)
	button:Hide()

	button.Icon = _G[name.."IconTexture"]
	button.Icon:SetInside()
	button.Icon:SetTexCoord(unpack(DB.TexCoord))
	button.Count = _G[name.."Count"]
	button.Count:SetPoint("BOTTOMRIGHT", -1, 2)
	B.SetFontSize(button.Count, C.db["Bags"]["FontSize"])
	button.iLvl = B.CreateFS(button, C.db["Bags"]["FontSize"], "", false, "BOTTOMLEFT", 1, 2)
	button.bagID = bag
	button.slotID = slot

	P.SetupBackdrop(button)
	B.CreateBD(button, .3)
	button:SetBackdropColor(.3, .3, .3, .3)

	button:SetScript("OnEnter", ItemButton_OnEnter)
	button:SetScript("OnLeave", B.HideTooltip)
	button:SetScript("OnClick", ItemButton_OnClick)

	button.Update = ItemButton_Update
	button.UpdateInfo = ItemButton_UpdateInfo
	button.Free = ItemButton_Free

	ItemButtons[bag][slot] = button

	return button
end

local function GetItemButton(bag, slot)
	return ItemButtons[bag][slot] or CreateItemButton(bag, slot)
end

local function getMoneyString(money)
	money = money or 0

	local str
	local g,s,c = floor(money/1e4), floor(money/100) % 100, money % 100

	if(g > 0) then str = (str and str.." " or "") .. g .. "|TInterface\\MoneyFrame\\UI-GoldIcon:16:16:0:0|t" end
	if(s > 0) then str = (str and str.." " or "") .. s .. "|TInterface\\MoneyFrame\\UI-SilverIcon:16:16:0:0|t" end
	if(c >= 0) then str = (str and str.." " or "") .. c .. "|TInterface\\MoneyFrame\\UI-CopperIcon:16:16:0:0|t" end
	return str
end

local function UpdateMoney()
	local ownerDB = getOwnerDB(Owner)
	local money = ownerDB.money
	local moneyStr = getMoneyString(money)
	if money then
		bagFrame.InfoFrame.money:SetText(moneyStr)
	end
end

local function UpdateName()
	local ownerDB = getOwnerDB(Owner)
	local class = ownerDB.class
	local r, g, b = DB.ClassColors[class].r, DB.ClassColors[class].g, DB.ClassColors[class].b
	bagFrame.Name:SetText(Owner)
	bagFrame.Name:SetTextColor(r, g, b)
end

local function FreeAllButtons()
	for bag, buttons in pairs(ItemButtons) do
		for slot, itemButton in pairs(buttons) do
			itemButton:Free()
		end
	end
end

local function LayoutButtons(frame, bags)
	local ownerDB = getOwnerDB(Owner)
	local x, y = 0, 0
	local column = module.db["BagsWidth"]
	local offset = 38
	local spacing = 3
	local iconSize = module.db["IconSize"]
	local size = iconSize + spacing
	local xOffset = 5
	local yOffset = -offset + xOffset

	for _, bag in ipairs(bags) do
		local bagData = ownerDB[bag]
		if bagData and bagData.size and bagData.size > 0 then
			for slot = 1, bagData.size do
				local itemButton = GetItemButton(bag, slot)
				local itemData = bagData[slot]
				if x == column then
					y = y + 1
					x = 0
				end
				itemButton:SetParent(frame)
				itemButton:ClearAllPoints()
				itemButton:SetPoint("TOPLEFT", frame, "TOPLEFT", x * size + xOffset , -y * size + yOffset)
				itemButton:Show()

				if itemData then
					itemButton:Update(itemData)
				end

				x = x + 1
			end
		end
	end

	local width = column * (iconSize + spacing) - spacing
	local height = (y + 1) * (iconSize + spacing) - spacing
	frame:SetSize(width + xOffset*2, height + offset)
end

local function InfoFrame_OnClick(self)
	self:Hide()
	self.search:Show()
end

local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or .3)
end

local function MatchCheck(button, text)
	local name = button.info and button.info.name
	if name and strfind(name, text) then
		return true
	end

	return false
end

local function Filter(button, text)
	if(text == "" or not text) then
		highlightFunction(button, true)
	else
		local result = MatchCheck(button, text)
		highlightFunction(button, result)
	end
end

local function ApplyToButtons(text)
	for _, buttons in pairs(ItemButtons) do
		for _, itemButton in pairs(buttons) do
			if itemButton:IsShown() then
				Filter(itemButton, text)
			end
		end
	end
end

local function DoSearch(self, text)
	if(type(text) == "string") then
		self:SetText(text)
	else
		text = self:GetText()
	end

	ApplyToButtons(text)
end

local function Search_OnEscapePressed(self)
	DoSearch(self, "")
	self:ClearFocus()
end

local function Search_OnEnterPressed(self)
	self:ClearFocus()
end

local function Search_OnEditFocusLost(self)
	self.infoFrame:Show()
	self:Hide()
end

local function CreateInfoFrame(parent)
	local infoFrame = CreateFrame("Button", nil, parent)
	infoFrame:SetPoint("TOPLEFT", 10, 0)
	infoFrame:SetSize(160, 32)
	infoFrame:RegisterForClicks("anyUp")
	infoFrame:SetScript("OnClick", InfoFrame_OnClick)

	local icon = infoFrame:CreateTexture()
	icon:SetSize(24, 24)
	icon:SetPoint("LEFT")
	icon:SetTexture("Interface\\Minimap\\Tracking\\None")
	icon:SetTexCoord(1, 0, 0, 1)

	local search = CreateFrame("EditBox", nil, parent)
	search:SetAllPoints(infoFrame)
	search:SetFontObject(GameFontHighlight)
	search:SetAutoFocus(true)
	search:SetAllPoints(infoFrame)
	local bg = B.CreateBDFrame(search, 0)
	bg:SetPoint("TOPLEFT", -5, -5)
	bg:SetPoint("BOTTOMRIGHT", 5, 5)
	B.CreateGradient(bg)
	search:SetScript("OnTextChanged", DoSearch)
	search:SetScript("OnEscapePressed", Search_OnEscapePressed)
	search:SetScript("OnEnterPressed", Search_OnEnterPressed)
	search:SetScript("OnEditFocusLost", Search_OnEditFocusLost)
	search.infoFrame = infoFrame
	infoFrame.search = search
	search:Hide()

	local tag = infoFrame:CreateFontString(nil, "OVERLAY")
	tag:SetFont(unpack(DB.Font))
	tag:SetPoint("LEFT", icon, "RIGHT", 5, 0)
	infoFrame.money = tag

	return infoFrame
end

local function CreateCloseButton(parent)
	local bu = B.CreateButton(parent, 22, 22, true, "Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	bu:RegisterForClicks("AnyUp")
	bu:SetScript("OnClick", function()
		parent:Hide()
	end)
	bu.title = CLOSE
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

local function UpdateAllBags(current)
	if current then
		if current == Owner then
			return
		else
			Owner = current
		end
	end

	FreeAllButtons()
	UpdateMoney()
	UpdateName()
	LayoutButtons(bagFrame, BAGS)
	LayoutButtons(bankFrame, BANKS)
	LayoutButtons(keyringFrame, KEYS)

	local search = bagFrame.InfoFrame.search
	local text = search and search:GetText()
	if text and text ~= "" then
		DoSearch(search, text)
	end
end

local function EasyMenu_Initialize(frame, level, menuList)
	for index = 1, #menuList do
		local value = menuList[index]
		if (value.text) then
			value.index = index
			UIDropDownMenu_AddButton(value, level)
		end
	end
end

local function CreateDropMenu()
	if not SelectorDropMenu then
		local frame = CreateFrame("Frame", "NDui_Plus_SelectorDropMenu", UIParent, "UIDropDownMenuTemplate")
		frame.displayMode = "MENU"
		frame.initialize = EasyMenu_Initialize

		SelectorDropMenu = frame
	end
	return SelectorDropMenu
end

local function GetOwnerColoredName(ownerDB)
	local color = RAID_CLASS_COLORS[ownerDB.class or "PRIEST"]
	return format("|cff%02x%02x%02x%s|r", color.r * 0xFF, color.g * 0xFF, color.b * 0xFF, ownerDB.name)
end

local function DeleteOwnerInfo(name)
	local realmData = NDuiPlusBAGDB[DB.MyRealm]
	if realmData then
		realmData[name] = nil
	end

	tDeleteItem(Owners, name)
end

local function CreateOwnerMenu(name)
	local isSelf = name == DB.MyName
	local isCurrent = name == Owner
	local hasArrow = not isSelf and not isCurrent
	local info = getOwnerDB(name)

	return {
		text = GetOwnerColoredName(info),
		checked = isCurrent,
		hasArrow = hasArrow,
		menuList = hasArrow and {
			{
				notCheckable = true,
				text = DELETE,
				func = function()
					DeleteOwnerInfo(name)
					CloseDropDownMenus(1)
				end,
			},
		},
		func = function()
			UpdateAllBags(name)
		end,
	}
end

local function CreateMenu()
	local menuList = {}
	for _, owner in ipairs(Owners) do
		tinsert(menuList, CreateOwnerMenu(owner))
	end
	return menuList
end

local function IsMenuOpened()
	return SelectorDropMenu and _G.UIDROPDOWNMENU_OPEN_MENU == SelectorDropMenu and DropDownList1:IsShown()
end

local function ToggleMenu(frame)
	if IsMenuOpened() then
		CloseDropDownMenus()
		PlaySound(851)
	else
		CloseDropDownMenus()
		ToggleDropDownMenu(1, nil, SelectorDropMenu or CreateDropMenu(), frame, 0, 0, CreateMenu())
		PlaySound(850)
	end
end

local function OwnerSelector_OnClick(self, btn)
	if btn == "RightButton" then
		UpdateAllBags(DB.MyName)

		if IsMenuOpened() then
			CloseDropDownMenus()
			PlaySound(851)
		end
	else
		B.HideTooltip()
		ToggleMenu(self)
	end
end

local function OwnerSelector_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:SetText(CHARACTER)
	GameTooltip:AddLine(P.LeftButtonTip(L.TOOLTIP_CHANGE_PLAYER), 1, 1, 1)
	GameTooltip:AddLine(P.RightButtonTip(L.TOOLTIP_RETURN_TO_SELF), 1, 1, 1)
	GameTooltip:Show()
end

local function CreateSelectorButton(parent)
	local bu = B.CreateButton(parent, 22, 22, true, "Interface\\CHATFRAME\\UI-ChatIcon-Battlenet")
	bu:RegisterForClicks("AnyUp")
	bu:SetScript("OnClick", OwnerSelector_OnClick)
	bu:SetScript("OnEnter", OwnerSelector_OnEnter)
	bu:SetScript("OnLeave", B.HideTooltip)

	return bu
end

local function CreateBankToggle(parent)
	local bu = B.CreateButton(parent, 22, 22, true, "Interface\\ICONS\\INV_Misc_Bag_08")
	bu:SetScript("OnClick", function()
		B:TogglePanel(bankFrame)
		if bankFrame:IsShown() then
			bu.bg:SetBackdropBorderColor(1, .8, 0)
			PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
		else
			bu.bg:SetBackdropBorderColor(0, 0, 0)
			PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
		end
	end)
	bu.title = BANK
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

local function CreateKeyToggle(parent)
	local bu = B.CreateButton(parent, 22, 22, true, "Interface\\ICONS\\INV_Misc_Key_12")
	bu:SetScript("OnClick", function()
		B:TogglePanel(keyringFrame)
		if keyringFrame:IsShown() then
			bu.bg:SetBackdropBorderColor(1, .8, 0)
			PlaySound(SOUNDKIT.KEY_RING_OPEN)
		else
			bu.bg:SetBackdropBorderColor(0, 0, 0)
			PlaySound(SOUNDKIT.KEY_RING_CLOSE)
		end
	end)
	bu.title = KEYRING
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

local function CreateMainFrame()
	bagFrame = CreateFrame("Frame", addonName.."_BagFrame", UIParent)
	tinsert(UISpecialFrames, addonName.."_BagFrame")
	bagFrame:SetPoint("TOPLEFT", UIParent, "LEFT", 150, 50)
	bagFrame:SetFrameStrata("HIGH")
	B.SetBD(bagFrame)
	B.CreateMF(bagFrame, nil, true)
	B.RestoreMF(bagFrame)

	bagFrame.InfoFrame = CreateInfoFrame(bagFrame)
	bagFrame.Name = B.CreateFS(bagFrame, 14, DB.MyName, true, "TOP", 0, -8)
	bagFrame.Close = CreateCloseButton(bagFrame)
	bagFrame.Close:SetPoint("TOPRIGHT", -5, -5)
	bagFrame.Selector = CreateSelectorButton(bagFrame)
	bagFrame.Selector:SetPoint("RIGHT", bagFrame.Close, "LEFT", -3, 0)
	bagFrame.BankToggle = CreateBankToggle(bagFrame)
	bagFrame.BankToggle:SetPoint("RIGHT", bagFrame.Selector, "LEFT", -3, 0)
	bagFrame.KeyToggle = CreateKeyToggle(bagFrame)
	bagFrame.KeyToggle:SetPoint("RIGHT", bagFrame.BankToggle, "LEFT", -3, 0)
	bagFrame:Hide()
	bagFrame:SetScript("OnShow", function()
		if Owner == DB.MyName then
			UpdateAllBags()
		end
	end)

	bankFrame = CreateFrame("Frame", addonName.."_BankFrame", bagFrame)
	bankFrame:SetPoint("BOTTOMLEFT", bagFrame, "TOPLEFT", 0, 5)
	bankFrame:SetFrameStrata("HIGH")
	bankFrame:SetClampedToScreen(true)
	B.SetBD(bankFrame)
	B.CreateMF(bankFrame, bagFrame, true)
	bankFrame.Title = B.CreateFS(bankFrame, 14, BANK, true, "TOPLEFT", 5, -8)
	bankFrame:Hide()

	keyringFrame = CreateFrame("Frame", addonName.."_KeyringFrame", bagFrame)
	keyringFrame:SetPoint("TOPLEFT", bagFrame, "BOTTOMLEFT", 0, -5)
	keyringFrame:SetFrameStrata("HIGH")
	keyringFrame:SetClampedToScreen(true)
	B.SetBD(keyringFrame)
	B.CreateMF(keyringFrame, bagFrame, true)
	keyringFrame.Title = B.CreateFS(keyringFrame, 14, KEYRING, true, "TOPLEFT", 5, -8)
	keyringFrame:Hide()
end

local function CreateOfflineToggle(parent)
	local bu = B.CreateButton(parent, 22, 22, true, "Interface\\HELPFRAME\\ReportLagIcon-Loot")
	bu.Icon:SetPoint("TOPLEFT", -1, 3)
	bu.Icon:SetPoint("BOTTOMRIGHT", 1, -3)
	bu:RegisterForClicks("AnyUp")
	bu:SetScript("OnClick", function()
		B:TogglePanel(_G.NDui_Plus_BagFrame)
	end)
	bu.title = L["OfflineBag"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:CreateWidgetButton()
	local cargBags = _G.NDui.cargBags
	local backpack = cargBags and cargBags:GetImplementation("NDui_Backpack")
	if backpack then
		local bag = backpack.contByName["Bag"]
		if bag then
			local buttons = bag.widgetButtons
			if buttons then
				local toggle = CreateOfflineToggle(bag)
				toggle:SetPoint("RIGHT", buttons[#buttons], "LEFT", -3, 0)
				tinsert(buttons, toggle)
			end

			local widgetArrow = bag.widgetArrow
			if widgetArrow then
				widgetArrow:Click()
				widgetArrow:Click()
			end
		end
	end
end

function module:OnLogin()
	if not module.db["OfflineBag"] then return end

	SetupCache()
	UpdateAllDB()
	CreateMainFrame()
	UpdateAllBags()

	if C.db["Bags"]["Enable"] then
		module:CreateWidgetButton()
	end

	B:RegisterEvent("BAG_UPDATE", UpdateBag)
	B:RegisterEvent("BAG_CLOSED", UpdateBag)
	B:RegisterEvent("PLAYER_MONEY", SaveMoney)
	B:RegisterEvent("BANKFRAME_OPENED", Bank_Opened)
	B:RegisterEvent("BANKFRAME_CLOSED", Bank_Closed)
	B:RegisterEvent("GET_ITEM_INFO_RECEIVED", UpdateItemButtonInfo)
end

SlashCmdList["NDUI_PLUS_BAG"] = function(msg)
	if not bagFrame then return end

	B:TogglePanel(_G.NDui_Plus_BagFrame)
end
SLASH_NDUI_PLUS_BAG1 = "/ndpb"