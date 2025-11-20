local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local _G = getfenv(0)
local select = select

function S:TradeLog()
	B.ReskinCheck(TBT_AnnounceCB)
	B.ReskinDropDown(TBT_AnnounceChannelDropDown)
	UIDropDownMenu_SetWidth(TBT_AnnounceChannelDropDown, 60)

	B.StripTextures(TradeListFrame)
	B.SetBD(TradeListFrame)
	B.Reskin(TradeListKeepOnlyTodayButton)
	B.ReskinClose(TradeListFrameClose)
	B.ReskinCheck(TradeListOnlyCompleteCB)
	B.ReskinSlider(TradeLogFrameScaleSlider)
	B.ReskinScroll(TradeListScrollFrameScrollBar)
	if _G.TradeListDescending then B.ReskinCheck(_G.TradeListDescending) end

	if TradeListScrollFrameScrollBar.SetBackdrop then
		TradeListScrollFrameScrollBar.SetBackdrop = B.Dummy
	end

	for i = 1, 6 do
		local header = _G["TradeListFrameColumnHeader"..i]
		B.StripTextures(header)
	end

	B.StripTextures(TradeLogFrame)
	B.SetBD(TradeLogFrame)
	B.ReskinClose(TradeLogFrameClose)
	B.CreateMF(TradeLogFrame)

	local function reskinButton(bu)
		bu:SetNormalTexture(0)
		bu:SetPushedTexture(0)
		local hl = bu:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside()
		local icon = _G[bu:GetName().."IconTexture"]
		icon:SetTexCoord(unpack(DB.TexCoord))
		icon:SetInside()
		bu.bg = B.CreateBDFrame(icon, .25)
		local bd = B.CreateBDFrame(bu, .25)
		bd:SetPoint("TOPLEFT", bu, "TOPRIGHT", C.mult, 0)
		bd:SetPoint("BOTTOMRIGHT", 80, 0)
		--B.ReskinIconBorder(bu.IconBorder)
	end

	for i = 1, MAX_TRADE_ITEMS do
		_G["TradeLogPlayerItem"..i.."SlotTexture"]:Hide()
		_G["TradeLogPlayerItem"..i.."NameFrame"]:Hide()
		_G["TradeLogRecipientItem"..i.."SlotTexture"]:Hide()
		_G["TradeLogRecipientItem"..i.."NameFrame"]:Hide()

		reskinButton(_G["TradeLogPlayerItem"..i.."ItemButton"])
		reskinButton(_G["TradeLogRecipientItem"..i.."ItemButton"])
	end

	if TBTFrame then		-- version check
		P:Delay(.5, function()
			for _, button in ipairs({"TradeFrameTargetWhisperButton", "TradeFrameTargetEmote1Button", "TradeFrameTargetEmote2Button"}) do
				local bu = _G[button]
				if bu then
					B.Reskin(bu)
				end
			end

			for i = 1, 3 do
				local bu = _G["TradeFramePlayerSpell"..i.."Button"]
				if bu then
					B.ReskinIcon(bu:GetNormalTexture())
					bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				end
			end

			for i = 1, TradeFrame:GetNumRegions() do
				local region = select(i, TradeFrame:GetRegions())
				if region:GetObjectType() == "FontString" and region:GetName() == nil then
					region:Hide()
				end
			end
		end)
	end

	if RecentTradeFrame then		-- version check
		RecentTradeFrame:ClearAllPoints()
		RecentTradeFrame:SetPoint("TOPLEFT", TradeFrame, "TOPRIGHT", 3, 0)
		RecentTradeFrame:SetPoint("BOTTOMLEFT", TradeFrame, "BOTTOMRIGHT", 3, 0)
		B.StripTextures(RecentTradeFrame)
		B.SetBD(RecentTradeFrame)
		B.ReskinClose(RecentTradeFrameClose)
	end
end

S:RegisterSkin("TradeLog", S.TradeLog)