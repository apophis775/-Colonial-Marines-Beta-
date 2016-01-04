
var/global/datum/starmap/starMap
var/global/list/all_sector_objects = list() //All -actual- existing stellar objects. This is sad on resources. :(
var/global/list/all_so_types = list() //A global list of all potential stellar objects to choose from.

//This is the datum for the whole shebang. It contains stuff for generating the grid and maintaining it.
/datum/starmap
	var/max_x = 4
	var/max_y = 4
	var/max_z = 4
	var/negative_allowed = 0
	var/warp_speed_minutes = 10
	var/mission_ratio = 0.75 //this to 1.0 of grid size is where objective will spawn.
	var/list/all_nodes = list()
	var/list/visited_nodes = list()
	var/max_sites_sector = 3
	var/list/uniques = list()
	var/mission_selected = 0 //Don't touch.

//New spacegrid! Let's fire it up.

//This is the datum for each individual coordinate on the grid. Stuff like planets show up here.
//Also known as a "sector"
/datum/sm_node
	var/sector_name = "Sector 001" //These should be randomized. 001 is actually Earth.
	var/x //Where does this node lie on the grid?
	var/y
	var/z
	var/list/datum/sector_object/sector_stuff = list() //What exactly is here?
	var/ship_here //Is the ship currently here?
	var/faction = "Neutral" //Does someone claim this sector? "Federation", "Neutral", etc
	var/has_subspace
	var/mission_objective
	var/datum/starmap/master
	var/image/onscreen_image = null

//"Stuff" in "space"
//May or may not actually exist.
//Foot travel destinations MUST have is_away_mission and map_file.
/datum/sector_object
	var/obj_name = "Sector Thingy" //The template should never actually exist.
	var/alt_tag = "<error>"
	var/datum/sm_node/master = null
	var/descrip = "A generic sector object. This should not exist."
	var/chance = 0
	var/is_away_mission = 0
	var/map_file = ""
	var/minerals = 0
	var/radiation = 0
	var/shields = 0 //Generic "points". Ship has 100. Starbase has 1000.
	var/weapons = 0 //Generic "points". ^^^
	var/is_hostile = 0
	var/faction = "Neutral" //"friendly", "neutral", "trader", "romulan", "borg". Faction stuff spawns more often in like factions.
	var/hailing_status = 0
	var/dockable = 0
	var/number_in_name = 0
	var/is_unique = 0
	var/max_per_sector = 1
	var/life_signs = "None" //"none", "basic", "intelligent", etc
	var/image/onscreen_image
	var/datum/sector_object/orbiting = null //Are we orbiting another stellar object?

/datum/sector_object/star
	obj_name = "Star"
	descrip = "A burning nuclear furnace."
	radiation = 5000
	number_in_name = 1
	max_per_sector = 1
	chance = 0
	onscreen_image = null //Change this when we get images
	var/startype

	initialize()
		..()
		if(rand(100) < 5)
			obj_name = "Black Hole"
			descrip = "A roiling mass of gravity and radiation."
			radiation = rand(150000,250000)
			return //Nothing else is ever at a black hole.

		startype = pick("Yellow Dwarf","White Dwarf","Red Giant","Red Dwarf","Supergiant","Pulsar","Neutron Star")

		//We're not going to bother actually making subtypes for these. We could, though.
		obj_name = startype
		radiation += rand(-1000,1000)
		if(startype == "Pulsar" || startype == "Neutron Star")
			radiation += 50000//This will do weird things and allow collection of rare materials.
			descrip = "A highly unstable, radioactive star."
			return //Nothing else here, sorry.

		if(!istype(master))
			return //Just to be safe..

		if(rand(100) < 20)
			master.create_sector_object("planet/large")
		if(rand(100) < 25)
			master.create_sector_object("planet")
		if(rand(100) < 35)
			master.create_sector_object("planet")
		if(rand(100) < 20)
			master.create_sector_object("planet/small")
		if(rand(100) < 10)
			master.create_sector_object("planet/small")
		if(rand(100) < 25)
			var/randsteroids = rand(1,3)
			for(var/i = 0 to randsteroids)
				master.create_sector_object("asteroid_small")

