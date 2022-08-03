local AddOnName, ns = ...
local B, C, L, DB, P = unpack(ns)

local pairs, type, next= pairs, type, next
local tinsert = table.insert
local pcall = pcall

local modules, initQueue, addonsToLoad = {}, {}, {}

P.DefaultSettings = {
	Debug = false,
	Changelog = {
		Version = "",
	},
	TexStyle = {
		Enable = false,
		Texture = "NDui_Plus",
		Index = 0,
	},
	RoleStyle = {
		Enable = false,
		Index = 1,
	},
	ActionBar = {
		ComboGlow = true,
		GlobalFade = false,
		Alpha = .1,
		Delay = 0,
		Combat = true,
		Target = true,
		Casting = true,
		Health = true,
		Vehicle = true,
		Bar1 = true,
		Bar2 = true,
		Bar3 = true,
		Bar4 = true,
		Bar5 = true,
		CustomBar = true,
		PetBar = true,
		StanceBar = true
	},
	UnitFrames= {
		Fader = false,
		Hover = true,
		Combat = true,
		Target = true,
		Focus = true,
		Health = true,
		Vehicle = true,
		Casting = true,
		Delay = 0,
		Smooth = .4,
		MinAlpha = .1,
		MaxAlpha = 1,
		RolePos = false,
		RolePoint = 2,
		RoleXOffset = 5,
		RoleYOffset = 5,
		RoleSize = 12,
	},
	Chat = {
		Emote = false,
		ClassColor = true,
		RaidIndex = false,
		Role = false,
		Icon = true,
		ChatHide = true,
		AutoShow = false,
		AutoHide = false,
		AutoHideTime = 10,
	},
	Loot = {
		Enable = true,
		Announce = true,
		AnnounceTitle = true,
		AnnounceRarity = 1,
	},
	AFK = {
		Enable = true,
	},
	Skins = {
		Ace3 = true,
		InboxMailBag = true,
		ButtonForge = true,
		ls_Toasts = true,
		WhisperPop = true,
		Immersion = true,
		TinyInspect = true,
		MeetingStone = true,
		tdBattlePetScript = true,
		RareScanner = true,
		WorldQuestTab = true,
		ExtVendor = true,
		HideToggle = false,
	},
	Tooltip = {
		Progression = true,
		CombatHide = true,
		ShowByShift = true,
		ProgRaids = true,
		ProgDungeons = true,
		ProgAchievement = true,
		KeystoneMaster = true,
		AchievementList = "",
		MountsSource = true,
		HideCreator = false,
		Covenant = true,
	},
	Misc = {
		LootSpecManager = false,
		TalentManager = true,
		QuestHelper = true,
		CopyMog = true,
		ShowHideVisual = true,
		ShowIllusion = true,
		SearchForIcons = true,
		AutoCollapse = false,
		ParagonRepRewards = true,
		ImprovedStableFrame = true,
		GarrisonTabs = true,
		AuctionEnhanced = true,
		GuildBankItemLevel = true,
		ExtVendorUI = false,
		WormholeHelper = true,
	},
}

P.CharacterSettings = {
	LootSpecManager = {},
	TalentManager = {},
	RenownLevels = {},
}

function P:InitialSettings(source, target, fullClean)
	for i, j in pairs(source) do
		if type(j) == "table" then
			if target[i] == nil or type(target[i]) ~= "table" then target[i] = {} end
			for k, v in pairs(j) do
				if target[i][k] == nil then
					target[i][k] = v
				end
			end
		else
			if target[i] == nil then target[i] = j end
		end
	end

	for i, j in pairs(target) do
		if source[i] == nil then target[i] = nil end
		if fullClean and type(j) == "table" then
			for k, v in pairs(j) do
				if type(v) ~= "table" and source[i] and source[i][k] == nil then
					target[i][k] = nil
				end
			end
		end
	end
end

function P.IsRetail()
	return _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE
end

function P.IsBCC()
	return _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
end

function P.IsClassic()
	return _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
end

function P:ThrowError(err, message)
	if not err then return end

	err = format("NDui_Plus: %s error\n%s", message, err)

	if _G.BaudErrorFrameHandler then
		_G.BaudErrorFrameHandler(err)
	else
		_G.ScriptErrorsFrame:OnError(err, false, false)
	end
