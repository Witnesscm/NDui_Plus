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
local cancelled_rolls = {}
local completedRolls = {}
LR.RollBars = {}

local fontSize = 14
local parentFrame
local GenerateName = P.NameGenerator(addonName.."_LootRoll")

local function ClickRoll(frame)
	RollOnLoot(frame.parent.rollID, frame.rolltype)
end

local rolltypes = {[1] = "need", [2] = "greed", [3] = "disenchant", [0] = "pass"}
local function SetTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tiptext)

	local rolls = frame.parent.rolls[frame.rolltype]
	if rolls then
		for _, infoTable in next, rolls do
			local playerName, className = unpack(infoTable)
			local r, g, b = B.ClassColor(className)
			GameTooltip:AddLine(playerName, r, g, b)
		end
	end

	GameTooltip:Show()
end

local function SetItemTip(frame, event)
	if not frame.link or (event == "MODIFIER_STATE_CHANGED" and not frame:IsMouseOver()) then return end

	GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(frame.link)

	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
end

local function LootClick(frame)
	if IsModifiedClick() then
		_G.HandleModifiedItemClick(frame.link)
	end
end

local function StatusUpdate(frame, elapsed)
	if not frame.parent.rollID then return end

	if frame.elapsed and frame.elapsed > 0.1 then
		frame:SetValue(GetLootRollTimeLeft(frame.parent.rollID))
		frame.elapsed = 0
	else
		frame.elapsed = (frame.elapsed or 0) + elapsed
	end
end

local iconCoords = {
	[0] = {1.05, -0.1, 1.05, -0.1}, -- pass
	[2] = {0.05, 1.05, -0.025, 0.85}, -- greed
	[1] = {0.05, 1.05, -0.05, .95}, -- need
	[3] = {0.05, 1.05, -0.05, .95}, -- disenchant
}

local function RollTexCoords(f, icon, rolltype, minX, maxX, minY, maxY)
	local offset = icon == f.pushedTex and (rolltype == 0 and -0.05 or 0.05) or 0
	icon:SetTexCoord(minX - offset, maxX, minY - offset, maxY)

	if icon == f.disabledTex then
		icon:SetDesaturated(true)
		icon:SetAlpha(0.25)
	end
end

