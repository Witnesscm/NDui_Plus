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

local cache = {}

local function AddChatIcon(link, linkType, id)
	if not link then return end

	if cache[link] then return cache[link] end

	local texture
	if linkType == "spell" or linkType == "enchant" or linkType == "mount" then
		texture = C_Spell.GetSpellTexture(id)
	elseif linkType == "item" or linkType == "keystone" then
		texture = C_Item.GetItemIconByID(id)
	elseif linkType == "talent" then
		texture = select(3, GetTalentInfoByID(id))
	elseif linkType == "pvptal" then
		texture = select(3, GetPvpTalentInfoByID(id))
	elseif linkType == "achievement" then
		texture = select(10, GetAchievementInfo(id))
	elseif linkType == "currency" then
		local info = C_CurrencyInfo.GetCurrencyInfo(id)
		texture = info and info.iconFileID
	elseif linkType == "battlepet" then
		texture = select(2, C_PetJournal.GetPetInfoBySpeciesID(id))
	elseif linkType == "battlePetAbil" then
		texture = select(3, C_PetBattles.GetAbilityInfoByID(id))
	elseif linkType == "azessence" then
		local info = C_AzeriteEssence.GetEssenceInfo(id)
		texture = info and info.icon
	elseif linkType == "conduit" then
		local spell = C_Soulbinds.GetConduitSpellID(id, 1)
		texture = spell and C_Spell.GetSpellTexture(spell)
	elseif linkType == "transmogappearance" then
		texture = select(4, C_TransmogCollection.GetAppearanceSourceInfo(id))
	elseif linkType == "transmogillusion" then
		local info = C_TransmogCollection.GetIllusionInfo(id)
		texture = info and info.icon
	end

	cache[link] = GetHyperlink(link, texture)

	return cache[link]
end

local function AddTradeIcon(link, id)
	if not link then return end

	if not cache[link] then
		cache[link] = GetHyperlink(link, C_Spell.GetSpellTexture(id))
	end

	return cache[link]
end

function CH:ChatLinkfilter(_, msg, ...)
	if CH.db["Icon"] then
		msg = gsub(msg, "(|c%x%x%x%x%x%x%x%x|H(%a+):(%d+).-|h.-|h.-|r)", AddChatIcon)
		msg = gsub(msg, "(|cnIQ%d:|H(%a+):(%d+).-|h.-|h.-|r)", AddChatIcon)
		msg = gsub(msg, "(|c%x%x%x%x%x%x%x%x|Htrade:[^:]-:(%d+).-|h.-|h|r)", AddTradeIcon)
	end

	return false, msg, ...
end

function CH:ChatLinkIcon()
	for _, event in pairs(CH.ChatEvents) do
		ChatFrame_AddMessageEventFilter(event, CH.ChatLinkfilter)
	end
end