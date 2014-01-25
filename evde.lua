require "old2dgeo"

local AutoUpdate = true 

--[[AutoUpdate Settings]]
local version = "17"
local SELF =  SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local URL = "https://bitbucket.org/vitouch/freekings-bol-scripts/raw/master/FreakingGoodEvade.lua"
local UPDATE_TMP_FILE = LIB_PATH.."FGETmp.txt"
local versionmessage = "Changelog: Bug Fixes for free users and for the flash, also hopefuly improved Autocarry reborn support."

function Update()
	DownloadFile(URL, UPDATE_TMP_FILE, UpdateCallback)
end

function UpdateCallback()
	file = io.open(UPDATE_TMP_FILE, "rb")
	if file ~= nil then
		content = file:read("*all")
		file:close()
		os.remove(UPDATE_TMP_FILE)
		if content then
			tmp, sstart = string.find(content, "local version = \"")
			if sstart then
				send, tmp = string.find(content, "\"", sstart+1)
			end
			if send then
				Version = tonumber(string.sub(content, sstart+1, send-1))
			end
			if (Version ~= nil) and (Version > tonumber(version)) and content:find("--EOS--") then
				file = io.open(SELF, "w")
				if file then
					file:write(content)
					file:flush()
					file:close()
					PrintChat("<font color=\"#81BEF7\" >FreakingGoodEvade:</font> <font color=\"#00FF00\">Successfully updated to: v"..Version.."</font>")
				else
					PrintChat("<font color=\"#81BEF7\" >FreakingGoodEvade:</font> <font color=\"#FF0000\">Error updating to new version (v"..Version..")</font>")
				end
				elseif (Version ~= nil) and (Version == tonumber(version)) then
				PrintChat("<font color=\"#81BEF7\" >FreakingGoodEvade:</font> <font color=\"#00FF00\">No updates found, latest version: v"..Version.." </font>")
			end
		end
	end
end

_G.evade = false
evadeBuffer = 15 -- expand the dangerous area (safer evades in laggy situations)
moveBuffer = 25 -- additional movement distance (champions stop a few pixels before their destination)
smoothing = 75 -- make movements smoother by moving further between evasion phases
dashrange = 0


