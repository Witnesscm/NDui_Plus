local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)

local function reskinFont(self, size)
	if not self then P:Debug("Unknown NWB FontString") return end

	local oldSize = select(2, self:GetFont())
	size = size or oldSize
	self:SetFont(DB.Font[1], size, DB.Font[3])
	self:SetShadowColor(0, 0, 0, 0)
end

local function reskinTooltip(self)
	if not self then P:Debug("Unknown NWB Tooltip") return end

	P.ReskinTooltip(self)
	if self.fs then reskinFont(self.fs) end
end

local function reskinTimer(self)
	if not self then P:Debug("Unknown NWB Timer") return end

	B.StripTextures(self)
	if self.Background then self.Background:SetAlpha(0) end

	for _, key in ipairs({"fs", "fs1", "fs2"}) do
		local fs = self[key]
		if fs then
			reskinFont(fs)
		end
	end
end

local function reskinCheck(self, tbl)
	for _, key in ipairs(tbl) do
		local check = self[key]
		if check then
			B.ReskinCheck(check)
		else
			P:Debug("Unknown NWB Check: %s", key)
		end
	end
end

local function reskinMarker(frame, isTower)
	local icon = frame.texture
	local tooltip = frame.tooltip

	if icon and not isTower then B.ReskinIcon(icon) end
	if tooltip then reskinTooltip(tooltip) end

	for _, key in ipairs({"timerFrame", "noLayerFrame"}) do
		local timer = frame[key]
		if timer then
			reskinTimer(timer)
		end
	end

	for _, key in ipairs({"fs", "fs1", "fs2", "fsLayer"}) do
		local fs = frame[key]
		if fs then
			reskinFont(fs)
		end
	end
end

local function reskinMarkers(tbl)
	for k, _ in pairs(tbl) do
		local mark = _G[k.."NWB"]
		if mark then
			reskinMarker(mark)
		end

		local mini = _G[k.."NWBMini"]
		if mini then
			reskinMarker(mini)
		end
	end
end

