local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local LT = P:RegisterModule("Loot")
----------------------------
-- Improved Loot Frame, by Cybeloras_
-- RayUI Loot, by fgprodigal
----------------------------
local _G = getfenv(0)
local select, format = select, format
local min, max, abs, floor, upper = math.min, math.max, math.abs, math.floor, string.upper
local GetNumLootItems, LootSlotHasItem, GetLootSlotLink, GetLootSlotInfo = GetNumLootItems, LootSlotHasItem, GetLootSlotLink, GetLootSlotInfo

function LT:OnLogin()
	if not LT.db["Enable"] then return end
	if not C.db["Skins"]["Loot"] then P:Print("需要启用NDui拾取框美化") return end

	for i = 1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions())
		if region.GetText and region:GetText() == ITEMS then
			region:Hide()
		end
	end

	LootFrame:SetWidth(200)
	LootFrame.title = LootFrame:CreateFontString(nil, "OVERLAY")
	LootFrame.title:SetFont(DB.Font[1], DB.Font[2]+2, DB.Font[3])
	LootFrame.title:SetPoint("TOPLEFT", 3, -4)
	LootFrame.title:SetPoint("TOPRIGHT", -105, -4)
	LootFrame.title:SetHeight(16)
	LootFrame.title:SetJustifyH("LEFT")

	local p, r, x, y = "TOP", "BOTTOM", 0, -4
	local buttonHeight = LootButton1:GetHeight() + abs(y)
	local baseHeight = LootFrame:GetHeight() - (buttonHeight * LOOTFRAME_NUMBUTTONS) - 41

	hooksecurefunc("LootFrame_Show", function(self, ...)
		local maxButtons = floor(UIParent:GetHeight() / LootButton1:GetHeight() * 0.7)
	
		local num = GetNumLootItems()

		if self.AutoLootTable then
			num = #self.AutoLootTable
		end

		self.AutoLootDelay = 0.4 + (num * 0.05)

		num = min(num, maxButtons)

		LootFrame:SetHeight(baseHeight + (max(num, 1) * buttonHeight))

		for i = 1, num do
			local button = _G["LootButton"..i]
			if i == 1 then
				button:ClearAllPoints()
				button:SetPoint("TOPLEFT", 9, -30)
			end
			if i > LOOTFRAME_NUMBUTTONS then
				if not button then
					button = CreateFrame("ItemButton", "LootButton"..i, LootFrame, "LootButtonTemplate", i)
				end
				LOOTFRAME_NUMBUTTONS = i
			end
			if i > 1 then
				button:ClearAllPoints()
				button:SetPoint(p, "LootButton"..(i-1), r, x, y)
			end

			local text = _G["LootButton"..i.."Text"]
			text:SetSize(140,38)
		end

		if UnitExists("target") and UnitIsDead("target") then
			LootFrame.title:SetText(UnitName("target"))
		else
			LootFrame.title:SetText(ITEMS)
		end
	
		if ( GetCVar("lootUnderMouse") == "1" ) then
			local x, y = GetCursorPosition();
			x = x / self:GetEffectiveScale();
			y = y / self:GetEffectiveScale();
			local posX = x - 175;
			local posY = y + 25;
			if (num > 0) then
				posX = x - 40;
				posY = y + 55;
				posY = posY + 40;
			end
			if( posY < 350 ) then
				posY = 350;
			end
			self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", posX, posY - 38);
		end

		LootFrame_Update();
	end)

	-- LootButtonBG
	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local bu = _G["LootButton"..index]
		if bu and not bu.styled then
			for i = 1, bu:GetNumChildren() do
				local child = select(i, bu:GetChildren())
				local xOfs = select(4, child:GetPoint(2))
				if xOfs and xOfs == 114 then
					child:SetPoint("BOTTOMRIGHT", LootFrame:GetWidth() - 55, 0)
					bu.styled = true
					break
				end
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

	local function Announce(chn)
		local nums = GetNumLootItems()
		if(nums == 0) then return end
		if LT.db["AnnounceTitle"] then
			if UnitIsPlayer("target") or not UnitExists("target") then -- Chests are hard to identify!
				SendChatMessage(format("*** %s ***", "箱子中的战利品"), chn)
			else
				SendChatMessage(format("*** %s%s ***", UnitName("target"), "的战利品"), chn)
			end
		end
		for i = 1, GetNumLootItems() do
			-- local link
			-- if(LootSlotHasItem(i)) then	 --判断，只发送物品
				-- link = GetLootSlotLink(i)
			-- else
				-- _, link = GetLootSlotInfo(i)
			-- end
			local link = GetLootSlotLink(i)
			local quality = select(5, GetLootSlotInfo(i))
			if link and quality and quality >= LT.db["AnnounceRarity"] then
				local messlink = "- %s"
				SendChatMessage(format(messlink, link), chn)
			end
		end
	end

	LootFrame.announce = {}
	for i = 1, #chn do
		LootFrame.announce[i] = CreateFrame("Button", "ItemLootAnnounceButton"..i, LootFrame)
		LootFrame.announce[i]:SetSize(17, 17)
		B.PixelIcon(LootFrame.announce[i], DB.normTex, true)
		B.CreateSD(LootFrame.announce[i])
		LootFrame.announce[i].Icon:SetVertexColor(unpack(chncolor[chn[i]]))
		LootFrame.announce[i]:SetPoint("RIGHT", i==1 and LootFrameCloseButton or LootFrame.announce[i-1], "LEFT", -3, 0)
		LootFrame.announce[i]:SetScript("OnClick", function() Announce(chn[i]) end)
		LootFrame.announce[i]:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
			GameTooltip:ClearLines()
			GameTooltip:AddLine("将战利品通报至".._G[chn[i]:upper()])
			GameTooltip:Show()
		end)
		LootFrame.announce[i]:SetScript("OnLeave", GameTooltip_Hide)
	end
end