champions = {}
champions2 = {
["Lux"] = {charName = "Lux", skillshots = {
["Light Binding"] =  {name = "LightBinding", spellName = "LuxLightBinding", spellDelay = 250, projectileName = "LuxLightBinding_mis.troy", projectileSpeed = 1200, range = 1300, radius = 80, type = "line", cc = "true"},
["Lux LightStrike Kugel"] = {name = "LuxLightStrikeKugel", spellName = "LuxLightStrikeKugel", spellDelay = 250, projectileName = "LuxLightstrike_mis.troy", projectileSpeed = 1400, range = 1100, radius = 275, type = "circular", cc = "false"},
["Lux Malice Cannon"] =  {name = "LuxMaliceCannon", spellName = "LuxMaliceCannon", spellDelay = 1375, projectileName = "LuxMaliceCannon_cas.troy", projectileSpeed = 50000, range = 3500, radius = 190, type = "line", cc = "true"},
}},
["Nidalee"] = {charName = "Nidalee", skillshots = {
["Javelin Toss"] = {name = "JavelinToss", spellName = "JavelinToss", spellDelay = 125, projectileName = "nidalee_javelinToss_mis.troy", projectileSpeed = 1300, range = 1500, radius = 60, type = "line", cc = "true"}
}},
["Kennen"] = {charName = "Kennen", skillshots = {
["Thundering Shuriken"] = {name = "ThunderingShuriken", spellName = "KennenShurikenHurlMissile1", spellDelay = 180, projectileName = "kennen_ts_mis.troy", projectileSpeed = 1700, range = 1050, radius = 50, type = "line", cc = "false"}--could be 4 if you have 2 marks
}},
["Amumu"] = {charName = "Amumu", skillshots = {
["Bandage Toss"] = {name = "BandageToss", spellName = "BandageToss", spellDelay = 250, projectileName = "Bandage_beam.troy", projectileSpeed = 2000, range = 1100, radius = 80, type = "line", cc = "true"}
}},
["Lee Sin"] = {charName = "LeeSin", skillshots = {
["Sonic Wave"] = {name = "SonicWave", spellName = "BlindMonkQOne", spellDelay = 250, projectileName = "blindMonk_Q_mis_01.troy", projectileSpeed = 1800, range = 1100, radius = 70, type = "line", cc = "true"} --if he hit this he will slow you
}},
["Morgana"] = {charName = "Morgana", skillshots = {
["Dark Binding Missile"] = {name = "DarkBinding", spellName = "DarkBindingMissile", spellDelay = 250, projectileName = "DarkBinding_mis.troy", projectileSpeed = 1200, range = 1300, radius = 80, type = "line", cc = "true"},
}},
["Sejuani"] = {charName = "Sejuani", skillshots = {
["SejuaniR"] = {name = "SejuaniR", spellName = "SejuaniGlacialPrisonCast", spellDelay = 250, projectileName = "Sejuani_R_mis.troy", projectileSpeed = 1600, range = 1200, radius = 110, type="line", cc = "true"},    
}},
["Sona"] = {charName = "Sona", skillshots = {
["Crescendo"] = {name = "Crescendo", spellName = "SonaCrescendo", spellDelay = 240, projectileName = "SonaCrescendo_mis.troy", projectileSpeed = 2400, range = 1000, radius = 160, type = "line", cc = "true"},        
}},
["Gragas"] = {charName = "Gragas", skillshots = {
["Barrel Roll"] = {name = "BarrelRoll", spellName = "GragasBarrelRoll", spellDelay = 250, projectileName = "gragas_barrelroll_mis.troy", projectileSpeed = 1000, range = 1115, radius = 180, type = "circular", cc = "never"},
["Barrel Roll Missile"] = {name = "BarrelRollMissile", spellName = "GragasBarrelRollMissile", spellDelay = 0, projectileName = "gragas_barrelroll_mis.troy", projectileSpeed = 1000, range = 1115, radius = 180, type = "circular", cc = "never"},
}},
["Syndra"] = {charName = "Syndra", skillshots = {
["Q"] = {name = "Q", spellName = "SyndraQ", spellDelay = 250, projectileName = "Syndra_Q_cas.troy", projectileSpeed = 500, range = 800, radius = 175, type = "circular", cc = "false"}
}},
["Malphite"] = {charName = "Malphite", skillshots = {
["UFSlash"] = {name = "UFSlash", spellName = "UFSlash", spellDelay = 0, projectileName = "UnstoppableForce_cas.troy", projectileSpeed = 150, range = 1000, radius = 300, type="circular", cc = "true"},    
}},
["Ezreal"] = {charName = "Ezreal", skillshots = {
["Mystic Shot"]             = {name = "MysticShot",      spellName = "EzrealMysticShot",      spellDelay = 250, projectileName = "Ezreal_mysticshot_mis.troy",  projectileSpeed = 2000, range = 1200,  radius = 80,  type = "line", cc = "false"},
["Essence Flux"]            = {name = "EssenceFlux",     spellName = "EzrealEssenceFlux",     spellDelay = 250, projectileName = "Ezreal_essenceflux_mis.troy", projectileSpeed = 1500, range = 1050,  radius = 80,  type = "line", cc = "false"},
["Mystic Shot (Pulsefire)"] = {name = "MysticShot",      spellName = "EzrealMysticShotPulse", spellDelay = 250, projectileName = "Ezreal_mysticshot_mis.troy",  projectileSpeed = 2000, range = 1200,  radius = 80,  type = "line", cc = "false"},
["Trueshot Barrage"]        = {name = "TrueshotBarrage", spellName = "EzrealTrueshotBarrage", spellDelay = 1000, projectileName = "Ezreal_TrueShot_mis.troy",    projectileSpeed = 2000, range = 20000, radius = 160, type = "line", cc = "false"},
}},
["Ahri"] = {charName = "Ahri", skillshots = {
["Orb of Deception"] = {name = "OrbofDeception", spellName = "AhriOrbofDeception", spellDelay = 250, projectileName = "Ahri_Orb_mis.troy", projectileSpeed = 2500, range = 900, radius = 100, type = "line", cc = "false"},
["Orb of Deception Back"] = {name = "OrbofDeceptionBack", spellName = "AhriOrbofDeception!", spellDelay = 250+360, projectileName = "Ahri_Orb_mis_02.troy", projectileSpeed = 915, range = 900, radius = 100, type = "line", cc = "false"},
["Charm"] = {name = "Charm", spellName = "AhriSeduce", spellDelay = 250, projectileName = "Ahri_Charm_mis.troy", projectileSpeed = 1000, range = 1000, radius = 60, type = "line", cc = "true"}
}},
["Olaf"] = {charName = "Olaf", skillshots = {
["Undertow"] = {name = "Undertow", spellName = "OlafAxeThrow", spellDelay = 250, projectileName = "olaf_axe_mis.troy", projectileSpeed = 1600, range = 1000, radius = 90, type = "line", cc = "true"}
}},
["Leona"] = {charName = "Leona", skillshots = {
["Zenith Blade"] = {name = "LeonaZenithBlade", spellName = "LeonaZenithBlade", spellDelay = 250, projectileName = "Leona_ZenithBlade_mis.troy", projectileSpeed = 2000, range = 950, radius = 110, type = "line", cc = "true"},
["Leona Solar Flare"] = {name = "LeonaSolarFlare", spellName = "LeonaSolarFlare", spellDelay = 250, projectileName = "Leona_SolarFlare_cas.troy", projectileSpeed = 2000, range = 1200, radius = 300, type = "circular", cc = "true"}
}},
["Karthus"] = {charName = "Karthus", skillshots = {
["Lay Waste"] = {name = "LayWaste", spellName = "LayWaste", spellDelay = 250, projectileName = "LayWaste_point.troy", projectileSpeed = 1750, range = 875, radius = 140, type = "circular", cc = "false"}
}},
["Chogath"] = {charName = "Chogath", skillshots = {
["Rupture"] = {name = "Rupture", spellName = "Rupture", spellDelay = 0, projectileName = "rupture_cas_01_red_team.troy", projectileSpeed = 950, range = 950, radius = 250, type = "circular", cc = "true"}
}},
["Blitzcrank"] = {charName = "Blitzcrank", skillshots = {
["Rocket Grab"] = {name = "RocketGrab", spellName = "RocketGrab", spellDelay = 250, projectileName = "FistGrab_mis.troy", projectileSpeed = 1800, range = 1050, radius = 70, type = "line", cc = "true"}
}},
["Anivia"] = {charName = "Anivia", skillshots = {
["Flash Frost"] = {name = "FlashFrost", spellName = "FlashFrostSpell", spellDelay = 250, projectileName = "cryo_FlashFrost_mis.troy", projectileSpeed = 850, range = 1100, radius = 110, type = "line", cc = "true"}
}},
["Zyra"] = {charName = "Zyra", skillshots = {
["Grasping Roots"] = {name = "GraspingRoots", spellName = "ZyraGraspingRoots", spellDelay = 250, projectileName = "Zyra_E_sequence_impact.troy", projectileSpeed = 1150, range = 1150, radius = 70,  type = "line", cc = "true"},
["Zyra Passive Death"] = {name = "ZyraPassive", spellName = "zyrapassivedeathmanager", spellDelay = 500, projectileName = "zyra_passive_plant_mis.troy", projectileSpeed = 2000, range = 1474, radius = 60,  type = "line", cc = "false"},
}},
["Nautilus"] = {charName = "Nautilus", skillshots = {
["Dredge Line"] = {name = "DredgeLine", spellName = "NautilusAnchorDrag", spellDelay = 250, projectileName = "Nautilus_Q_mis.troy", projectileSpeed = 2000, range = 1080, radius = 80, type = "line", cc = "true"},
}},
["Caitlyn"] = {charName = "Caitlyn", skillshots = {
["Piltover Peacemaker"] = {name = "PiltoverPeacemaker", spellName = "CaitlynPiltoverPeacemaker", spellDelay = 625, projectileName = "caitlyn_Q_mis.troy", projectileSpeed = 2200, range = 1300, radius = 90, type = "line", cc = "false"},
["Caitlyn Entrapment"] = {name = "CaitlynEntrapment", spellName = "CaitlynEntrapment", spellDelay = 150, projectileName = "caitlyn_entrapment_mis.troy", projectileSpeed = 2000, range = 950, radius = 80, type = "line", cc = "true"},
}},
["Mundo"] = {charName = "DrMundo", skillshots = {
["Infected Cleaver"] = {name = "InfectedCleaver", spellName = "InfectedCleaverMissile", spellDelay = 250, projectileName = "dr_mundo_infected_cleaver_mis.troy", projectileSpeed = 2000, range = 1050, radius = 75, type = "line", cc = "true"},
}},
["Brand"] = {charName = "Brand", skillshots = {
["BrandBlaze"] = {name = "BrandBlaze", spellName = "BrandBlaze", spellDelay = 250, projectileName = "BrandBlaze_mis.troy", projectileSpeed = 1600, range = 1100, radius = 80, type = "line", cc = "true"},
["Pillar of Flame"] = {name = "PillarofFlame", spellName = "BrandFissure", spellDelay = 250, projectileName = "BrandPOF_tar_green.troy", projectileSpeed = 900, range = 1100, radius = 240, type = "circular", cc = "false"}
}},
["Corki"] = {charName = "Corki", skillshots = {
["Missile Barrage"] = {name = "MissileBarrage", spellName = "MissileBarrage", spellDelay = 250, projectileName = "corki_MissleBarrage_mis.troy", projectileSpeed = 2000, range = 1300, radius = 40, type = "line", cc = "false"},
["Missile Barrage big"] = {name = "MissileBarragebig", spellName = "MissileBarrage!", spellDelay = 250, projectileName = "Corki_MissleBarrage_DD_mis.troy", projectileSpeed = 2000, range = 1300, radius = 40, type = "line", cc = "false"}
}},
["TwistedFate"] = {charName = "TwistedFate", skillshots = {
["Loaded Dice"] = {name = "LoadedDice", spellName = "WildCards", spellDelay = 250, projectileName = "Roulette_mis.troy", projectileSpeed = 1000, range = 1450, radius = 40, type = "line", cc = "false"},
}},
["Swain"] = {charName = "Swain", skillshots = {
["Nevermove"] = {name = "Nevermove", spellName = "SwainShadowGrasp", spellDelay = 250, projectileName = "swain_shadowGrasp_transform.troy", projectileSpeed = 1000, range = 900, radius = 180, type = "circular", cc = "true"}
}},
["Cassiopeia"] = {charName = "Cassiopeia", skillshots = {
["Noxious Blast"] = {name = "NoxiousBlast", spellName = "CassiopeiaNoxiousBlast", spellDelay = 250, projectileName = "CassNoxiousSnakePlane_green.troy", projectileSpeed = 500, range = 850, radius = 130, type = "circular", cc = "false"},
}},
["Sivir"] = {charName = "Sivir", skillshots = { --hard to measure speed
["Boomerang Blade"] = {name = "BoomerangBlade", spellName = "SivirQ", spellDelay = 250, projectileName = "Sivir_Base_Q_mis.troy", projectileSpeed = 1350, range = 1175, radius = 101, type = "line", cc = "false"},
}},
["Ashe"] = {charName = "Ashe", skillshots = {
["Enchanted Arrow"] = {name = "EnchantedArrow", spellName = "EnchantedCrystalArrow", spellDelay = 250, projectileName = "EnchantedCrystalArrow_mis.troy", projectileSpeed = 1600, range = 25000, radius = 120, type = "line", cc = "true"},
}},
["KogMaw"] = {charName = "KogMaw", skillshots = {
["Living Artillery"] = {name = "LivingArtillery", spellName = "KogMawLivingArtillery", spellDelay = 250, projectileName = "KogMawLivingArtillery_mis.troy", projectileSpeed = 1050, range = 2200, radius = 225, type = "circular", cc = "false"}
}},
["Khazix"] = {charName = "Khazix", skillshots = {
["KhazixW"] = {name = "KhazixW", spellName = "KhazixW", spellDelay = 250, projectileName = "Khazix_W_mis_enhanced.troy", projectileSpeed = 1700, range = 1025, radius = 70, type = "line", cc = "true"},
["khazixwlong"] = {name = "khazixwlong", spellName = "khazixwlong", spellDelay = 250, projectileName = "Khazix_W_mis_enhanced.troy", projectileSpeed = 1700, range = 1025, radius = 70, type = "line", cc = "true"},
}},
["Zed"] = {charName = "Zed", skillshots = {
["ZedShuriken"] = {name = "ZedShuriken", spellName = "ZedShuriken", spellDelay = 250, projectileName = "Zed_Q_Mis.troy", projectileSpeed = 1700, range = 925, radius = 50, type = "line", cc = "false"},
}},
["Leblanc"] = {charName = "Leblanc", skillshots = {
["Ethereal Chains"] = {name = "EtherealChains", spellName = "LeblancSoulShackle", spellDelay = 250, projectileName = "leBlanc_shackle_mis.troy", projectileSpeed = 1600, range = 960, radius = 70, type = "line", cc = "true"},
["Ethereal Chains R"] = {name = "EtherealChainsR", spellName = "LeblancSoulShackleM", spellDelay = 250, projectileName = "leBlanc_shackle_mis_ult.troy", projectileSpeed = 1600, range = 960, radius = 70, type = "line", cc = "true"},
}},
["Draven"] = {charName = "Draven", skillshots = {
["Stand Aside"] = {name = "StandAside", spellName = "DravenDoubleShot", spellDelay = 250, projectileName = "Draven_E_mis.troy", projectileSpeed = 1400, range = 1100, radius = 130, type = "line", cc = "true"},
["DravenR"] = {name = "DravenR", spellName = "DravenRCast", spellDelay = 500, projectileName = "Draven_R_mis!.troy", projectileSpeed = 2000, range = 25000, radius = 160, type = "line", cc = "false"},
}},
["Elise"] = {charName = "Elise", skillshots = {
["Cocoon"] = {name = "Cocoon", spellName = "EliseHumanE", spellDelay = 250, projectileName = "Elise_human_E_mis.troy", projectileSpeed = 1450, range = 1100, radius = 70, type = "line", cc = "true"}
}},
["Lulu"] = {charName = "Lulu", skillshots = {
["LuluQ"] = {name = "LuluQ", spellName = "LuluQ", spellDelay = 250, projectileName = "Lulu_Q_Mis.troy", projectileSpeed = 1450, range = 1000, radius = 50, type = "line", cc = "true"}
}},
["Thresh"] = {charName = "Thresh", skillshots = {
["ThreshQ"] = {name = "ThreshQ", spellName = "ThreshQ", spellDelay = 500, projectileName = "Thresh_Q_whip_beam.troy", projectileSpeed = 1900, range = 1100, radius = 65, type = "line", cc = "true"} -- 60 real radius
}},
["Shen"] = {charName = "Shen", skillshots = {
["ShadowDash"] = {name = "ShadowDash", spellName = "ShenShadowDash", spellDelay = 0, projectileName = "shen_shadowDash_mis.troy", projectileSpeed = 3000, range = 575, radius = 50, type = "line", cc = "true"}
}},
["Quinn"] = {charName = "Quinn", skillshots = {
["QuinnQ"] = {name = "QuinnQ", spellName = "QuinnQ", spellDelay = 250, projectileName = "Quinn_Q_missile.troy", projectileSpeed = 1550, range = 1050, radius = 80, type = "line", cc = "false"}
}},
["Veigar"] = {charName = "Veigar", skillshots = {
["Dark Matter"] = {name = "VeigarDarkMatter", spellName = "VeigarDarkMatter", spellDelay = 250, projectileName = "!", projectileSpeed = 900, range = 900, radius = 225, type = "circular", cc = "false"}
}},
["Jayce"] = {charName = "Jayce", skillshots = {
["JayceShockBlast"] = {name = "JayceShockBlast", spellName = "JayceShockBlast!", spellDelay = 250, projectileName = "JayceOrbLightning.troy", projectileSpeed = 1450, range = 1050, radius = 70, type = "line", cc = "false"},
["JayceShockBlastCharged"] = {name = "JayceShockBlastCharged", spellName = "JayceShockBlast", spellDelay = 250, projectileName = "JayceOrbLightningCharged.troy", projectileSpeed = 2350, range = 1600, radius = 70, type = "line", cc = "false"},
}},
["Nami"] = {charName = "Nami", skillshots = {
["NamiQ"] = {name = "NamiQ", spellName = "NamiQ", spellDelay = 250, projectileName = "Nami_Q_mis.troy", projectileSpeed = 1500, range = 1625, radius = 225, type = "circular", cc = "true"}
}},
["Fizz"] = {charName = "Fizz", skillshots = {
["Fizz Ultimate"] = {name = "FizzULT", spellName = "FizzMarinerDoom", spellDelay = 250, projectileName = "Fizz_UltimateMissile.troy", projectileSpeed = 1350, range = 1275, radius = 80, type = "line", cc = "true"},
}},
["Varus"] = {charName = "Varus", skillshots = {
["Varus Q Missile"] = {name = "VarusQMissile", spellName = "somerandomspellnamethatwillnevergetcalled", spellDelay = 0, projectileName = "VarusQ_mis.troy", projectileSpeed = 1900, range = 1600, radius = 70, type = "line", cc = "false"},
["VarusR"] = {name = "VarusR", spellName = "VarusR", spellDelay = 250, projectileName = "VarusRMissile.troy", projectileSpeed = 1950, range = 1250, radius = 100, type = "line", cc = "true"},
}},
["Karma"] = {charName = "Karma", skillshots = {
["KarmaQ"] = {name = "KarmaQ", spellName = "KarmaQ", spellDelay = 250, projectileName = "TEMP_KarmaQMis.troy", projectileSpeed = 1700, range = 1050, radius = 90, type = "line", cc = "true"},
}},
["Aatrox"] = {charName = "Aatrox", skillshots = {--Radius starts from 150 and scales down, so I recommend putting half of it, because you won't dodge pointblank skillshots.
["Blade of Torment"] = {name = "BladeofTorment", spellName = "AatroxE", spellDelay = 250, projectileName = "AatroxBladeofTorment_mis.troy", projectileSpeed = 1200, range = 1075, radius = 75, type = "line", cc = "true"},
["AatroxQ"] = {name = "AatroxQ", spellName = "AatroxQ", spellDelay = 250, projectileName = "AatroxQ.troy", projectileSpeed = 450, range = 650, radius = 145, type = "circular", cc = "true"},
}},
["Xerath"] = {charName = "Xerath", skillshots = {
["Xerath Arcanopulse"] =  {name = "XerathArcanopulse", spellName = "XerathArcanopulse", spellDelay = 1375, projectileName = "Xerath_Beam_cas.troy", projectileSpeed = 25000, range = 1025, radius = 100, type = "line", cc = "false"},
["Xerath Arcanopulse Extended"] =  {name = "XerathArcanopulseExtended", spellName = "xeratharcanopulseextended", spellDelay = 1375, projectileName = "Xerath_Beam_cas.troy", projectileSpeed = 25000, range = 1625, radius = 100, type = "line", cc = "false"},
["xeratharcanebarragewrapper"] = {name = "xeratharcanebarragewrapper", spellName = "xeratharcanebarragewrapper", spellDelay = 250, projectileName = "Xerath_E_cas.troy", projectileSpeed = 300, range = 1100, radius = 265, type = "circular", cc = "false"},
["xeratharcanebarragewrapperext"] = {name = "xeratharcanebarragewrapperext", spellName = "xeratharcanebarragewrapperext", spellDelay = 250, projectileName = "Xerath_E_cas.troy", projectileSpeed = 300, range = 1700, radius = 265, type = "circular", cc = "false"},
}},
["Lucian"] = {charName = "Lucian", skillshots = {
["LucianQ"] =  {name = "LucianQ", spellName = "LucianQ", spellDelay = 350, projectileName = "Lucian_Q_laser.troy", projectileSpeed = 25000, range = 570*2, radius = 65, type = "line", cc = "false"},
["LucianW"] =  {name = "LucianW", spellName = "LucianW", spellDelay = 300, projectileName = "Lucian_W_mis.troy", projectileSpeed = 1600, range = 1000, radius = 80, type = "line", cc = "false"},
}},
["Viktor"] = {charName = "Viktor", skillshots = {
["ViktorDeathRay1"] =  {name = "ViktorDeathRay1", spellName = "ViktorDeathRay!", spellDelay = 500, projectileName = "Viktor_DeathRay_Fix_Mis.troy", projectileSpeed = 780, range = 700, radius = 80, type = "line", cc = "false"},
["ViktorDeathRay2"] =  {name = "ViktorDeathRay2", spellName = "ViktorDeathRay!", spellDelay = 500, projectileName = "Viktor_DeathRay_Fix_Mis_Augmented.troy", projectileSpeed = 780, range = 700, radius = 80, type = "line", cc = "false"},
}},
["Rumble"] = {charName = "Rumble", skillshots = {
["RumbleGrenade"] =  {name = "RumbleGrenade", spellName = "RumbleGrenade", spellDelay = 250, projectileName = "rumble_taze_mis.troy", projectileSpeed = 2000, range = 950, radius = 90, type = "line", cc = "true"},
}},
["Nocturne"] = {charName = "Nocturne", skillshots = {
["NocturneDuskbringer"] =  {name = "NocturneDuskbringer", spellName = "NocturneDuskbringer", spellDelay = 250, projectileName = "NocturneDuskbringer_mis.troy", projectileSpeed = 1400, range = 1125, radius = 60, type = "line", cc = "false"},
}},
["Yasuo"] = {charName = "Yasuo", skillshots = {
["yasuoq3"] =  {name = "yasuoq3", spellName = "yasuoq3w", spellDelay = 250, projectileName = "Yasuo_Q_wind_mis.troy", projectileSpeed = 1200, range = 1000, radius = 80, type = "line", cc = "true"},
["yasuoq1"] =  {name = "yasuoq1", spellName = "yasuoQW", spellDelay = 250, projectileName = "Yasuo_Q_WindStrike.troy", projectileSpeed = 25000, range = 475, radius = 40, type = "line", cc = "false"},
["yasuoq2"] =  {name = "yasuoq2", spellName = "yasuoq2w", spellDelay = 250, projectileName = "Yasuo_Q_windstrike_02.troy", projectileSpeed = 25000, range = 475, radius = 40, type = "line", cc = "false"},
}},
-- ["Orianna"] = {charName = "Orianna", skillshots = {
--    ["OrianaIzunaCommand"] =  {name = "OrianaIzunaCommand", spellName = "OrianaIzunaCommand!", spellDelay = 250, projectileName = "Oriana_Ghost_mis.troy", projectileSpeed = 1200, range = 2000, radius = 80, type = "line", cc = "false"},
-- }},
["Ziggs"] = {charName = "Ziggs", skillshots = {
["ZiggsQ"] =  {name = "ZiggsQ", spellName = "ZiggsQ", spellDelay = 250, projectileName = "ZiggsQ.troy", projectileSpeed = 1700, range = 1400, radius = 155, type = "line", cc = "false"},
}},
["Annie"] = {charName = "Annie", skillshots = {
["AnnieR"] =  {name = "AnnieR", spellName = "InfernalGuardian", spellDelay = 100, projectileName = "nothing", projectileSpeed = 0, range = 600, radius = 300, type = "circular", cc = "true"},
}},
["Galio"] = {charName = "Galio", skillshots = {
["GalioResoluteSmite"] =  {name = "GalioResoluteSmite", spellName = "GalioResoluteSmite", spellDelay = 250, projectileName = "galio_concussiveBlast_mis.troy", projectileSpeed = 850, range = 2000, radius = 200, type = "circular", cc = "true"},
}},
["Jinx"] = {charName = "Jinx", skillshots = {
["W"] =  {name = "Zap", spellName = "JinxWMissile", spellDelay = 600, projectileName = "Jinx_W_mis.troy", projectileSpeed = 3300, range = 1450, radius = 70, type = "line", cc = "true"},
["R"] =  {name = "SuperMegaDeathRocket", spellName = "JinxRWrapper", spellDelay = 600, projectileName = "Jinx_R_Mis.troy", projectileSpeed = 1700, range = 20000, radius = 120, type = "line", cc = "false"},
}},         
}

