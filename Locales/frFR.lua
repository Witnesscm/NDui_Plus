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
L["ComboGlow"] = "Mouvement 'Finisher' en évidence"
L["ComboGlowTip"] = "Les mouvements 'finishers' des Voleur et Druide se mettent en surbrillance. Ne supporte que les barres d'action de NDui."
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
L["Loots in chest"] = "Loots in chest"
L["Loots"] = "Loots"
L["Announce Loots to"] = "Announce Loots to "
L["QuestHelper"] = "Assistant de Quête"
L["QuestHelperTip"] = "Assistant de quête, inclut：|nLoh|nA dos d'aile écorchée|nLa voie des aspirants."
L["QuickSpecSwap"] = "Double Clic pour changer la spécialisation."
L["LootSpecManagerEnable"] = "Activer le gestionnaire de spécialisation de butin"
L["TalentManagerEnable"] = "Activer le Gestionnaire de Talents"
L["TalentManagerTip"] = "Save several talent sets and switch back and forth between them quickly."
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
L["Bar1"] = "Barre1"
L["Bar2"] = "Barre2"
L["Bar3"] = "Barre3"
L["Bar4"] = "Barre4"
L["Bar5"] = "Barre5"
L["CustomBar"] = "Barre personnalisée"
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
L["MythicDungeons"] = "Donjons Mythiques"
L["Keystone Master Achievement"] = "Haut-Fait maître mythique"
L["AchievementList"] = "Liste des Haut-Faits"
L["Astuce de la liste des achats"] = "Entrez l'ID du Haut-Fait. Utilisez ESPACE entre différents ID. "
L["[ABBR] Raid Finder"] = "RF"
L["[ABBR] Normal"] = "N"
L["[ABBR] Heroic"] = "H"
L["[ABBR] Mythic"] = "M"
L["[ABBR] Castle Nathria"] = "CS"
L["Castle Nathria"] = "Château Nathria"
L["[ABBR] The Necrotic Wake"] = "NW"
L["The Necrotic Wake"] = "Sillage nécrotique"
L["[ABBR] Plaguefall"] = "PF"
L["Plaguefall"] = "Malepeste"
L["[ABBR] Mists of Tirna Scithe"] = "MISTS"
L["Mists of Tirna Scithe"] = "Brumes de Tirna Scithe"
L["[ABBR] Halls of Atonement"] = "HOA"
L["Halls of Atonement"] = "Salles de l'Expiation"
L["[ABBR] Theater of Pain"] = "TOP"
L["Theater of Pain"] = "Théâtre de la Souffrance"
L["[ABBR] De Other Side"] = "DOS"
L["De Other Side"] = "L'Autre Côté"
L["[ABBR] Spires of Ascension"] = "SOA"
L["Spires of Ascension"] = "Flèches de l'Ascension"
L["[ABBR] Sanguine Depths"] = "SD"
L["Sanguine Depths"] = "Profondeurs Sanguines"
L["Total"] = "Total"
L["%month%-%day%-%year%"] = "%month%-%day%-%year%"
L["Shadowlands Keystone Master: Season One"] = "Maître mythique de Shadowlands : saison 1"
L["[ABBR] Shadowlands Keystone Master: Season One"] = "Maître mythique: saison 1"
L["Shadowlands Keystone Master: Season Two"] = "Maître mythique de Shadowlands : saison 2"
L["[ABBR] Shadowlands Keystone Master: Season Two"] = "Maître mythique: saison 2"
L["Sanctum of Domination"] = "Sanctum de Domination"
L["[ABBR] Sanctum of Domination"] = "SoD"
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
L["ChatHide"] = "Cacher le cadre de chat"
L["ChatHideTip"] = "Besoin de verrouiller les paramètres du cadre de chat de NDui."
L["AutoShow"] = "Montrer automatiquement le cadre de chat"
L["AutoShowTip"] = "Afficher automatiquement le cadre de chat et clignote quand un nouveau murmure a été reçu."
L["AutoHide"] = "Cacher automatiquement le cadre de chat"
L["AutoHideTip"] = "Cacher le cadre de chat quand aucune nouvelle ne vient pour un moment."
L["AutoHideTime"] = "Temps de masquage automatique"
L["Click to hide ChatFrame"] = "Cliquez pour masquer le cadre de chat"
L["Click to show ChatFrame"] = "Cliquez pour afficher le cadre de chat"
L["You have new wisper"] = "Vous avez un nouveau message"
L["HideToggle"] = "Cacher le bouton d'activation de détails"
L["AFK Mode"] = "Mode AFK"
L["No Guild"] = "Pas de guilde"
L["SearchForIcons"] = "Chercher des icones"
L["SearchForIconsGUITip"] = "Add a search box on icon selector, support Macro, Equipment Manager, Guild Bank."
L["SearchForIconsTip"] = "|nSupporte ID de sort、ID d'objet、ID d'icone|n|nAppuyez sur ENTREE lors de la saisie d'une ID d'icone."
L["QuestHelperTip1"] = "Spammez <espace> pour compléter!"
L["QuestHelperTip2"] = "Restez dans le cercle et spammez <espace> pour compléter!"
L["Trainer Ikaros"] = "Instructeur Ikaros"
L["Nadjia the Mistblade"] = "Nadjia la Lame fantôme"
L["ShowCovenant"] = "Montrer congrégation"
L["ShowCovenantTip"] = "Afficher l'icône de congrégation des joueurs en groupe ."
L["Covenant"] = "Congrégation: %s"
L["AutoCollapse"] = "Réduction automatique"
L["ParagonRepRewards"] = "Récompense de parangons"
L["ParagonRepRewardsTip"] = "Displays the collection of paragon reputation rewards."
L["ImprovedStableFrame"] = "Cadre d'écurie améliorée"
L["Train All"] = "Tout entrainer"
L["Train All Cost"] = "%d compétences disponibles pour  %s"
L["GarrisonTabs"] = "MOnglets de rapport de mission"
L["GarrisonTabsTip"] = "Aajouter des onglets sur le panneau de rapport de mission pour d'ancienne page d'extension et corriger certains widgets incorrects."
L["AuctionEnhanced"] = "Hotel des ventes amélioré"
L["AuctionEnhancedTip"] = "Afficher les statistiques tertiaires des équipements dans l'hotel des ventes."
L["GuildBankItemLevel"] = "Guild Bank ItemLevel"
L["Tazavesh: Streets of Wonder"] = "Tazavesh: Streets of Wonder"
L["[ABBR] Tazavesh: Streets of Wonder"] = "SoW"
L["Tazavesh: So'leah's Gambit"] = "Tazavesh: So'leah's Gambit"
L["[ABBR] Tazavesh: So'leah's Gambit"] = "SG"
L["Shadowlands Keystone Master: Season Three"] = "Shadowlands Keystone Master: Season Three"
L["[ABBR] Shadowlands Keystone Master: Season Three"] = "Keystone Master S3"
L["Shadowlands Keystone Hero: Season Three"] = "Shadowlands Keystone Hero: Season Three"
L["[ABBR] Shadowlands Keystone Hero: Season Three"] = "Keystone Hero S3"
L["Sepulcher of the First Ones"] = "Sepulcher of the First Ones"
L["[ABBR] Sepulcher of the First Ones"] = "SFO"
L["ExtVendorUI"] = "Extended Vendor UI"