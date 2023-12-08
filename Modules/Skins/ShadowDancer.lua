local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

function S:ShadowDancer()
	if not S.db["ShadowDancer"] then return end

	Scorpio "ShadowDancer.NDuiSkin" ""

	__SystemEvent__()
	function SHADOWDANCER_OPEN_MENU(self, menu)
		for _, info in ipairs(menu) do
			if info.text == _Locale["Masque Skin"] then
				info.disabled = true
			end
		end
	end

	SKIN_NAME = "ShadowDancer.NDuiSkin"
	Style.RegisterSkin(SKIN_NAME)

	UI.Property{
		name = "ShadowBackgroundFrame",
		require = DancerButton,
		childtype = Frame,
	}

	SKIN_STYLE = {
		[DancerButton] = {
			FlyoutBorder = NIL,
			FlyoutBorderShadow = NIL,
			EquippedItemTexture = NIL,
			FlashTexture = NIL,
			BackgroundFrame = {
				backdrop = {bgFile = DB.bdTex, edgeFile = DB.bdTex, edgeSize = C.mult},
				backdropColor = Color(.2, .2, .2, .25),
				backdropBorderColor = Color(0, 0, 0, 1),
				frameLevel = 0,
				location = {
					Anchor("TOPLEFT", -C.mult, C.mult, "IconTexture"),
					Anchor("BOTTOMRIGHT", C.mult, -C.mult, "IconTexture"),
				},
			},
			ShadowBackgroundFrame = {
				backdrop = {edgeFile = DB.glowTex, edgeSize = 5},
				backdropBorderColor = Color(0, 0, 0, .4),
				frameLevel = 1,
				location = {
					Anchor("TOPLEFT", -4, 4, "BackgroundFrame"),
					Anchor("BOTTOMRIGHT", 4, -4, "BackgroundFrame"),
				},
			},
			BackgroundTexture = {
				file = DB.bgTex,
				hWrapMode = "REPEAT",
				vWrapMode = "REPEAT",
				alphaMode = "ADD",
				drawLayer = "BACKGROUND",
				horizTile = true,
				vertTile = true,
				subLevel = -1,
				location = {
					Anchor("TOPLEFT", 0, 0, "BackgroundFrame"),
					Anchor("BOTTOMRIGHT", 0, 0, "BackgroundFrame"),
				},
			},
			IconTexture = {
				texCoords = RectType(unpack(DB.TexCoord)),
				location = {
					Anchor("TOPLEFT", C.mult, -C.mult),
					Anchor("BOTTOMRIGHT", -C.mult, C.mult),
				},
			},
			NormalTexture = {
				file = NIL,
				texCoords = RectType(unpack(DB.TexCoord)),
				vertexColor = Color(.3, .3, .3, 1),
				location = {
					Anchor("TOPLEFT", C.mult, -C.mult),
					Anchor("BOTTOMRIGHT", -C.mult, C.mult),
				},
			},
			PushedTexture = {
				file = DB.pushedTex,
				location = {
					Anchor("TOPLEFT", C.mult, -C.mult),
					Anchor("BOTTOMRIGHT", -C.mult, C.mult),
				},
			},
			CheckedTexture = {
				color = Color(1, .8, 0, .35),
				location = {
					Anchor("TOPLEFT", C.mult, -C.mult),
					Anchor("BOTTOMRIGHT", -C.mult, C.mult),
				},
			},
			HighlightTexture = {
				color = Color(1, 1, 1, .25),
				alphaMode = "ADD",
				drawLayer = "HIGHLIGHT",
				subLevel = 0,
				location = {
					Anchor("TOPLEFT", C.mult, -C.mult),
					Anchor("BOTTOMRIGHT", -C.mult, C.mult),
				},
			},
			Cooldown = {
				location = {
					Anchor("TOPLEFT", 0, 0),
					Anchor("BOTTOMRIGHT", 0, 0),
				},
			},
			NameLabel = {
				font = {
					font = DB.Font[1],
					height = DB.Font[2],
					outline = "NORMAL",
				},
				vertexColor = Color.WHITE,
				location = {
					Anchor("BOTTOMLEFT", 0, 0),
					Anchor("BOTTOMRIGHT", 0, 0)
				},
			},
			HotKeyLabel = {
				font = {
					font = DB.Font[1],
					height = DB.Font[2],
					outline = "NORMAL",
				},
				vertexColor = Wow.FromUIProperty("InRange"):Map(function(ir) return ir == false and Color.RED or Color(.6, .6, .6, 1) end),
				location = {
					Anchor("TOPRIGHT", 0, 0),
					Anchor("TOPLEFT", 0, 0)
				},
			},
			CountLabel = {
				font = {
					font = DB.Font[1],
					height = DB.Font[2],
					outline = "NORMAL",
				},
				vertexColor = Color.WHITE,
				location = {
					Anchor("BOTTOMRIGHT", 2, 0),
				},
			},
		},
	}

	Style.UpdateSkin(SKIN_NAME, SKIN_STYLE)
	Style.ActiveSkin(SKIN_NAME)
end

S:RegisterSkin("ShadowDancer", S.ShadowDancer)