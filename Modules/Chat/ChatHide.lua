local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local _, _, NL = unpack(_G.NDui)
local CH = P:GetModule("Chat")
local NCH = B:GetModule("Chat")
------------------
-- Credit: RayUI
------------------
local copy
local isMoving = false
local hasNew = false
local timeout = 0
local chatIn = true
local offset = 18

do
	-- NDui CopyButton
	local copyStr = format(NL["Chat Copy"], DB.LeftButton, DB.RightButton)

	hooksecurefunc(B, "AddTooltip", function(frame, anchor, text, ...)
		if copy then return end

		if anchor == "ANCHOR_RIGHT" and text == copyStr then
			copy = frame
		end
	end)
end

function CH:StopFlash()
	hasNew = false
	P:StopFlash(CH.ChatToggle.bg.__shadow)
	CH.ChatToggle.bg.__shadow:SetBackdropBorderColor(0, 0, 0, .4)
end

function CH:MoveOut()
	isMoving = true
	chatIn = false
	CH.ChatBG:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 30)
	P:Slide(CH.ChatBG, "LEFT", C.db["Chat"]["ChatWidth"] + offset, 220)
	P:UIFrameFadeOut(CH.ChatBG, .5, CH.ChatBG:GetAlpha(), 0)
end

function CH:MoveIn()
	isMoving = true
	chatIn = true
	CH.ChatBG:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -C.db["Chat"]["ChatWidth"] - offset, 30)
	P:Slide(CH.ChatBG, "RIGHT", C.db["Chat"]["ChatWidth"] + offset, 220)
	P:UIFrameFadeIn(CH.ChatBG, .5, CH.ChatBG:GetAlpha(), 1)
	CH:StopFlash()
end

function CH:ToggleChat()
	timeout = 0
	if chatIn then
		CH:MoveOut()
	else
		CH:MoveIn()
	end
end

function CH:SetupChat()
	if not self or self.__parentBG then return end

	self:SetParent(CH.ChatBG)
	self.__parentBG = CH.ChatBG
	_G[self:GetName() .. "Tab"]:SetParent(CH.ChatBG)

	if self.__gradient then
		self.__gradient:SetFrameLevel(0)
	end
end

function CH:AutoShow()
	timeout = 0
	if not chatIn then
		if isMoving then
			isMoving = false
			CH.ChatBG:SetScript("OnUpdate", nil)
		end
		CH.ChatBG:ClearAllPoints()
		CH.ChatBG:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 30)
		P:UIFrameFadeIn(CH.ChatBG, .7, 0, 1)
		chatIn = true
		hasNew = false
	end
end

function CH.WhisperFlash(event)
	if chatIn then return end

	local r, g, b
	if event == "CHAT_MSG_WHISPER" then
		r, g, b = ChatTypeInfo["WHISPER"].r, ChatTypeInfo["WHISPER"].g, ChatTypeInfo["WHISPER"].b
	elseif event == "CHAT_MSG_BN_WHISPER" then
		r, g, b = ChatTypeInfo["BN_WHISPER"].r, ChatTypeInfo["BN_WHISPER"].g, ChatTypeInfo["BN_WHISPER"].b
	end

	hasNew = true
	CH.ChatToggle:SetAlpha(1)
	CH.ChatToggle.bg.__shadow:SetBackdropBorderColor(r, g, b, 1)
	P:Flash(CH.ChatToggle.bg.__shadow, 1, true)
end

local ChatEvents = {
	["ASWhisper"] = {"CHAT_MSG_WHISPER", "CHAT_MSG_BN_WHISPER"},
	["ASGroup"] = {"CHAT_MSG_PARTY", "CHAT_MSG_RAID", "CHAT_MSG_INSTANCE_CHAT"},
	["ASGuild"] = {"CHAT_MSG_GUILD"},
}

function CH:UpdateAutoShow()
	if not CH.ChatBG then return end

	for key, events in pairs(ChatEvents) do
		for _, event in ipairs(events) do
			if CH.db["AutoShow"] and CH.db[key]  then
				B:RegisterEvent(event, CH.AutoShow)
			else
				B:UnregisterEvent(event, CH.AutoShow)
			end
		end
	end

	if CH.db["AutoShow"] then
		B:RegisterEvent("PLAYER_REGEN_DISABLED", CH.AutoShow)
	else
		B:UnregisterEvent("PLAYER_REGEN_DISABLED", CH.AutoShow)
	end

	if CH.db["AutoShow"] and CH.db["ASWhisper"]  then
		B:UnregisterEvent("CHAT_MSG_WHISPER", CH.WhisperFlash)
		B:UnregisterEvent("CHAT_MSG_BN_WHISPER", CH.WhisperFlash)
	else
		B:RegisterEvent("CHAT_MSG_WHISPER", CH.WhisperFlash)
		B:RegisterEvent("CHAT_MSG_BN_WHISPER", CH.WhisperFlash)
	end
