local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local pairs = pairs

local Media = "Interface\\Addons\\NDui_Plus\\Media\\Texture\\"

local function reskinFrame(frame)
	B.StripTextures(frame)
	local bg = B.SetBD(frame)
	bg:SetInside()
end

local function reskinArrow(button, name)
	button:SetNormalTexture(Media.."UI-ChatIcon-Scroll"..name.."-Up")
	button:SetPushedTexture(Media.."UI-ChatIcon-Scroll"..name.."-Down")
	button:SetDisabledTexture(Media.."UI-ChatIcon-Scroll"..name.."-Disabled")
	if button.flashFrame then
		button.flashFrame.texture:SetTexture(Media.."UI-ChatIcon-BlinkHilight")
	end
end

local function reskinListFont()
	local listButtons = _G.WhisperPopFrameList.listButtons
	for _, button in pairs(listButtons) do
		if button.text and not button.styled then
			P.ReskinFont(button.text)
			button.styled = true
		end
	end
end

function S:WhisperPop()
	if not S.db["WhisperPop"] then return end

	local cr, cg, cb = DB.r, DB.g, DB.b

	reskinFrame(WhisperPopFrame)
	reskinFrame(WhisperPopMessageFrame)
	reskinArrow(WhisperPopScrollingMessageFrameButtonUp, "Up")
	reskinArrow(WhisperPopScrollingMessageFrameButtonDown, "Down")
	reskinArrow(WhisperPopScrollingMessageFrameButtonEnd, "End")
	B.ReskinScroll(WhisperPopFrameListScrollBar)
	if WhisperPopMessageFrameProtectCheck then
		B.ReskinCheck(WhisperPopMessageFrameProtectCheck)
	end

	local listHL = WhisperPopFrameListHighlightTexture
	listHL:SetTexture(DB.bdTex)
	listHL:SetVertexColor(cr, cg, cb, .25)

	local lists = {WhisperPopFrameListDelete, WhisperPopFrameTopCloseButton, WhisperPopMessageFrameTopCloseButton}
	for _, list in pairs(lists) do
		B.ReskinClose(list)
	end

	local config = _G.WhisperPopFrameConfig
	config:ClearNormalTexture()
	config:ClearPushedTexture()
	config:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	B.ReskinIcon(config.icon)

	local notify = _G.WhisperPopNotifyButton
	B.Reskin(notify)
	notify:SetCheckedTexture(0)
	notify.icon:SetDesaturated(false)
	notify.icon.SetDesaturated = B.Dummy
	notify.icon:SetSize(13, 13)
	notify.icon:SetTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")

	WhisperPopFrameList:HookScript("OnShow", reskinListFont)
	WhisperPopFrameList:HookScript("OnSizeChanged", reskinListFont)
end

S:RegisterSkin("WhisperPop", S.WhisperPop)