-- Globals ---------------------------------------------------------------------
enemyes = {}
nAllies = 0
allies = {}
nEnemies = 0
evading             = false
allowCustomMovement = true
captureMovements    = true
lastMovement        = {}
detectedSkillshots  = {}
nSkillshots = 0
CastingSpell = false
lastset = 0
trueWidth = {}
trueSpeed = {}
trueDelay = {}
haveflash = false
flashSlot = nil
flashready = false
lastspell = "Q"
useflash = false
shieldslot = nil
-- Code ------------------------------------------------------------------------
function getTarget(targetId)
		if targetId ~= 0 and targetId ~= nil then
		return objManager:GetObjectByNetworkId(targetId)
	end
	return nil
end

function OnSendPacket(p)
		if VIP_USER then
		local packet = Packet(p)
		if packet:get('name') == 'S_MOVE' then
			if packet:get('sourceNetworkId') == myHero.networkID then
				if captureMovements then
					lastMovement.destination = Point2(packet:get('x'), packet:get('y'))
					lastMovement.type = packet:get('type')
					lastMovement.targetId = packet:get('targetNetworkId')
					
					if evading then
						for i, detectedSkillshot in pairs(detectedSkillshots) do
							if detectedSkillshot and detectedSkillshot.evading and inDangerousArea(detectedSkillshot, Point2(myHero.x, myHero.z)) then
								dodgeSkillshot(detectedSkillshot)
								break
							end
						end
					end
				end
				if not allowCustomMovement then
					packet:block()
				end          
			end
			elseif packet:get('name') == 'S_CAST' then
			if captureMovements then
				lastMovement.spellId = packet:get('spellId')
				lastMovement.type = 7
				lastMovement.targetId = packet:get('targetNetworkId')
				lastMovement.destination = Point2(packet:get('toX'), packet:get('toY'))
				
				if evading then
					for i, detectedSkillshot in pairs(detectedSkillshots) do
						if detectedSkillshot and detectedSkillshot.evading and inDangerousArea(detectedSkillshot, Point2(myHero.x, myHero.z)) then
							dodgeSkillshot(detectedSkillshot)
							break
						end
					end
				end
			end
			
			if not allowCustomMovement then
				if packet:get('spellId') == 12 then --Allow Flash when enabled and detected
					stopEvade()
				else
					packet:block()
				end
			end
		end
	end
end

function getLastMovementDestination()
		if VIP_USER then
		if lastMovement.type == 3 then
			heroPosition = Point2(myHero.x, myHero.z)
			
			target = getTarget(lastMovement.targetId)
			if _isValidTarget(target) then
				targetPosition = Point2(target.x, target.z)
				
				local attackRange = (myHero.range + GetDistance(myHero.minBBox, myHero.maxBBox) / 2 + GetDistance(target.minBBox, target.maxBBox) / 2)
				
				if attackRange <= heroPosition:distance(targetPosition) then
					return targetPosition + (heroPosition - targetPosition):normalized() * attackRange
				else
					return heroPosition
				end
			else
				return heroPosition
			end
			elseif lastMovement.type == 7 then
			heroPosition = Point2(myHero.x, myHero.z)
			
			target = getTarget(lastMovement.targetId)
			if _isValidTarget(target) then
				targetPosition = Point2(target.x, target.z)
				
				local castRange = myHero:GetSpellData(lastMovement.spellId).range
				
				if castRange <= heroPosition:distance(targetPosition) then
					return targetPosition + (heroPosition - targetPosition):normalized() * castRange
				else
					return heroPosition
				end
			else
				local castRange = myHero:GetSpellData(lastMovement.spellId).range
				
				if castRange <= heroPosition:distance(lastMovement.destination) then
					return lastMovement.destination + (heroPosition - lastMovement.destination):normalized() * castRange
				else
					return heroPosition
				end
			end
		else
			return lastMovement.destination
		end
		else return lastMovement.destination
	end
end

