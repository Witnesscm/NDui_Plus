local addonName, ns = ...
local B, C, L, DB, P = unpack(ns)
local LR = P:RegisterModule("LootRoll")
-------------------------
-- Credit: ElvUI teksLoot
-------------------------
--Lua functions
local _G = _G
local pairs, unpack, next = pairs, unpack, next
local wipe, tinsert, format = wipe, tinsert, format
--WoW API / Variables
local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local GameTooltip = GameTooltip
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown
local RollOnLoot = RollOnLoot

local GameTooltip_Hide = GameTooltip_Hide
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem

local C_LootHistory_GetItem = C_LootHistory.GetItem
local C_LootHistory_GetPlayerInfo = C_LootHistory.GetPlayerInfo
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GREED, NEED, PASS = GREED, NEED, PASS
local ROLL_DISENCHANT = ROLL_DISENCHANT

local enableDisenchant = false

local cachedRolls = {}
local completedRolls = {}
LR.RollBars = {}

local fontSize = 14
local parentFrame
local GenerateName = P.NameGenerator(addonName.."_LootRoll")

local function ClickRoll(button)
	RollOnLoot(button.parent.rollID, button.rolltype)
end

local rolltypes = {[1] = "need", [2] = "greed", [3] = "disenchant", [0] = "pass"}
local function SetTip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:AddLine(button.tiptext)

	local rolls = button.parent.rolls[button.rolltype]
	if rolls then
		for _, infoTable in next, rolls do
			local playerName, className = unpack(infoTable)
			local r, g, b = B.ClassColor(className)
			GameTooltip:AddLine(playerName, r, g, b)
		end
	end

	GameTooltip:Show()
end

local function SetItemTip(button, event)
	if not button.link or (event == "MODIFIER_STATE_CHANGED" and not button:IsMouseOver()) then return end

	GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(button.link)

	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
end

local function LootClick(button)
	if IsModifiedClick() then
		_G.HandleModifiedItemClick(button.link)
	end
end

local function StatusUpdate(button, elapsed)
	local bar = button.parent
	if not bar.rollID then
		if not bar.isTest then
			bar:Hide()
		end

		return
	end

	if button.elapsed and button.elapsed > 0.1 then
		local timeLeft = GetLootRollTimeLeft(bar.rollID)
		if timeLeft <= 0 then -- workaround for other addons auto-passing loot
			LR.LootRoll_Cancel(bar, nil, bar.rollID)
		else
			button:SetValue(timeLeft)
			button.elapsed = 0
		end
	else
		button.elapsed = (button.elapsed or 0) + elapsed
	end
end

local iconCoords = {
	[0] = {1.05, -0.1, 1.05, -0.1}, -- pass
	[2] = {0.05, 1.05, -0.025, 0.85}, -- greed
	[1] = {0.05, 1.05, -0.05, .95}, -- need
	[3] = {0.05, 1.05, -0.05, .95}, -- disenchant
}

local function RollTexCoords(button, icon, rolltype, minX, maxX, minY, maxY)
	local offset = icon == button.pushedTex and (rolltype == 0 and -0.05 or 0.05) or 0
	icon:SetTexCoord(minX - offset, maxX, minY - offset, maxY)

	if icon == button.disabledTex then
		icon:SetDesaturated(true)
		icon:SetAlpha(0.25)
	end
end