end

function P:Debug(...)
	if NDuiPlusDB["Debug"] then
		_G.DEFAULT_CHAT_FRAME:AddMessage("|cFF70B8FFNDui_Plus:|r " .. format(...))
	end
end

function P:Print(...)
	_G.DEFAULT_CHAT_FRAME:AddMessage("|cFF70B8FFNDui_Plus:|r " .. format(...))
end

function P:Error(...)
	_G.UIErrorsFrame:AddMessage("|cFF70B8FF"..format(...).."|r ")
end

function P:VersionCheck_Compare(new, old)
	local new1, new2, new3 = strsplit(".", new)
	new1, new2, new3 = tonumber(new1), tonumber(new2), tonumber(new3)

	local old1, old2, old3 = strsplit(".", old)
	old1, old2, old3 = tonumber(old1), tonumber(old2), tonumber(old3)

	if new1 > old1 or (new1 == old1 and new2 > old2) or (new1 == old1 and new2 == old2 and new3 > old3) then
		return "IsNew"
	elseif new1 < old1 or (new1 == old1 and new2 < old2) or (new1 == old1 and new2 == old2 and new3 < old3) then
		return "IsOld"
	end
end

function P:Notifications()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetPoint("CENTER")
	frame:SetSize(300, 150)
	frame:SetFrameStrata("HIGH")
	B.CreateMF(frame)
	B.SetBD(frame)

	local close = B.CreateButton(frame, 16, 16, true, DB.closeTex)
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() frame:Hide() end)

	B.CreateFS(frame, 18, AddOnName, true, "TOP", 0, -10)
	B.CreateFS(frame, 16, format(L["Version Check"], P.SupportVersion), false, "CENTER")
end

function P:CallLoadedAddon(addonName, object)
	for _, func in next, object do
		if type(func) == "function" then
			local _, catch = pcall(func)
			P:ThrowError(catch, format("%s callback", addonName))
		end
	end

	addonsToLoad[addonName] = nil
end

function P:AddCallbackForAddon(addonName, func)
	local addon = addonsToLoad[addonName]
	if not addon then
		addonsToLoad[addonName] = {}
		addon = addonsToLoad[addonName]
	end

	tinsert(addon, func)
end

-- Modules
function P:RegisterModule(name)
	if modules[name] then P:Print("Module <"..name.."> has been registered.") return end
	local module = {}
	module.name = name
	modules[name] = module

	tinsert(initQueue, module)
	return module
end

function P:GetModule(name)
	if not modules[name] then P:Print("Module <"..name.."> does not exist.") return end

	return modules[name]
end

function P:Initialize()
	local status = P:VersionCheck_Compare(DB.Version, P.SupportVersion)
	if status == "IsOld" then
		P:Print(L["Version Check"], P.SupportVersion)
		P:Notifications()
		return
	end

	for _, module in next, initQueue do
		if module.OnLogin then
			local _, catch = pcall(module.OnLogin, module)
			P:ThrowError(catch, format("%s Module", module.name))
		else
			P:Print("Module <"..module.name.."> does not loaded.")
		end
	end

	for addonName, object in pairs(addonsToLoad) do
		local isLoaded, isFinished = IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			P:CallLoadedAddon(addonName, object)
		end
	end

	B:RegisterEvent("ADDON_LOADED", function(_, addonName)
		local object = addonsToLoad[addonName]
		if object then
			P:CallLoadedAddon(addonName, object)
		end
	end)

	P.Initialized = true
	P.Modules = modules
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == "NDui_Plus" then
		P:InitialSettings(P.DefaultSettings, NDuiPlusDB, true)
		P:InitialSettings(P.CharacterSettings, NDuiPlusCharDB)

		for _, module in next, initQueue do
			module.db = NDuiPlusDB[module.name]

			local charDB = NDuiPlusCharDB[module.name]
			if module.db and charDB then
				setmetatable(module.db, {__index=charDB})
			elseif charDB then
				module.db = charDB
			end
		end

		P:BuildTextureTable()
		P:ReplaceTexture()

		self:UnregisterEvent(event)
	elseif event == "PLAYER_LOGIN" then
		P:Initialize()
	end
end)