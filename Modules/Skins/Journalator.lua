local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function reskinFilterButton(self)
	if not self then P:Debug("Unknown: FilterButton") return end

	B.StripTextures(self)
	B.Reskin(self)
	if self.Text then
		self.Text:SetPoint("CENTER")
	end
	if self.Icon then
		B.SetupArrow(self.Icon, "right")
		self.Icon:SetPoint("RIGHT")
		self.Icon:SetSize(14, 14)
	end
end

local function reskinTabbedView(self)
	for i, tab in ipairs(self.Tabs) do
		B.ReskinTab(tab)

		if i == 1 then
			tab:ClearAllPoints()
			tab:SetPoint("BOTTOMLEFT", 20, 10)
		end
	end
end

local function reskinListIcon(self)
	if not self.tableBuilder then return end

	for _, row in ipairs(self.tableBuilder.rows) do
		local cells = row.cells
		if cells then
			for _, cell in ipairs(cells) do
				if cell and cell.Icon then
					if not cell.styled then
						cell.Icon.bg = B.ReskinIcon(cell.Icon)
						if cell.IconBorder then cell.IconBorder:Hide() end
						cell.styled = true
					end
					cell.Icon.bg:SetShown(cell.Icon:IsShown())
				end
			end
		end
	end
end

local function reskinListHeader(frame)
	if not frame or not frame.tableBuilder or not frame.ScrollArea then P:Debug("Unknown: ListHeader") return end

	B.CreateBDFrame(frame.ScrollArea, .25)
	S:Proxy("ReskinTrimScroll", frame.ScrollArea.ScrollBar)

	for _, column in ipairs(frame.tableBuilder.columns) do
		local header = column.headerFrame
		if header then
			header:DisableDrawLayer("BACKGROUND")
			header.bg = B.CreateBDFrame(header)
			header.bg:SetPoint("BOTTOMRIGHT", -2, -C.mult)
			local hl = header:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .1)
			hl:SetAllPoints(header.bg)
		end
	end

	if frame.UpdateTable then
		hooksecurefunc(frame, "UpdateTable", reskinListIcon)
	end
end

local function reskinTabDisplay(self)
	S:Proxy("StripTextures", self.ResultsListingInset)
	reskinListHeader(self.ResultsListing)
end

local function reskinInfoDisplay(self)
	if not self.styled then
		S:Proxy("StripTextures", self.Inset)
		B.CreateBDFrame(self, .25)
		S:Proxy("Reskin", self.OptionsButton)

		self.styled = true
	end
end

function S:Journalator()
	local Journalator = _G.Journalator
	if not Journalator then return end

	hooksecurefunc(_G.JournalatorDisplayMixin, "OnLoad", function()
		local frame = _G.JNRView
		B.ReskinPortraitFrame(frame)

		for _, tab in ipairs(frame.Tabs) do
			B.ReskinTab(tab)
		end

		local Filters = frame.Filters
		if Filters then
			S:Proxy("ReskinInput", Filters.SearchFilter)
			reskinFilterButton(Filters.RealmDropDown)
			reskinFilterButton(Filters.CharacterDropDown)
			P.ReskinDropDown(Filters.FactionDropDown.DropDown)
			P.ReskinDropDown(Filters.TimePeriodDropDown.DropDown)
		end

		local ExportCSV = _G.JournalatorExportCSVTextFrame
		if ExportCSV then
			S:Proxy("StripTextures", ExportCSV)
			S:Proxy("SetBD", ExportCSV)
			S:Proxy("Reskin", ExportCSV.Close)
			S:Proxy("ReskinTrimScroll", ExportCSV.ScrollBar)
		end

		S:Proxy("Reskin", frame.ExportCSV)
	end)

	hooksecurefunc(_G.JournalatorTabbedViewMixin, "OnLoad", reskinTabbedView)
	hooksecurefunc(_G.JournalatorDataTabDisplayMixin, "OnLoad", reskinTabDisplay)
	hooksecurefunc(_G.JournalatorInfoDisplayMixin, "OnShow", reskinInfoDisplay)
end

S:RegisterSkin("Journalator_Display", S.Journalator)