local function RollButtonTextures(button, texture, rolltype)
	button:SetNormalTexture(texture)
	button:SetPushedTexture(texture)
	button:SetDisabledTexture(texture)
	button:SetHighlightTexture(texture)

	button.normalTex = button:GetNormalTexture()
	button.disabledTex = button:GetDisabledTexture()
	button.pushedTex = button:GetPushedTexture()
	button.highlightTex = button:GetHighlightTexture()

	local minX, maxX, minY, maxY = unpack(iconCoords[rolltype])
	RollTexCoords(button, button.normalTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(button, button.disabledTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(button, button.pushedTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(button, button.highlightTex, rolltype, minX, maxX, minY, maxY)
end

local function RollMouseDown(button)
	if button.highlightTex then
		button.highlightTex:SetAlpha(0)
	end
end

local function RollMouseUp(button)
	if button.highlightTex then
		button.highlightTex:SetAlpha(1)
	end
end

local function CreateRollButton(parent, texture, rolltype, tiptext, ...)
	local button = CreateFrame("Button", format("$parent_%sButton", tiptext), parent)
	button:SetPoint(...)
	button:SetWidth(LR.db["Height"] - 4)
	button:SetHeight(LR.db["Height"] - 4)
	button:SetScript("OnMouseDown", RollMouseDown)
	button:SetScript("OnMouseUp", RollMouseUp)
	button:SetScript("OnClick", ClickRoll)
	button:SetScript("OnEnter", SetTip)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button:SetMotionScriptsWhileDisabled(true)
	button:SetHitRectInsets(3, 3, 3, 3)

	RollButtonTextures(button, texture.."-Up", rolltype)

	button.parent = parent
	button.rolltype = rolltype
	button.tiptext = tiptext

	button.text = button:CreateFontString(nil, nil)
	button.text:SetFont(DB.Font[1], fontSize, DB.Font[3])
	button.text:SetPoint("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)

	return button
end

function LR:CreateRollBar(name)
	local bar = CreateFrame("Frame", name or GenerateName(), UIParent)
	bar:SetSize(LR.db["Width"], LR.db["Height"])
	bar:SetFrameStrata("MEDIUM")
	bar:SetFrameLevel(10)
	bar:SetScript("OnEvent", LR.LootRoll_Cancel)
	bar:RegisterEvent("CANCEL_LOOT_ROLL")
	bar:Hide()

	local button = CreateFrame("Button", nil, bar)
	button:SetPoint("RIGHT", bar, "LEFT", - (C.mult*2), 0)
	button:SetSize(bar:GetHeight() - (C.mult*2), bar:GetHeight() - (C.mult*2))
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button:SetScript("OnClick", LootClick)
	button:SetScript("OnEvent", SetItemTip)
	button:RegisterEvent("MODIFIER_STATE_CHANGED")
	bar.button = button

	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(DB.TexCoord))
	button.bg = B.SetBD(button.icon)

	button.stack = button:CreateFontString(nil, "OVERLAY")
	button.stack:SetPoint("BOTTOMRIGHT", -1, 2)
	button.stack:SetFont(unpack(DB.Font))

	button.ilvl = button:CreateFontString(nil, "OVERLAY")
	button.ilvl:SetPoint("BOTTOMLEFT", 1, 1)
	button.ilvl:SetFont(DB.Font[1], fontSize - 2, DB.Font[3])

	local status = CreateFrame("StatusBar", nil, bar)
	status:SetPoint("TOPLEFT", C.mult, -(LR.db["Style"] == 2 and bar:GetHeight() / 1.6 or C.mult))
	status:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetFrameLevel(status:GetFrameLevel()-1)
	B.CreateSB(status, true)
	status:SetStatusBarColor(.8, .8, .8, .9)
	status.parent = bar
	bar.status = status

	bar.need = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Dice]], 1, NEED, "LEFT", bar.button, "RIGHT", 6, 0)
	bar.greed = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Coin]], 2, GREED, "LEFT", bar.need, "RIGHT", 3, 0)
	bar.disenchant = enableDisenchant and CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-DE]], 3, ROLL_DISENCHANT, "LEFT", bar.greed, "RIGHT", 3, 0)
	bar.pass = CreateRollButton(bar, [[Interface\Buttons\UI-GroupLoot-Pass]], 0, PASS, "LEFT", bar.disenchant or bar.greed, "RIGHT", 3, 0)

	local bind = bar:CreateFontString()
	bind:SetPoint("LEFT", bar.pass, "RIGHT", 3, 0)
	bind:SetFont(DB.Font[1], fontSize, DB.Font[3])
	bar.fsbind = bind

	local loot = bar:CreateFontString(nil, "ARTWORK")
	loot:SetFont(DB.Font[1], fontSize, DB.Font[3])
	loot:SetPoint("LEFT", bind, "RIGHT", 0, 0)
	loot:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
	loot:SetSize(200, 10)
	loot:SetJustifyH("LEFT")
	bar.fsloot = loot

	bar.rolls = {}

	return bar
end

