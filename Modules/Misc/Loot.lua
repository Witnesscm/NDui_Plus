local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local LT = P:RegisterModule("Loot")
----------------------------
-- Improved Loot Frame, by Cybeloras
-- RayUI Loot, by fgprodigal
----------------------------
local _G = getfenv(0)
local select, format = select, format
local upper = string.upper
local GetNumLootItems, GetLootSlotLink, GetLootSlotInfo = GetNumLootItems, GetLootSlotLink, GetLootSlotInfo

local ScrollBoxElementHeight = 46
local ScrollBoxSpacing = 2

local function AnnounceLoot(chn)
	for i = 1, GetNumLootItems() do
		local link = GetLootSlotLink(i)
		local quality = select(5, GetLootSlotInfo(i))
		if link and quality and quality >= LT.db["AnnounceRarity"] then
			SendChatMessage(format("- %s", link), chn)
		end
	end
end

local function Announce(chn)
	local nums = GetNumLootItems()
	if nums == 0 then return end
	if LT.db["AnnounceTitle"] then
		if UnitIsPlayer("target") or not UnitExists("target") then
			SendChatMessage(format("*** %s ***", L["Loots in chest"]), chn)
		else
			SendChatMessage(format("*** %s%s ***", UnitName("target"), L["Loots"]), chn)
		end
	end
	if IsInInstance() or chn ~= "say" then
		P:Delay(.1, AnnounceLoot, chn)
	else
		AnnounceLoot(chn)
	end
end

function LT:OnLogin()
	if not LT.db["Enable"] then return end

	local LootFrame = _G.LootFrame
	LootFrame.panelMaxHeight = 1000
	LootFrame.ScrollBox:SetPoint("BOTTOMRIGHT", -4, 4)

	local title = LootFrame:CreateFontString(nil, "OVERLAY")
	title:SetFont(DB.Font[1], DB.Font[2]+2, DB.Font[3])
	title:SetPoint("TOPLEFT", 3, -4)
	title:SetPoint("TOPRIGHT", -105, -4)
	title:SetHeight(16)
	title:SetJustifyH("LEFT")
	LootFrame.title = title
	LootFrame:SetTitle("")

	function LootFrame:CalculateElementsHeight()
		return ScrollUtil.CalculateScrollBoxElementExtent(self.ScrollBox:GetDataProviderSize(), ScrollBoxElementHeight, ScrollBoxSpacing) - 8
	end

	hooksecurefunc(LootFrame, "Open", function(self)
		if UnitExists("target") and UnitIsDead("target") then
			self.title:SetText(UnitName("target"))
		else
			self.title:SetText(ITEMS)
		end

		for _, button in self.ScrollBox:EnumerateFrames() do
			if not button.__styled then
				if button.NameFrame then button.NameFrame:Hide() end
				if button.QualityStripe then button.QualityStripe:Hide() end
				if button.QualityText then button.QualityText:Hide() end

				button.__styled = true
			end
		end
	end)

	if not LT.db["Announce"] then return end

	local chn = { "say", "guild", "party", "raid"}
	local chncolor = {
		say = { 1, 1, 1},
		guild = { .25, 1, .25},
		party = { 2/3, 2/3, 1},
		raid = { 1, .5, 0},
	}

	LootFrame.announce = {}
	for i = 1, #chn do
		LootFrame.announce[i] = CreateFrame("Button", nil, LootFrame)
		LootFrame.announce[i]:SetSize(17, 17)
		B.PixelIcon(LootFrame.announce[i], DB.normTex, true)
		B.CreateSD(LootFrame.announce[i])
		LootFrame.announce[i].Icon:SetVertexColor(unpack(chncolor[chn[i]]))
		LootFrame.announce[i]:SetPoint("RIGHT", i==1 and LootFrame.ClosePanelButton or LootFrame.announce[i-1], "LEFT", -3, 0)
		LootFrame.announce[i]:SetScript("OnClick", function() Announce(chn[i]) end)
		LootFrame.announce[i]:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
			GameTooltip:ClearLines()
			GameTooltip:AddLine(L["Announce Loots to"].._G[upper(chn[i])])
			GameTooltip:Show()
		end)
		LootFrame.announce[i]:SetScript("OnLeave", B.HideTooltip)
	end
end