/datum/sector_object/planet
	obj_name = "Medium Planet"
	var/planet_class = "M"
	var/planet_type = ""
	var/rotation = "Normal"
	var/atmosphere = "None"
	var/gravity = "Normal"
	var/volcanism = "Low"
	var/weather = "Low"

	is_away_mission = 1 //We can travel here!
	map_file = "" //Maps go here!

	initialize()
		..()
		generate_planet()


	proc/generate_planet()
		planet_class = pick("D","D","D","D","H","H","J","J","J","K","L","L","L","M","M","M","M","M","N","T","Y")
		gravity = pick("Low","Normal","Normal","Normal","High")
		radiation = rand(0,100)
		minerals = rand(0,15000)
		switch(planet_class)
			if("D") //Dead planet or moon. No atmosphere.
				gravity = pick("Low","Low","Normal","Normal","High")
				weather = "None"
				planet_type = pick("Barren","(Moon)","Dead")
				life_signs = "None"

			if("H") //Generally uninhabitable. Volcanic, etc.
				rotation = pick("Eccentric","Eccentric","Tilted","Tilted","Erratic","Erratic","Normal","Normal")
				atmosphere = pick("Unsafe","Unsafe","Sulphuric","Acidic","Safe","Poisonous")
				planet_type = pick("Volcanic","Acidic","Storm-wracked","Uninhabitable")
				gravity = pick("Low","Normal","High","High","Extreme")
				volcanism = pick("Low","Medium","High","High","Extreme")
				weather = pick("Low","Medium","High","High","Extreme")
				life_signs = pick("None","None","None","Proto")

			if("J") //Common gas giant.
				weather = pick("High","High","Extreme")
				volcanism = "None"
				gravity = "Extreme"
				atmosphere = "Chaotic"
				planet_type = "Gas Giant"
				life_signs = "None"
				minerals = 0

			if("K") //Habitable, with help.
				rotation = pick("Eccentric","Eccentric","Tilted","Tilted","Erratic","Erratic","Normal","Normal")
				atmosphere = pick("Unsafe","Unsafe","Unsafe","Safe","Poisonous")
				planet_type = pick("Jungle","Desert","Rocky","Ocean")
				gravity = pick("Low","Normal","Normal","Normal","High")
				weather = pick("Low","Medium","Medium","Medium","High")
				life_signs = pick("None","None","None","Proto","Proto","Simple Bacteria","Complex Bacteria")

			if("L") //Habitable, but uninhabited by animal life. Plants, bacteria, etc only
				rotation = pick("Eccentric","Normal","Normal")
				atmosphere = "Safe"
				planet_type = pick("Jungle","Forest","Ocean","Lush","Gaia")
				gravity = pick("Low","Normal","Normal","Normal","High")
				weather = pick("Low","Medium","Medium","Medium","High")
				life_signs = pick("Proto","Simple Plants","Simple Plants","Complex Plants","Complex Plants")

			if("M") //Habitable, and inhabited.
				rotation = pick("Eccentric","Normal","Normal","Tilted")
				atmosphere = "Safe"
				planet_type = pick("Jungle","Forest","Ocean","Lush","Lush","Gaia","Gaia")
				gravity = pick("Low","Normal","Normal","Normal")
				weather = pick("Low","Medium")
				life_signs = pick("Complex Plants","Complex Mixed","Primitive","Industrial","Modern")
				if(life_signs == "Modern" || life_signs == "Industrial")
					faction = pick("Federation","Federation","Federation","Romulan","Romulan","Klingon","Klingon","Ferengi","Cardassian","Bajoran","Pirate","Neutral","Neutral","Neutral")
				if(master.faction != "Neutral")
					faction = master.faction

			if("N") //Sulfuric gas planet.
				weather = pick("High","High","Extreme")
				volcanism = "None"
				gravity = "Extreme"
				atmosphere = "Sulphuric"
				planet_type = "Sulfuric Gas Giant"
				life_signs = "???"
				minerals = 0

			if("T") //Uncommon gas giant
				weather = pick("High","High","Extreme")
				volcanism = "None"
				gravity = "Extreme"
				atmosphere = "Chaotic"
				planet_type = "Gas Giant"
				life_signs = "None"
				radiation = rand(500,15000)
				minerals = 0

			if("Y") //Demon planet!
				rotation = pick("Eccentric","Eccentric","Tilted","Erratic")
				weather = "Extreme"
				volcanism = "Extreme"
				atmosphere = "???"
				planet_type = "Demon World"
				life_signs = "???"
				radiation = rand(0,150000)
				minerals = rand(0,150000)

		descrip = "A planet. Rot: [rotation] W:[weather] V: [volcanism] Atm: [atmosphere] LS: [life_signs]"

/datum/sector_object/planet/small
	obj_name = "Small Planet"

/datum/sector_object/planet/large
	obj_name = "Large Planet"

/datum/sector_object/fed_starbase
	obj_name = "Starbase"
	descrip = "A Federation starbase, equipped with all the amenities one could want."
	is_away_mission = 1
	map_file = ""
	shields = 1000
	weapons = 1000
	dockable = 1
	chance = 5 //Not big. 1 in 20 is still sizeable.
	faction = "Federation"
	number_in_name = 1

/datum/sector_object/asteroid_small
	obj_name = "Small Asteroid Belt"
	descrip = "A small field of rocks drifting through space."
	chance = 50 //Very high chance.
	faction = "Neutral"
	max_per_sector = 5
	number_in_name = 1
	map_file = ""

	initialize()
		..()
		minerals = rand(50,100)
		radiation = rand(0,10)

/datum/sector_object/asteroid_large
	obj_name = "Large Asteroid Field"
	descrip = "A large belt of rocks drifting through space."
	chance = 15
	faction = "Neutral"
	max_per_sector = 1
	number_in_name = 1
	map_file = ""

	initialize()
		..()
		minerals = rand(100,1000)
		radiation = rand(0,100)

/datum/sector_object/radioactive_anomaly
	obj_name = "Radioactive Anomaly"
	descrip = "A large, strange anomalous sector of space."
	chance = 15

	initialize()
		..()
		radiation = 15000 + rand(-5000,25000)

/datum/sector_object/nebula
	obj_name = "Radioactive Nebula"
	descrip = "A massive cloud of glowing gas."
	chance = 20

	initialize()
		..()
		radiation = 5000 + rand(-500,25000)