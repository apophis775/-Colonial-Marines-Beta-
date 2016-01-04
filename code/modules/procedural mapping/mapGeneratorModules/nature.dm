
//Contents exist primarily for the nature generator test type.


//Pine Trees
/datum/mapGeneratorModule/pineTrees
	spawnableAtoms = list(/obj/structure/flora/tree/pine = 5)

//Dead Trees
/datum/mapGeneratorModule/deadTrees
	spawnableAtoms = list(/obj/structure/flora/tree/dead = 3)

//Random assortment of bushes
/datum/mapGeneratorModule/randBushes
	spawnableAtoms = list()

/datum/mapGeneratorModule/randBushes/New()
	..()
	spawnableAtoms = typesof(/obj/structure/flora/ausbushes)
	for(var/i in spawnableAtoms)
		spawnableAtoms[i] = 3


//Random assortment of rocks and rockpiles
/datum/mapGeneratorModule/randRocks
	spawnableAtoms = list(/obj/structure/flora/rock = 10, /obj/structure/flora/rock/pile = 5)


//Grass turfs
/datum/mapGeneratorModule/bottomLayer/grassTurfs
	spawnableTurfs = list(/turf/simulated/floor/grass = 100)


//Grass tufts with a high spawn chance
/datum/mapGeneratorModule/denseLayer/grassTufts
	spawnableTurfs = list()
	spawnableAtoms = list(/obj/structure/flora/ausbushes/grassybush = 5)
