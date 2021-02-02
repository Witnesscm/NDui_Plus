local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local CH = P:GetModule("Chat")
----------------------------
-- TinyChat, Author:M
----------------------------
local function GetHyperlink(Hyperlink, texture)
	if (not texture) then
		return Hyperlink
	else
		return "|T" .. texture .. ":0:0:0:0:64:64:5:59:5:59|t" .. Hyperlink
	end
end

local function AddChatIcon(Hyperlink)
	local schema, id = strmatch(Hyperlink, "|H(%w+):(%d+):")
	if not id then return end

	local texture
	if schema == "item" then
		texture = select(10, GetItemInfo(tonumber(id)))
	elseif schema == "spell" then
		texture = select(3, GetSpellInfo(tonumber(id)))
	elseif schema == "achievement" then
		texture = select(10, GetAchievementInfo(tonumber(id)))
	end

	return GetHyperlink(Hyperlink, texture)
end

local function AddEnchantIcon(Hyperlink)
	local id = strmatch(Hyperlink, "Henchant:(%d-)|")
	if not id then return end

	return GetHyperlink(Hyperlink, GetSpellTexture(tonumber(id)))
end

local function AddTalentIcon(Hyperlink)
	local schema, id = strmatch(Hyperlink, "H(%w+):(%d-)|")
	if not id then return end

	local texture
	if schema == "talent" then
		texture = select(3, GetTalentInfoByID(tonumber(id)))
	elseif schema == "pvptal" then
		texture = select(3, GetPvpTalentInfoByID(tonumber(id)))
	end

	return GetHyperlink(Hyperlink, texture)
end

local function AddTradeIcon(Hyperlink)
	local id = strmatch(Hyperlink, "Htrade:[^:]-:(%d+)")
	if not id then return end

	return GetHyperlink(Hyperlink, GetSpellTexture(tonumber(id)))
end

function CH:ChatLinkfilter(event, msg, ...)
	if NDuiPlusDB["Chat"]["Icon"] then
		msg = gsub(msg, "(|H%w+:%d+:.-|h.-|h)", AddChatIcon)
		msg = gsub(msg, "(|Henchant:%d+|h.-|h)", AddEnchantIcon)
		msg = gsub(msg, "(|H%w+:%d+|h.-|h)", AddTalentIcon)
		msg = gsub(msg, "(|Htrade:.+:%d+|h.-|h)", AddTradeIcon)
	end

	return false, msg, ...
end

function CH:ChatLinkIcon()
	for _, event in pairs(CH.ChatEvents) do
		ChatFrame_AddMessageEventFilter(event, CH.ChatLinkfilter)
	end

	-- fix send message
	hooksecurefunc("ChatEdit_OnTextChanged", function(self, userInput)
		local text = self:GetText()
		if userInput and NDuiPlusDB["Chat"]["Icon"] then
			local newText, count = gsub(text, "|T.+|t", "")
			if count > 0 then
				self:SetText(newText)
			end
		end
	end)
end