local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local CH = P:GetModule("Chat")
------------------------
-- Credit: BasicChatMods
------------------------
local gsub = string.gsub

function CH:UpdateGroupInfo()
	wipe(CH.GroupNames)
	wipe(CH.GroupRoles)

	if not IsInGroup() then return end

	for i = 1, GetNumGroupMembers() do
		local name, _, subgroup, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)
		if name and subgroup and role then
			CH.GroupNames[name] = tostring(subgroup)
			CH.GroupRoles[name] = role
		end
	end
end

local function addRaidIndex(fullName, info, nameText)
	local name = Ambiguate(fullName, "none")
	local group = name and CH.GroupNames[name]
	local role = name and CH.GroupRoles[name]
	local icon = CH.db["Role"] and role and CH.RolePaths[role] or ""

	if group and IsInRaid() and CH.db["RaidIndex"] then
		nameText = nameText..":"..group
	end

	return "|Hplayer:"..fullName..info.."|h"..icon.."["..nameText.."]|h"
end

function CH:UpdateRaidIndex(text, ...)
	if IsInGroup() and (CH.db["RaidIndex"] or CH.db["Role"]) then
		text = gsub(text, "|Hplayer:([^:]+)([^|Hh]+)|h%[([^:]+)%]|h", addRaidIndex)
	end

	return self.origAddMsg(self, text, ...)
end

function CH:ChatRaidIndex()
	local roleList = P.RoleList[NDuiPlusDB["RoleStyle"]["Index"]]
	CH.RolePaths = {
		TANK = P.TextureString(roleList.TANK, ":16:16"),
		HEALER = P.TextureString(roleList.HEALER, ":16:16"),
		DAMAGER = P.TextureString(roleList.DAMAGER, ":16:16")
	}

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