local function GetFrame()
	for _, bar in next, LR.RollBars do
		if not bar.rollID then
			return bar
		end
	end

	local bar = LR:CreateRollBar()
	if next(LR.RollBars) then
		if LR.db["Direction"] == 2 then
			bar:SetPoint("TOP", LR.RollBars[#LR.RollBars], "BOTTOM", 0, -4)
		else
			bar:SetPoint("BOTTOM", LR.RollBars[#LR.RollBars], "TOP", 0, 4)
		end
	else
		bar:SetPoint("TOP", parentFrame, "TOP")
	end

	tinsert(LR.RollBars, bar)
	return bar
end

function LR:LootRoll_Start(rollID, rollTime)
	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired = GetLootRollItemInfo(rollID)
	if not name then
		for _, rollBar in next, LR.RollBars do
			if rollBar.rollID == rollID then
				LR.LootRoll_Cancel(rollBar, nil, rollID)
			end
		end

		return
	end

	local link = GetLootRollItemLink(rollID)
	local level = B.GetItemLevel(link)
	local color = ITEM_QUALITY_COLORS[quality]

	local bar = GetFrame()
	if not bar then return end

	wipe(bar.rolls)
	bar.rollID = rollID
	bar.time = rollTime

	bar.button.icon:SetTexture(texture)
	bar.button.stack:SetText(count > 1 and count or "")
	bar.button.ilvl:SetText(LR.db["ItemLevel"] and level or "")
	bar.button.ilvl:SetTextColor(color.r, color.g, color.b)
	bar.button.link = link

	if LR.db["ItemQuality"] then
		bar.button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		bar.button.bg:SetBackdropBorderColor(0, 0, 0)
	end

	bar.need.text:SetText(0)
	bar.greed.text:SetText(0)
	bar.pass.text:SetText(0)

	if canNeed then
		bar.need:Enable()
		bar.need.tiptext = NEED
	else
		bar.need:Disable()
		bar.need.tiptext = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonNeed]
	end

	if canGreed then
		bar.greed:Enable()
		bar.greed.tiptext = GREED
	else
		bar.greed:Disable()
		bar.greed.tiptext = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonGreed]
	end

	if bar.disenchant then
		bar.disenchant.text:SetText(0)
		if canDisenchant then
			bar.disenchant:Enable()
			bar.disenchant.tiptext = ROLL_DISENCHANT
		else
			bar.disenchant:Disable()
			bar.disenchant.tiptext = format(_G["LOOT_ROLL_INELIGIBLE_REASON"..reasonDisenchant], deSkillRequired)
		end
	end

	bar.fsbind:SetText(bop and "BoP" or "BoE")
	bar.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)
	bar.fsloot:SetText(name)
	bar.status.elapsed = 1
	bar.status:SetStatusBarColor(color.r, color.g, color.b, .7)
	bar.status:SetMinMaxValues(0, rollTime)
	bar.status:SetValue(rollTime)

	bar:Show()

	for rollid, rollTable in pairs(cachedRolls) do
		if bar.rollID == rollid then
			for rollType, rollerInfo in pairs(rollTable) do
				local rollerName, class = rollerInfo[1], rollerInfo[2]
				if not bar.rolls[rollType] then bar.rolls[rollType] = {} end
				tinsert(bar.rolls[rollType], { rollerName, class })
				bar[rolltypes[rollType]].text:SetText(#bar.rolls[rollType])
			end

			completedRolls[rollid] = true
			break
		end
	end
end

function LR:LootRoll_Update(itemIdx, playerIdx)
	local rollID = C_LootHistory_GetItem(itemIdx)
	local name, class, rollType = C_LootHistory_GetPlayerInfo(itemIdx, playerIdx)

	local rollIsHidden = true
	if name and rollType then
		for _, bar in next, LR.RollBars do
			if bar.rollID == rollID then
				if not bar.rolls[rollType] then bar.rolls[rollType] = {} end
				tinsert(bar.rolls[rollType], { name, class })
				bar[rolltypes[rollType]].text:SetText(#bar.rolls[rollType])
				rollIsHidden = false
				break
			end
		end

		if rollIsHidden then
			if not cachedRolls[rollID] then cachedRolls[rollID] = {} end
			if not cachedRolls[rollID][rollType] then
				if not cachedRolls[rollID][rollType] then cachedRolls[rollID][rollType] = {} end
				tinsert(cachedRolls[rollID][rollType], { name, class })
			end
		end
	end
end

function LR:LootRoll_Complete()
	wipe(cachedRolls)
	wipe(completedRolls)
end

function LR:LootRoll_Cancel(_, rollID)
	if self.rollID == rollID then
		self.rollID = nil
		self.time = nil
	end
end

function LR:OnLogin()
	if not LR.db["Enable"] then return end

	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetSize(LR.db["Width"], LR.db["Height"])
	B.Mover(parentFrame, L["teksLoot LootRoll"], "teksLoot", {"TOP", UIParent, 0, -200})
	fontSize = LR.db["Height"] / 2

	B:RegisterEvent("LOOT_HISTORY_ROLL_CHANGED", self.LootRoll_Update)
	B:RegisterEvent("LOOT_HISTORY_ROLL_COMPLETE", self.LootRoll_Complete)
	B:RegisterEvent("LOOT_ROLLS_COMPLETE", self.LootRoll_Complete)
	B:RegisterEvent("START_LOOT_ROLL", self.LootRoll_Start)

	_G.UIParent:UnregisterEvent("START_LOOT_ROLL")
	_G.UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")
end

local testFrame
local function OnClick_Hide(self)
	self:GetParent():Hide()
end

function LR:LootRollTest()
	if not parentFrame then return end

	if testFrame then
		if testFrame:IsShown() then
			testFrame:Hide()
		else
			testFrame:Show()
		end
		return
	end

	testFrame = LR:CreateRollBar("NDuiPlus_LootRoll")
	testFrame.isTest = true
	testFrame:Show()
	testFrame:SetPoint("TOP", parentFrame, "TOP")
	testFrame.need:SetScript("OnClick", OnClick_Hide)
	testFrame.greed:SetScript("OnClick", OnClick_Hide)
	testFrame.pass:SetScript("OnClick", OnClick_Hide)

	local itemID = 17103
	local bop = 1
	local name, link, quality, itemLevel, _, _, _, _, _, icon = GetItemInfo(itemID)
	if not name then
		name, link, quality, itemLevel, icon = "碧空之歌", "|cffa335ee|Hitem:17103::::::::17:::::::|h[碧空之歌]|h|r", 4, 29, 135349
	end
	local color = ITEM_QUALITY_COLORS[quality]
	testFrame.button.icon:SetTexture(icon)
	testFrame.button.link = link
	testFrame.fsloot:SetText(name)
	testFrame.fsbind:SetText(bop and "BoP" or "BoE")
	testFrame.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

	testFrame.status:SetStatusBarColor(color.r, color.g, color.b, .7)
	testFrame.status:SetMinMaxValues(0, 100)
	testFrame.status:SetValue(80)

	testFrame.button.itemLevel = itemLevel
	testFrame.button.color = color
	testFrame.button.ilvl:SetText(LR.db["ItemLevel"] and itemLevel or "")
	testFrame.button.ilvl:SetTextColor(color.r, color.g, color.b)

	if LR.db["ItemQuality"] then
		testFrame.button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		testFrame.button.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

function LR:UpdateLootRollTest()
	if not parentFrame then return end

	if not testFrame then
		LR:LootRollTest()
	end

	local width, height = LR.db["Width"], LR.db["Height"]
	testFrame:Show()
	testFrame:SetSize(width, height)
	testFrame.button:SetSize(height - (C.mult*2), height - (C.mult*2))
	testFrame.fsbind:SetFont(DB.Font[1], height / 2, DB.Font[3])
	testFrame.fsloot:SetFont(DB.Font[1], height / 2, DB.Font[3])
	testFrame.need:SetSize(height-4, height-4)
	testFrame.greed:SetSize(height-4, height-4)
	testFrame.pass:SetSize(height-4, height-4)
	testFrame.status:SetPoint("TOPLEFT", C.mult, -(LR.db["Style"] == 2 and testFrame:GetHeight() / 1.6 or C.mult))

	local itemLevel, color = testFrame.button.itemLevel, testFrame.button.color
	testFrame.button.ilvl:SetText(LR.db["ItemLevel"] and itemLevel or "")
	testFrame.button.ilvl:SetFont(DB.Font[1], height / 2 - 2, DB.Font[3])

	if LR.db["ItemQuality"] then
		testFrame.button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		testFrame.button.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

SlashCmdList["NDUI_TEKS"] = function()
	LR:LootRollTest()
end
SLASH_NDUI_TEKS1 = "/teks"