local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local CH = P:GetModule("Chat")
----------------------
-- Credit: TinyChat
----------------------
local function GetHyperlink(hyperlink, texture)
	if (not texture) then
		return hyperlink
	else
		return "|T" .. texture .. ":0:0:0:0:64:64:5:59:5:59|t" .. hyperlink
	end
end

local tip = B.ScanTip
local talentLink = "talent:%d:0"

local function GetTalentIconByID(id)
	tip:SetOwner(UIParent, "ANCHOR_NONE")
	tip:SetHyperlink(format(talentLink, id))

	local _, spell = tip:GetSpell()
	if spell then
		return GetSpellTexture(spell)
	end
end

local honorTextures = {
	[136998] = "Interface\\PVPFrame\\PVP-Currency-Alliance",
	[137000] = "Interface\\PVPFrame\\PVP-Currency-Horde",
}

local function GetCurrencyIconByID(id)
	local info = C_CurrencyInfo.GetCurrencyInfo(id)
	local icon = info and info.iconFileID

	return honorTextures[icon] or icon
end

local cache = {}

local function AddChatIcon(link, linkType, id)
	if not link then return end

	if cache[link] then return cache[link] end

	local texture
	if linkType == "spell" or linkType == "enchant" then
		texture = GetSpellTexture(id)
	elseif linkType == "item" then
		texture = GetItemIcon(id)
	elseif linkType == "talent" then
		texture = GetTalentIconByID(id)
	elseif linkType == "achievement" then
		texture = select(10, GetAchievementInfo(id))
	elseif linkType == "currency" then
		texture = GetCurrencyIconByID(id)
	end

	cache[link] = GetHyperlink(link, texture)

	return cache[link]
end

local function AddTradeIcon(link, id)
	if not link then return end

	if not cache[link] then
		cache[link] = GetHyperlink(link, GetSpellTexture(id))
	end

	return cache[link]
end

function CH:ChatLinkfilter(_, msg, ...)
	if CH.db["Icon"] then
		msg = gsub(msg, "(|c%x%x%x%x%x%x%x%x|H(%a+):(%d+).-|h.-|h.-|r)", AddChatIcon)
		msg = gsub(msg, "(|c%x%x%x%x%x%x%x%x|Htrade:[^:]-:(%d+).-|h.-|h.-|r)", AddTradeIcon)
	end

	return false, msg, ...
end

function CH:ChatLinkIcon()
	for _, event in pairs(CH.ChatEvents) do
		ChatFrame_AddMessageEventFilter(event, CH.ChatLinkfilter)
	end
end