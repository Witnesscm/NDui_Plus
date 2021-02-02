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
	if not IsAddOnLoaded("Rematch") then return end

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

	hooksecurefunc(RematchOptionPanel.funcs, "PanelTabsToRight", function()
		if not RematchSettings.PanelTabsToRight then
			RematchFrame.PanelTabs:SetPoint("TOPLEFT", RematchFrame, "BOTTOMLEFT", -6, 1)
		end
	end)

	-- RematchLoadedTeamPanel
	local teamPanel = RematchLoadedTeamPanel
	S.RematchTitleButton(teamPanel.Footnotes.Close, true)
	S.RematchTitleButton(teamPanel.Footnotes.Maximize)

	-- RematchMiniQueue
	B.StripTextures(RematchMiniQueue.Status)
	B.StripTextures(RematchMiniQueue.Top)
	NS.RematchFilter(RematchMiniQueue.Top.QueueButton)

	-- RematchMiniPanel
	local miniPanel = RematchMiniPanel
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

	-- ALPTCConfigs
	local function reskinALPTInput(self)
		self:SetBackdrop(nil)
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

	local config = RematchDialog.ALPTCConfigs
	if config then
		for i = 1, 3 do
			B.ReskinCheck(config["Breed"..i])
			B.ReskinCheck(config["NoAlt"..i])
			B.ReskinCheck(config["Highest"..i])
			B.ReskinCheck(config["UseGroup"..i])

			-- reskinALPTInput(config["HP"..i])
			-- reskinALPTInput(config["MinLvl"..i])
			-- reskinALPTInput(config["FilterHP"..i.."_1"])
			-- reskinALPTInput(config["FilterHP"..i.."_2"])
			-- reskinALPTInput(config["FilterAttack"..i.."_1"])
			-- reskinALPTInput(config["FilterAttack"..i.."_2"])
			-- reskinALPTInput(config["FilterSpeed"..i.."_1"])
			-- reskinALPTInput(config["FilterSpeed"..i.."_2"])

			reskinALPTDropDown(config["Groups"..i])
		end

		B.ReskinCheck(config.Disable)
	end

	local function delayFunc()
		B.StripTextures(miniPanel.Target.ModelBorder)
		B.CreateBDFrame(miniPanel.Target.ModelBorder, 0)

		local ALPTBtn = _G.ALPTRematchOptionButton
		if ALPTBtn and not InCombatLockdown() then
			ALPTBtn:ClearAllPoints()
			ALPTBtn:SetParent(RematchJournal)
			ALPTBtn:SetPoint("TOPRIGHT", RematchJournal, "TOPRIGHT", -230, -28)
			ALPTBtn:SetSize(28, 28)
		end
	end
	C_Timer.After(.5, delayFunc)
end

S:RegisterSkin("Rematch", S.Rematch)