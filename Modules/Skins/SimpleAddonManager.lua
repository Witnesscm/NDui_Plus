local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")
--------------------------
-- Credit: ElvUI_WindTools
--------------------------
local _G = _G
local hooksecurefunc = hooksecurefunc
local pairs = pairs

local function ReskinScrollFrameItems(frame, template)
	if template == "SimpleAddonManagerAddonItem" or template == "SimpleAddonManagerCategoryItem" then
		for _, btn in pairs(frame.buttons) do
			if not btn.styled then
				S:Proxy("ReskinCheck", btn.EnabledButton)
				if btn.ExpandOrCollapseButton then
					B.ReskinCollapse(btn.ExpandOrCollapseButton)
				end
				btn.styled = true
			end
		end
	end
end

local function ReskinSizer(frame)
	if not frame then
		return
	end

	frame:SetPoint("BOTTOMRIGHT")
end

local function SAMDropDownSkin(frame)
	if not frame then
		return
	end

	frame:SetWidth(180)
	frame:SetHeight(32)
	P.ReskinDropDown(frame)
	frame.Button:SetSize(20, 20)
	frame.Text:ClearAllPoints()
	frame.Text:SetPoint("RIGHT", frame.Button, "LEFT", -2, 0)
end

local function ReskinModules(frame)
	-- MainFrame
	S:Proxy("Reskin", frame.OkButton)
	S:Proxy("Reskin", frame.CancelButton)
	S:Proxy("Reskin", frame.EnableAllButton)
	S:Proxy("Reskin", frame.DisableAllButton)
	SAMDropDownSkin(frame.CharacterDropDown)

	frame.OkButton:ClearAllPoints()
	frame.OkButton:SetPoint("RIGHT", frame.CancelButton, "LEFT", -2, 0)
	frame.DisableAllButton:ClearAllPoints()
	frame.DisableAllButton:SetPoint("LEFT", frame.EnableAllButton, "RIGHT", 2, 0)
	ReskinSizer(frame.Sizer)

	-- SearchBox
	S:Proxy("ReskinInput", frame.SearchBox)
	S:Proxy("ReskinArrow", frame.ResultOptionsButton, "down")

	-- AddonListFrame
	S:Proxy("ReskinScroll", frame.ScrollFrame.ScrollBar)

	-- CategoryFrame
	S:Proxy("Reskin", frame.CategoryFrame.NewButton)
	S:Proxy("Reskin", frame.CategoryFrame.SelectAllButton)
	S:Proxy("Reskin", frame.CategoryFrame.ClearSelectionButton)
	S:Proxy("Reskin", frame.CategoryButton)
	S:Proxy("ReskinScroll", frame.CategoryFrame.ScrollFrame.ScrollBar)

	frame.CategoryFrame.NewButton:ClearAllPoints()
	frame.CategoryFrame.NewButton:SetHeight(20)
	frame.CategoryFrame.NewButton:SetPoint("BOTTOMLEFT", frame.CategoryFrame.SelectAllButton, "TOPLEFT", 0, 2)
	frame.CategoryFrame.NewButton:SetPoint("BOTTOMRIGHT", frame.CategoryFrame.ClearSelectionButton, "TOPRIGHT", 0, 2)

	-- Profile
	S:Proxy("Reskin", frame.SetsButton)
	S:Proxy("Reskin", frame.ConfigButton)

	-- Misc
	hooksecurefunc("HybridScrollFrame_CreateButtons", ReskinScrollFrameItems)
	ReskinScrollFrameItems(frame.ScrollFrame, "SimpleAddonManagerAddonItem")
	ReskinScrollFrameItems(frame.CategoryFrame.ScrollFrame, "SimpleAddonManagerCategoryItem")
end

function S:SimpleAddonManager()
	local SimpleAddonManager = _G.SimpleAddonManager
	if not SimpleAddonManager then return end

	B.StripTextures(SimpleAddonManager)
	B.SetBD(SimpleAddonManager)
	S:Proxy("ReskinClose", SimpleAddonManager.CloseButton)
	hooksecurefunc(SimpleAddonManager, "Initialize", ReskinModules)
end

S:RegisterSkin("SimpleAddonManager", S.SimpleAddonManager)