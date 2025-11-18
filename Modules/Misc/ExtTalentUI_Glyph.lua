local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

if not P.IsWrath() then return end

local r, g, b = DB.r, DB.g, DB.b

-- https://nether.wowhead.com/wotlk/data/talents-classic
M.GlyphSpellToIcon = {
	[56799] = 136205, [58364] = 132353, [56847] = 135840, [56368] = 135812, [56384] = 135843, [56416] = 135969, [63091] = 236220, [54931] = 135983, [58620] = 135834, [63235] = 237545,
	[63331] = 135152, [55682] = 136149, [52648] = 327502, [56241] = 136139, [56800] = 132090, [56832] = 132204, [56848] = 135125, [56369] = 135807, [63092] = 236205, [55443] = 135849,
	[58094] = 136194, [63220] = 236250, [63252] = 236277, [58669] = 237518, [63332] = 136132, [55683] = 135922, [56226] = 135827, [56242] = 135789, [56801] = 132302, [58366] = 132338,
	[58382] = 132342, [54821] = 132122, [56370] = 135846, [63093] = 135994, [55444] = 236289, [58015] = 136121, [62135] = 236170, [58063] = 132315, [58079] = 136148, [58095] = 132333,
	[63237] = 237565, [63253] = 236279, [63269] = 136177, [58686] = 136119, [63333] = 136145, [55684] = 135994, [59309] = 136182, [56802] = 132292, [56818] = 132350, [57856] = 132112,
	[56850] = 132369, [56371] = 135827, [55445] = 136018, [58032] = 132289, [58080] = 136162, [58096] = 132277, [58623] = 136120, [63254] = 236273, [58671] = 135771, [63302] = 236298,
	[63334] = 136182, [55685] = 132864, [56228] = 135817, [56244] = 136183, [54743] = 136085, [56803] = 132354, [56819] = 136121, [57857] = 136080, [56851] = 132160, [56372] = 135841,
	[57937] = 135995, [56420] = 135902, [57985] = 135994, [54935] = 135949, [58017] = 133644, [58033] = 132914, [58081] = 136155, [58097] = 132337, [63223] = 237537, [58640] = 237515,
	[63271] = 237577, [63303] = 237558, [63335] = 135833, [55686] = 135926, [56229] = 136191, [59327] = 237529, [54760] = 136100, [56820] = 132274, [58369] = 136012, [58385] = 132155,
	[54824] = 134914, [56373] = 135862, [57954] = 135960, [57986] = 136091, [54936] = 135907, [58098] = 136105, [58625] = 237525, [58657] = 237519, [58673] = 132728, [63304] = 236291,
	[63320] = 136126, [55687] = 136208, [56246] = 136216, [56805] = 136023, [56821] = 136189, [58370] = 132369, [58386] = 132223, [54825] = 136041, [56374] = 135838, [57955] = 135928,
	[57987] = 135928, [54937] = 135920, [58099] = 132350, [63225] = 135967, [58642] = 237530, [63273] = 252995, [55672] = 135940, [55688] = 136206, [56231] = 136210, [56247] = 136221,
	[56806] = 135430, [58355] = 132337, [56838] = 132222, [54810] = 132091, [54826] = 134206, [56375] = 136071, [57924] = 135932, [63066] = 236178, [54922] = 236258, [55449] = 136015,
	[55673] = 135980, [55689] = 135933, [56216] = 136188, [56232] = 136145, [56248] = 136218, [56807] = 136168, [58356] = 136105, [58372] = 132316, [54811] = 132136, [56360] = 136116,
	[56376] = 135848, [57925] = 135992, [63067] = 236174, [54923] = 135963, [55450] = 135824, [58676] = 136168, [63291] = 237579, [59219] = 132120, [55674] = 135953, [55690] = 136091,
	[56217] = 136147, [56233] = 136228, [56249] = 136217, [56808] = 136206, [56824] = 135130, [57862] = 136104, [56856] = 136076, [54828] = 236168, [56377] = 135844, [57926] = 135806,
	[57958] = 135906, [54924] = 135958, [54940] = 135960, [58038] = 132331, [58070] = 136163, [58613] = 136088, [58629] = 136144, [58677] = 136145, [63324] = 236303, [55675] = 135887,
	[55691] = 135739, [56218] = 136118, [56250] = 136220, [54733] = 136080, [56809] = 132155, [56841] = 132218, [54813] = 132135, [54829] = 136096, [54845] = 135753, [57927] = 135850,
	[63069] = 132153, [55436] = 132315, [55452] = 136115, [58039] = 132307, [58055] = 136148, [63229] = 237563, [63309] = 237559, [63325] = 236312, [55676] = 136184, [55692] = 135924,
	[56235] = 135807, [56810] = 132306, [56826] = 132213, [58375] = 134951, [67598] = 132140, [54830] = 136045, [57928] = 135843, [63086] = 132223, [54926] = 132326, [55453] = 136048,
	[54934] = 135903, [55437] = 136042, [70937] = 135862, [58104] = 132342, [58631] = 237526, [58647] = 237520, [68164] = 132351, [57858] = 132117, [57903] = 132293, [63310] = 236302,
	[63326] = 236318, [55677] = 135894, [58357] = 132282, [58384] = 132306, [56804] = 132294, [55446] = 132314, [57870] = 132179, [54925] = 132347, [56811] = 132307, [63270] = 237589,
	[58376] = 135871, [54815] = 136231, [54831] = 136018, [56380] = 136075, [63268] = 132304, [63055] = 236167, [55442] = 136018, [57902] = 132118, [55438] = 136043, [54943] = 135917,
	[63222] = 236265, [56836] = 132330, [58057] = 135863, [63068] = 135826, [65243] = 236169, [58616] = 135675, [63231] = 237542, [54756] = 136006, [54930] = 135874, [58680] = 134228,
	[55451] = 135814, [54939] = 135928, [63327] = 132345, [55678] = 135902, [62970] = 236153, [62969] = 236149, [54938] = 135875, [57900] = 132150, [54812] = 132270, [56844] = 132294,
	[56812] = 132297, [56828] = 132208, [57866] = 132163, [62126] = 135903, [54832] = 136048, [56381] = 136048, [58228] = 136199, [63056] = 236170, [56798] = 132310, [58353] = 136080,
	[54928] = 135926, [55455] = 135790, [56365] = 135736, [59332] = 135772, [58058] = 136010, [57855] = 136078, [58009] = 135987, [56857] = 132252, [62210] = 135735, [63248] = 135936,
	[58367] = 135358, [63280] = 135829, [58368] = 132355, [63312] = 136160, [63328] = 132361, [55679] = 135907, [58388] = 135291, [55448] = 136048, [56238] = 136168, [56364] = 136082,
	[59336] = 237517, [61205] = 236217, [56813] = 132282, [56829] = 132212, [56845] = 135834, [63057] = 136097, [56366] = 132220, [56382] = 132221, [58107] = 136154, [57947] = 135974,
	[63095] = 135988, [57979] = 135970, [55440] = 136052, [55456] = 135127, [58027] = 136058, [56842] = 132329, [58059] = 136080, [62080] = 236168, [54929] = 135068, [58618] = 136214,
	[56414] = 132325, [63249] = 236276, [58387] = 132363, [62259] = 237532, [55447] = 135813, [56363] = 136096, [63329] = 132362, [55680] = 135943, [55454] = 237582, [59289] = 136095,
	[54927] = 135891, [55439] = 237575, [58377] = 132365, [54754] = 136081, [56814] = 136136, [56830] = 132127, [56846] = 135813, [54818] = 132152, [56367] = 134134, [56383] = 135991,
	[62971] = 236162, [59307] = 132099, [63065] = 236176, [63090] = 236214, [55441] = 135861, [63279] = 136089, [63219] = 236253, [62132] = 237589, [63246] = 135982, [58365] = 132350,
	[63256] = 236283, [63218] = 236247, [58635] = 132388, [57904] = 132242, [60200] = 136119, [56833] = 132179, [63298] = 136097, [56849] = 132211, [63330] = 135277, [55681] = 136207,
	[63224] = 135972, [56224] = 135230, [56240] = 136197, [70947] = 136118, [71013] = 136081, [55115] = 135068, [405004] = 135984, [413895] = 136017, [414812] = 311430
}

