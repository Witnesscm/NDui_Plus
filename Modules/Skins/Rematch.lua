local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
local NS = B:GetModule("Skins")

local _G = getfenv(0)

function S:RematchTitleButton(close)
	B.StripTextures(self, close and 0 or 1)
	local bg = B.CreateBDFrame(self, .25)
	bg:SetPoint("TOPLEFT", 7, -7)
	bg:SetPoint("BOTTOMRIGHT", -7, 7)
end

function S:Rematch()
	-- RematchFrame
	--[[
	local frame = RematchFrame
	B.StripTextures(frame)
	B.SetBD(frame)
	B.StripTextures(frame.TitleBar)

	S.RematchTitleButton(frame.TitleBar.CloseButton, true)
	S.RematchTitleButton(frame.TitleBar.LockButton)
	S.RematchTitleButton(frame.TitleBar.MinimizeButton)
	S.RematchTitleButton(frame.TitleBar.SinglePanelButton)

	for _, tab in ipairs(frame.PanelTabs.Tabs) do
		B.ReskinTab(tab)
	end
	--]]

	hooksecurefunc(_G.RematchOptionPanel.funcs, "PanelTabsToRight", function()
		if not _G.RematchSettings.PanelTabsToRight then
			_G.RematchFrame.PanelTabs:SetPoint("TOPLEFT", RematchFrame, "BOTTOMLEFT", -6, 1)
		end
	end)

	-- RematchLoadedTeamPanel
	local teamPanel = _G.RematchLoadedTeamPanel
	if teamPanel then
		S.RematchTitleButton(teamPanel.Footnotes.Close, true)
		S.RematchTitleButton(teamPanel.Footnotes.Maximize)
	end

	-- RematchMiniQueue
	local miniQueue = _G.RematchMiniQueue
	if miniQueue then
		B.StripTextures(miniQueue.Status)
		B.StripTextures(miniQueue.Top)
		NS.RematchFilter(miniQueue.Top.QueueButton)
	end

	-- RematchMiniPanel
	local miniPanel = _G.RematchMiniPanel
	if miniPanel then
		B.StripTextures(miniPanel.Background)
		B.CreateBDFrame(miniPanel, .25)
		B.StripTextures(miniPanel.Target)
		B.CreateBDFrame(miniPanel.Target, 0)

		local loadButton = miniPanel.Target.LoadButton
		loadButton:DisableDrawLayer("BACKGROUND")
		B.Reskin(loadButton)

		for _, button in ipairs(miniPanel.Target.Pets) do
			NS.RematchIcon(button)
		end

		hooksecurefunc(miniPanel, "Update", function(self)
			if not self then return end

			for _, button in ipairs(miniPanel.Pets) do
				if not button.styled then
					--NS.RematchIcon(button)
					NS.RematchXP(button.HP)
					NS.RematchXP(button.XP)
					button.Status:SetAllPoints(button.Icon)

					-- for i = 1, 3 do
						-- NS.RematchIcon(button.Abilities[i])
					-- end

					button.styled = true
				end
			end
		end)
	end

	-- ALPTCConfigs
	local function reskinALPTInput(self)
		self:DisableDrawLayer("BACKGROUND")
		P.ReskinInput(self)
		self.bg:SetInside()
	end

	local function reskinALPTDropDown(self)
		B.StripTextures(self)
		local bg = B.CreateBDFrame(self, 0)
		bg:SetPoint("TOPLEFT", 15, -4)
		bg:SetPoint("BOTTOMRIGHT", 110, 8)
		B.CreateGradient(bg)

		local down = self.Button
		down:ClearAllPoints()
		down:SetPoint("RIGHT", bg, 0, 0)
		B.ReskinArrow(down, "down")
		down:SetSize(20,20)
	end

	local config = _G.RematchDialog.ALPTCConfigs
	if config then
		for i = 1, 3 do
			for _, key in ipairs({"Breed", "NoAlt", "Highest", "Lowest", "UseGroup"}) do
				local check = config[key..i]
				if check then
					B.ReskinCheck(check)
				end
			end

			for _, key in ipairs({"HP"..i, "MinLvl"..i, "FilterHP"..i.."_1", "FilterHP"..i.."_2", "FilterAttack"..i.."_1", "FilterAttack"..i.."_2", "FilterSpeed"..i.."_1", "FilterSpeed"..i.."_2"}) do
				local eb = config[key]
				if eb then
					reskinALPTInput(eb)
				end
			end

			if config["Groups"..i] then
				reskinALPTDropDown(config["Groups"..i])
			end
		end

		B.ReskinCheck(config.Disable)
	end

	local function delayFunc()
		B.StripTextures(miniPanel.Target.ModelBorder)
		B.CreateBDFrame(miniPanel.Target.ModelBorder, 0)

		local ALPTBtn = _G.ALPTRematchOptionButton
		if ALPTBtn and not InCombatLockdown() then
			ALPTBtn:ClearAllPoints()
			ALPTBtn:SetParent(_G.RematchJournal)
			ALPTBtn:SetPoint("TOPRIGHT", _G.RematchJournal, "TOPRIGHT", -230, -28)
			ALPTBtn:SetSize(28, 28)
		end
	end
	C_Timer.After(.5, delayFunc)
end

--S:RegisterSkin("Rematch", S.Rematch)