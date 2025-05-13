local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local rollQueue = {}

local function ProcessNextRoll()
	if #rollQueue > 0 then
		local roll = tremove(rollQueue, 1)
		pcall(RollOnLoot, roll[1], roll[2])

		C_Timer.After(.3, ProcessNextRoll)
	end
end

function M:AutoRoll_OnEvent(rollID)
	local autoRoll = M.db["AutoRoll"]
	if autoRoll == 3 then return end

	local _, name, _, _, _, canNeed, canGreed, _, _, _, _, _, canTransmog = GetLootRollItemInfo(rollID)
	if not name then return end

	local rollType = 0
	if autoRoll == 1 then
		if canNeed then
			rollType = 1
		elseif canTransmog then
			rollType = 4
		elseif canGreed then
			rollType = 2
		end
	end

	if not next(rollQueue) then
		C_Timer.After(1, ProcessNextRoll)
	end

	tinsert(rollQueue, { rollID, rollType })
end

local options = {
	{text = P.AtlasString("lootroll-toast-icon-need-up").." "..NEED, icon = 130772, size = 20},
	{text = P.AtlasString("lootroll-toast-icon-pass-up").." "..PASS, icon = 130775, size = 20},
	{text = DISABLE, icon = 616343, size = 30},
}

local function UpdateButtonIcon(bu)
	local option = options[M.db["AutoRoll"]]
	bu:SetSize(option.size, option.size)
	bu.Icon:SetTexture(option.icon)
	bu:SetHighlightTexture(option.icon)
end

function M:AutoRoll_CreateButton()
	local bu = CreateFrame("Button", nil, GroupLootHistoryFrame)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	UpdateButtonIcon(bu)
	bu:SetPoint("CENTER", GroupLootHistoryFrame.ClosePanelButton, "LEFT", -14, 0)
	B.AddTooltip(bu, "ANCHOR_RIGHT", L["Auto Roll"], "info")

	local menuList = {}
	for i, option in ipairs(options) do
		tinsert(menuList, {
			text = option.text,
			func = function()
				M.db["AutoRoll"] = i
				UpdateButtonIcon(bu)
			end,
			checked = function()
				return i == M.db["AutoRoll"]
			end
		})
	end

	bu:SetScript("OnClick", function()
		P:EasyMenu(menuList, bu)
	end)
end

function M:AutoRoll()
	M:AutoRoll_CreateButton()
	B:RegisterEvent("START_LOOT_ROLL", M.AutoRoll_OnEvent)
end

M:RegisterMisc("AutoRoll", M.AutoRoll)