local GLYPHTYPE_MAJOR = 1
local GLYPHTYPE_MINOR = 2
local NUM_GLYPH_SLOTS = 6

local GlyphMap = {
	[1] = 1,
	[2] = 4,
	[3] = 6,
	[4] = 2,
	[5] = 3,
	[6] = 5,
}

StaticPopupDialogs["NDUIPLUS_CONFIRM_REMOVE_GLYPH"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		local talentGroup = M.TalentUI and M.TalentUI.talentGroup or 1
		if talentGroup == C_SpecializationInfo.GetActiveSpecGroup() then
			RemoveGlyphFromSocket(self.data.id)
		end
	end,
	OnCancel = function (self)
	end,
	OnShow = function(self)
		self.text:SetFormattedText(CONFIRM_GLYPH_REMOVAL, self.data.name)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

local function GlyphButton_OnClick(self, button)
	local id = self:GetID()
	local talentGroup = M.TalentUI.talentGroup

	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local link = GetGlyphLink(id, talentGroup)
		if link then
			ChatEdit_InsertLink(link)
		end
	elseif button == "RightButton" then
		if IsShiftKeyDown() and talentGroup == C_SpecializationInfo.GetActiveSpecGroup() then
			if self.glyphName then
				StaticPopup_Show("NDUIPLUS_CONFIRM_REMOVE_GLYPH", nil, nil, {name = self.glyphName, id = id})
			end
		end
	elseif talentGroup == C_SpecializationInfo.GetActiveSpecGroup() then
		if self.glyphName and GlyphMatchesSocket(id) then
			local newGlyphName = GetPendingGlyphInfo()
			if newGlyphName then
				StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", nil, nil, {id = id, currentName = self.glyphName, name = newGlyphName})
			end
		else
			PlaceGlyphInSocket(id)
		end
	end
end

local function GlyphButton_OnEnter(self)
	if self.enabled then
		self.bg:SetBackdropBorderColor(r, g, b)
	end

	_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	_G.GameTooltip:SetGlyph(self:GetID(), M.TalentUI.talentGroup)
	_G.GameTooltip:Show()
end

local function GlyphButton_OnLeave(self)
	if self.enabled then
		self.bg:SetBackdropBorderColor(0, 0, 0)
	end

	_G.GameTooltip:Hide()
end

function M:GlyphUI_Create(id)
	local button = CreateFrame("Button", "NDuiPlusGlyph"..id, self)
	button:SetSize(190, 50)
	button:SetID(id)

	button.bg = B.CreateBDFrame(button, .25)
	B.CreateSD(button.bg, 8, true)
	button.bg.__shadow:SetBackdropBorderColor(r, g, b, 1)
	button.bg.__shadow:SetFrameLevel(button.bg:GetFrameLevel()-1)
	button.bg.__shadow:Hide()

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetSize(40, 40)
	icon:SetPoint("LEFT", 5, 0)
	B.ReskinIcon(icon)
	button.icon = icon

	local name = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	name:SetTextColor(1, 1, 1, 1)
	name:SetPoint("LEFT", icon, "RIGHT", 10, 0)
	button.name = name

	button:SetScript("OnClick", GlyphButton_OnClick)
	button:SetScript("OnEnter", GlyphButton_OnEnter)
	button:SetScript("OnLeave", GlyphButton_OnLeave)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	return button
end

function M:GlyphUI_UpdateSlot()
	local id = self:GetID()
	local talentGroup = M.TalentUI.talentGroup
	local enabled, glyphType, _, glyphSpell, iconFile = GetGlyphSocketInfo(id, talentGroup)

	self.enabled = enabled
	self.glyphType = glyphType
	self.bg:SetBackdropColor(0, 0, 0, .25)

	if self.IsFlashing then
		self.bg.__shadow:Hide()
		P:StopFlash(self.bg.__shadow, 1, true)
		self.IsFlashing = nil
	end

	if not glyphSpell then
		self.spell = nil
		self.glyphName = nil
		self.name:SetText("")
		self.icon:SetTexture(nil)

		if not enabled then
			self.bg:SetBackdropColor(.5, .5, .5, .25)
		end
	else
		self.spell = glyphSpell
		self.glyphName = GetSpellInfo(glyphSpell)
		self.name:SetText(self.glyphName)
		self.icon:SetTexture(M.GlyphSpellToIcon[glyphSpell] or iconFile)
	end
end

function M:GlyphUI_Update()
	if not M.GlyphUI or not M.GlyphUI:IsVisible() then return end

	local isActiveTalentGroup = not M.TalentUI.pet and M.TalentUI.talentGroup == C_SpecializationInfo.GetActiveSpecGroup(false, M.TalentUI.pet)

	for i = 1, NUM_GLYPH_SLOTS do
		SetDesaturation(M.GlyphUI.slots[i].icon, not isActiveTalentGroup)
		M.GlyphUI_UpdateSlot(M.GlyphUI.slots[i])
	end
end

function M.GlyphUI_OnShow(self)
	PlaySound(SOUNDKIT.TALENT_SCREEN_OPEN)
	M:GlyphUI_Update()
end

function M.GlyphUI_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= .1 then
		for i = 1, NUM_GLYPH_SLOTS do
			local button = M.GlyphUI.slots[i]
			local id = button:GetID()
			local shadow = button.bg.__shadow
			if button.enabled then
				if GlyphMatchesSocket(id) then
					if not button.IsFlashing then
						shadow:Show()
						P:Flash(shadow, 1, true)
						button.IsFlashing = true
					end
				else
					if button.IsFlashing then
						shadow:Hide()
						P:StopFlash(shadow, 1, true)
						button.IsFlashing = nil
					end
				end
			end
		end

		self.elapsed = 0
	end
end

function M.GlyphUI_GlyphUpdate(event, index)
	local glyph = M.GlyphUI.slots[index]
	if glyph and M.GlyphUI:IsVisible() then
		M.GlyphUI_UpdateSlot(glyph)
		local glyphType = glyph.glyphType
		if event == "GLYPH_ADDED" or event == "GLYPH_UPDATED" then
			if glyphType == GLYPHTYPE_MINOR then
				PlaySound(SOUNDKIT.GLYPH_MINOR_CREATE)
			elseif glyphType == GLYPHTYPE_MAJOR then
				PlaySound(SOUNDKIT.GLYPH_MAJOR_CREATE)
			end
		elseif event == "GLYPH_REMOVED" then
			if glyphType == GLYPHTYPE_MINOR then
				PlaySound(SOUNDKIT.GLYPH_MINOR_DESTROY)
			elseif glyphType == GLYPHTYPE_MAJOR then
				PlaySound(SOUNDKIT.GLYPH_MAJOR_DESTROY)
			end
		end
	end

	if _G.GameTooltip:IsOwned(glyph) then
		GlyphButton_OnEnter(glyph)
	end
end

function M.GlyphUI_Open()
	if M.db["TalentExpand"] then
		if M.GlyphUI:IsVisible() then
			M:GlyphUI_Update()
		else
			M.TalentUI:Show()
			M.GlyphUI:Show()
		end
	else
		OpenGlyphFrame()
	end
end

function M:GlyphUI_Init()
	local frame = CreateFrame("Frame", "NDuiPlusGlyphFrame", M.TalentUI)
	frame:SetSize(238, M.TalentUI.playerHeight)
	frame:SetPoint("TOPRIGHT", M.TalentUI, "TOPLEFT", -4, 0)
	frame:SetFrameLevel(15)
	B.SetBD(frame)
	B.CreateMF(frame, M.TalentUI)
	frame:SetClampedToScreen(true)
	frame:SetScript("OnShow", M.GlyphUI_OnShow)
	frame:SetScript("OnHide", function() PlaySound(SOUNDKIT.TALENT_SCREEN_CLOSE) end)
	frame:SetScript("OnUpdate", M.GlyphUI_OnUpdate)
	frame:Hide()
	M.GlyphUI = frame

	local Close = CreateFrame("Button", nil, frame)
	B.ReskinClose(Close)
	Close:SetScript("OnClick", function()
		frame:Hide()
	end)
	frame.Close = Close

	frame.slots = {}
	for index, id in ipairs(GlyphMap) do
		local glyph = M.GlyphUI_Create(frame, id)
		if index == 1 then
			glyph:SetPoint("TOPLEFT", 24, -100)
		elseif index == 4 then
			glyph:SetPoint("TOPLEFT", 24, -100-383)
		else
			glyph:SetPoint("TOP", frame.slots[GlyphMap[index-1]], "BOTTOM", 0, -24)
		end
		frame.slots[id] = glyph
	end

	frame.labels = {}
	for i = 1, 2 do
		local label = frame:CreateFontString(nil, "OVERLAY")
		label:SetFont(DB.Font[1], 16, DB.Font[3])
		label:SetTextColor(1, .8, 0)
		label:SetPoint("CENTER", frame, "TOP", 0, i == 1 and -50 or -50-383)
		label:SetText(i == 1 and MAJOR_GLYPH or MINOR_GLYPH)
		frame.labels[i] = label
	end

	B:RegisterEvent("PLAYER_LEVEL_UP", M.GlyphUI_Update)
	B:RegisterEvent("GLYPH_ADDED", M.GlyphUI_GlyphUpdate)
	B:RegisterEvent("GLYPH_REMOVED", M.GlyphUI_GlyphUpdate)
	B:RegisterEvent("GLYPH_UPDATED", M.GlyphUI_GlyphUpdate)
	_G.UIParent:UnregisterEvent("USE_GLYPH")
	B:RegisterEvent("USE_GLYPH", M.GlyphUI_Open)

	_G.ToggleGlyphFrame = function()
		if M.db["TalentExpand"] then
			if M.TalentUI:IsShown() then
				M.TalentUI:Hide()
			else
				M.TalentUI:Show()
				M.GlyphUI:Show()
			end
		else
			if not C_AddOns.IsAddOnLoaded("Blizzard_TalentUI") then TalentFrame_LoadUI() end
			if not C_AddOns.IsAddOnLoaded("Blizzard_GlyphUI") then GlyphFrame_LoadUI() end

			if GlyphFrame_Toggle then
				GlyphFrame_Toggle()
			end
		end
	end
end