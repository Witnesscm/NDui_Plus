local _, ns = ...
local _, _, L = unpack(ns)
if GetLocale() ~= "frFR" then return end

L["Version Check"] = "Ne prend en charge que NDui v%s"
L["Changelog"] = "Journal des modifications"
L["Option Tips"] = "|nLes options non marquées avec un astérisque (*) nécessitent un rechargement de l'interface utilisateur.|n|nDouble clic sur l'en-tête du curseur réinitialisera sa valeur."
L["Tips"] = "Astuces"
L["EditBox Tip"] = "|nAppuyez sur ENTREE lorsque vous avez fini de taper."
L["Actionbar"] = "Barre d'action"
L["UnitFrames"] = "Cadres d'unité"
L["Chat"] = "Chat"
L["Skins"] = "Apparences"
L["Tooltip"] = "infobulle"
L["Misc"] = "Divers"
L["FinisherGlow"] = "Mouvement 'Finisher' en évidence"
L["FinisherGlowTip"] = "Les mouvements 'finishers' des Voleur et Druide se mettent en surbrillance. Ne supporte que les barres d'action de NDui."
L["UnitFramesFader"] = "Fondu des cadres d'unité"
L["UnitFramesFaderTip"] = "Activer le fondu des cadres d'unité, prendre en charge uniquement le cadre du joueur et le cadre du familier."
L["Fade Settings"] = "Paramètres de fondu"
L["Fade Condition"] = "Condition de fondu"
L["Fade Delay"] = "Délai de fondu"
L["Smooth"] = "Lisse"
L["MinAlpha"] = "Min Alpha"
L["MaxAlpha"] = "Max Alpha"
L["Hover"] = "Survol"
L["Combat"] = "Combat"
L["Target"] = "Cible"
L["Focus"] = "Focalisation"
L["Health"] = "Santé"
L["Vehicle"] = "Véhicule"
L["Casting"] = "Incantation"
L["Role Icon"] = "Icône de rôle"
L["Role Icon Settings"] = "Paramètres de l'icône du rôle"
L["Point"] = "Point"
L["X Offset"] = "Décalage X"
L["Y Offset"] = "Décalage Y"
L["Icon Size"] = "Taille des icônes"
L["Emote"] = "E"
L["ChatEmote"] = "Emote de Chat"
L["ChatEmoteTip"] = "CLIC-DROIT sur le bouton d'émote pour ouvrir le panneau d'émote ou le symbole '{'"
L["ChatClassColor"] = "Couleur du nom du joueur"
L["ChatClassColorTip"] = "Utilisez la couleur de la classe pour les noms des joueurs lorsqu'ils sont mentionnés."
L["ChatRaidIndex"] = "Afficher l'index de l'équipe"
L["ChatRaidIndexTip"] = "Afficher l'index de l'équipe après le nom du membre du raid."
L["ChatRole"] = "Afficher l'icône de rôle"
L["ChatRoleTip"] = "Afficher l'icône du rôle avant le nom du joueur."
L["ChatLinkIcon"] = "Afficher l'icône du lien de chat"
L["ReplaceTexture"] = "Remplacer Texture NDui"
L["ReplaceTextureTip"]= "Remplacer la texture de NDui|nSupporte LibSharedMedia-3.0."
L["Texture Style"] = "Style de texture"
L["ReplaceRoleTexture"] = "Remplacer Texture du rôle"
L["Style du rôle"] = "Style du rôle"
L["Addon Skin"] = "Apparence d'addon"
L["LootEnhancedEnable"] = "Activer le butin amélioré"
L["LootEnhancedTip"] = "Butin amélioré, il faut activer l'apparence du cadre de butin de NDui."
L["LootAnnounceButton"] = "Bouton d'annonce de butin"
L["Announce Target Name"] = "Annoncer le nom de la cible"
L["Rarity Threshold"] = "Seuil de rareté"
L["Loots in chest"] = "Butins dans le coffre"
L["Loots"] = "Butins"
L["Announce Loots to"] = "Annoncez des butins à "
L["QuestHelper"] = "Assistant de Quête"
L["QuestHelperTip"] = "Assistant de quête, inclut：|nLoh|nA dos d'aile écorchée|nLa voie des aspirants."
L["QuickSpecSwap"] = "Double Clic pour changer la spécialisation."
L["LootSpecManagerEnable"] = "Activer le gestionnaire de spécialisation de butin"
L["LootSpecManager"] = "Gestionnaire de spécialisation de butin"
L["LootSpecManagerTip"] = "Changer automatiquement votre spécification de butin. Commande : /lsm"
L["LootSpecManagerTips"] = "|nBasé sur le gestionnaire de spécialisation de butin, change automatiquement votre spécialisation de butin entre les bosses, supporte Raid et M+."
L["Loot Spec"] = "Spécialisation du butin"
L["Mythic+"] = "Mythique+"
L["LootSpecManagerRaidStart"] = "Boss engagé. La spécification a été modifiée."
L["LootSpecManagerM+Start"] = "M+ démarré, la spécialisation de butin a changé."
L["Not set"] = "Non défini"
L["Set Name"] = "Définir le nom"
L["Ignored"] = "Ignoré"
L["Talent Manager"] = "Gestionnaire de Talents"
L["Talent Set"] = "Ensemble de Talents"
L["You must enter a set name."] = "Vous devez entrer un nom d'ensemble."
L["Already have a set named %s."] = "Vous avez déjà un ensemble nommé %s."
L["Too many sets here, please delete one of them and try again."] = "Trop d'ensemble ici, s'il vous plaît supprimez l'un d'eux et essayez à nouveau."
L["GlobalFadeEnable"] = "Activer le fondu global"
L["Fade Alpha"] = "Alpha du fondu"
L["Bar"] = "Barre"
L["PetBar"] = "Barre de familiers"
L["StanceBar"] = "Barre de posture"
L["MountsSource"] = "Source des montures"
L["MountsSourceTip"] = "Afficher la source des montures sur l'infobulle."
L["HideCreator"] = "Cacher le créateur"
L["HideCreatorTip"] = "Cacher le nom du créateur sur l'infobulle."
L["Progression"] = "Afficher la progression PvE"
L["ProgressionTip"] = "Ajouter la progression PvE sur l'infobulle."
L["CombatHide"] = "Cacher en Combat"
L["ShowByShift"] = "Afficher les infos par SHIFT"
L["Raids"] = "Raids"
L["Keystone Master Achievement"] = "Haut-Fait maître mythique"
L["AchievementList"] = "Liste des Haut-Faits"
L["Astuce de la liste des achats"] = "Entrez l'ID du Haut-Fait. Utilisez ESPACE entre différents ID. "
L["[ABBR] Raid Finder"] = "RF"
L["[ABBR] Normal"] = "N"
L["[ABBR] Heroic"] = "H"
L["[ABBR] Mythic"] = "M"
L["Total"] = "Total"
L["%month%-%day%-%year%"] = "%month%-%day%-%year%"
L["Not Completed"] = "Non terminé"
L["Special Achievements"] = "Haut-faits spéciaux"
L["Score (Level)"] = "Score (niveau)"
L["Hands"] = "Mains"
L["Feet"] = "Pieds"
L["Transmog"] = "Transmogrification"
L["CopyMogEnable"] = "Activer la copie de la transmog"
L["CopyMogTip"] = "Copier le texte de transmogrification, supporte le joueur et inspecter l'unité."
L["ShowHideVisual"] = "Afficher l'apparence cachée"
L["ShowIllusion"] = "Afficher l'illusion"
L["LootRoll"] = "Activer le LootRoll amélioré"
L["LootRollTip"] = "/teks test, /mm move"
L["teksLoot LootRoll"] = "teksLoot LootRoll"
L["Frame Width"] = "Largeur du cadre"
L["Frame Height"] = "Hauteur du cadre"
L["Growth Direction"] = "Direction de la croissance"
L["Up"] = "En haut"
L["Down"] = "En bas"
L["Style"] = "Style de barre"
L["Style 1"] = "Style 1"
L["Style 2"] = "Style 2"
L["ChatHide"] = "Cacher le cadre de chat"
L["ChatHideTip"] = "Besoin de verrouiller les paramètres du cadre de chat de NDui."
L["AutoShow"] = "Montrer automatiquement le cadre de chat"
L["AutoShowTip"] = "Afficher automatiquement le cadre de chat et clignote quand un nouveau murmure a été reçu."
L["Message Type"] = "Type de message"
L["Whisper"] = "Chuchotement"
L["Group"] = "Groupe"
L["Guild"] = "Guilde"
L["AutoHide"] = "Cacher automatiquement le cadre de chat"
L["AutoHideTip"] = "Cacher le cadre de chat quand aucune nouvelle ne vient pour un moment."
L["AutoHideTime"] = "Temps de masquage automatique"
L["Click to hide ChatFrame"] = "Cliquez pour masquer le cadre de chat"
L["Click to show ChatFrame"] = "Cliquez pour afficher le cadre de chat"
L["You have new wisper"] = "Vous avez un nouveau message"
L["HideToggle"] = "Cacher le bouton d'activation de détails"
L["AFK Mode"] = "Mode AFK"
L["No Guild"] = "Pas de guilde"
L["IconSearch"] = "Recherche d'icônes"
L["IconSearchGUITip"] = "Ajouter un champ de recherche sur le sélecteur d'icônes, supporte les Macros, le gestionnaire d'équipement, la banque de guilde."
L["IconSearchTip"] = "|nSupporte les ID de sort, d'objets, de haut-faits, de monnaies, d'icônes."
L["QuestHelperTip1"] = "Spammez <espace> pour compléter!"
L["QuestHelperTip2"] = "Restez dans le cercle et spammez <espace> pour compléter!"
L["Trainer Ikaros"] = "Instructeur Ikaros"
L["Nadjia the Mistblade"] = "Nadjia la Lame fantôme"
L["AutoCollapse"] = "Réduction automatique"
L["ParagonRepRewards"] = "Récompense de parangons"
L["ParagonRepRewardsTip"] = "Affiche la collection de récompenses de réputation de parangon."
L["ExtVendorUI"] = "Interface de vendeur étendue"
L["ExtMacroUI"] = "Interface étendue pour les macros"
L["ExtMacroUITip"] = "|cffff0000S'il est activé, il provoquera des altérations qui ne pourront pas modifier les macros et prendre les macros en combat.|r"
L["TrainAll"] = "Tout entrainer"
L["TrainAllCost"] = "%d compétences disponibles pour  %s"
L["TrainAllTip"] = "Ajoute un bouton  \"Tout entrainer\" à la fenêtre du formateur de profession."
L["GarrisonTabs"] = "Onglets de rapport de mission"
L["GarrisonTabsTip"] = "Ajouter des onglets sur le panneau de rapport de mission pour d'ancienne page d'extension et corriger certains widgets incorrects."
L["AuctionEnhanced"] = "Hotel des ventes amélioré"
L["AuctionEnhancedTip"] = "Afficher les statistiques tertiaires des équipements dans l'hotel des ventes."
L["GuildBankItemLevel"] = "Niveau d'objet de la banque de guilde"
L["Wormhole Centrifuge Helper"] = "Aide Centrifugeuse spatiotemporelle"
L["WeakAurasSkinTips"] = "WeakAuras skin is not working %s"
L["Click for details"] = "Click for details"
L["WeakAuras Skins FAQ"] = "WeakAuras Skins FAQ"
L["You are using Official WeakAuras, the skin of WeakAuras will not be loaded due to the limitation."] = "You are using Official WeakAuras, the skin of WeakAuras will not be loaded due to the limitation."
L["If you want to use WeakAuras skin, please install |cff99ccffWeakAurasPatched|r or change the code manually."] = "If you want to use WeakAuras skin, please install |cff99ccffWeakAurasPatched|r or change the code manually."
L["You can disable this alert via disabling WeakAuras Skin in |cff99ccffNDui|r Console."] = "You can disable this alert via disabling WeakAuras Skin in |cff99ccffNDui|r Console."
L["Press Ctrl+C to copy the URL"] = "Press Ctrl+C to copy the URL"
L["Vault of the Incarnates"] = "Caveau des Incarnations"
L["[ABBR] Vault of the Incarnates"] = "VOTI"
L["Temple of the Jade Serpent"] = "Temple du Serpent de jade"
L["[ABBR] Temple of the Jade Serpent"] = "TJS"
L["Shadowmoon Burial Grounds"] = "Terres sacrées d'Ombrelune"
L["[ABBR] Shadowmoon Burial Grounds"] = "SBG"
L["Halls of Valor"] = "Salles des Valeureux"
L["[ABBR] Halls of Valor"] = "HOV"
L["Court of Stars"] = "Cour des Étoiles"
L["[ABBR] Court of Stars"] = "COS"
L["Ruby Life Pools"] = "Bassins de l'Essence rubis"
L["[ABBR] Ruby Life Pools"] = "RLP"
L["The Nokhud Offensive"] = "L'offensive Nokhud"
L["[ABBR] The Nokhud Offensive"] = "NO"
L["The Azure Vault"] = "Le Caveau d'Azur"
L["[ABBR] The Azure Vault"] = "AV"
L["Algeth'ar Academy"] = "Académie d'Algeth'ar"
L["[ABBR] Algeth'ar Academy"] = "AA"
L["Aberrus, the Shadowed Crucible"] = "Aberrus, the Shadowed Crucible"
L["[ABBR] Aberrus, the Shadowed Crucible"] = "Aberrus"
L["Neltharion's Lair"] = "Neltharion's Lair"
L["[ABBR] Neltharion's Lair"] = "NL"
L["Freehold"] = "Freehold"
L["[ABBR] Freehold"] = "FH"
L["The Underrot"] = "The Underrot"
L["[ABBR] The Underrot"] = "UNDR"
L["Uldaman: Legacy of Tyr"] = "Uldaman: Legacy of Tyr"
L["[ABBR] Uldaman: Legacy of Tyr"] = "ULD"
L["Neltharus"] = "Neltharus"
L["[ABBR] Neltharus"] = "NELT"
L["Brackenhide Hollow"] = "Brackenhide Hollow"
L["[ABBR] Brackenhide Hollow"] = "BH"
L["Halls of Infusion"] = "Halls of Infusion"
L["[ABBR] Halls of Infusion"] = "HOI"
L["The Vortex Pinnacle"] = "The Vortex Pinnacle"
L["[ABBR] The Vortex Pinnacle"] = "VP"
L["Dragonflight Keystone Master: Season One"] = "Maîtrise mythique de Dragonflight : saison 1"
L["[ABBR] Dragonflight Keystone Master: Season One"] = "Maîtrise mythique S1"
L["Dragonflight Keystone Hero: Season One"] = "Héros mythique de Dragonflight : saison 1"
L["[ABBR] Dragonflight Keystone Hero: Season One"] = "Héros mythique S1"
L["Dragonflight Keystone Master: Season Two"] = "Maîtrise mythique de Dragonflight : saison 2"
L["[ABBR] Dragonflight Keystone Master: Season Two"] = "Maîtrise mythique S2"
L["Dragonflight Keystone Hero: Season Two"] = "Héros mythique de Dragonflight : saison 2"
L["[ABBR] Dragonflight Keystone Hero: Season Two"] = "Héros mythique S2"
L["Dragonflight Keystone Master: Season Three"] = "Maîtrise mythique de Dragonflight : saison 3"
L["[ABBR] Dragonflight Keystone Master: Season Three"] = "Maîtrise mythique S3"
L["Dragonflight Keystone Hero: Season Three"] = "Héros mythique de Dragonflight : saison 3"
L["[ABBR] Dragonflight Keystone Hero: Season Three"] = "Héros mythique S3"
L["Dragonflight Keystone Master: Season Four"] = "Maîtrise mythique de Dragonflight : saison 4"
L["[ABBR] Dragonflight Keystone Master: Season Four"] = "Maîtrise mythique S4"
L["Dragonflight Keystone Hero: Season Four"] = "Héros mythique de Dragonflight : saison 4"
L["[ABBR] Dragonflight Keystone Hero: Season Four"] = "Héros mythique S4"
L["Item Level"] = "Niveau d'Objet"
L["Item Quality"] = "Qualité de l'objet"
L["Learn All Specialization"] = "Apprendre toutes les spécialisations"
L["Learn All"] = "Tout apprendre"
L["Amirdrassil, the Dream's Hope"] = "Amirdrassil, the Dream's Hope"
L["[ABBR] Amirdrassil, the Dream's Hope"] = "Amirdrassil"
L["The Everbloom"] = "The Everbloom"
L["[ABBR] The Everbloom"] = "EB"
L["Darkheart Thicket"] = "Darkheart Thicket"
L["[ABBR] Darkheart Thicket"] = "DHT"
L["Black Rook Hold"] = "Black Rook Hold"
L["[ABBR] Black Rook Hold"] = "BRH"
L["Atal'Dazar"] = "Atal'Dazar"
L["[ABBR] Atal'Dazar"] = "AD"
L["Waycrest Manor"] = "Waycrest Manor"
L["[ABBR] Waycrest Manor"] = "WM"
L["Throne of the Tides"] = "Throne of the Tides"
L["[ABBR] Throne of the Tides"] = "TOTT"
L["Dawn of the Infinite: Galakrond's Fall"] = "Dawn of the Infinite: Galakrond's Fall"
L["[ABBR] Dawn of the Infinite: Galakrond's Fall"] = "FALL"
L["Dawn of the Infinite: Murozond's Rise"] = "Dawn of the Infinite: Murozond's Rise"
L["[ABBR] Dawn of the Infinite: Murozond's Rise"] = "RISE"