function OnLoad()
	GoodEvadeConfig = scriptConfig("Good Evade", "goodEvade")
	GoodEvadeConfig:addParam("dodgeEnabled", "Dodge Skillshots", SCRIPT_PARAM_ONOFF, true)
	GoodEvadeConfig:addParam("Flash", "Use flash to dodge"), SCRIPT_PARAM_ONOFF, true)
	GoodEvadeConfig:addParam("drawEnabled", "Draw Skillshots", SCRIPT_PARAM_ONOFF, true)
	GoodEvadeConfig:addParam("dodgeCConly", "Dodge CC only spells", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	GoodEvadeConfig:addParam("dodgeCConly2", "Dodge CC only spells toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, 77)
	GoodEvadeConfig:addParam("resetdodge", "Reset Dodge", SCRIPT_PARAM_ONKEYDOWN, false, 17)
	GoodEvadeConfig:permaShow("dodgeEnabled")
	GoodEvadeConfig:permaShow("Flash")
	
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team ~= myHero.team then
			for i, skillShotChampion in pairs(champions2) do
				if skillShotChampion.charName == hero.charName then
					table.insert(champions, skillShotChampion)
				end
			end
		end
	end
	
	
	stopEvade()
	
	isVayne = false
	if myHero.charName == "Vayne" then 
		isVayne = true
		dashrange = 300
	end
	isGraves = false
	if myHero.charName == "Graves" then 
		isGraves = true
		dashrange = 425
	end
	isEzreal = false
	if myHero.charName == "Ezreal" then 
		isEzreal = true
		dashrange = 450
	end
	isKassadin = false
	if myHero.charName == "Kassadin" then 
		isKassadin = true
		dashrange = 700
	end
	if myHero.charName == "Caitlyn"
		then isCaitlyn  = true
		dashrange = 400
	end
	isLeblanc = false
	if myHero.charName == "Leblanc" then 
		isLeblanc = true
		dashrange = 600
	end
	isRiven = false
	if myHero.charName == "Riven" then 
		isRiven = true
		dashrange = 325
	end
	isFizz = false
	if myHero.charName == "Fizz" then 
		isFizz = true
		dashrange = 400
	end
	isShen = false
	if myHero.charName == "Shen" then 
		isShen = true
		dashrange = 600
	end
	isShaco = false
	if myHero.charName == "Shaco" then 
		isShaco = true
		dashrange = 400
	end
	isRenekton = false          
	if myHero.charName == "Renekton" then 
		isRenekton = true
		dashrange = 450
	end 
	isTristana = false
	if myHero.charName == "Tristana" then 
		isTristana = true
		dashrange = 900
	end
	isTryndamere = false
	if myHero.charName == "Tryndamere" then 
		isTryndamere = true
		dashrange = 660
	end
	isCorki = false
	if myHero.charName == "Corki" then 
		isCorki = true
		dashrange = 800
	end
	isLucian = false
	if myHero.charName == "Lucian" then 
		isLucian = true
		dashrange = 425
	end
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then 
		haveflash = true
		flashSlot = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then 
		flashSlot = SUMMONER_2
		haveflash = true
	end
	
	lastMovement = {
	destination = Point2(myHero.x, myHero.z),
	moveCommand = Point2(myHero.x, myHero.z),
	type = 2,
	targetId = nil,
	spellId = nil,
	approachedPoint = nil
	}
	
	GoodEvadeSkillshotConfig = scriptConfig("Good Evade skillshots", "goodEvade skillshot config")
	for i, skillShotChampion in pairs(champions) do
		for i, skillshot in pairs(skillShotChampion.skillshots) do
			name = tostring(skillshot.name)
			name2 = tostring(skillshot.name)
			if skillshot.cc == "true" then
				GoodEvadeSkillshotConfig:addParam(name, "Dodge "..name2, SCRIPT_PARAM_SLICE, 2, 0, 2, 0)
				elseif skillshot.cc == "false" then GoodEvadeSkillshotConfig:addParam(name, "Dodge "..name2, SCRIPT_PARAM_SLICE, 1, 0, 2, 0)
				elseif skillshot.cc == "never" then GoodEvadeSkillshotConfig:addParam(name, "Dodge "..name2, SCRIPT_PARAM_SLICE, 0, 0, 2, 0)
			end
		end
	end
	
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team ~= myHero.team then
			table.insert(enemyes, hero)
			elseif hero.team == myHero.team and hero.nEnemies ~= myHero.networkID then
			table.insert(allies, hero)
		end
	end
	
	if #enemyes == 5 then
		for i, skillShotChampion in pairs(champions) do
			if skillShotChampion.charName ~= enemyes[1].charName and skillShotChampion.charName ~= enemyes[2].charName and skillShotChampion.charName ~= enemyes[3].charName
				and skillShotChampion.charName ~= enemyes[4].charName and skillShotChampion.charName ~= enemyes[5].charName then
				champions[i] = nil
			end
		end
	end
	
	player:RemoveCollision()
	player:SetVisionRadius(1700)
	
	GoodEvadeConfig.dodgeEnabled = true
	
	PrintChat(" >> Freaking Good Evade v"..version.." loaded")
	PrintChat("One line of code, no flasherino by andreluis034")
	PrintChat(versionmessage)
	if AutoUpdate then
		DelayAction(Update, 10)
	end
end



function getSideOfLine(linePoint1, linePoint2, point)
	if not point then return 0 end
	result = ((linePoint2.x - linePoint1.x) * (point.y - linePoint1.y) - (linePoint2.y - linePoint1.y) * (point.x - linePoint1.x))
	if result < 0 then
		return -1
		elseif result > 0 then
		return 1
	else
		return 0
	end
end

function dodgeSkillshot(skillshot)
		if GoodEvadeConfig.dodgeEnabled and not myHero.dead and CastingSpell == false then
		if skillshot.skillshot.type == "line" then
			dodgeLineShot(skillshot)
		else
			dodgeCircularShot(skillshot)
		end
	end
end

function dodgeCircularShot(skillshot)
	skillshot.evading = true
	
	heroPosition = Point2(myHero.x, myHero.z)
	
	moveableDistance = myHero.ms * math.max(skillshot.endTick - GetTickCount() - GetLatency(), 0) / 1000
	evadeRadius = skillshot.skillshot.radius + hitboxSize / 2 + evadeBuffer + moveBuffer
	
	safeTarget = skillshot.endPosition + (heroPosition - skillshot.endPosition):normalized() * evadeRadius
	if isreallydangerous(skillshot) then
		if HaveShield() then
			CastSpell(shieldslot)
			for i, detectedSkillshot in ipairs(detectedSkillshots) do
				if detectedSkillshot.skillshot.name == skillshot.skillshot.name then
					table.remove(detectedSkillshots, i)
					i = i-1
					if detectedSkillshot.evading then
						continueMovement(detectedSkillshot)
					end
				end
			end
			return
			elseif flashready and GoodEvadeConfig.Flash then
			FlashTo(safeTarget.x, safeTarget.y)
			return 
		end
	end
	
	if getLastMovementDestination():distance(skillshot.endPosition) <= evadeRadius then
		closestTarget = skillshot.endPosition + (getLastMovementDestination() - skillshot.endPosition):normalized() * evadeRadius
	else
		closestTarget = nil
	end
	
	lineDistance = Line2(heroPosition, getLastMovementDestination()):distance(skillshot.endPosition)
	directionTarget = heroPosition + (getLastMovementDestination() - heroPosition):normalized() * (math.sqrt(heroPosition:distance(skillshot.endPosition)^2 - lineDistance^2) + math.sqrt(evadeRadius^2 - lineDistance^2))
	if directionTarget:distance(skillshot.endPosition) >= evadeRadius + 1 then
		directionTarget = heroPosition + (getLastMovementDestination() - heroPosition):normalized() * (math.sqrt(evadeRadius^2 - lineDistance^2) - math.sqrt(heroPosition:distance(skillshot.endPosition)^2 - lineDistance^2))
	end
	
	possibleMovementTargets = {}
	intersectionPoints = Circle2(skillshot.endPosition, evadeRadius):intersectionPoints(Circle2(heroPosition, moveableDistance))
	if #intersectionPoints == 2 then
		leftTarget = intersectionPoints[1]
		rightTarget = intersectionPoints[2]
		
		local theta = ((-skillshot.endPosition + leftTarget):polar() - (-skillshot.endPosition + rightTarget):polar()) % 360
		if ((theta >= 180 and getSideOfLine(skillshot.endPosition, leftTarget, directionTarget)
			== getSideOfLine(skillshot.endPosition, leftTarget, heroPosition)
			and getSideOfLine(skillshot.endPosition, rightTarget, directionTarget)
			== getSideOfLine(skillshot.endPosition, rightTarget, heroPosition))
			or (theta <= 180 and (getSideOfLine(skillshot.endPosition, leftTarget, directionTarget)
			== getSideOfLine(skillshot.endPosition, leftTarget, heroPosition)
			or getSideOfLine(skillshot.endPosition, rightTarget, directionTarget)
			== getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)))) then
			table.insert(possibleMovementTargets, directionTarget)
		end
		
		--[[if closestTarget and ((theta >= 180 and getSideOfLine(skillshot.endPosition, leftTarget, closestTarget) == getSideOfLine(skillshot.endPosition, leftTarget, heroPosition) and getSideOfLine(skillshot.endPosition, rightTarget, closestTarget) == getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)) or (theta <= 180 and (getSideOfLine(skillshot.endPosition, leftTarget, closestTarget) == getSideOfLine(skillshot.endPosition, leftTarget, heroPosition) or getSideOfLine(skillshot.endPosition, rightTarget, closestTarget) == getSideOfLine(skillshot.endPosition, rightTarget, heroPosition)))) then
		table.insert(possibleMovementTargets, closestTarget)
		end]]
		
		table.insert(possibleMovementTargets, safeTarget)
		table.insert(possibleMovementTargets, leftTarget)
		table.insert(possibleMovementTargets, rightTarget)
	else
		if skillshot.skillshot.radius <= moveableDistance then
			table.insert(possibleMovementTargets, closestTarget)
			table.insert(possibleMovementTargets, directionTarget)
			table.insert(possibleMovementTargets, safeTarget)
		end
	end
	
	closestPoint = findBestDirection(skillshot, getLastMovementDestination(), possibleMovementTargets)
	if closestPoint ~= nil then
		closestPoint = closestPoint + (closestPoint - heroPosition):normalized() * smoothing
		evadeTo(closestPoint.x, closestPoint.y)
		elseif NeedDash(skillshot, true) then
		if getLastMovementDestination() ~= heroPosition and not isreallydangerous(skillshot) then
			dashpos = heroPosition - (heroPosition - getLastMovementDestination()):normalized() * dashrange
			evadeTo(dashpos.x, dashpos.y, true)
			elseif NeedDash(skillshot, true) then evadeTo(safeTarget.x, safeTarget.y, true)
			elseif HaveShield() then 
			for i, detectedSkillshot in ipairs(detectedSkillshots) do
				if detectedSkillshot.skillshot.name == skillshot.skillshot.name then
					table.remove(detectedSkillshots, i)
					i = i-1
					if detectedSkillshot.evading then
						continueMovement(detectedSkillshot)
					end
				end
			end
			CastSpell(shieldslot)
		end
	end
end

function HaveShield()
		if myHero.charName == "Sivir" and myHero:GetSpellData(_W) == READY then
		shieldslot = _W
		return true
		elseif myHero.charName == "Nocturne" and myHero:GetSpellData(_W) == READY then
		shieldslot = _W
		return true
	else
		return false
	end
end

function FlashTo(x, y)
	CastSpell(flashSlot, x, y)
end

