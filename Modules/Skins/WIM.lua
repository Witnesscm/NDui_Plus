local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function DisableTexture(button)
	for _, func in pairs({"SetNormalTexture", "SetPushedTexture", "SetDisabledTexture", "SetHighlightTexture", "SetWidth", "SetHeight"}) do
		if button[func] then button[func] = B.Dummy end
	end
end

local function HandleChatFrame(frame)
	if frame.styled then return end

	local backdrop = frame.widgets.Backdrop
	local msgbox = frame.widgets.msg_box
	local chat = frame.widgets.chat_display
	local up = frame.widgets.scroll_up
	local down = frame.widgets.scroll_down

	for _, v in pairs({"tl", "tr", "bl", "br", "t", "b", "l", "r", "bg"}) do
		backdrop[v]:SetTexture(nil)
		backdrop[v].SetTexture = B.Dummy
	end
	B.SetBD(backdrop)

	msgbox.bg = B.CreateBDFrame(msgbox, .25)
	msgbox.bg:SetPoint("TOPLEFT", -6, -2)
	msgbox.bg:SetPoint("BOTTOMRIGHT", C.mult, 2)

	chat.bg = B.CreateBDFrame(chat, .25)
	chat.bg:SetPoint("TOPLEFT", -6, C.mult)
	chat.bg:SetPoint("BOTTOMRIGHT", 4, -6)

	B.ReskinArrow(up, "up")
	up:SetPoint("TOPRIGHT", -10, -49)
	DisableTexture(up)
	B.ReskinArrow(down, "down")
	down:SetPoint("BOTTOMRIGHT", -10, 33)
	DisableTexture(down)

	frame.circle = frame:CreateTexture(nil, "BACKGROUND");
	frame.circle:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
	frame.circle:SetSize(40, 40)
	frame.circle:SetPoint("TOPLEFT", 2, -2)
	frame.circle:Hide()

	if frame.UpdateIcon then
		hooksecurefunc(frame, "UpdateIcon", function(self)
			self.circle:Hide()
			if _G.WIM.constants.classes[self.class] then
				local classTag = _G.WIM.constants.classes[self.class].tag
				local tcoords = CLASS_ICON_TCOORDS[classTag]
				if tcoords then
					self.widgets.class_icon:SetTexture(nil)
					self.circle:SetTexCoord(tcoords[1], tcoords[2], tcoords[3], tcoords[4])
					self.circle:Show()
				end
			end
		end)
	end

	frame.styled = true
end

local function HandleIconButton(button)
	if button.icon and not button.styled then
		B.ReskinIcon(button:GetNormalTexture())
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button:SetPushedTexture(0)
		button.SetPushedTexture = B.Dummy
		button.icon:SetTexCoord(unpack(DB.TexCoord))

		button.styled = true
	end
end

local function HandleWindow()
	local index = 1
	local msgFrame = _G["WIM3_msgFrame"..index]
	while msgFrame do
		HandleChatFrame(msgFrame)
		index = index + 1
		msgFrame = _G["WIM3_msgFrame"..index]
	end

	index = 1
	local button = _G["WIM_ShortcutBarButton"..index]
	while button do
		HandleIconButton(button)
		index = index + 1
		button = _G["WIM_ShortcutBarButton"..index]
	end
end

function S:WIM()
	local WIM = _G.WIM
	if not WIM then return end

	local minimap = _G.WIM3MinimapButton
	if minimap then
		minimap.backGround:SetTexture("")
		minimap:DisableDrawLayer("OVERLAY")
	end

	hooksecurefunc(WIM, "CreateWhisperWindow", HandleWindow)
	hooksecurefunc(WIM, "CreateChatWindow", HandleWindow)
	hooksecurefunc(WIM, "CreateW2WWindow", HandleWindow)
	hooksecurefunc(WIM, "ShowDemoWindow", HandleWindow)
	hooksecurefunc(WIM, "PopContextMenu", function()
		S:SkinDropDownMenu("LibDropDownMenu_List1")
	end)
end

S:RegisterSkin("WIM", S.WIM)