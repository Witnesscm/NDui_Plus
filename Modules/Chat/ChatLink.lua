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

local TEXTURE_GETTERS = {
	spell = C_Spell.GetSpellTexture,
	enchant = C_Spell.GetSpellTexture,
	mount = C_Spell.GetSpellTexture,
	item = C_Item.GetItemIconByID,
	keystone = C_Item.GetItemIconByID,
	talent = function(id) return select(3, GetTalentInfoByID(id)) end,
	talentbuild = function(id) return select(4, GetSpecializationInfoByID(id)) end,
	pvptal = function(id) return select(3, GetPvpTalentInfoByID(id)) end,
	achievement = function(id) return select(10, GetAchievementInfo(id)) end,
	currency = function(id)
		local info = C_CurrencyInfo.GetCurrencyInfo(id)
		return info and info.iconFileID
	end,
	battlepet = function(id) return select(2, C_PetJournal.GetPetInfoBySpeciesID(id)) end,
	battlePetAbil = function(id) return select(3, C_PetBattles.GetAbilityInfoByID(id)) end,
	azessence = function(id)
		local info = C_AzeriteEssence.GetEssenceInfo(id)
		return info and info.icon
	end,
	conduit = function(id)
		local spell = C_Soulbinds.GetConduitSpellID(id, 1)
		return spell and C_Spell.GetSpellTexture(spell)
	end,
	transmogappearance = function(id)
		return select(4, C_TransmogCollection.GetAppearanceSourceInfo(id))
	end,
	transmogillusion = function(id)
		local info = C_TransmogCollection.GetIllusionInfo(id)
		return info and info.icon
	end
}

local cache = {}

local function AddChatIcon(link, linkType, id)
	if not link then return end

	if not cache[link] then
		local texture = TEXTURE_GETTERS[linkType] and TEXTURE_GETTERS[linkType](tonumber(id))
		if texture then
			cache[link] = GetHyperlink(link, texture)
		end
	end

	return cache[link] or link
end

local function AddTradeIcon(link, id)
	if not link then return end

	if not cache[link] then
		cache[link] = GetHyperlink(link, C_Spell.GetSpellTexture(id))
	end

	return cache[link]
end

local function AddJournalIcon(link, id)
	if not link then return end

	if not cache[link] then
		local info = C_EncounterJournal.GetSectionInfo(id)
		local texture = info and info.abilityIcon
		cache[link] = GetHyperlink(link, texture)
	end

	return cache[link]
end

function CH:ChatLinkfilter(_, msg, ...)
	if CH.db["Icon"] then
		msg = gsub(msg, "(|c%x%x%x%x%x%x%x%x|H(%a+):(%d+).-|h.-|h.-|r)", AddChatIcon)
		msg = gsub(msg, "(|cnIQ%d:|H(%a+):(%d+).-|h.-|h.-|r)", AddChatIcon)
		msg = gsub(msg, "(|c%x%x%x%x%x%x%x%x|Htrade:[^:]-:(%d+).-|h.-|h|r)", AddTradeIcon)
		msg = gsub(msg, "(|c%x%x%x%x%x%x%x%x|Hjournal:2:(%d+):.-|h.-|h|r)", AddJournalIcon)
	end

	return false, msg, ...
end

function CH:ChatLinkIcon()
	for _, event in pairs(CH.ChatEvents) do
		ChatFrameUtil.AddMessageEventFilter(event, CH.ChatLinkfilter)
	end
end