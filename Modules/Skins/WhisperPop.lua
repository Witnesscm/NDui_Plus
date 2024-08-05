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

	reskinFrame(_G.WhisperPopFrame)
	reskinFrame(_G.WhisperPopMessageFrame)
	reskinArrow(_G.WhisperPopScrollingMessageFrameButtonUp, "Up")
	reskinArrow(_G.WhisperPopScrollingMessageFrameButtonDown, "Down")
	reskinArrow(_G.WhisperPopScrollingMessageFrameButtonEnd, "End")
	S:Proxy("ReskinScroll", _G.WhisperPopFrameListScrollBar)
	S:Proxy("ReskinCheck", _G.WhisperPopMessageFrameProtectCheck)
	S:Proxy("ReskinClose", _G.WhisperPopFrameTopCloseButton)
	S:Proxy("ReskinClose", _G.WhisperPopMessageFrameTopCloseButton)
	S:Proxy("ReskinClose", _G.WhisperPopFrameListDelete, nil, nil, nil, true)
	_G.WhisperPopFrameList:HookScript("OnShow", reskinListFont)
	_G.WhisperPopFrameList:HookScript("OnSizeChanged", reskinListFont)

	local HL = _G.WhisperPopFrameListHighlightTexture
	HL:SetTexture(DB.bdTex)
	HL:SetVertexColor(DB.r, DB.g, DB.b, .25)

	local config = _G.WhisperPopFrameConfig
	config:SetNormalTexture(0)
	config:SetPushedTexture(0)
	config:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	B.ReskinIcon(config.icon)

	local notify = _G.WhisperPopNotifyButton
	B.Reskin(notify)
	notify:SetCheckedTexture(0)
	notify.icon:SetDesaturated(false)
	notify.icon.SetDesaturated = B.Dummy
	notify.icon:SetSize(13, 13)
	notify.icon:SetTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")
end

S:RegisterSkin("WhisperPop", S.WhisperPop)