local function RollButtonTextures(f, texture, rolltype)
	f:SetNormalTexture(texture)
	f:SetPushedTexture(texture)
	f:SetDisabledTexture(texture)
	f:SetHighlightTexture(texture)

	f.normalTex = f:GetNormalTexture()
	f.disabledTex = f:GetDisabledTexture()
	f.pushedTex = f:GetPushedTexture()
	f.highlightTex = f:GetHighlightTexture()

	local minX, maxX, minY, maxY = unpack(iconCoords[rolltype])
	RollTexCoords(f, f.normalTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(f, f.disabledTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(f, f.pushedTex, rolltype, minX, maxX, minY, maxY)
	RollTexCoords(f, f.highlightTex, rolltype, minX, maxX, minY, maxY)
end

local function RollMouseDown(f)
	if f.highlightTex then
		f.highlightTex:SetAlpha(0)
	end
end

local function RollMouseUp(f)
	if f.highlightTex then
		f.highlightTex:SetAlpha(1)
	end
end

local function CreateRollButton(parent, texture, rolltype, tiptext, ...)
	local f = CreateFrame("Button", format("$parent_%sButton", tiptext), parent)
	f:SetPoint(...)
	f:SetWidth(LR.db["Height"] - 4)
	f:SetHeight(LR.db["Height"] - 4)
	f:SetScript("OnMouseDown", RollMouseDown)
	f:SetScript("OnMouseUp", RollMouseUp)
	f:SetScript("OnClick", ClickRoll)
	f:SetScript("OnEnter", SetTip)
	f:SetScript("OnLeave", GameTooltip_Hide)
	f:SetMotionScriptsWhileDisabled(true)
	f:SetHitRectInsets(3, 3, 3, 3)

	RollButtonTextures(f, texture.."-Up", rolltype)

	f.parent = parent
	f.rolltype = rolltype
	f.tiptext = tiptext

	f.text = f:CreateFontString(nil, nil)
	f.text:SetFont(DB.Font[1], fontSize, DB.Font[3])
	f.text:SetPoint("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)

	return f
end

function LR:CreateRollFrame(name)
	local frame = CreateFrame("Frame", name or GenerateName(), UIParent)
	frame:SetSize(LR.db["Width"], LR.db["Height"])
	frame:SetFrameStrata("MEDIUM")
	frame:SetFrameLevel(10)
	frame:Hide()

	local button = CreateFrame("Button", nil, frame)
	button:SetPoint("RIGHT", frame, "LEFT", - (C.mult*2), 0)
	button:SetSize(frame:GetHeight() - (C.mult*2), frame:GetHeight() - (C.mult*2))
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", GameTooltip_Hide)
	button:SetScript("OnClick", LootClick)
	button:SetScript("OnEnter", SetItemTip)
	frame.button = button

	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(DB.TexCoord))
	B.SetBD(button.icon)

	button.stack = button:CreateFontString(nil, "OVERLAY")
	button.stack:SetPoint("BOTTOMRIGHT", -1, 2)
	button.stack:SetFont(unpack(DB.Font))

	local status = CreateFrame("StatusBar", nil, frame)
	status:SetPoint("TOPLEFT", C.mult, -(LR.db["Style"] == 2 and frame:GetHeight() / 1.6 or C.mult))
	status:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetFrameLevel(status:GetFrameLevel()-1)
	B.CreateSB(status, true)
	status:SetStatusBarColor(.8, .8, .8, .9)
	status.parent = frame
	frame.status = status

	frame.need = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Dice]], 1, NEED, "LEFT", frame.button, "RIGHT", 6, 0)
	frame.greed = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Coin]], 2, GREED, "LEFT", frame.need, "RIGHT", 3, 0)
	frame.disenchant = enableDisenchant and CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-DE]], 3, ROLL_DISENCHANT, "LEFT", frame.greed, "RIGHT", 3, 0)
	frame.pass = CreateRollButton(frame, [[Interface\Buttons\UI-GroupLoot-Pass]], 0, PASS, "LEFT", frame.disenchant or frame.greed, "RIGHT", 3, 0)

	local bind = frame:CreateFontString()
	bind:SetPoint("LEFT", frame.pass, "RIGHT", 3, 0)
	bind:SetFont(DB.Font[1], fontSize, DB.Font[3])
	frame.fsbind = bind

	local loot = frame:CreateFontString(nil, "ARTWORK")
	loot:SetFont(DB.Font[1], fontSize, DB.Font[3])
	loot:SetPoint("LEFT", bind, "RIGHT", 0, 0)
	loot:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
	loot:SetSize(200, 10)
	loot:SetJustifyH("LEFT")
	frame.fsloot = loot

	frame.rolls = {}

	return frame
end