function dodgeLineShot(skillshot)
	heroPosition = Point2(myHero.x, myHero.z)
	local evadeTo1
	local evadeTo2
	skillshot.evading = true
	
	skillshotLine = Line2(skillshot.startPosition, skillshot.endPosition)
	distanceFromSkillshotPath = skillshotLine:distance(heroPosition)
	evadeDistance = skillshot.skillshot.radius + hitboxSize / 2 + evadeBuffer + moveBuffer
	
	normalVector = Point2(skillshot.directionVector.y, -skillshot.directionVector.x):normalized()
	nessecaryMoveWidth = evadeDistance - distanceFromSkillshotPath
	
	evadeTo1 = heroPosition + normalVector * nessecaryMoveWidth
	evadeTo2 = heroPosition - normalVector * nessecaryMoveWidth
	if skillshotLine:distance(evadeTo1) >= skillshotLine:distance(evadeTo2) then
		longitudinalApproachLength = calculateLongitudinalApproachLength(skillshot, nessecaryMoveWidth)
		if longitudinalApproachLength >= 0 then
			evadeToTarget1 = evadeTo1 - skillshot.directionVector * longitudinalApproachLength
		end
		
		longitudinalApproachLength = calculateLongitudinalApproachLength(skillshot, evadeDistance + distanceFromSkillshotPath)
		if longitudinalApproachLength >= 0 then
			evadeToTarget2 = heroPosition - normalVector * (evadeDistance + distanceFromSkillshotPath) - skillshot.directionVector * longitudinalApproachLength
		end
		
		longitudinalRetreatLength = calculateLongitudinalRetreatLength(skillshot, nessecaryMoveWidth)
		if longitudinalRetreatLength >= 0 then
			evadeToTarget3 = evadeTo1 + skillshot.directionVector * longitudinalRetreatLength
		end
		
		longitudinalRetreatLength = calculateLongitudinalRetreatLength(skillshot, evadeDistance + distanceFromSkillshotPath)
		if longitudinalRetreatLength >= 0 then
			evadeToTarget4 = heroPosition - normalVector * (evadeDistance + distanceFromSkillshotPath) + skillshot.directionVector * longitudinalRetreatLength
		end
		
		safeTarget = evadeTo1
		
		closestPoint = getLastMovementDestination() + normalVector * (evadeDistance - skillshotLine:distance(getLastMovementDestination()))
		closestPoint2 = getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) + normalVector * evadeDistance
	else
		longitudinalApproachLength = calculateLongitudinalApproachLength(skillshot, nessecaryMoveWidth)
		if longitudinalApproachLength >= 0 then
			evadeToTarget1 = evadeTo2 - skillshot.directionVector * longitudinalApproachLength
		end
		
		longitudinalApproachLength = calculateLongitudinalApproachLength(skillshot, evadeDistance + distanceFromSkillshotPath)
		if longitudinalApproachLength >= 0 then
			evadeToTarget2 = heroPosition + normalVector * (evadeDistance + distanceFromSkillshotPath) - skillshot.directionVector * longitudinalApproachLength
		end
		
		longitudinalRetreatLength = calculateLongitudinalRetreatLength(skillshot, nessecaryMoveWidth)
		if longitudinalRetreatLength >= 0 then
			evadeToTarget3 = evadeTo2 + skillshot.directionVector * longitudinalRetreatLength
		end
		
		longitudinalRetreatLength = calculateLongitudinalRetreatLength(skillshot, evadeDistance + distanceFromSkillshotPath)
		if longitudinalRetreatLength >= 0 then
			evadeToTarget4 = heroPosition + normalVector * (evadeDistance + distanceFromSkillshotPath) + skillshot.directionVector * longitudinalRetreatLength
		end
		
		safeTarget = evadeTo2
		
		closestPoint = getLastMovementDestination() - normalVector * (evadeDistance - skillshotLine:distance(getLastMovementDestination()))
		closestPoint2 = getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) - normalVector * evadeDistance
	end
	
	if skillshotLine:distance(getLastMovementDestination()) <= evadeDistance then
		directionTarget = findBestDirection(skillshot,getLastMovementDestination(), {closestPoint, closestPoint2, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) - normalVector * evadeDistance, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) + normalVector * evadeDistance})
	else
		if getSideOfLine(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) == getSideOfLine(skillshot.startPosition, skillshot.endPosition, heroPosition) then
			if skillshotLine:distance(heroPosition) <= skillshotLine:distance(getLastMovementDestination()) then
				directionTarget = heroPosition + (getLastMovementDestination()-heroPosition):normalized() * ((evadeDistance - distanceFromSkillshotPath) * heroPosition:distance(getLastMovementDestination())) / (skillshotLine:distance(getLastMovementDestination()) - distanceFromSkillshotPath)
			else
				directionTarget = heroPosition + (getLastMovementDestination()-heroPosition):normalized() * ((evadeDistance + distanceFromSkillshotPath) * heroPosition:distance(getLastMovementDestination())) / (distanceFromSkillshotPath - skillshotLine:distance(getLastMovementDestination()))
			end
		else
			directionTarget = heroPosition + (getLastMovementDestination() - heroPosition):normalized() * (evadeDistance + distanceFromSkillshotPath) * heroPosition:distance(getLastMovementDestination()) / (skillshotLine:distance(getLastMovementDestination()) + distanceFromSkillshotPath)
		end
	end
	
	evadeTarget = nil
	if (evadeToTarget1 ~= nil and evadeToTarget3 ~= nil and Line2(evadeToTarget1, evadeToTarget3):distance(directionTarget) <= 1 and getSideOfLine(evadeToTarget1, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget1), directionTarget) ~= getSideOfLine(evadeToTarget3, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget3), directionTarget)) or (evadeToTarget2 ~= nil and evadeToTarget4 ~= nil and Line2(evadeToTarget2, evadeToTarget4):distance(directionTarget) <= 1 and getSideOfLine(evadeToTarget2, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget2), directionTarget) ~= getSideOfLine(evadeToTarget4, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget4), directionTarget)) or (evadeToTarget1 ~= nil and evadeToTarget3 == nil and getSideOfLine(heroPosition, evadeToTarget1, skillshot.startPosition) ~= getSideOfLine(heroPosition, evadeToTarget1, directionTarget)) or (evadeToTarget2 ~= nil and evadeToTarget4 == nil and getSideOfLine(heroPosition, evadeToTarget2, skillshot.startPosition) ~= getSideOfLine(heroPosition, evadeToTarget2, directionTarget)) then
		evadeTarget = directionTarget
	else
		possibleMovementTargets = {}
		
		if (evadeToTarget1 ~= nil and evadeToTarget3 ~= nil and Line2(evadeToTarget1, evadeToTarget3):distance(closestPoint2) <= 1 and getSideOfLine(evadeToTarget1, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget1), closestPoint2) ~= getSideOfLine(evadeToTarget3, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget3), closestPoint2)) or (evadeToTarget2 ~= nil and evadeToTarget4 ~= nil and Line2(evadeToTarget2, evadeToTarget4):distance(closestPoint2) <= 1 and getSideOfLine(evadeToTarget2, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget2), closestPoint2) ~= getSideOfLine(evadeToTarget4, getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, evadeToTarget4), closestPoint2)) or (evadeToTarget1 ~= nil and evadeToTarget3 == nil and getSideOfLine(heroPosition, evadeToTarget1, skillshot.startPosition) ~= getSideOfLine(heroPosition, evadeToTarget1, closestPoint2)) or (evadeToTarget2 ~= nil and evadeToTarget4 == nil and getSideOfLine(heroPosition, evadeToTarget2, skillshot.startPosition) ~= getSideOfLine(heroPosition, evadeToTarget2, closestPoint2)) then
			table.insert(possibleMovementTargets, closestPoint2)
		end
		
		if evadeToTarget1 ~= nil then
			table.insert(possibleMovementTargets, evadeToTarget1)
		end
		
		if evadeToTarget2 ~= nil then
			table.insert(possibleMovementTargets, evadeToTarget2)
		end
		
		if evadeToTarget3 ~= nil then
			table.insert(possibleMovementTargets, evadeToTarget3)
		end
		
		if evadeToTarget4 ~= nil then
			table.insert(possibleMovementTargets, evadeToTarget4)
		end
		
		evadeTarget = findBestDirection(skillshot,getLastMovementDestination(), possibleMovementTargets)
	end
	
	if evadeTarget then
		if getSideOfLine(skillshot.startPosition, skillshot.endPosition, evadeTarget) == getSideOfLine(skillshot.startPosition, skillshot.endPosition, getLastMovementDestination()) and skillshotLine:distance(getLastMovementDestination()) > evadeDistance then
			pathDirectionVector = (evadeTarget - heroPosition)
			if getSideOfLine(skillshot.startPosition, skillshot.endPosition, heroPosition) == getSideOfLine(skillshot.startPosition, skillshot.endPosition, evadeTarget) then
				evadeTarget = evadeTarget + pathDirectionVector:normalized() * (pathDirectionVector:len() + smoothing / (evadeDistance - distanceFromSkillshotPath) * pathDirectionVector:len())
			else
				evadeTarget = evadeTarget + pathDirectionVector:normalized() * (pathDirectionVector:len() + smoothing / (evadeDistance + distanceFromSkillshotPath) * pathDirectionVector:len())
			end
		end
		evadeTo(evadeTarget.x, evadeTarget.y)
		elseif NeedDash(skillshot, true)
		then if (evadeTo1:distance(lastMovement.destination) > evadeTo2:distance(lastMovement.destination)) and not InsideTheWall(evadeTo2) then
			safeTarget = evadeTo2
			elseif (evadeTo2:distance(lastMovement.destination) > evadeTo1:distance(lastMovement.destination)) and not InsideTheWall(evadeTo1) then
			safeTarget = evadeTo1
			elseif InsideTheWall(evadeTo2) then
			safeTarget = evadeTo1
			elseif InsideTheWall(evadeTo1) then
			safeTarget = evadeTo2
		end
		evadeTo(safeTarget.x, safeTarget.y, true)
		elseif HaveShield() then 
		for i, detectedSkillshot in ipairs(detectedSkillshots) do
			if detectedSkillshot.skillshot.name == skillshot.skillshot.name then
				table.remove(detectedSkillshots, i)
				i = i-1
				if detectedSkillshot.evading then
					continueMovement(detectedSkillshot)
				end
			end
		end
		CastSpell(shieldslot)
	end
end---------------------------

function _isDangerSkillshot(skillshot)
		if skillshot.skillshot.name == "LeonaZenithBlade" 
		or skillshot.skillshot.name == "EnchantedArrow" 
		or skillshot.skillshot.name == "LuxMaliceCannon"
		or skillshot.skillshot.name == "SejuaniR"
		or skillshot.skillshot.name == "Crescendo"
		or skillshot.skillshot.name == "TrueshotBarrage"
		or skillshot.skillshot.name == "RocketGrab"
		or skillshot.skillshot.name == "DredgeLine"
		or skillshot.skillshot.name == "EnchantedArrow"
		or skillshot.skillshot.name == "ShadowDash"
		or skillshot.skillshot.name == "FizzULT"
		or skillshot.skillshot.name == "VarusR"
		or skillshot.skillshot.name == "SuperMegaDeathRocket"
		or skillshot.skillshot.name == "UFSlash"
		or skillshot.skillshot.name == "LeonaSolarFlare"
		or skillshot.skillshot.name == "AnnieR"
		then
		return true
	else
		return false
	end 
