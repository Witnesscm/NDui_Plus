local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local CH = P:GetModule("Chat")
------------------------
-- Credit: BasicChatMods
------------------------
local gsub = string.gsub

function CH:UpdateGroupInfo()
	wipe(CH.GroupNames)

	if not IsInRaid() then return end

	for i = 1, GetNumGroupMembers() do
		local name, _, subgroup = GetRaidRosterInfo(i)
		if name and subgroup then
			CH.GroupNames[name] = tostring(subgroup)
		end
	end
end

local function addRaidIndex(fullName, info, nameText)
	local name = Ambiguate(fullName, "none")
	local group = name and CH.GroupNames[name]

	if group then
		nameText = nameText..":"..group
	end

	return "|Hplayer:"..fullName..info.."|h["..nameText.."]|h"
end

function CH:UpdateRaidIndex(text, ...)
	if IsInRaid() and CH.db["RaidIndex"] then
		text = gsub(text, "|Hplayer:([^:]+)([^|Hh]+)|h%[([^:]+)%]|h", addRaidIndex)
	end

	return self.origAddMsg(self, text, ...)
end

function CH:ChatRaidIndex()
	local eventList = {
		"GROUP_ROSTER_UPDATE",
		"PLAYER_ENTERING_WORLD",
	}

	for _, event in next, eventList do
		B:RegisterEvent(event, CH.UpdateGroupInfo)
	end

	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame"..i]
			chatFrame.origAddMsg = chatFrame.AddMessage
			chatFrame.AddMessage = CH.UpdateRaidIndex
		end
	end
end