local function GetFrame()
	for _, f in next, LR.RollBars do
		if not f.rollID then
			return f
		end
	end

	local f = LR:CreateRollFrame()
	if next(LR.RollBars) then
		if LR.db["Direction"] == 2 then
			f:SetPoint("TOP", LR.RollBars[#LR.RollBars], "BOTTOM", 0, -4)
		else
			f:SetPoint("BOTTOM", LR.RollBars[#LR.RollBars], "TOP", 0, 4)
		end
	else
		f:SetPoint("TOP", parentFrame, "TOP")
	end

	tinsert(LR.RollBars, f)
	return f
end

function LR:LootRoll_Start(rollID, rollTime)
	if cancelled_rolls[rollID] then return end
	local link = GetLootRollItemLink(rollID)
	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired = GetLootRollItemInfo(rollID)
	local color = ITEM_QUALITY_COLORS[quality]

	local f = GetFrame()
	wipe(f.rolls)
	f.rollID = rollID
	f.time = rollTime

	f.button.icon:SetTexture(texture)
	f.button.stack:SetText(count > 1 and count or "")
	f.button.link = link
	f.button:RegisterEvent("MODIFIER_STATE_CHANGED")

	f.need.text:SetText(0)
	f.greed.text:SetText(0)
	f.pass.text:SetText(0)

	if canNeed then
		f.need:Enable()
		f.need.tiptext = NEED
	else
		f.need:Disable()
		f.need.tiptext = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonNeed]
	end

	if canGreed then
		f.greed:Enable()
		f.greed.tiptext = GREED
	else
		f.greed:Disable()
		f.greed.tiptext = _G["LOOT_ROLL_INELIGIBLE_REASON"..reasonGreed]
	end

	if f.disenchant then
		f.disenchant.text:SetText(0)
		if canDisenchant then
			f.disenchant:Enable()
			f.disenchant.tiptext = ROLL_DISENCHANT
		else
			f.disenchant:Disable()
			f.disenchant.tiptext = format(_G["LOOT_ROLL_INELIGIBLE_REASON"..reasonDisenchant], deSkillRequired)
		end
	end

	f.fsbind:SetText(bop and "BoP" or "BoE")
	f.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)
	f.fsloot:SetText(name)
	f.status.elapsed = 1
	f.status:SetStatusBarColor(color.r, color.g, color.b, .7)
	f.status:SetMinMaxValues(0, rollTime)
	f.status:SetValue(rollTime)

	f:Show()

	for rollid, rollTable in pairs(cachedRolls) do
		if f.rollID == rollid then
			for rollType, rollerInfo in pairs(rollTable) do
				local rollerName, class = rollerInfo[1], rollerInfo[2]
				if not f.rolls[rollType] then f.rolls[rollType] = {} end
				tinsert(f.rolls[rollType], { rollerName, class })
				f[rolltypes[rollType]].text:SetText(#f.rolls[rollType])
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
		for _, f in next, LR.RollBars do
			if f.rollID == rollID then
				if not f.rolls[rollType] then f.rolls[rollType] = {} end
				tinsert(f.rolls[rollType], { name, class })
				f[rolltypes[rollType]].text:SetText(#f.rolls[rollType])
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

function LR:LootRoll_Cancel(rollID)
	cancelled_rolls[rollID] = true

	for _, bar in next, LR.RollBars do
		if bar.rollID == rollID then
			bar.rollID = nil
			bar.time = nil
			bar:Hide()
			bar.button:UnregisterAllEvents()
		end
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
	B:RegisterEvent("CANCEL_LOOT_ROLL", self.LootRoll_Cancel)

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

	testFrame = LR:CreateRollFrame("NDuiPlus_LootRoll")
	testFrame:Show()
	testFrame:SetPoint("TOP", parentFrame, "TOP")
	testFrame.need:SetScript("OnClick", OnClick_Hide)
	testFrame.greed:SetScript("OnClick", OnClick_Hide)
	testFrame.pass:SetScript("OnClick", OnClick_Hide)

	local itemID = 17103
	local bop = 1
	local name, link, quality, _, _, _, _, _, _, icon = GetItemInfo(itemID)
	if not name then
		name, link, quality, icon = "碧空之歌", "|cffa335ee|Hitem:17103::::::::17:::::::|h[碧空之歌]|h|r", 4, 135349
	end
	testFrame.button.icon:SetTexture(icon)
	testFrame.button.link = link
	testFrame.fsloot:SetText(name)
	testFrame.fsbind:SetText(bop and "BoP" or "BoE")
	testFrame.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

	local color = ITEM_QUALITY_COLORS[quality]
	testFrame.status:SetStatusBarColor(color.r, color.g, color.b, .7)
	testFrame.status:SetMinMaxValues(0, 100)
	testFrame.status:SetValue(80)
end

function LR:UpdateLootRollTest()
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
end

SlashCmdList["NDUI_TEKS"] = function()
	LR:LootRollTest()
end
SLASH_NDUI_TEKS1 = "/teks"