end

function isreallydangerous(skillshot)
		if skillshot.skillshot.name == "UFSlash"
		or skillshot.skillshot.name == "Crescendo"
		or skillshot.skillshot.name == "FizzULT"
		or skillshot.skillshot.name == "Enchanted Arrow"
		or skillshot.skillshot.name == "AnnieR"
		then return true
	else
		return false
	end
end

function InsideTheWall(evadeTestPoint)
	local heroPosition = Point2(myHero.x, myHero.z)
	local dist = evadeTestPoint:distance(heroPosition)
	local interval = 50
	local nChecks = math.ceil((dist+50)/50)
	
	if evadeTestPoint.x == 0 or evadeTestPoint.y == 0 then
		return true
	end 
	for k=1, nChecks, 1 do
		local checksPos = evadeTestPoint + (evadeTestPoint - heroPosition):normalized()*(interval*k)
		if IsWall(D3DXVECTOR3(checksPos.x, myHero.y, checksPos.y)) then
			return true
		end
	end
	if IsWall(D3DXVECTOR3(evadeTestPoint.x + 20, myHero.y, evadeTestPoint.y + 20)) then return true end
	if IsWall(D3DXVECTOR3(evadeTestPoint.x + 20, myHero.y, evadeTestPoint.y - 20)) then return true end
	if IsWall(D3DXVECTOR3(evadeTestPoint.x - 20, myHero.y, evadeTestPoint.y - 20)) then return true end
	if IsWall(D3DXVECTOR3(evadeTestPoint.x - 20, myHero.y, evadeTestPoint.y + 20)) then return true end
	
	return false
end

function findBestDirection(skillshot, referencePoint, possiblePoints)
	if not skillshot then return closestPoint end
	referencePoint = Point2(mousePos.x , mousePos.z)
	closestPoint = nil
	closestDistance = nil
	side1 = getSideOfLine(skillshot.startPosition, skillshot.endPosition, Point2(myHero.x, myHero.z)) 
	for i, point in pairs(possiblePoints) do
		if point ~= nil and skillshot ~= nil then
			side2 = getSideOfLine(skillshot.startPosition, skillshot.endPosition, point)
			distToSkillshot = Line2(skillshot.startPosition, skillshot.endPosition):distance(point)
			mindistSkillshot = skillshot.skillshot.radius + hitboxSize / 2 + evadeBuffer
			distance = point:distance(referencePoint)
			if (closestDistance == nil or distance <= closestDistance) and not InsideTheWall(point) 
				and distToSkillshot > mindistSkillshot and (side1 == side2 or side1 == 0) then
				closestDistance = distance
				closestPoint = point
			end
		end
	end
	
	return closestPoint
end

function calculateLongitudinalApproachLength(skillshot, d)
	v1 = skillshot.skillshot.projectileSpeed
	v2 = myHero.ms
	longitudinalDistance = math.max(skillshotPosition(skillshot, GetTickCount()):distance(getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, Point2(myHero.x, myHero.z))) - hitboxSize / 2 - skillshot.skillshot.radius, 0)  + v1 * math.max(skillshot.startTick - GetTickCount(), 0) / 1000
	
	preResult = -d^2 * v1^4 + d^2 * v2^2 * v1^2 + longitudinalDistance^2 * v2^2 * v1^2
	if preResult >= 0 then
		result = (math.sqrt(preResult) - longitudinalDistance * v2^2) / (v1^2 - v2^2)
		if result >= 0 then
			return result
		end
	end
	
	return -1
end

function calculateLongitudinalApproachLength2(skillshot, d)
	v1 = skillshot.skillshot.projectileSpeed
	v2 = myHero.ms + (dashrange * 4)
	longitudinalDistance = math.max(skillshotPosition(skillshot, GetTickCount()):distance(getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, Point2(myHero.x, myHero.z))) - hitboxSize / 2 - skillshot.skillshot.radius, 0)  + v1 * math.max(skillshot.startTick - GetTickCount(), 0) / 1000
	
	preResult = -d^2 * v1^4 + d^2 * v2^2 * v1^2 + longitudinalDistance^2 * v2^2 * v1^2
	if preResult >= 0 then
		result = (math.sqrt(preResult) - longitudinalDistance * v2^2) / (v1^2 - v2^2)
		if result >= 0 then
			return result
		end
	end
	
	return -1
end

function calculateLongitudinalRetreatLength(skillshot, d)
	v1 = skillshot.skillshot.projectileSpeed
	v2 = myHero.ms
	longitudinalDistance = math.max(skillshotPosition(skillshot, GetTickCount()):distance(getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, Point2(myHero.x, myHero.z))) - hitboxSize / 2 - skillshot.skillshot.radius, 0) + v1 * math.max(skillshot.startTick - GetTickCount(), 0) / 1000
	
	preResult = -d^2 * v1^4 + d^2 * v2^2 * v1^2 + longitudinalDistance^2 * v2^2 * v1^2
	if preResult >= 0 then
		result = (math.sqrt(preResult) + longitudinalDistance * v2^2) / (v1^2 - v2^2)
		if result >= 0 then
			return result
		end
	end
	
	return -1
end

function calculateLongitudinalRetreatLength2(skillshot, d)
	v1 = skillshot.skillshot.projectileSpeed
	v2 = myHero.ms + (dashrange * 4)
	longitudinalDistance = math.max(skillshotPosition(skillshot, GetTickCount()):distance(getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, Point2(myHero.x, myHero.z))) - hitboxSize / 2 - skillshot.skillshot.radius, 0) + v1 * math.max(skillshot.startTick - GetTickCount(), 0) / 1000
	
	preResult = -d^2 * v1^4 + d^2 * v2^2 * v1^2 + longitudinalDistance^2 * v2^2 * v1^2
	if preResult >= 0 then
		result = (math.sqrt(preResult) + longitudinalDistance * v2^2) / (v1^2 - v2^2)
		if result >= 0 then
			return result
		end
	end
	
	return -1
end

function inDangerousArea(skillshot, coordinate)
		if skillshot.skillshot.type == "line" then
		return inRange(skillshot, coordinate) 
		and not skillshotHasPassed(skillshot, coordinate) 
		and Line2(skillshot.startPosition, skillshot.endPosition):distance(coordinate) < (skillshot.skillshot.radius + hitboxSize / 2 + evadeBuffer) 
		and coordinate:distance(skillshot.startPosition + skillshot.directionVector) <= coordinate:distance(skillshot.startPosition - skillshot.directionVector)
	else
		return coordinate:distance(skillshot.endPosition) <= skillshot.skillshot.radius + hitboxSize / 2 + evadeBuffer
	end
end

function inRange(skillshot, coordinate)
	return getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, coordinate):distance(skillshot.startPosition) <= skillshot.skillshot.range
end

function OnDeleteObj(object)
		if object ~= nil and object.type == "obj_GeneralParticleEmmiter" then
		for i, detectedSkillshot in ipairs(detectedSkillshots) do
			if detectedSkillshot.skillshot.type == "line" then
				if detectedSkillshot.skillshot.projectileName == object.name then
					table.remove(detectedSkillshots, i)
					i = i-1
					if detectedSkillshot.evading then
						continueMovement(detectedSkillshot)
					end
				end
			end
		end
	end
end
function OnCreateObj(object)
		if object ~= nil and object.type == "obj_GeneralParticleEmmiter" then
		for i, skillShotChampion in pairs(champions) do
			for i, skillshot in pairs(skillShotChampion.skillshots) do
				if GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 2 then
					if skillshot.projectileName == object.name then
						for i, detectedSkillshot in pairs(detectedSkillshots) do
							if detectedSkillshot.skillshot.projectileName == skillshot.projectileName then
								return
							end
						end
						for i = 1, heroManager.iCount, 1 do
							currentHero = heroManager:GetHero(i)
							if currentHero.team == myHero.team and skillShotChampion.charName == currentHero.charName then
								return
							end
						end
						
						startPosition = Point2(object.x, object.z)
						if GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 2 or (GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 1 and nEnemies <= 2 and not (GoodEvadeConfig.dodgeCConly or GoodEvadeConfig.dodgeCConly2)) then
							if skillshot.type == "line" then                            
								skillshotToAdd = {object = object, startPosition = startPosition, endPosition = nil, directionVector = nil, 
								startTick = GetTickCount(), endTick = GetTickCount() + skillshot.range/skillshot.projectileSpeed*1000, 
								skillshot = skillshot, evading = false, drawit = false}
							else
								endPosition = Point2(object.x, object.z)
								table.insert(detectedSkillshots, {startPosition = startPosition, endPosition = endPosition, 
								directionVector = (endPosition - startPosition):normalized(), startTick = GetTickCount() + skillshot.spellDelay, 
								endTick = GetTickCount() + skillshot.spellDelay + skillshot.projectileSpeed, skillshot = skillshot, evading = false, drawit = false})
							end
						end
						return
					end
				end
			end
		end
	end
end
function OnAnimation(unit, animationName)
	if unit.isMe and (animationName == "Idle1" or animationName == "Run") then CastingSpell = false end
end

function OnProcessSpell(unit, spell)
		if unit.isMe and myHero.charName == "MasterYi" and spell.name == myHero:GetSpellData(_W).name then
		CastingSpell = true
		elseif unit.isMe and myHero.charName == "Nunu" and spell.name == myHero:GetSpellData(_R).name then
		CastingSpell = true
		elseif unit.isMe and myHero.charName == "MissFortune" and spell.name == myHero:GetSpellData(_R).name then
		CastingSpell = true
		elseif unit.isMe and myHero.charName == "Malzahar" and spell.name == myHero:GetSpellData(_R).name then
		CastingSpell = true
		elseif unit.isMe and myHero.charName == "Katarina" and spell.name == myHero:GetSpellData(_R).name then
		CastingSpell = true
		elseif unit.isMe and myHero.charName == "Janna" and spell.name == myHero:GetSpellData(_R).name then
		CastingSpell = true
		elseif unit.isMe and myHero.charName == "Galio" and spell.name == myHero:GetSpellData(_R).name then
		CastingSpell = true
		elseif unit.isMe and myHero.charName == "FiddleSticks" and spell.name == myHero:GetSpellData(_W).name then
		CastingSpell = true
		elseif unit.isMe and myHero.charName == "FiddleSticks" and spell.name == myHero:GetSpellData(_R).name then
		CastingSpell = true
	end
	if unit.isMe and isLeblanc then
		if spell.name == myHero:GetSpellData(_Q).name then lastspell = "Q"
			elseif spell.name == myHero:GetSpellData(_W).name then lastspell = "W"
			elseif spell.name == myHero:GetSpellData(_E).name then lastspell = "E"
		end
	end
	if not myHero.dead and unit.team ~= myHero.team then
		for i, skillShotChampion in pairs(champions) do
			if skillShotChampion.charName == unit.charName then
				for i, skillshot in pairs(skillShotChampion.skillshots) do
					if skillshot.spellName == spell.name then
						startPosition = Point2(unit.x, unit.z)
						endPosition = Point2(spell.endPos.x, spell.endPos.z)
						directionVector = (endPosition - startPosition):normalized()
						if GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 2 or (GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 1 and nEnemies <= 2 and not (GoodEvadeConfig.dodgeCConly or GoodEvadeConfig.dodgeCConly2)) then
							if skillshot.type == "line" then
								table.insert(detectedSkillshots, {startPosition = startPosition, endPosition = startPosition + directionVector * skillshot.range,
								directionVector = directionVector, startTick = GetTickCount() + skillshot.spellDelay, 
								endTick = GetTickCount() + skillshot.spellDelay + skillshot.range/skillshot.projectileSpeed*1000, skillshot = skillshot, evading = false, drawit = true})
								elseif skillshot.type == "circular" then
								table.insert(detectedSkillshots, {startPosition = startPosition, endPosition = endPosition, 
								directionVector = directionVector, startTick = GetTickCount() + skillshot.spellDelay, 
								endTick = GetTickCount() + skillshot.spellDelay + skillshot.projectileSpeed, skillshot = skillshot, evading = false, drawit = true})
							end
						end
						return
					end
				end
			end
		end
	end
