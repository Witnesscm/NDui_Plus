local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function SkinScrollBar(self)
	if not self then
		P.Developer_ThrowError("scrollbar is nil")
		return
	end

	S:Proxy("ReskinScroll", self.scrollBar or self.ScrollBar)
end

local function SkinInfoFrame(self)
	if not self then
		P.Developer_ThrowError("frame is nil")
		return
	end

	B.StripTextures(self)
	B.SetBD(self)
	S:Proxy("ReskinClose", self.CloseButton)
end

local function SkinSortOrder(self)
	if not self.UpdateList then
		P.Developer_ThrowError("func is nil")
		return
	end

	hooksecurefunc(self, "RefreshList", function()
		local buttons = self.scrollFrame and self.scrollFrame.buttons
		if buttons then
			for _, bu in ipairs(buttons) do
				if not bu.styled then
					S:Proxy("ReskinInput", bu.SortBox, 18)
					bu.styled = true
				end
			end
		end
	end)
end

local function SkinBagSyncFrame(name, module)
	local frame = module.frame
	if not frame then return end

	B.StripTextures(frame)
	B.SetBD(frame)

	if frame.closeBtn then
		B.ReskinClose(frame.closeBtn)
	end

	if frame.SearchBox then
		B.ReskinInput(frame.SearchBox)
	end

	if module.scrollFrame then
		S:Proxy("ReskinScroll", module.scrollFrame.scrollBar)
	end

	if module.warningFrame then
		SkinInfoFrame(module.warningFrame)
	end

	for _, key in ipairs({"PlusButton", "RefreshButton", "HelpButton"}) do
		local bu = frame[key]
		if bu then
			B.Reskin(bu)
		end
	end

	if name == "Search" then
		S:Proxy("Reskin", frame.searchFiltersBtn)
		S:Proxy("Reskin", frame.resetButton)
		SkinInfoFrame(module.helpFrame)
		SkinScrollBar(module.helpFrame.ScrollFrame)
		SkinInfoFrame(module.savedSearch)
		SkinScrollBar(module.savedSearch.scrollFrame)
		S:Proxy("Reskin", module.savedSearch.addSavedBtn)
	elseif name == "SearchFilters" then
		SkinScrollBar(module.playerScroll)
		SkinScrollBar(module.locationScroll)
		S:Proxy("Reskin", frame.selectAllButton)
		S:Proxy("Reskin", frame.resetButton)
	elseif name == "Blacklist" then
		P.ReskinDropDown(frame.guildDD)
		S:Proxy("Reskin", frame.addGuildBtn)
		S:Proxy("Reskin", frame.addItemIDBtn)
		S:Proxy("ReskinInput", frame.itemIDBox)
	elseif name == "Whitelist" then
		S:Proxy("Reskin", frame.addItemIDBtn)
		S:Proxy("ReskinInput", frame.itemIDBox)
	elseif name == "SortOrder" then
		SkinSortOrder(module)
	end
end

function S:BagSync()
	local BagSync = _G.BagSync
	if not BagSync then return end

	for name, module in pairs(BagSync._modulesByName) do
		SkinBagSyncFrame(name, module)
	end

	local ExtTip = BagSync:GetModule("ExtTip")
	if ExtTip then
		P:SecureHook(ExtTip, "EnsureTip", function(self)
			P.ReskinTooltip(self.extTip)
		end)
	end
end

S:RegisterSkin("BagSync", S.BagSync)