function S:NovaWorldBuffs()
	local NWB = LibStub("AceAddon-3.0"):GetAddon("NovaWorldBuffs")
	if not NWB then return end

	for _, key in ipairs({"NWBlayerFrame", "NWBLayerMapFrame", "NWBbuffListFrame", "NWBVersionFrame", "NWBCopyFrame", "NWBTimerLogFrame", "NWBLFrame"}) do
		local frame = _G[key]
		if frame then
			B.StripTextures(frame)
			B.SetBD(frame, nil, -12, 12, 12, -12)

			local close = _G[key.."Close"]
			if close then
				B.ReskinClose(close, 0, 0)
			end

			local scroll = _G[key.."ScrollBar"]
			if scroll then
				B.ReskinScroll(scroll)
				scroll:ClearAllPoints()
				scroll:SetPoint("TOPLEFT", frame, "TOPRIGHT", -13, -32)
				scroll:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -13, 9)
			end
		end
	end

	if _G.NWBCopyDragFrame then
		B.StripTextures(_G.NWBCopyDragFrame)
	end

	local buttons = {
		"NWBbuffListFrameConfButton",
		"NWBbuffListFrameTimersButton",
		"NWBbuffListFrameWipeButton",
		"NWBlayerFrameConfButton",
		"NWBlayerFrameBuffsButton",
		"NWBlayerFrameMapButton",
		"NWBlayerFrameCopyButton",
		"NWBlayerFrameTimerLogButton",
		"NWBTimerLogRefreshButton",
		"NWBGuildLayersButton",
		"NWBLFrameRefreshButton",
	}

	for _, key in ipairs(buttons) do
		local bu = _G[key]
		if bu then
			B.Reskin(bu)
			if bu.tooltip then reskinTooltip(bu.tooltip) end
		end
	end

	for _, key in ipairs({"NWBbuffListDragTooltip", "NWBlayerDragTooltip", "NWBLayerMapDragTooltip", "NWBVersionDragTooltip", "NWBLDragTooltip"}) do
		local tip = _G[key]
		if tip then
			reskinTooltip(tip)
		end
	end

	hooksecurefunc(NWB, "createBuffsListExtraButtons", function()
		reskinCheck(NWB, {"showStatsButton", "showStatsAllButton"})
		S:Proxy("ReskinSlider", NWB.charsMinLevelSlider)
	end)

	hooksecurefunc(NWB, "createCopyFormatButton", function()
		reskinCheck(NWB, {"copyDiscordButton"})
	end)

	if NWB.createDmfHelperButtons then
		hooksecurefunc(NWB, "createDmfHelperButtons", function()
			reskinCheck(NWB, {"dmfChatCountdown", "dmfAutoResButton"})
		end)
	end

	hooksecurefunc(NWB, "createTimerLogCheckboxes", function()
		reskinCheck(NWB, {"timerLogShowRendButton", "timerLogShowOnyButton", "timerLogShowNefButton"})
	end)

	hooksecurefunc(NWB, "createTimerLogMergeLayersCheckbox", function()
		reskinCheck(NWB, {"timerLogMergeLayersButton"})
	end)

	local minimap = _G.MinimapLayerFrame
	if minimap then
		B.StripTextures(minimap)
		reskinTooltip(minimap.tooltip)

		if minimap.fs then
			minimap.fs:SetFont(DB.Font[1], DB.Font[2], DB.Font[3])
			minimap.fs.SetFont = B.Dummy
		end
	end

	reskinMarkers(NWB.songFlowers)
	reskinMarkers(NWB.tubers)
	reskinMarkers(NWB.dragons)
	reskinMarker(_G.NWBDMF)
	reskinMarker(_G.NWBDMFContinent)
	--reskinMarker(_G.nefWorldMapNoLayerFrame)

	hooksecurefunc(NWB, "refreshWorldbuffMarkers", function()
		if NWB.isLayered then
			for layer in NWB:pairsByKeys(NWB.data.layers) do
				for k in pairs(NWB.worldBuffMapMarkerTypes) do
					local mark = _G[k..layer.."NWBWorldMap"]
					if mark and not mark.styled then
						reskinMarker(mark)
						mark.styled = true
					end
				end
			end
		else
			for k in pairs(NWB.worldBuffMapMarkerTypes) do
				local mark = _G[k.."NWBWorldMap"]
				if mark and not mark.styled then
					reskinMarker(mark)
					mark.styled = true
				end
			end
		end
	end)

	hooksecurefunc(NWB, "createDisableLayerButton", function(_, count)
		local button = _G["NWBDisableLayerButton" .. count]
		if button then
			B.Reskin(button)
			reskinTooltip(button.tooltip)
		end
	end)

	hooksecurefunc(NWB, "updateFelwoodWorldmapMarker", function(_, type)
		local button = _G[type .. "NWB"]
		if button then
			local i = 1
			local timer = i == 1 and button.timerFrame or button["timerFrame"..i]
			while timer do
				if not timer.styled then
					reskinTimer(timer)
					timer.styled = true
				end

				i = i + 1
				timer = button["timerFrame"..i]
			end
		end
	end)

	for _, key in pairs({"NWBShatDailyMap", "NWBShatHeroicMap"}) do
		local dailyMap = _G[key]
		if dailyMap then
			if dailyMap.textFrame and dailyMap.textFrame.fs then
				B.StripTextures(dailyMap.textFrame)
				reskinFont(dailyMap.textFrame.fs)
			end

			reskinTooltip(dailyMap.tooltip)
		end
	end

	if _G["towersNWBTerokkarMap"] then
		reskinMarker(_G["towersNWBTerokkarMap"], true)
	end

	local function reskinNWBTerokkarMaps()
		for layer in NWB:pairsByKeys(NWB.data.layers) do
			local frame = _G["towers" .. layer .. "NWBTerokkarMap"]
			if frame and not frame.styled then
				reskinMarker(frame, true)
				frame.styled = true
			end
		end
	end

	reskinNWBTerokkarMaps()
	hooksecurefunc(NWB, "createTerokkarMarkers", reskinNWBTerokkarMaps)
end

S:RegisterSkin("NovaWorldBuffs", S.NovaWorldBuffs)