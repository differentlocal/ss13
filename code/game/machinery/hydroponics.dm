/obj/machinery/hydroponics
	name = "Hydroponics Tray"
	icon = 'hydroponics.dmi'
	icon_state = "hydrotraynew"
	density = 1
	anchored = 1
	var/waterlevel = 100 // The amount of water in the tray (max 100)
	var/nutrilevel = 10 // The amount of nutrient in the tray (max 10)
	var/pestlevel = 0 // The amount of pests in the tray (max 10)
	var/weedlevel = 0 // The amount of weeds in the tray (max 10)
	var/yieldmod = 1 //Modifier to yield
	var/mutmod = 1 //Modifier to mutation chance
	var/toxic = 0 // Toxicity in the tray?
	var/age = 0 // Current age
	var/dead = 0 // Is it dead?
	var/health = 0 // Its health.
	var/lastproduce = 0 // Last time it was harvested
	var/lastcycle = 0 //Used for timing of cycles.
	var/cycledelay = 200 // About 10 seconds / cycle
	var/planted = 0 // Is it occupied?
	var/harvest = 0 //Ready to harvest?
	var/obj/item/seeds/myseed = null // The currently planted seed



obj/machinery/hydroponics/process()

	if(world.time > (src.lastcycle + src.cycledelay))
		src.lastcycle = world.time
		if(src.planted && !src.dead)
			// Advance age
			src.age++

			// Drink random amount of water
			src.waterlevel -= rand(1,6)

			// Nutrients deplete slowly
			if(src.nutrilevel > 0)
				if(prob(50))
					src.nutrilevel -= 1

			// Lack of nutrients hurts non-weeds
			if(src.nutrilevel == 0 && src.myseed.plant_type != 1)
				src.health -= rand(1,3)

			// Adjust the water level so it can't go negative
			if(src.waterlevel < 0)
				src.waterlevel = 0

			// If the plant is dry, it loses health pretty fast, unless mushroom
			if(src.waterlevel <= 0 && src.myseed.plant_type != 2)
				src.health -= rand(1,3)
			else if(src.waterlevel <= 10 && src.myseed.plant_type != 2)
				src.health -= rand(0,1)

			// Too much toxins cause harm, but when the plant drinks the contaiminated water, the toxins disappear slowly
			if(src.toxic >= 40 && src.toxic < 80)
				src.health -= 1
				src.toxic -= rand(1,10)
			if(src.toxic >= 80)
				src.health -= 3
				src.toxic -= rand(1,10)

			// Sufficient water level and nutrient level = plant healthy
			if(src.waterlevel > 10 && src.nutrilevel > 0)
				src.health += rand(1,2)

			// Too many pests cause the plant to be sick
			if(src.pestlevel >= 5)
				src.health -= 1

			// If it's a weed, it doesn't stunt the growth
			if(src.weedlevel >= 5 && src.myseed.plant_type != 1 )
				src.health -= 1

			// Don't go overboard with the health
			if(src.health > src.myseed.endurance)
				src.health = src.myseed.endurance

			// If the plant is too old, lose health fast
			if(src.age > src.myseed.lifespan)
				src.health -= rand(1,5)

			// Plant dies if health = 0
			if(src.health <= 0)
				src.dead = 1
				src.harvest = 0
				src.weedlevel += 1 // Weeds flourish
				//src.toxic = 0 // Water is still toxic
				src.pestlevel = 0 // Pests die

			// Harvest code
			if(src.age > src.myseed.production && (src.age - src.lastproduce) > src.myseed.production && (!src.harvest && !src.dead))
				var/m_count = 0
				while(m_count < src.mutmod)
					if(prob(90))
						src.mutate()
					else
						src.mutatespecie() // Just testing this here until mutagens are in place
					m_count++;
				if(src.yieldmod > 0 && src.myseed.yield != -1) // Unharvestable shouldn't be harvested
					src.harvest = 1
				else
					src.lastproduce = src.age
			if(prob(5))  // On each tick, there's a 5 percent chance the pest population will increase
				src.pestlevel += 1
			if(prob(5) && src.waterlevel > 10 && src.nutrilevel > 0)  // On each tick, there's a 5 percent chance the weed population will increase, but there needs to be water/nuts for that!
				src.weedlevel += 1
		else
			if(prob(10) && src.waterlevel > 10 && src.nutrilevel > 0)  // If there's no plant, the percentage chance is 10%
				src.weedlevel += 1

		// These (v) wouldn't be necessary if additional checks were made earlier (^)

		if (src.weedlevel > 10) // Make sure it won't go overoboard
			src.weedlevel = 10
		if (src.toxic < 0) // Make sure it won't go overoboard
			src.toxic = 0
		if (src.pestlevel > 10 ) // Make sure it won't go overoboard
			src.pestlevel = 10

		// Weeeeeeeeeeeeeeedddssss

		if (prob(50) && src.weedlevel == 10) // At this point the plant is kind of fucked. Weeds can overtake the plant spot.
			if(src.planted)
				if(src.myseed.plant_type == 0) // If a normal plant
					src.weedinvasion()
				else
					src.mutateweed() // Just testing this out okay
			else
				src.weedinvasion() // Weed invasion into empty tray
		src.updateicon()
	return