end

function CH:AutoHide()
	local x, y = GetCursorPosition()
	local cursor = (x > CH.ChatBG:GetLeft() and x < CH.ChatBG:GetLeft() + CH.ChatBG:GetWidth()) and (y > CH.ChatBG:GetBottom() and y < CH.ChatBG:GetBottom() + CH.ChatBG:GetHeight())
	timeout = timeout + 1
	if timeout > CH.db["AutoHideTime"] and chatIn and not ChatFrame1EditBox:IsShown() and not InCombatLockdown() and not cursor then
		CH:MoveOut()
	end
end

function CH:UpdateAutoHide()
	if not CH.ChatBG then return end

	if CH.db["AutoHide"] then
		CH.ChatBG.hideTimer = P:ScheduleRepeatingTimer(CH.AutoHide, 1)
	else
		if CH.ChatBG.hideTimer then
			P:CancelTimer(CH.ChatBG.hideTimer)
		end
	end
end

local function finishFunc()
	CH.ChatToggle.text:SetText(chatIn and "<" or ">")
end

local function resetChatAnchor(self, _, parent)
	if not parent or parent == UIParent then
		CH.ChatBG:ClearAllPoints()
		CH.ChatBG:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", chatIn and 0 or -C.db["Chat"]["ChatWidth"] - offset, 30)
		CH.ChatBG:SetWidth(C.db["Chat"]["ChatWidth"])
		CH.ChatBG:SetHeight(C.db["Chat"]["ChatHeight"])

		self:ClearAllPoints()
		self:SetAllPoints(CH.ChatBG)
	end
end

function CH:ChatHide()
	if not CH.db["ChatHide"] then return end
	if not C.db["Chat"]["Lock"] then return end

	-- Chat Background
	local chatBG = CreateFrame("Frame", "NDui_PlusChatBG", UIParent)
	chatBG:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 30)
	chatBG:SetWidth(C.db["Chat"]["ChatWidth"])
	chatBG:SetHeight(C.db["Chat"]["ChatHeight"])
	chatBG.FadeObject = {finishedFunc = finishFunc, finishedFuncKeep = true}
	chatBG.finish_function = function() isMoving = false end
	CH.ChatBG = chatBG

	-- Toggle Button
	local button = CreateFrame("Button", nil, UIParent)
	button:SetSize(20, 80)
	button:SetPoint("LEFT", chatBG, "RIGHT", offset, 0)
	B.ReskinMenuButton(button)
	B.CreateSD(button.bg, nil, true)
	button.text = B.CreateFS(button, 18, "<", true)
	button:SetAlpha(0)
	button:SetScript("OnClick", function()
		CH:ToggleChat()
	end)

	button:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
		GameTooltip:ClearLines()
		local r, g, b = .6, .8, 1
		if chatIn then
			GameTooltip:AddLine(L["Click to hide ChatFrame"], r, g, b)
		else
			GameTooltip:AddLine(L["Click to show ChatFrame"], r, g, b)
		end
		if not hasNew then
			P:UIFrameFadeIn(self, 0.5, self:GetAlpha(), 1)
		else
			GameTooltip:AddLine(L["You have new wisper"])
		end
		GameTooltip:Show()
	end)
	button:HookScript("OnLeave", function(self)
		if not hasNew then
			P:UIFrameFadeOut(self, 0.5, self:GetAlpha(), 0)
		end
		GameTooltip:Hide()
	end)
	CH.ChatToggle = button

	-- EditBox Handler
	ChatFrame1EditBox:HookScript("OnShow", function(self)
		timeout = 0
		if not chatIn then
			if isMoving then
				isMoving = false
				CH.ChatBG:SetScript("OnUpdate", nil)
			end
			CH.ChatBG:ClearAllPoints()
			CH.ChatBG:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 30)
			P:UIFrameFadeIn(CH.ChatBG, .7, 0, 1)
			CH:StopFlash()
			chatIn = true
		end
	end)
	ChatFrame1EditBox:HookScript("OnHide", function(self)
		timeout = 0
	end)

	-- Modified NDui ChatFrame
	for i = 1, NUM_CHAT_WINDOWS do
		local chatframe = _G["ChatFrame" .. i]
		CH.SetupChat(chatframe)
	end

	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for _, chatFrameName in ipairs(CHAT_FRAMES) do
			local frame = _G[chatFrameName]
			if frame.isTemporary then
				CH.SetupChat(frame)
			end
		end
	end)

	-- Misc
	_G.GeneralDockManager:SetParent(CH.ChatBG)
	_G.ChatFrameMenuButton:GetParent():SetParent(CH.ChatBG)
	if copy then copy:SetParent(CH.ChatBG) end

	hooksecurefunc(_G.ChatFrame1, "SetPoint", resetChatAnchor)
	resetChatAnchor(_G.ChatFrame1)

	CH:UpdateAutoShow()
	CH:UpdateAutoHide()
end