end

function skillshotPosition(skillshot, tickCount)
		if skillshot.skillshot.type == "line" then
		return skillshot.startPosition + skillshot.directionVector * math.max(tickCount - skillshot.startTick, 0) * skillshot.skillshot.projectileSpeed / 1000
	else
		return skillshot.endPosition
	end
end

function skillshotHasPassed(skillshot, coordinate)
	footOfPerpendicular = getPerpendicularFootpoint(skillshot.startPosition, skillshot.endPosition, coordinate)
	currentSkillshotPosition = skillshotPosition(skillshot, GetTickCount() - 2 * GetLatency())
	side1 = getSideOfLine(coordinate, footOfPerpendicular, currentSkillshotPosition)
	side2 =  getSideOfLine(coordinate, footOfPerpendicular, skillshot.startPosition)
	return side1 ~= side2 and currentSkillshotPosition:distance(footOfPerpendicular) >= (skillshot.skillshot.radius + hitboxSize / 2)
end

function getPerpendicularFootpoint(linePoint1, linePoint2, point)
	distanceFromLine = Line2(linePoint1, linePoint2):distance(point)
	directionVector = (linePoint2 - linePoint1):normalized()
	
	footOfPerpendicular = point + Point2(-directionVector.y, directionVector.x) * distanceFromLine
	if Line2(linePoint1, linePoint2):distance(footOfPerpendicular) > distanceFromLine then
		footOfPerpendicular = point - Point2(-directionVector.y, directionVector.x) * distanceFromLine
	end
	
	return footOfPerpendicular
end

function OnTick()
		if not VIP_USER then
		if evading then
			for i, detectedSkillshot in pairs(detectedSkillshots) do
				if detectedSkillshot and detectedSkillshot.evading and inDangerousArea(detectedSkillshot, Point2(myHero.x, myHero.z)) then
					dodgeSkillshot(detectedSkillshot)
				end
			end
		end
	end
	if haveflash then 
		if myHero:CanUseSpell(flashSlot) == READY then 
			flashready = true 
			else flashready = false 
		end
	end
	if GoodEvadeConfig.resetdodge then
		stopEvade()
		detectedSkillshots = {}
	end
	if not VIP_USER then
		if AutoCarry ~= nil then 
			if AutoCarry.MainMenu ~= nil then 
				if AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.LastHit or AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LaneClear
					then
					if lastset < GetTickCount()
						then   lastMovement.destination = Point2(mousePos.x, mousePos.z)
						lastset = GetTickCount() + 100
					end
				end
				elseif AutoCarry.Keys ~= nil then
				if AutoCarry.Keys.AutoCarry or AutoCarry.Keys.MixedMode or AutoCarry.Keys.LastHit or AutoCarry.Keys.LaneClear then
					if lastset < GetTickCount() then 
						lastMovement.destination = Point2(mousePos.x, mousePos.z)
						lastset = GetTickCount() + 100
					end
				end
			end
		end
	end
	nSkillshots = 0
	for _, detectedSkillshot in pairs(detectedSkillshots) do
		if detectedSkillshot then nSkillshots = nSkillshots + 1 end
	end
	
	if not allowCustomMovement and nSkillshots == 0 then
		stopEvade()
	end
	
	hitboxSize = GetDistance(myHero.minBBox, myHero.maxBBox)
	
	nEnemies = CountEnemyHeroInRange(1500)
	table.sort(enemyes, function(x,y) return GetDistance(x) < GetDistance(y) end)
	
	if skillshotToAdd ~= nil and skillshotToAdd.object ~= nil and skillshotToAdd.object.valid and (GetTickCount() - skillshotToAdd.startTick) >= GetLatency()+20 then
		skillshotToAdd.directionVector = (Point2(skillshotToAdd.object.x, skillshotToAdd.object.z) - skillshotToAdd.startPosition):normalized()
		skillshotToAdd.endPosition = skillshotToAdd.startPosition + skillshotToAdd.directionVector * skillshotToAdd.skillshot.range
		
		table.insert(detectedSkillshots, skillshotToAdd)
		
		skillshotToAdd = nil
	end
	
	heroPosition = Point2(myHero.x, myHero.z)
	for i, detectedSkillshot in ipairs(detectedSkillshots) do
		if detectedSkillshot.endTick <= GetTickCount() then
			table.remove(detectedSkillshots, i)
			i = i-1
			if detectedSkillshot.evading then
				continueMovement(detectedSkillshot)
			end
		else
			if evading then
				if detectedSkillshot.evading and not inDangerousArea(detectedSkillshot, heroPosition) then
					if detectedSkillshot.skillshot.type == "line" then
						-- SKILLSHOT PASSED
						side1 = getSideOfLine(detectedSkillshot.startPosition, detectedSkillshot.endPosition, heroPosition) 
						side2 = getSideOfLine(detectedSkillshot.startPosition, detectedSkillshot.endPosition, getLastMovementDestination())
						if skillshotHasPassed(detectedSkillshot, heroPosition) then
							continueMovement(detectedSkillshot)
							
							-- DESTINATION SAFE
							elseif not inDangerousArea(detectedSkillshot, getLastMovementDestination()) and (side1 == side2) and (side1 ~= 0) then
							continueMovement(detectedSkillshot)
							
							-- OUT OF RANGE
							elseif not inRange(detectedSkillshot, heroPosition) and not inRange(detectedSkillshot, getLastMovementDestination()) then
							continueMovement(detectedSkillshot)
							
							-- APPROACH TARGET
						else
							if lastMovement.approachedPoint ~= getLastMovementDestination() then
								footpoint = getPerpendicularFootpoint(detectedSkillshot.startPosition, detectedSkillshot.endPosition, getLastMovementDestination())
								closestSafePoint = footpoint + Point2(-detectedSkillshot.directionVector.y, detectedSkillshot.directionVector.x) * (detectedSkillshot.skillshot.radius + hitboxSize / 2 + evadeBuffer + moveBuffer)
								if (getSideOfLine(detectedSkillshot.startPosition, detectedSkillshot.endPosition, heroPosition) ~= getSideOfLine(detectedSkillshot.startPosition, detectedSkillshot.endPosition, closestSafePoint)) then
									closestSafePoint = footpoint - Point2(-detectedSkillshot.directionVector.y, detectedSkillshot.directionVector.x) * (detectedSkillshot.skillshot.radius + hitboxSize / 2 + evadeBuffer + moveBuffer)
								end
								
								captureMovements = false
								allowCustomMovement = true
						if skillshot ~= nil then if skillshot.spellName ~= nil then if GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 2 and (nSkillshots > 1) and NeedDash(skillshot, true) then DashTo(closestSafePoint.x, closestSafePoint.y) end end
									myHero:MoveTo(closestSafePoint.x, closestSafePoint.y)
									lastMovement.moveCommand = Point2(closestSafePoint.x, closestSafePoint.y)
									allowCustomMovement = false
									captureMovements = true
									
									lastMovement.approachedPoint = getLastMovementDestination()
								end
							end
						end
					else
						evadeRadius = detectedSkillshot.skillshot.radius + hitboxSize / 2 + evadeBuffer + moveBuffer
						directionVector = (heroPosition - detectedSkillshot.endPosition):normalized()
						tangentDirectionVector = Point2(-directionVector.y, directionVector.x)
						movementTargetSideOfLine = getSideOfLine(heroPosition, heroPosition + tangentDirectionVector, getLastMovementDestination())
						skillshotSideOfLine = getSideOfLine(heroPosition, heroPosition + tangentDirectionVector, detectedSkillshot.endPosition)
						
						-- DESTINATION SAFE
						if movementTargetSideOfLine == 0 or movementTargetSideOfLine ~= skillshotSideOfLine then
							continueMovement(detectedSkillshot)
						else
							if getLastMovementDestination():distance(detectedSkillshot.endPosition) <= evadeRadius then
								closestTarget = detectedSkillshot.endPosition + (getLastMovementDestination() - detectedSkillshot.endPosition):normalized() * evadeRadius
							else
								closestTarget = nil
							end
							
							dx = detectedSkillshot.endPosition.x - heroPosition.x
							dy = detectedSkillshot.endPosition.y - heroPosition.y
							D_squared = dx * dx + dy * dy
							if D_squared < evadeRadius * evadeRadius then
								safePoint1 = heroPosition - tangentDirectionVector * (evadeRadius / 2 + smoothing)
								safePoint2 = heroPosition + tangentDirectionVector * (evadeRadius / 2 + smoothing)
							else
								intersectionPoints = Circle2(detectedSkillshot.endPosition, evadeRadius):intersectionPoints(Circle2(heroPosition, math.sqrt(D_squared - evadeRadius * evadeRadius)))
								if #intersectionPoints == 2 then
									safePoint1 = heroPosition - (heroPosition - intersectionPoints[1]):normalized() * (evadeRadius / 2 + smoothing)
									safePoint2 = heroPosition - (heroPosition - intersectionPoints[2]):normalized() * (evadeRadius / 2 + smoothing)
								else
									safePoint1 = heroPosition - tangentDirectionVector * (evadeRadius / 2 + smoothing)
									safePoint2 = heroPosition + tangentDirectionVector * (evadeRadius / 2 + smoothing)
								end
							end
							
							local theta = ((-detectedSkillshot.endPosition + safePoint2):polar() - (-detectedSkillshot.endPosition + safePoint1):polar()) % 360
							if closestTarge and (
								(
								theta < 180 and (
								getSideOfLine(detectedSkillshot.endPosition, safePoint2, closestTarget) == getSideOfLine(detectedSkillshot.endPosition, safePoint2, heroPosition) and
								getSideOfLine(detectedSkillshot.endPosition, safePoint1, closestTarget) == getSideOfLine(detectedSkillshot.endPosition, safePoint1, heroPosition)
								)
								) or (
								theta > 180 and (
								getSideOfLine(detectedSkillshot.endPosition, safePoint2, closestTarget) == getSideOfLine(detectedSkillshot.endPosition, safePoint2, heroPosition) or
								getSideOfLine(detectedSkillshot.endPosition, safePoint1, closestTarget) == getSideOfLine(detectedSkillshot.endPosition, safePoint1, heroPosition)
								)
								)
								) then
								possibleMovementTargets = {closestTarget, safePoint1, safePoint2}
							else
								possibleMovementTargets = {safePoint1, safePoint2}
							end
							
							closestPoint = findBestDirection(skillshot,getLastMovementDestination(), possibleMovementTargets)
							if closestPoint ~= nil then
								captureMovements = false
								allowCustomMovement = true
							if skillshot ~= nil then if skillshot.spellName ~= nil then if GoodEvadeSkillshotConfig[tostring(skillshot.name)] == 2 and (nSkillshots > 1) and NeedDash(skillshot, true) then DashTo(closestPoint.x, closestPoint.y) end
										myHero:MoveTo(closestPoint.x, closestPoint.y)
										lastMovement.moveCommand = Point2(closestPoint.x, closestPoint.y)
										allowCustomMovement = false
										captureMovements = true
									end
								end
							end
						end
					end
				end
				elseif inDangerousArea(detectedSkillshot, heroPosition) then
				dodgeSkillshot(detectedSkillshot)
			end
		end
	end