obj/machinery/hydroponics/proc/updateicon()
	//Refreshes the icon
	overlays = null
	if(src.planted)
		if(dead)
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-dead")
		else if(src.harvest)
			if(src.myseed.plant_type == 2) // Shrooms don't have a -harvest graphic
				overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[src.myseed.growthstages]")
			else
				overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-harvest")
		else if(src.age < src.myseed.maturation)
			var/t_growthstate = ((src.age / src.myseed.maturation) * src.myseed.growthstages ) // Make sure it won't crap out due to HERPDERP 6 stages only
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[round(t_growthstate)]")
			src.lastproduce = src.age //Cheating by putting this here, it means that it isn't instantly ready to harvest
		else
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[src.myseed.growthstages]") // Same

		if(src.waterlevel <= 10)
			overlays += image('hydroponics.dmi', icon_state="over_lowwater")
		if(src.nutrilevel <= 2)
			overlays += image('hydroponics.dmi', icon_state="over_lownutri")
		if(src.health <= (src.myseed.endurance / 2))
			overlays += image('hydroponics.dmi', icon_state="over_lowhealth")
		if(src.weedlevel >= 5)
			overlays += image('hydroponics.dmi', icon_state="over_alert")
		if(src.pestlevel >= 5)
			overlays += image('hydroponics.dmi', icon_state="over_alert")
		if(src.toxic >= 40)
			overlays += image('hydroponics.dmi', icon_state="over_alert")
		if(src.harvest)
			overlays += image('hydroponics.dmi', icon_state="over_harvest")
	return



obj/machinery/hydroponics/proc/weedinvasion() // If a weed growth is sufficient, this happens.
	src.dead = 0
	if(src.myseed) // In case there's nothing in the tray beforehand
		del(src.myseed)
	switch(rand(1,15))		// randomly pick predominative weed
		if(14 to 15)
			src.myseed = new /obj/item/seeds/nettleseed
		if(12 to 13)
			src.myseed = new /obj/item/seeds/harebell
		if(10 to 11)
			src.myseed = new /obj/item/seeds/amanitamycelium
		if(6 to 9)
			src.myseed = new /obj/item/seeds/chantermycelium
		//if(6 to 7) implementation for tower caps still kinda missing
		//	src.myseed = new /obj/item/seeds/towermycelium
		if(4 to 5)
			src.myseed = new /obj/item/seeds/plumpmycelium
		else
			src.myseed = new /obj/item/seeds/weeds
	src.planted = 1
	src.age = 0
	src.health = src.myseed.endurance
	src.lastcycle = world.time
	src.harvest = 0
	src.weedlevel = 0 // Reset
	src.pestlevel = 0 // Reset
	spawn(5) // Wait a while
	src.updateicon()
	src.visible_message("\red[src] has been overtaken by \blue [src.myseed.plantname]!")
	var/P = new /obj/decal/point(src)
	spawn (20)
	del(P)

	return


