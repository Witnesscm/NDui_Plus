local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local PET_CAGE = 82800

local qualityColors = {}
for index, value in pairs(DB.QualityColors) do
	qualityColors[index] = {r = value.r, g = value.g, b = value.b}
end
qualityColors[Enum.ItemQuality.Common] = {r = 1, g = 1, b = 1}

function M:ItemLevel_UpdateGuildBank(tab, index)
	if not self.iLvl then
		self.iLvl = B.CreateFS(self, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
	end

	local level, quality
	local link = GetGuildBankItemLink(tab, index)
	local itemID = link and strmatch(link, "Hitem:(%d+):")
	itemID = tonumber(itemID)

	if itemID then
		if itemID == PET_CAGE then
			local data = C_TooltipInfo.GetGuildBankItem(tab, index)
			if data then
				local speciesID, petLevel, breedQuality = data.battlePetSpeciesID, data.battlePetLevel, data.battlePetBreedQuality
				if speciesID and speciesID > 0 then
					level, quality = petLevel, breedQuality
				end
			end
		else
			level = B.GetItemLevel(link)
			quality = select(3, C_Item.GetItemInfo(link))
		end
	end

	if level and quality then
		local color = qualityColors[quality]
		self.iLvl:SetText(level)
		self.iLvl:SetTextColor(color.r, color.g, color.b)

		if self.bg and itemID == PET_CAGE then
			self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	else
		self.iLvl:SetText("")
	end
end

function M:ItemLevel_GuildBank()
	if not M.db["GuildBankItemLevel"] then return end

	hooksecurefunc(_G.GuildBankFrame, "Update", function(self)
		if self.mode == "bank" then
			local tab = GetCurrentGuildBankTab()
			local button, index, column
			for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
				index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
				if index == 0 then
					index = NUM_SLOTS_PER_GUILDBANK_GROUP
				end
				column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
				button = self.Columns[column].Buttons[index]

				if button and button:IsShown() then
					M.ItemLevel_UpdateGuildBank(button, tab, i)
				end
			end
		end
	end)
end

function M:ItemLevel()
	-- iLvl on GuildBankFrame
	P:AddCallbackForAddon("Blizzard_GuildBankUI", M.ItemLevel_GuildBank)
end

M:RegisterMisc("ItemLevel", M.ItemLevel)