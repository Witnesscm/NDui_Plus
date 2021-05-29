local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local CH = P:GetModule("Chat")
----------------------------
-- TinyChat, Author:M
----------------------------
local _G = getfenv(0)
local ipairs, select = ipairs, select
local gsub = string.gsub

local locale = GetLocale()

local emotes = {
		--表情
	{ key = "angel",	zhTW="天使",	  zhCN="天使" },
	{ key = "angry",	zhTW="生氣",	  zhCN="生气" },
	{ key = "biglaugh", zhTW="大笑",	  zhCN="大笑" },
	{ key = "clap",	 zhTW="鼓掌",	  zhCN="鼓掌" },
	{ key = "cool",	 zhTW="酷",		zhCN="酷" },
	{ key = "cry",	  zhTW="哭",		zhCN="哭" },
	{ key = "cutie",	zhTW="可愛",	  zhCN="可爱" },
	{ key = "despise",  zhTW="鄙視",	  zhCN="鄙视" },
	{ key = "dreamsmile", zhTW="美夢",	zhCN="美梦" },
	{ key = "embarrass", zhTW="尷尬",	 zhCN="尴尬" },
	{ key = "evil",	 zhTW="邪惡",	  zhCN="邪恶" },
	{ key = "excited",  zhTW="興奮",	  zhCN="兴奋" },
	{ key = "faint",	zhTW="暈",		zhCN="晕" },
	{ key = "fight",	zhTW="打架",	  zhCN="打架" },
	{ key = "flu",	  zhTW="流感",	  zhCN="流感" },
	{ key = "freeze",   zhTW="呆",		zhCN="呆" },
	{ key = "frown",	zhTW="皺眉",	  zhCN="皱眉" },
	{ key = "greet",	zhTW="致敬",	  zhCN="致敬" },
	{ key = "grimace",  zhTW="鬼臉",	  zhCN="鬼脸" },
	{ key = "growl",	zhTW="齜牙",	  zhCN="龇牙" },
	{ key = "happy",	zhTW="開心",	  zhCN="开心" },
	{ key = "heart",	zhTW="心",		zhCN="心" },
	{ key = "horror",   zhTW="恐懼",	  zhCN="恐惧" },
	{ key = "ill",	  zhTW="生病",	  zhCN="生病" },
	{ key = "innocent", zhTW="無辜",	  zhCN="无辜" },
	{ key = "kongfu",   zhTW="功夫",	  zhCN="功夫" },
	{ key = "love",	 zhTW="花痴",	  zhCN="花痴" },
	{ key = "mail",	 zhTW="郵件",	  zhCN="邮件" },
	{ key = "makeup",   zhTW="化妝",	  zhCN="化妆" },
	{ key = "mario",	zhTW="馬里奧",	zhCN="马里奥" },
	{ key = "meditate", zhTW="沉思",	  zhCN="沉思" },
	{ key = "miserable", zhTW="可憐",	 zhCN="可怜" },
	{ key = "okay",	 zhTW="好",		zhCN="好" },
	{ key = "pretty",   zhTW="漂亮",	  zhCN="漂亮" },
	{ key = "puke",	 zhTW="吐",		zhCN="吐" },
	{ key = "shake",	zhTW="握手",	  zhCN="握手" },
	{ key = "shout",	zhTW="喊",		zhCN="喊" },
	{ key = "shuuuu",   zhTW="閉嘴",	  zhCN="闭嘴" },
	{ key = "shy",	  zhTW="害羞",	  zhCN="害羞" },
	{ key = "sleep",	zhTW="睡覺",	  zhCN="睡觉" },
	{ key = "smile",	zhTW="微笑",	  zhCN="微笑" },
	{ key = "suprise",  zhTW="吃驚",	  zhCN="吃惊" },
	{ key = "surrender", zhTW="失敗",	 zhCN="失败" },
	{ key = "sweat",	zhTW="流汗",	  zhCN="流汗" },
	{ key = "tear",	 zhTW="流淚",	  zhCN="流泪" },
	{ key = "tears",	zhTW="悲劇",	  zhCN="悲剧" },
	{ key = "think",	zhTW="想",		zhCN="想" },
	{ key = "titter",   zhTW="偷笑",	  zhCN="偷笑" },
	{ key = "ugly",	 zhTW="猥瑣",	  zhCN="猥琐" },
	{ key = "victory",  zhTW="勝利",	  zhCN="胜利" },
	{ key = "volunteer", zhTW="雷鋒",	 zhCN="雷锋" },
	{ key = "wronged",  zhTW="委屈",	  zhCN="委屈" },	
		--指定了texture一般用於BLIZ自帶的素材
	{ key = "wrong",	zhTW="錯",		zhCN="错",	texture = "Interface\\RaidFrame\\ReadyCheck-NotReady" },
	{ key = "right",	zhTW="對",		zhCN="对",	texture = "Interface\\RaidFrame\\ReadyCheck-Ready" },
	{ key = "question", zhTW="疑問",	  zhCN="疑问",  texture = "Interface\\RaidFrame\\ReadyCheck-Waiting" },
	{ key = "skull",	zhTW="骷髏",	  zhCN="骷髅",  texture = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull" },
	{ key = "sheep",	zhTW="羊",		zhCN="羊",	texture = "Interface\\TargetingFrame\\UI-TargetingFrame-Sheep" },
		--原版暴雪提供的8个图标
	{ key = "rt1",	zhTW="rt1",		zhCN="rt1",	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1" },
	{ key = "rt2",	zhTW="rt2",		zhCN="rt2",	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2" },
	{ key = "rt3",	zhTW="rt3",		zhCN="rt3",	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3" },
	{ key = "rt4",	zhTW="rt4",		zhCN="rt4",	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4" },
	{ key = "rt5",	zhTW="rt5",		zhCN="rt5",	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5" },
	{ key = "rt6",	zhTW="rt6",		zhCN="rt6",	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6" },
	{ key = "rt7",	zhTW="rt7",		zhCN="rt7",	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7" },
	{ key = "rt8",	zhTW="rt8",		zhCN="rt8",	texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8" },
}

local function ReplaceEmote(value)
	local emote = value:gsub("[%{%}]", "")
	for _, v in ipairs(emotes) do
		if (emote == v.key or emote == v.zhCN or emote == v.zhTW) then
			return "|T".. (v.texture or "Interface\\AddOns\\NDui_Plus\\Media\\Emotes\\".. v.key) ..":16|t"
		end
	end
	return value
end

local function filter(self, event, msg, ...)
	msg = msg:gsub("%{.-%}", ReplaceEmote)
	return false, msg, ...
end

local function EmoteButton_OnClick(self, button)
	local editBox = ChatEdit_ChooseBoxForSend()
	ChatEdit_ActivateChat(editBox)
	editBox:SetText(editBox:GetText():gsub("{$","") .. self.emote)
	if (button == "LeftButton") then
		self:GetParent():Hide()
	end
end

local function EmoteButton_OnEnter(self)
	self:GetParent().title:SetText(self.emote)
end

local function EmoteButton_OnLeave(self)
	self:GetParent().title:SetText("")
end

function CH:ChatEmote()
	if not CH.db["Emote"] then return end

	for _, event in pairs(CH.ChatEvents) do
		ChatFrame_AddMessageEventFilter(event, filter)
	end

	local icon
	local width, height, column, space = 22, 22, 10, 6
	local index = 0

	local panel = CreateFrame("Frame", nil, UIParent)
	panel.title = panel:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
	panel.title:SetPoint("TOP", panel, "TOP", 0, -5)
	panel:SetWidth(column * (width + space) + 12)
	panel:SetClampedToScreen(true)
	panel:SetFrameStrata("DIALOG")
	panel:SetPoint("BOTTOMRIGHT", _G["ChatFrame1EditBox"], "TOPRIGHT", 0, 10)

	for _, v in ipairs(emotes) do
		icon = CreateFrame("Button", nil, panel)
		icon.emote = "{" .. (v[locale] or v.key) .. "}"
		icon:SetSize(width, height)
		if (v.texture) then
			icon:SetNormalTexture(v.texture)
		else
			icon:SetNormalTexture("Interface\\AddOns\\NDui_Plus\\Media\\Emotes\\" .. v.key)
		end
		icon:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
		icon:SetPoint("TOPLEFT", 8+(index%column)*(width+space), -24 - floor(index/column)*(height+space))
		icon:SetScript("OnMouseUp", EmoteButton_OnClick)
		icon:SetScript("OnEnter", EmoteButton_OnEnter)
		icon:SetScript("OnLeave", EmoteButton_OnLeave)
		index = index + 1
	end

	panel:SetHeight(ceil(index / column) * (height + space) + 24)
	B.SetBD(panel)
	panel:Hide()

	hooksecurefunc("ChatEdit_OnHide", function() C_Timer.After(.5, function() panel:Hide() end) end)
	hooksecurefunc("ChatEdit_OnTextChanged", function(self, userInput)
		local text = self:GetText()
		if (userInput and strsub(text, -1) == "{") then
			panel:Show()
		end
	end)

	local lang = _G["ChatFrame1EditBoxLanguage"]
	local button = CreateFrame("Button", nil, _G["ChatFrame1EditBox"])
	button:SetSize(24, 24)
	button:RegisterForClicks("AnyUp")
	button:SetPoint("TOPLEFT", lang, "TOPRIGHT", 5, 0)
	button:SetPoint("BOTTOMRIGHT", lang, "BOTTOMRIGHT", 29, 0)
	button:SetNormalFontObject("DialogButtonNormalText")
	button:SetText(L["Emote"])
	button:GetFontString():SetPoint("CENTER", 2, 0)
	B.SetBD(button)
	button:SetScript("OnClick", function(self) 
		if panel:IsShown() then
			panel:Hide()
		else
			panel:Show()
		end 
	end)

	local function TextToEmote(text)
		text = text:gsub("%{.-%}", ReplaceEmote)
		return text
	end

	local function findChatBubble()
		for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
			local frame = chatBubble:GetChildren()
			if frame and not frame:IsForbidden() then
				local oldMessage = frame.String:GetText()
				local afterMessage = TextToEmote(oldMessage)
				if oldMessage ~= afterMessage then
					frame.String:SetText(afterMessage)
				end
				CH:HookBubble(chatBubble, frame)
			end
		end
	end

	local events = {
		CHAT_MSG_SAY = "chatBubbles",
		CHAT_MSG_YELL = "chatBubbles",
		CHAT_MSG_MONSTER_SAY = "chatBubbles",
		CHAT_MSG_MONSTER_YELL = "chatBubbles",
		CHAT_MSG_PARTY = "chatBubblesParty",
		CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
		CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
	}

	local bubbleHook = CreateFrame("Frame")
	for event in next, events do
		bubbleHook:RegisterEvent(event)
	end
	bubbleHook:SetScript("OnEvent", function(self, event)
		if GetCVarBool(events[event]) then
			self.elapsed = 0
			self:Show()
		end
	end)

	bubbleHook:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > .1 then
			findChatBubble()
			self:Hide()
		end
	end)
	bubbleHook:Hide()
end