obj/machinery/hydroponics/proc/mutate() // Mutates the current seed

	src.myseed.lifespan += rand(-2,2)
	if(src.myseed.lifespan < 10)
		src.myseed.lifespan = 10
	else if(src.myseed.lifespan > 30)
		src.myseed.lifespan = 30

	src.myseed.endurance += rand(-5,5)
	if(src.myseed.endurance < 10)
		src.myseed.endurance = 10
	else if(src.myseed.endurance > 100)
		src.myseed.endurance = 100

	src.myseed.production += rand(-1,1)
	if(src.myseed.production < 2)
		src.myseed.production = 2
	else if(src.myseed.production > 10)
		src.myseed.production = 10

	if(src.myseed.yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		src.myseed.yield += rand(-2,2)
		if(src.myseed.yield < 0)
			src.myseed.yield = 0
		else if(src.myseed.yield > 10)
			src.myseed.yield = 10

	if(src.myseed.potency != -1) //Not all plants have a potency
		src.myseed.potency += rand(-10,10)
		if(src.myseed.potency < 0)
			src.myseed.potency = 0
		else if(src.myseed.potency > 100)
			src.myseed.potency = 100
	return



obj/machinery/hydroponics/proc/hardmutate() // Strongly mutates the current seed.

	src.myseed.lifespan += rand(-4,4)
	if(src.myseed.lifespan < 10)
		src.myseed.lifespan = 10
	else if(src.myseed.lifespan > 30)
		src.myseed.lifespan = 30

	src.myseed.endurance += rand(-10,10)
	if(src.myseed.endurance < 10)
		src.myseed.endurance = 10
	else if(src.myseed.endurance > 100)
		src.myseed.endurance = 100

	src.myseed.production += rand(-2,2)
	if(src.myseed.production < 2)
		src.myseed.production = 2
	else if(src.myseed.production > 10)
		src.myseed.production = 10

	if(src.myseed.yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		src.myseed.yield += rand(-4,4)
		if(src.myseed.yield < 0)
			src.myseed.yield = 0
		else if(src.myseed.yield > 10)
			src.myseed.yield = 10

	if(src.myseed.potency != -1) //Not all plants have a potency
		src.myseed.potency += rand(-20,20)
		if(src.myseed.potency < 0)
			src.myseed.potency = 0
		else if(src.myseed.potency > 100)
			src.myseed.potency = 100
	return



obj/machinery/hydroponics/proc/mutatespecie() // Mutagent produced a new plant!

	if ( istype(src.myseed, /obj/item/seeds/nettleseed ))
		del(src.myseed)
		src.myseed = new /obj/item/seeds/deathnettleseed

	else if ( istype(src.myseed, /obj/item/seeds/amanitamycelium ))
		del(src.myseed)
		src.myseed = new /obj/item/seeds/angelmycelium

	else if ( istype(src.myseed, /obj/item/seeds/chiliseed ))
		del(src.myseed)
		src.myseed = new /obj/item/seeds/icepepperseed

	else
		return

	src.dead = 0
	src.hardmutate()
	src.planted = 1
	src.age = 0
	src.health = src.myseed.endurance
	src.lastcycle = world.time
	src.harvest = 0
	src.weedlevel = 0 // Reset

	spawn(5) // Wait a while
	src.updateicon()
	src.visible_message("\red[src] has suddenly mutated into \blue [src.myseed.plantname]!")

	return



obj/machinery/hydroponics/proc/mutateweed() // If the weeds gets the mutagent instead. Mind you, this pretty much destroys the old plant
	if ( src.weedlevel > 5 && src.myseed.plant_type == 1 )
		//user << "Weeds have overtaken the spot! The weeds mutate!"
		del(src.myseed)
		switch(rand(100))
			if(1 to 33)		src.myseed = new /obj/item/seeds/libertymycelium
			if(34 to 66)	src.myseed = new /obj/item/seeds/angelmycelium
			else			src.myseed = new /obj/item/seeds/deathnettleseed

		src.dead = 0
		src.hardmutate()
		src.planted = 1
		src.age = 0
		src.health = src.myseed.endurance
		src.lastcycle = world.time
		src.harvest = 0
		src.weedlevel = 0 // Reset

		spawn(5) // Wait a while
		src.updateicon()
		src.visible_message("\red The mutated weeds in [src] spawned a \blue [src.myseed.plantname]!")

	return



obj/machinery/hydroponics/proc/plantdies() // OH NOES!!!!! I put this all in one function to make things easier
	src.health = 0
	src.dead = 1
	src.harvest = 0
	src.updateicon()
	//user << "The plant whiters and dies." Fix this
	return



obj/machinery/hydroponics/proc/mutatepest()  // Until someone makes a spaceworm, this is commented out
//	if ( src.pestlevel > 5 )
//  	user << "The worms seem to behave oddly..."
//		spawn(10)
//		new /obj/alien/spaceworm(src.loc)
//	else
	//user << "Nothing happens..."
	return



obj/machinery/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob)

	//Called when mob user "attacks" it with object O
	if (istype(O, /obj/item/weapon/reagent_containers/glass/bucket))
		var/b_amount = O.reagents.get_reagent_amount("water")
		if(b_amount > 0 && src.waterlevel < 100)
			if(b_amount + src.waterlevel > 100)
				b_amount = 100 - src.waterlevel
			O.reagents.remove_reagent("water", b_amount)
			src.waterlevel += b_amount
			playsound(src.loc, 'slosh.ogg', 25, 1)
			user << "You fill the tray with [b_amount] units of water."
	// 		Toxicity dilutation code. The more water you put in, the lesser the toxin concentration.
	//		src.toxic -= round(b_amount/2)
	//		if (src.toxic < 0 ) // Make sure it won't go overoboard
	//			src.toxic = 0
		else if(src.waterlevel >= 100)
			user << "\red The hydroponics tray is already full."
		else
			user << "\red The bucket is not filled with water."
		src.updateicon()

	else if ( istype(O, /obj/item/nutrient) )
		var/obj/item/nutrient/myNut = O
		user.u_equip(O)
		src.nutrilevel = 10
		src.yieldmod = myNut.yieldmod
		src.mutmod = myNut.mutmod
		user << "You replace the nutrient solution in the tray"
		del(O)
		src.updateicon()

	else if ( istype(O, /obj/item/weapon/weedspray) )
		var/obj/item/weedkiller/myWKiller = O
		user.u_equip(O)
		src.toxic += myWKiller.toxicity
		src.weedlevel -= myWKiller.WeedKillStr
		if (src.weedlevel < 0 ) // Make sure it won't go overoboard
			src.weedlevel = 0
		if (src.toxic > 100 ) // Make sure it won't go overoboard
			src.toxic = 100
		user << "You apply the weedkiller solution into the tray"
		playsound(src.loc, 'spray3.ogg', 50, 1, -6)
		del(O)
		src.updateicon()

	else if ( istype(O, /obj/item/weapon/pestspray) )
		var/obj/item/pestkiller/myPKiller = O
		user.u_equip(O)
		src.toxic += myPKiller.toxicity
		src.pestlevel -= myPKiller.PestKillStr
		if (src.pestlevel < 0 ) // Make sure it won't go overoboard
			src.pestlevel = 0
		if (src.toxic > 100 ) // Make sure it won't go overoboard
			src.toxic = 100
		user << "You apply the pestkiller solution into the tray"
		playsound(src.loc, 'spray3.ogg', 50, 1, -6)
		del(O)
		src.updateicon()
	// else if ( istype(O, /obj/item/weapon/reagent_containers/glass/bucket))  If injected with vitamins... it should make the health regenerate
	//	if(src.planted)
	//		src.health += 5
	//      src.endurance += 1
	//		if( src.health > src.myspeed.endurance )
	//			src.health = src.myseed.endurance
	// else if ( istype(O, /obj/item/weapon/reagent_containers/glass/bucket))  If injected with mutagen... not sure how to make the syringe injection work
	//	if (src.planted)
	//		switch(rand(100))
	//			if (100 to 91)	src.plantdies()
	//			if (90  to 81)  src.mutatespecie()
	//			if (80	to 66)	src.hardmutate()
	//			if (65  to 41)  src.mutate()
	//			if (40  to 31)  user << "Nothing happens..."
	//			if (30	to 21)  src.mutateweed()
	//			if (20  to 11)  src.mutatepest()
	//			if (10  to  1)  src.plantdies()
	//			else 			user << "Nothing happens..."

	else if ( istype(O, /obj/item/seeds/) )
		if(!src.planted)
			user.u_equip(O)
			user << "You plant the [O.name]"
			src.dead = 0
			src.myseed = O
			src.planted = 1
			src.age = 1
			src.health = src.myseed.endurance
			src.lastcycle = world.time
			O.loc = src
			if((user.client  && user.s_active != src))
				user.client.screen -= O
			O.dropped(user)
			src.updateicon()
		else
			user << "\red The tray already has a seed in it!"

	else if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		if(src.planted && src.myseed)
			user << "*** <B>[src.myseed.name]</B> ***"
			user << "-<B>Plant Age:</B> [src.age]"
			user << "--<B>Plant Endurance:</B> [src.myseed.endurance]"
			user << "--<B>Plant Lifespan:</B> [src.myseed.lifespan]"
			if(src.myseed.yield != -1)
				user << "--<B>Plant Yield:</B> [src.myseed.yield]"
			user << "--<B>Plant Production:</B> [src.myseed.production]"
			if(src.myseed.potency != -1)
				user << "--<B>Plant Potency:</B> [src.myseed.potency]"
			user << "--<B>Weed level:</B> [src.weedlevel]/10"
			user << "--<B>Pest level:</B> [src.pestlevel]/10"
			user << "--<B>Toxicity level:</B> [src.toxic]/100"
			user << ""
		else
			user << "<B>No plant found.</B>"
			user << "--<B>Weed level:</B> [src.weedlevel]/10"
			user << "--<B>Pest level:</B> [src.pestlevel]/10"
			user << "--<B>Toxicity level:</B> [src.toxic]/100"
			user << ""

	else if (istype(O, /obj/item/weapon/plantbgone))
		if(src.planted && src.myseed)
			src.health -= rand(5,20)
			src.pestlevel -= 1 // Kill kill kill
			src.weedlevel -= 2 // Kill kill kill
			src.toxic += 5 // Oops
			src.visible_message("\red <B>\The [src] has been sprayed with \the [O][(user ? " by [user]." : ".")]")
			playsound(src.loc, 'spray3.ogg', 50, 1, -6)
		else
			user << "\red Nothing is planted in the hydrotray!"

	return



/obj/machinery/hydroponics/attack_hand(mob/user as mob)
	if(src.harvest)
		if(!user in range(1,src))
			return
		var/item = text2path(src.myseed.productname)
		var/t_amount = 0

		while ( t_amount < (src.myseed.yield * src.yieldmod ))
			if(src.myseed.species == "nettle" || src.myseed.species == "deathnettle") // User gets a WEPON
				var/obj/item/weapon/grown/t_prod = new item(user.loc)
				t_prod.seed = src.myseed.mypath
				t_prod.species = src.myseed.species
				t_prod.lifespan = src.myseed.lifespan
				t_prod.endurance = src.myseed.endurance
				t_prod.maturation = src.myseed.maturation
				t_prod.production = src.myseed.production
				t_prod.yield = src.myseed.yield
				t_prod.potency = src.myseed.potency
				t_prod.force = src.myseed.potency // POTENCY == DAMAGE FUCK YEEAHHH
				t_prod.plant_type = src.myseed.plant_type
				t_amount++
			//else if(src.myseed.species == "towercap")
				//var/obj/item/wood/t_prod = new item(user.loc) - User gets wood (heh) - not implemented yet
			else
				var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new item(user.loc) // User gets a consumable
				t_prod.seed = src.myseed.mypath
				t_prod.species = src.myseed.species
				t_prod.lifespan = src.myseed.lifespan
				t_prod.endurance = src.myseed.endurance
				t_prod.maturation = src.myseed.maturation
				t_prod.production = src.myseed.production
				t_prod.yield = src.myseed.yield
				t_prod.potency = src.myseed.potency
				t_prod.plant_type = src.myseed.plant_type
				if(src.myseed.species == "amanita" || src.myseed.species == "angel")
					t_prod.poison_amt = src.myseed.potency * 2 // Potency translates to poison amount
					t_prod.drug_amt = src.myseed.potency / 5 // Small trip
				else if(src.myseed.species == "liberty")
					t_prod.drug_amt = src.myseed.potency // TRIP TIME
				else if(src.myseed.species == "chili" || src.myseed.species == "chiliice")
					t_prod.heat_amt = src.myseed.potency // BRING ON THE HEAT
				t_amount++
		src.harvest = 0
		src.lastproduce = src.age
		if((src.yieldmod * src.myseed.yield) <= 0)
			usr << text("\red You fail to harvest anything useful")
		else
			usr << text("You harvest from the [src.myseed.plantname]")
			if(src.myseed.oneharvest)
				src.planted = 0
				src.dead = 0
		src.updateicon()
	else if(src.dead)
		src.planted = 0
		src.dead = 0
		usr << text("You remove the dead plant from the tray")
		del(src.myseed)
		src.updateicon()
	else
		if(src.planted && !src.dead)
			usr << text("The hydroponics tray has \blue [src.myseed.plantname] \black planted")
			if(src.health <= (src.myseed.endurance / 2))
				usr << text("The plant looks unhealthy")
		else
			usr << text("The hydroponics tray is empty")
		usr << text("Water: [src.waterlevel]/100")
		usr << text("Nutrient: [src.nutrilevel]/10")
		if(src.weedlevel >= 5) // Visual aid for those blind
			usr << text("The tray is filled with weeds!")
		if(src.pestlevel >= 5) // Visual aid for those blind
			usr << text("The tray is filled with tiny worms!")
		usr << text ("") // Empty line for readability.



/obj/item/device/analyzer/plant_analyzer
	name = "Plant Analyzer"
	icon_state = "hydro"

	attack_self(mob/user as mob)
		return 0


// BROKEN!!!!!!

/datum/vinetracker
	var/list/vines = list()

	proc/vineprocess()
		set background = 1
		while(vines.len > 0)
			for(var/obj/plant/vine/V in vines)
				sleep(-1)
				switch(V.stage)
					if(1)
						for(var/turf/T in orange(1, V))
							var/plantfound = 0
							if(istype(T, /turf/space)) // Vines don't grow in space
								break
							for(var/obj/O in T)		   // Vines don't grow on other plants, either
								if(istype(O, /obj/plant))
									plantfound = 1
									break

							if(plantfound)
								continue
							var/chance = rand(1,100)
							if(chance < 50)
								spawn() new /obj/plant/vine(T)
								continue
						V.health += 5
						if(V.health >= 30)
							V.stage = 2
							V.icon_state = "spacevine2"
							V.density = 1
					else if(2)
						/*
						for(var/turf/T in orange(1, V))
							var/plantfound = 0
							if(istype(T, /turf/space))
								break
							for(var/obj/O in T)
								if(istype(O, /obj/plant))
									plantfound = 1
									break
							if(plantfound)
								continue
							if(prob(15))
								spawn() new /obj/plant/vine(T)
						*/
						V.health += 5
						if(V.health >= 40)
							V.stage = 3
							V.icon_state = "spacevine3"
					else if(3)
						V.health += 10
						if(V.health >= 60)
							V.stage = 4
							V.icon_state = "spacevine4"
					else if(4)
						V.health += 20
						spawn(3000) del(V)
			sleep(600)



obj/plant
	anchored = 1
	var/stage = 1
	var/health = 10

obj/plant/vine
	name = "space vine"
	icon = 'hydroponics.dmi'
	icon_state = "spacevine1"
	anchored = 1
	health = 20
	var/datum/vinetracker/tracker

	New()
		..()
		for(var/datum/vinetracker/V in world)
			if(V)
				tracker = V
				V.vines.Add(src)
				return
		var/datum/vinetracker/V = new /datum/vinetracker
		tracker = V
		V.vines.Add(src)
		spawn () V.vineprocess()

	attackby(var/obj/item/weapon/W, var/mob/user)
		if(health <= 0)
			del(src)
			return
		src.visible_message("\red <B>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]")
		var/damage = W.force * 2

		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W

			if(WT.welding)
				damage = 15
				playsound(src.loc, 'Welder.ogg', 100, 1)

		src.health -= damage

/obj/plant/vine/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 350)
		health -= 15
		if(health <= 0)
			del(src)