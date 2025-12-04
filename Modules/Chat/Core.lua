local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local CH = P:RegisterModule("Chat")
-----------------
-- Credit: ElvUI
-----------------
CH.GuidCache = {}
CH.ClassNames = {}
CH.GroupNames = {}
CH.GroupRoles = {}

CH.ChatEvents = {
	"CHAT_MSG_BATTLEGROUND",
	"CHAT_MSG_BATTLEGROUND_LEADER",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_SAY",
	-- "CHAT_MSG_SYSTEM",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",
	"CHAT_MSG_LOOT",
	"CHAT_MSG_CURRENCY",
}

local isCalling = false
function CH:GetPlayerInfoByGUID(guid)
	if isCalling then return end

	local data = CH.GuidCache[guid]
	if not data then
		isCalling = true
		local ok, localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = pcall(GetPlayerInfoByGUID, guid)
		isCalling = false

		if not (ok and englishClass) then return end

		if realm == "" then realm = nil end
		local nameWithRealm
		if name and name ~= "" then
			nameWithRealm = (realm and name.."-"..realm) or name.."-"..DB.MyRealm
		end

		data = {
			localizedClass = localizedClass,
			englishClass = englishClass,
			localizedRace = localizedRace,
			englishRace = englishRace,
			sex = sex,
			name = name,
			realm = realm,
			nameWithRealm = nameWithRealm,
		}

		if name then
			CH.ClassNames[strlower(name)] = englishClass
		end
		if nameWithRealm then
			CH.ClassNames[strlower(nameWithRealm)] = englishClass
		end

		CH.GuidCache[guid] = data
	end

	return data
end

function CH:ClassFilter(message)
	local isFirstWord, rebuiltString

	for word in gmatch(message, "%s-%S+%s*") do
		local tempWord = gsub(word,"^[%s%p]-([^%s%p]+)([%-]?[^%s%p]-)[%s%p]*$","%1%2")
		local lowerCaseWord = strlower(tempWord)

		local classMatch = CH.ClassNames[lowerCaseWord]
		local wordMatch = classMatch and lowerCaseWord

		if wordMatch then
			local r, g, b = B.ClassColor(classMatch)
			word = gsub(word, gsub(tempWord, "%-","%%-"), format("\124cff%.2x%.2x%.2x%s\124r", r*255, g*255, b*255, tempWord))
		end

		if not isFirstWord then
			rebuiltString = word
			isFirstWord = true
		else
			rebuiltString = format("%s%s", rebuiltString, word)
		end
	end

	return rebuiltString
end

function CH:UpdateBubbleColor()
	if not CH.db["ClassColor"] then return end

	local backdrop = self.backdrop
	local str = backdrop and backdrop.String
	local text = str and str:GetText()
	local rebuiltString = text and CH:ClassFilter(text)

	if rebuiltString then
		str:SetText(RemoveExtraSpaces(rebuiltString))
	end
end

function CH:HookBubble(frame, backdrop)
	if frame.isHooked then return end

	if not frame.backdrop then
		frame.backdrop = backdrop
		frame:HookScript("OnShow", CH.UpdateBubbleColor)
		CH.UpdateBubbleColor(frame)
	end

	frame.isHooked = true
end

function CH:UpdateChatColor(_, msg, ...)
	msg = CH:ClassFilter(msg) or msg
	return false, msg, ...
end

function CH:ChatClassColor()
	if not CH.db["ClassColor"] then return end

	for _, event in pairs(CH.ChatEvents) do
		ChatFrameUtil.AddMessageEventFilter(event, CH.UpdateChatColor)
	end

	hooksecurefunc("GetPlayerInfoByGUID",function(...)
		CH:GetPlayerInfoByGUID(...)
	end)
end

function CH:OnLogin()
	self:ChatEmote()
	self:ChatClassColor()
	self:ChatRaidIndex()
	self:ChatLinkIcon()
	self:ChatHide()
end