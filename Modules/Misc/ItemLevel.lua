local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14

function M:ItemLevel_Update(link)
	if not self.iLvl then
		self.iLvl = B.CreateFS(self, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
	end

	local quality = link and select(3, GetItemInfo(link))
	if quality then
		local level = B.GetItemLevel(link)
		local color = DB.QualityColors[quality]
		self.iLvl:SetText(level)
		self.iLvl:SetTextColor(color.r, color.g, color.b)
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

				M.ItemLevel_Update(button, GetGuildBankItemLink(tab, i))
			end
		end
	end)
end

function M:ItemLevel()
	-- iLvl on GuildBankFrame
	P:AddCallbackForAddon("Blizzard_GuildBankUI", M.ItemLevel_GuildBank)
end

M:RegisterMisc("ItemLevel", M.ItemLevel)