end

function DashTo(x, y)
		if isVayne and  myHero:CanUseSpell(_Q) == READY then
		CastSpell(_Q, x, y)
		elseif isRiven and  myHero:CanUseSpell(_E) == READY then
		CastSpell(_E, x, y)
		elseif isGraves and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E, x, y)
		elseif isEzreal and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E, x, y)
		elseif isKassadin and myHero:CanUseSpell(_R) == READY then
		CastSpell(_R, x, y)
		elseif isLeblanc and myHero:CanUseSpell(_W) == READY then
		CastSpell(_W, x, y)
		elseif isLeblanc and myHero:CanUseSpell(_R) == READY and lastspell == "W" then
		CastSpell(_R, x, y)
		elseif isFizz and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E, x, y)
		elseif isShaco and myHero:CanUseSpell(_Q) == READY then
		CastSpell(_Q, x, y)
		elseif isTryndamere and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E, x, y)
		elseif isCorki and myHero:CanUseSpell(_W) == READY then
		CastSpell(_W, x, y)
		elseif isShen and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E, x, y) 
		elseif isRenekton and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E, x, y)
		elseif isTristana and myHero:CanUseSpell(_W) == READY then
		CastSpell(_W, x, y)
		elseif isLucian and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E, x, y)
		elseif isCaitlyn and myHero:CanUseSpell(_E) == READY then
		myPos = Point2(myHero.x, myHero.z)
		castpos = myPos + (myPos - (Point2(x, y)))
		CastSpell(_E, castpos.x, castpos.y)
		elseif haveflash and flashready and useflash and GoodEvadeConfig.Flash then
		CastSpell(flashSlot, x, y)
		useflash = false
	end                              
end
function NeedDash(skillshot, forceDash)
	useflash = false
	local hp = myHero.health / myHero.maxHealth
	if isVayne and myHero:CanUseSpell(_Q) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then 
			dashrange = 300
		return true end
		if nSkillshots > 1 or _isDangerSkillshot(skillshot) then 
			dashrange = 300
		return true end
		elseif isRiven and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then 
			dashrange = 325 
		return true end
		if nSkillshots > 1 or _isDangerSkillshot(skillshot) then 
			dashrange = 325
		return true end
		elseif isGraves and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then
			dashrange = 425
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 425
		return true end
		elseif isTryndamere and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then
			dashrange = 660
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 660
		return true end
		elseif isShaco and myHero:CanUseSpell(_Q) == READY and skillshot.skillshot.cc == "true" then
		if skillshot or hp < 0.4 then
			dashrange = 400
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 400
		return true end
		elseif isEzreal and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then
			dashrange = 450
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 450
		return true end
		elseif isFizz and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
		if skillshot or hp < 0.4 then
			dashrange = 400
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 400
		return true end
		elseif isShen and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then
			dashrange = 600
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 600
		return true end
		elseif isKassadin and myHero:CanUseSpell(_R) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then
			dashrange = 700
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 700
		return true end
		elseif isLeblanc and myHero:CanUseSpell(_W) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then
			dashrange = 600
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 600
		return true end
		elseif isLeblanc and myHero:CanUseSpell(_R) == READY and skillshot.skillshot.cc == "true" and lastspell == "W" then
		if forceDash or hp < 0.4 then
			dashrange = 600
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 600
		return true end
		elseif isRenekton and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then
			dashrange = 450
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 450
		return true end
		elseif isTristana and myHero:CanUseSpell(_W) == READY and skillshot.skillshot.cc == "true" then
		if _isDangerSkillshot(skillshot) then
			dashrange = 900
		return true end
		elseif isCorki and myHero:CanUseSpell(_W) == READY and skillshot.skillshot.cc == "true" then
		if _isDangerSkillshot(skillshot) then
			dashrange = 800
		return true end
		elseif isLucian and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then
			dashrange = 425
		return true end
		if _isDangerSkillshot(skillshot) then
			dashrange = 425
		return true end
		elseif isCaitlyn and myHero:CanUseSpell(_E) == READY and skillshot.skillshot.cc == "true" then
		if forceDash or hp < 0.4 then
			dashrange = 400
		return true end
		elseif haveflash and flashready and isreallydangerous(skillshot) then
		dashrange = 400
		useflash = true
		return true 
	end                              
	return false
end

function evadeTo(x, y, forceDash)
	startEvade()
	evadePoint = Point2(x, y)
	allowCustomMovement = true
	captureMovements = false
	if forceDash then
		local evadePos = Point2(x, y)
		local myPos = Point2(myHero.x, myHero.z)
		local dashPos = myPos - (myPos - evadePos):normalized() * dashrange
	DashTo(dashPos.x, dashPos.y) end    
	myHero:MoveTo(x, y)
	lastMovement.moveCommand = Point2(x, y)
	captureMovements = true
	allowCustomMovement = false
	evading = true
	evadingTick = GetTickCount()
end

function continueMovement(skillshot)
		if VIP_USER then
		if evading then
			skillshot.evading = false
			lastMovement.approachedPoint = nil
			
			stopEvade()
			
			if lastMovement.type == 2 then
				captureMovements = false
				myHero:MoveTo(getLastMovementDestination().x, getLastMovementDestination().y)
				captureMovements = true
				elseif lastMovement.type == 3 then
				target = getTarget(lastMovement.targetId)
				
				if _isValidTarget(target) then
					captureMovements = false
					myHero:Attack(target)
					captureMovements = true
				else
					captureMovements = false
					myHero:MoveTo(myHero.x, myHero.z)
					captureMovements = true
				end
				elseif lastMovement.type == 10 then
				myHero:HoldPosition()
				elseif lastMovement.type == 7 then
				--[[if myHero.userdataObject ~= nil and myHero.userdataObject:CanUseSpell(lastMovement.spellId) then
				target = getTarget(lastMovement.targetId)
				if _isValidTarget(target) then
				CastSpell(lastMovement.spellId, target)
			else
				CastSpell(lastMovement.spellId, lastMovement.destination.x, lastMovement.destination.y)
				end
				end]]
				lastMovement.type = 3
			end
		end
		elseif evading then
		skillshot.evading = false
		lastMovement.approachedPoint = nil
		stopEvade()    
		if continuetarget == nil then
			captureMovements = false
			myHero:MoveTo(getLastMovementDestination().x, getLastMovementDestination().y)
			captureMovements = true
			elseif continuetarget ~= nil then
			target = continuetarget
			if _isValidTarget(target) then
				captureMovements = false
				myHero:Attack(target)
				captureMovements = true
			else
				captureMovements = false
				myHero:MoveTo(myHero.x, myHero.z)
				captureMovements = true
			end
		end
	end
end

function drawLineshit(point1, point2, color, width)
	x1, y1, onScreen1 = get2DFrom3D(point1.x, myHero.y, point1.y)
	x2, y2, onScreen2 = get2DFrom3D(point2.x, myHero.y, point2.y)
	
	DrawLine(x1, y1, x2, y2, width, color)
end   
function OnDraw()
		if GoodEvadeConfig.drawEnabled then
		for i, detectedSkillshot in pairs(detectedSkillshots) do
			skillshotPos = skillshotPosition(detectedSkillshot, GetTickCount())
			if detectedSkillshot.drawit == true then
				if detectedSkillshot.skillshot.type == "line" and detectedSkillshot.skillshot.name ~= "Enchanted Arrow" then
					drawLineshit(detectedSkillshot.startPosition, detectedSkillshot.endPosition, 0xFFFF0000, 3)
					--DrawCircle(skillshotPos.x, myHero.y, skillshotPos.y, detectedSkillshot.skillshot.radius + 10, 0x00FF00)
					DrawCircle(skillshotPos.x, myHero.y, skillshotPos.y, detectedSkillshot.skillshot.radius, 0xFFFFFF)
					--DrawCircle(skillshotPos.x, myHero.y, skillshotPos.y, detectedSkillshot.skillshot.radius - 10, 0xFFFFFF)
					--DrawCircle(skillshotPos.x, myHero.y, skillshotPos.y, detectedSkillshot.skillshot.radius - 20, 0xFFFFFF)
					--DrawCircle(skillshotPos.x, myHero.y, skillshotPos.y, detectedSkillshot.skillshot.radius - 30, 0xFFFFFF)
				else
					DrawCircle(skillshotPos.x, myHero.y, skillshotPos.y, detectedSkillshot.skillshot.radius, 0x00FF00)
				end
			end
		end
	end
end

function _isValidTarget(target)
	return target ~= nil and target.valid and target.dead == false and target.bTargetable and target.bMagicImunebMagicImune ~= true and target.bInvulnerable ~= true and target.visible
end

function startEvade()
	allowCustomMovement = false
	if AutoCarry then if AutoCarry.MainMenu ~= nil then
			_G.AutoCarry.CanAttack = false
			_G.AutoCarry.CanMove = false
			elseif AutoCarry.Keys ~= nil then
			_G.AutoCarry.MyHero:MovementEnabled(false)
			_G.AutoCarry.MyHero:AttacksEnabled(false)
		end
	end
	_G.evade = true
	evading = true  
end

function stopEvade()
	--detectedSkillshots = {}
	allowCustomMovement = true
	if AutoCarry then if AutoCarry.MainMenu ~= nil then
			_G.AutoCarry.CanAttack = true
			_G.AutoCarry.CanMove = true
			elseif AutoCarry.Keys ~= nil then
			_G.AutoCarry.MyHero:MovementEnabled(true)
			_G.AutoCarry.MyHero:AttacksEnabled(true)
		end
	end
	_G.evade = false
	evading = false
end

function OnWndMsg(msg, key)
		if not VIP_USER then
		if msg == WM_RBUTTONDOWN then
			if evading then
				for i, detectedSkillshot in pairs(detectedSkillshots) do
					if detectedSkillshot and detectedSkillshot.evading and inDangerousArea(detectedSkillshot, Point2(myHero.x, myHero.z)) then
						dodgeSkillshot(detectedSkillshot)
					end
				end
			end
			lastMovement.destination = Point2(mousePos.x, mousePos.z)
		end
	end
end
