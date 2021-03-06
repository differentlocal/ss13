// Bottles transfer 50 units
// Beakers transfer 30 units
// Syringes transfer 15 units
// Droppers transfer 5 units

//BUG!!!: reactions on splashing etc cause errors because stuff gets deleted before it executes.
//		  Bandaid fix using spawn - very ugly, need to fix this.

///////////////////////////////Grenades
/obj/item/weapon/chem_grenade
	name = "metal casing"
	icon_state = "chemg1"
	icon = 'chemical.dmi'
	item_state = "flashbang"
	w_class = 2.0
	force = 2.0
	var/stage = 0
	var/state = 0
	var/list/beakers = new/list()
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY

	New()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/assembly/time_ignite) && !stage)
			user << "\blue You add [W] to the metal casing."
			playsound(src.loc, 'Screwdriver2.ogg', 25, -3)
			del(W) //Okay so we're not really adding anything here. cheating.
			icon_state = "chemg2"
			name = "unsecured grenade"
			stage = 1
		else if(istype(W,/obj/item/weapon/screwdriver) && stage == 1)
			if(beakers.len)
				user << "\blue You lock the assembly."
				playsound(src.loc, 'Screwdriver.ogg', 25, -3)
				name = "grenade"
				icon_state = "chemg3"
				stage = 2
			else
				user << "\red You need to add at least one beaker before locking the assembly."
		else if (istype(W,/obj/item/weapon/reagent_containers/glass) && stage == 1)
			if(beakers.len == 2)
				user << "\red The grenade can not hold more containers."
				return
			else
				if(W.reagents.total_volume)
					user << "\blue You add \the [W] to the assembly."
					user.drop_item()
					W.loc = src
					beakers += W
				else
					user << "\red \the [W] is empty."

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (istype(target, /obj/item/weapon/storage)) return ..()
		if (!src.state && stage == 2)
			user << "\red You prime the grenade! 3 seconds!"
			src.state = 1
			src.icon_state = "chemg4"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn(30)
				explode()
			user.drop_item()
			var/t = (isturf(target) ? target : target.loc)
			walk_towards(src, t, 3)

	attack_self(mob/user as mob)
		if (!src.state && stage == 2)
			user << "\red You prime the grenade! 3 seconds!"
			src.state = 1
			src.icon_state = "chemg4"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn(30)
				explode()

	attack_hand()
		walk(src,0)
		return ..()
	attack_paw()
		return attack_hand()

	proc
		explode()
			var/has_reagents = 0
			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				if(G.reagents.total_volume) has_reagents = 1

			if(!has_reagents)
				playsound(src.loc, 'Screwdriver2.ogg', 50, 1)
				state = 0
				return

			playsound(src.loc, 'bamf.ogg', 50, 1)

			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				G.reagents.trans_to(src, G.reagents.total_volume)

			if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
				var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread()
				steam.set_up(10, 0, get_turf(src))
				steam.attach(src)
				steam.start()

				for(var/atom/A in view(3, src.loc))
					if( A == src ) continue
					src.reagents.reaction(A, 1, 10)


			invisibility = 100 //Why am i doing this?
			spawn(50)		   //To make sure all reagents can work
				del(src)	   //correctly before deleting the grenade.


/obj/item/weapon/chem_grenade/metalfoam
	name = "metal foam grenade"
	desc = "Used for emergency sealing of air breaches."
	icon_state = "chemg3"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("aluminium", 30)
		B2.reagents.add_reagent("foaming_agent", 10)
		B2.reagents.add_reagent("pacid", 10)

		beakers += B1
		beakers += B2

/obj/item/weapon/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	icon_state = "chemg3"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("fluorosurfactant", 30)
		B2.reagents.add_reagent("water", 10)
		B2.reagents.add_reagent("cleaner", 10)

		beakers += B1
		beakers += B2
/*
/obj/item/weapon/chem_grenade/poo
	name = "poo grenade"
	desc = "A ShiTastic! brand biological warfare charge. Not very effective unless the target is squeamish."
	icon_state = "chemg3"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("poo", 30)
		B2.reagents.add_reagent("poo", 30)

		beakers += B1
		beakers += B2
*/
///////////////////////////////Grenades

/obj/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'chemical.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.my_atom = src

/obj/item/weapon/gun/syringe
	name = "syringe gun"
	icon = 'gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	m_amt = 2000

	examine()
		set src in view(2)
		..()
		usr << "\icon [src] Syringe gun:"
		usr << "\blue [syringes] / [max_syringes] Syringes."

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I, /obj/item/weapon/reagent_containers/syringe))
			if(syringes.len < max_syringes)
				user.drop_item()
				I.loc = src
				syringes += I
				user << "\blue You put the syringe in the syringe gun."
				user << "\blue [syringes.len] / [max_syringes] Syringes."
			else
				usr << "\red The syringe gun cannot hold more syringes."

	afterattack(obj/target, mob/user , flag)
		if(!isturf(target.loc) || target == user) return

		if(syringes.len)
			spawn(0) fire_syringe(target,user)
		else
			usr << "\red The syringe gun is empty."

	proc
		fire_syringe(atom/target, mob/user)
			if (locate (/obj/table, src.loc))
				return
			else
				var/turf/trg = get_turf(target)
				var/obj/syringe_gun_dummy/D = new/obj/syringe_gun_dummy(get_turf(src))
				var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
				S.reagents.trans_to(D, S.reagents.total_volume)
				syringes -= S
				del(S)
				D.icon_state = "syringeproj"
				D.name = "syringe"
				playsound(user.loc, 'syringeproj.ogg', 50, 1)

				for(var/i=0, i<6, i++)
					if(D.loc == trg) break
					step_towards(D,trg)

					for(var/mob/living/carbon/M in D.loc)
						if(!istype(M,/mob/living/carbon)) continue
						if(M == user) continue
						D.reagents.reaction(M, INGEST)
						D.reagents.trans_to(M, 15)
						M.bruteloss += 5
						for(var/mob/O in viewers(world.view, D))
							O.show_message(text("\red [] was hit by the syringe!", M), 1)

						del(D)
						return
					if(D)
						for(var/atom/A in D.loc)
							if(A == user) continue
							if(A.density) del(D)

						sleep(1)
					if(D)
						spawn(10) del(D)

					return



/obj/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	flags = FPRINT
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/amount_per_transfer_from_this = 10

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return

	New()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src

	examine()
		set src in view(2)
		..()
		usr << "\blue It contains:"
		if(!reagents) return
		if(reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				usr << "\blue [R.volume] units of [R.name]"
		else
			usr << "\blue Nothing."

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					new /obj/effects/water(src.loc)
					del(src)
					return
			if(3.0)
				if (prob(5))
					new /obj/effects/water(src.loc)
					del(src)
					return
			else
		return

	blob_act()
		if(prob(50))
			new /obj/effects/water(src.loc)
			del(src)



/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'chemical.dmi'
	icon_state = null
	w_class = 1
	var/amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		return
	attackby(obj/item/I as obj, mob/user as mob)
		return
	afterattack(obj/target, mob/user , flag)
		return

////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/glass/
	name = " "
	desc = " "
	icon = 'chemical.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	var/list/can_be_placed_into = list(
	/obj/machinery/chem_master/,
	/obj/table,
	/obj/secure_closet,
	/obj/closet,
	/obj/item/weapon/storage,
	/obj/machinery/atmospherics/unary/cryo_cell,
	/obj/item/weapon/chem_grenade,
	/obj/machinery/bot/medbot,
	/obj/machinery/computer/pandemic,
	/obj/item/weapon/secstorage/ssafe)

	examine()
		set src in view(2)
		..()
		usr << "\blue It contains:"
		if(!reagents) return
		if(reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				usr << "\blue [R.volume] units of [R.name]"
		else
			usr << "\blue Nothing."

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

	afterattack(obj/target, mob/user , flag)
		for(var/type in src.can_be_placed_into)
			if(istype(target, type))
				return

		if(ismob(target) && target.reagents && reagents.total_volume)
			user << "\blue You splash the solution onto [target]."

			var/mob/M = target
			M.attack_log += text("[] <b>[]/[]</b> ����� <b>[]/[]</b> � ������� <b>[]</b>", world.time, user, user.client, M, M.client, reagents.get_reagents())
			user.attack_log += text("[] <b>[]/[]</b> ����� <b>[]/[]</b> � ������� <b>[]</b>", world.time, user, user.client, M, M.client, reagents.get_reagents())

			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red [] has been splashed with something by []!", target, user), 1)
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return
		else if(istype(target, /obj/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume && target.reagents)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, 10)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			var/trans = src.reagents.trans_to(target, 10)
			user << "\blue You transfer [trans] units of the solution to [target]."

		else if(reagents.total_volume)
			user << "\blue You splash the solution onto [target]."
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return

////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/dropper
	name = "Dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	var/filled = 0

	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		if(filled)

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food)) //You can inject humans and food but you cant remove the shit.
				user << "\red You cannot directly fill this object."
				return

			if(ismob(target))
				var/mob/M = target
				M.attack_log += text("[] <b>[]/[]</b> ������ �� <b>[]/[]</b> �� <b>[]</b>", world.time, user, user.client, M, M.client, reagents.get_reagents())
				user.attack_log += text("[] <b>[]/[]</b> ������ �� <b>[]/[]</b> �� <b>[]</b>", world.time, user, user.client, M, M.client, reagents.get_reagents())

				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red <B>[] drips something onto []!</B>", user, target), 1)
				src.reagents.reaction(target, TOUCH)

			spawn(5) src.reagents.trans_to(target, 5)
			user << "\blue You transfer 5 units of the solution."
			filled = 0
			icon_state = "dropper[filled]"

		else

			if(!target.is_open_container() && !istype(target,/obj/reagent_dispensers))
				user << "\red You cannot directly remove reagents from [target]."
				return

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			target.reagents.trans_to(src, 5)

			user << "\blue You fill the dropper with 5 units of the solution."

			filled = 1
			icon_state = "dropper[filled]"

		return
////////////////////////////////////////////////////////////////////////////////
/// Droppers. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/syringe
	name = "Syringe"
	desc = "A syringe."
	icon = 'syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	var/mode = "d"

	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src

	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_self(mob/user as mob)
		switch(mode)
			if("d")
				mode = "i"
			if("i")
				mode = "d"
		update_icon()

	attack_hand()
		..()
		update_icon()

	attack_paw()
		return attack_hand()

	attackby(obj/item/I as obj, mob/user as mob)
		return

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		switch(mode)
			if("d")

				if(reagents.total_volume >= reagents.maximum_volume)
					user << "\red The syringe is full."
					return

				if(ismob(target))//Blood!
					var/mob/M = target
					M.attack_log += text("[] <b>[]/[]</b> ���� ����� <b>[]/[]</b>", world.time, user, user.client, M, M.client)
					user.attack_log += text("[] <b>[]/[]</b> ���� ����� <b>[]/[]</b>", world.time, user, user.client, M, M.client)

					if(src.reagents.has_reagent("blood"))
						user << "\red There is already a blood sample in this syringe"
						return
					if(istype(target, /mob/living/carbon))//maybe just add a blood reagent to all mobs. Then you can suck them dry...With hundreds of syringes. Jolly good idea.
						var/amount = src.reagents.maximum_volume - src.reagents.total_volume
						var/mob/living/carbon/T = target
						var/datum/reagent/B = new /datum/reagent/blood
						B.holder = src
						B.volume = amount
						//set reagent data
						B.data["donor"] = T
						if(T.virus && T.virus.spread_type != SPECIAL)
							B.data["virus"] = new T.virus.type(0)
						B.data["blood_DNA"] = copytext(T.dna.unique_enzymes,1,0)
						if(T.resistances&&T.resistances.len)
							B.data["resistances"] = T.resistances.Copy()
						if(istype(target, /mob/living/carbon/human))//I wish there was some hasproperty operation...
							var/mob/living/carbon/human/HT = target
							B.data["blood_type"] = copytext(HT.b_type,1,0)
						//debug
						//for(var/D in B.data)
						//	world << "Data [D] = [B.data[D]]"
						//debug
						src.reagents.reagent_list += B
						src.reagents.update_total()
						src.on_reagent_change()
						src.reagents.handle_reactions()
						user << "\blue You take a blood sample from [target]"
						for(var/mob/O in viewers(4, user))
							O.show_message("\red [user] takes a blood sample from [target].", 1)
					return


				if(!target.reagents.total_volume)
					user << "\red [target] is empty."
					return


				if(!target.is_open_container() && !istype(target,/obj/reagent_dispensers))
					user << "\red You cannot directly remove reagents from this object."
					return

				target.reagents.trans_to(src, 5)

				user << "\blue You fill the syringe with 5 units of the solution."

			if("i")
				if(!reagents.total_volume)
					user << "\red The Syringe is empty."
					return

				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					user << "\red [target] is full."
					return

				if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food))
					user << "\red You cannot directly fill this object."
					return

				if(ismob(target) && target != user)
					var/mob/M = target
					M.attack_log += text("[] <b>[]/[]</b> ������ � <b>[]/[]</b> ����� � <b>[]</b>", world.time, user, user.client, M, M.client, reagents.get_reagents())
					user.attack_log += text("[] <b>[]/[]</b> ������ � <b>[]/[]</b> ����� � <b>[]</b>", world.time, user, user.client, M, M.client, reagents.get_reagents())

					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red <B>[] is trying to inject []!</B>", user, target), 1)
					if(!do_mob(user, target)) return
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red [] injects [] with the syringe!", user, target), 1)
					src.reagents.reaction(target, INGEST)
				if(ismob(target) && target == user)
					src.reagents.reaction(target, INGEST)

				spawn(5)
					src.reagents.trans_to(target, 5)
					user << "\blue You inject 5 units of the solution. The syringe now contains [src.reagents.total_volume] units."
		return

	proc
		update_icon()
			var/rounded_vol = round(reagents.total_volume,5)
			if(ismob(loc))
				icon_state = "[mode][rounded_vol]"
			else
				icon_state = "[rounded_vol]"
			item_state = "syringe_[rounded_vol]"

////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food

	var/heal_amt = 0

	// -- Skie - Mushrooms & poisoned foor
	// 0 = no poison, 25 = some poison, >50 = LOTS of poison
	var/poison_amt = 0

	// -- Skie - Psilocybin
	// 0 = no trip, 25 = medium trip, 50 large trip, >75 = WTF
	var/drug_amt = 0

	// -- Skie - Hot foods
	// 0 = no heat, 25 = cayenne, 50 = habanero, >75 = jolokia
	var/heat_amt = 0

	// ����
	var/calories = 0

	proc
		heal(var/mob/M)
			var/healing = min(src.heal_amt/2, 1.0) // Should prevent taking damage from healing
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				for(var/A in H.organs)
					var/datum/organ/external/affecting = null
					if(!H.organs[A])	continue
					affecting = H.organs[A]
					if(!istype(affecting, /datum/organ/external))	continue
					if(affecting.heal_damage(healing, healing))
						H.UpdateDamageIcon()
					else
						H.UpdateDamage()
			else
				M.bruteloss = max(0, M.bruteloss - healing)
				M.fireloss = max(0, M.fireloss - healing)
			M.updatehealth()


	proc
		poison(var/mob/M)
			var/poison_temp = src.poison_amt
			src = null
			spawn(200)
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/C = M
				if(poison_temp > 0)
					C.toxloss += rand(0,poison_temp/2) // Some initial damage
					C.fireloss += rand(0,poison_temp/4) // Some initial damage
					C.UpdateDamageIcon()
					C.weakened += poison_temp/(rand(1,4))
					if(poison_temp > 20 && poison_temp < 50)
						C << "\red You feel absolutely horrible."
						C.emote(pick("blink", "blink_r", "twitch_s", "frown", "blush", "shrug", "pale", "sniff", "whimper", "flap", "drool", "moan", "twitch"))
					else if(poison_temp > 49)
						C << "<B>\red You feel like your liver is being disintegrated by an infernal poison.</B>"
						C.emote(pick("groan", "frown", "moan", "whimper", "drool", "pale"))


					C.eye_blurry += poison_temp
					C.make_dizzy(5*poison_temp)
					spawn()
					for(poison_temp, poison_temp>0, 1) // Poison does 10 damage per tick
						sleep(100) // Every 10 seconds
						C.toxloss += min(poison_temp, 10)
						poison_temp -= 10 // Until poison amount is depleted


	proc
		drug(var/mob/M)
			var/drug_temp = src.drug_amt
			src = null // Detach proc
			spawn(200) // In 20 seconds...
			if(istype(M, /mob/living/carbon/human))

				var/mob/living/carbon/human/C = M
				C.druggy += (drug_temp*(drug_temp/15)+10) // Have a trip
				if(drug_temp > 25)
					C.make_dizzy(5*drug_temp) // Dizzify
					C.stuttering = drug_temp // Speech impediments
					spawn(3000) // 5 minutes
					C << "\red You feel a craving for a trip..."

				if(drug_temp > 50)
					C.make_jittery(5*drug_temp) // Jitter
					spawn(-1)
					for(var/i=1, i == 1, 1)
						C.see_invisible = 15
						sleep(300)
						C.emote(pick("blink", "blink_r", "twitch_s", "frown", "blush", "shrug", "pale", "sniff", "whimper", "flap", "drool", "moan", "twitch"))
						if(prob(15))
							C.see_invisible = 0
							i = 0
							C.client.view = world.view // Return view range back to normal
				if(drug_temp > 75)
					C.confused += drug_temp // Hard to move where you want
					C.weakened += rand(0, drug_temp/4) // Fall on your back
					// Add cool stuff here later, like everything starting to look different etc.

					C.client.view = min(C.client.view + rand(0,4), 14) // FUCK YE

	proc
		burn(var/mob/M)
			var/temp_heat = src.heat_amt
			var/temp_name = src.name
			src = null
			spawn(50)
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/C = M

				// BRING ON THE HEAT/FROST
				spawn()
				while(temp_heat > 5) // Until chili pepper's potency is depleted
					sleep(20) // Every 2 seconds
					C.fireloss += 3 // Do some burn damage because body temperature itself doesn't do anything :(
					if (temp_heat > 0 && temp_name == "Chili")
						C.bodytemperature += min(temp_heat*5, 25)
						temp_heat -= 5 // Until heat amount is depleted
					else if (temp_heat > 0 && temp_name == "Icepepper") // Herp derp, bad way to do it but herp derp
						C.bodytemperature -= min(temp_heat*5, 25)
						temp_heat -= 5 // Until heat amount is depleted
	proc
		eat(var/mob/M)
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/C = M
				C.eat(src)
				//TODO: ������� ��������� �����������
				/*C.fullness += src.calories
				// ���� ��������� - ��������� � ������
				if (C.fullness > 120)
					C.fullness = 70
					C.weakened += rand(1, 5)
					C.fireloss += rand(5, 15)
					C.updatehealth()*/



/obj/item/weapon/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'food.dmi'
	icon_state = null
	var/amount = 3
	heal_amt = 1

	New()
		var/datum/reagents/R = new/datum/reagents(10)
		reagents = R
		R.my_atom = src

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(!src.amount)
			user << "\red None of [src] left, oh no!"
			del(src)
			return 0
		if(istype(M, /mob/living/carbon/human))
			if(M == user)
				M << "\blue You take a bite of [src]."
				if(reagents)
					if(reagents.total_volume)
						reagents.reaction(M, INGEST)
						spawn(5)
							reagents.trans_to(M, reagents.total_volume)
				src.amount--
				playsound(M.loc,'eatfood.ogg', rand(10,50), 1)
				M.nutrition += src.heal_amt * 10
				if(src.heal_amt > 0)
					src.heal(M)
				if(src.poison_amt > 0)
					src.poison(M)
				if(src.drug_amt > 0)
					src.drug(M)
				if(src.heat_amt > 0)
					src.burn(M)
				if(src.calories > 0)
					src.eat(M)
				if(!src.amount)
					user << "\red You finish eating [src]."
					del(src)
				return 1
			else
				M.attack_log += text("[] <b>[]/[]</b> �������� ��������� <b>[]/[]</b> � ������� <b>[]</b>", world.time, user, user.client, M, M.client, src)
				user.attack_log += text("[] <b>[]/[]</b> �������� ��������� <b>[]/[]</b> � ������� <b>[]</b>", world.time, user, user.client, M, M.client, src)

				for(var/mob/O in viewers(world.view, user))
					O.show_message("\red [user] attempts to feed [M] [src].", 1)
				if(!do_mob(user, M)) return

				M.attack_log += text("[] <b>[]/[]</b> �������� <b>[]/[]</b> � ������� <b>[]</b>", world.time, user, user.client, M, M.client, src)
				user.attack_log += text("[] <b>[]/[]</b> �������� <b>[]/[]</b> � ������� <b>[]</b>", world.time, user, user.client, M, M.client, src)

				for(var/mob/O in viewers(world.view, user))
					O.show_message("\red [user] feeds [M] [src].", 1)
				if(reagents)
					if(reagents.total_volume)
						reagents.reaction(M, INGEST)
						spawn(5)
							reagents.trans_to(M, reagents.total_volume)
				src.amount--
				playsound(M.loc, 'eatfood.ogg', rand(10,50), 1)
				M.nutrition += src.heal_amt * 10
				if(src.heal_amt > 0)
					src.heal(M)
				if(src.poison_amt > 0)
					src.poison(M)
				if(src.drug_amt > 0)
					src.drug(M)
				if(src.heat_amt > 0)
					src.burn(M)
				if(src.calories > 0)
					src.eat(M)
				if(!src.amount)
					user << "\red [M] finishes eating [src]."
					del(src)
				return 1


		return 0

	attackby(obj/item/I as obj, mob/user as mob)
		return
	afterattack(obj/target, mob/user , flag)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/
	icon = 'harvest.dmi'

////////////////////////////////////////////////////////////////////////////////
/// FOOD END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'drinks.dmi'
	icon_state = null
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		update_gulp_size()

	proc
		update_gulp_size()
			gulp_size = round(reagents.total_volume / 5)
			if (gulp_size < 5) gulp_size = 5

	on_reagent_change()
		update_gulp_size()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		var/datum/reagents/R = src.reagents

		if(!R.total_volume || !R)
			user << "\red None of [src] left, oh no!"
			return 0

		if(M == user)
			M << "\blue You swallow a gulp of [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			playsound(M.loc,'drink.ogg', rand(10,50), 1)
			return 1
		else if( istype(M, /mob/living/carbon/human) )

			M.attack_log += text("[] <b>[]/[]</b> �������� ������� <b>[]/[]</b> � ������� <b>[]</b>", world.time, user, user.client, M, M.client, src)
			user.attack_log += text("[] <b>[]/[]</b> �������� ������� <b>[]/[]</b> � ������� <b>[]</b>", world.time, user, user.client, M, M.client, src)

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to feed [M] [src].", 1)
			if(!do_mob(user, M)) return

			M.attack_log += text("[] <b>[]/[]</b> ������ <b>[]/[]</b> � ������� <b>[]</b>", world.time, user, user.client, M, M.client, src)
			user.attack_log += text("[] <b>[]/[]</b> ������ <b>[]/[]</b> � ������� <b>[]</b>", world.time, user, user.client, M, M.client, src)

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] feeds [M] [src].", 1)

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			playsound(M.loc,'drink.ogg', rand(10,50), 1)
			return 1

		return 0

	attackby(obj/item/I as obj, mob/user as mob)
		return

	afterattack(obj/target, mob/user , flag)

		if(istype(target, /obj/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, 10)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			var/trans = src.reagents.trans_to(target, 10)
			user << "\blue You transfer [trans] units of the solution to [target]."

		return
////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/pill
	name = "pill"
	desc = "a pill."
	icon = 'chemical.dmi'
	icon_state = null
	item_state = "pill"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		icon_state = "pill[rand(1,20)]"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(M == user)
			M << "\blue You swallow [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, reagents.total_volume)
					del(src)
			else
				del(src)
			return 1

		else if(istype(M, /mob/living/carbon/human) )

			M.attack_log += text("[] <b>[]/[]</b> �������� ��������� <b>[]/[]</b> � ������� <b>[] ([])</b>", world.time, user, user.client, M, M.client, src, reagents.get_reagents())
			user.attack_log += text("[] <b>[]/[]</b> �������� ��������� <b>[]/[]</b> � ������� <b>[] ([])</b>", world.time, user, user.client, M, M.client, src, reagents.get_reagents())

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to force [M] to swallow [src].", 1)

			if(!do_mob(user, M)) return

			M.attack_log += text("[] <b>[]/[]</b> �������� <b>[]/[]</b> � ������� [] ([])", world.time, user, user.client, M, M.client, src, reagents.get_reagents())
			user.attack_log += text("[] <b>[]/[]</b> �������� <b>[]/[]</b> � ������� [] ([])", world.time, user, user.client, M, M.client, src, reagents.get_reagents())

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] forces [M] to swallow [src].", 1)

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, reagents.total_volume)
					del(src)
			else
				del(src)

			return 1

		return 0

	attackby(obj/item/I as obj, mob/user as mob)
		return

	afterattack(obj/target, mob/user , flag)

		if(target.is_open_container() == 1 && target.reagents)
			if(!target.reagents.total_volume)
				user << "\red [target] is empty. Cant dissolve pill."
				return
			user << "\blue You dissolve the pill in [target]"
			reagents.trans_to(target, reagents.total_volume)
			for(var/mob/O in viewers(2, user))
				O.show_message("\red [user] puts something in [target].", 1)
			spawn(5)
				del(src)

		return

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Subtypes.
////////////////////////////////////////////////////////////////////////////////

//Glasses
/obj/item/weapon/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	m_amt = 200
	g_amt = 0

	amount_per_transfer_from_this = 10
	flags = FPRINT | OPENCONTAINER
	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src

	attackby(var/obj/D, mob/user as mob)
		if(istype(D, /obj/item/device/prox_sensor))
			var/obj/item/weapon/bucket_sensor/B = new /obj/item/weapon/bucket_sensor
			B.loc = user
			if (user.r_hand == D)
				user.u_equip(D)
				user.r_hand = B
			else
				user.u_equip(D)
				user.l_hand = B
			B.layer = 20
			user << "You add the sensor to the bucket"
			del(D)
			del(src)

/obj/item/weapon/reagent_containers/glass/dispenser
	name = "reagent glass"
	desc = "A reagent glass."
	icon = 'chemical.dmi'
	icon_state = "beaker"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER


/obj/item/weapon/reagent_containers/glass/dispenser/surfactant
	name = "reagent glass (surfactant)"
	icon_state = "liquid"

	New()
		..()
		reagents.add_reagent("fluorosurfactant", 20)


/obj/item/weapon/reagent_containers/glass/large
	name = "large reagent glass"
	desc = "A large reagent glass."
	icon = 'chemical.dmi'
	icon_state = "beakerlarge"
	item_state = "beaker"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

/obj/item/weapon/reagent_containers/glass/bottle/
	name = "bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		icon_state = "bottle[rand(1,20)]"

/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline
	name = "inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	amount_per_transfer_from_this = 10

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("inaprovaline", 30)

/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle12"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("toxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/stoxin
	name = "sleep-toxin bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle20"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("stoxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin
	name = "anti-toxin bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle17"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("anti_toxin", 30)


/obj/item/weapon/reagent_containers/glass/bottle/flu_virion
	name = "Flu virion culture bottle"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/flu(0)
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)


/obj/item/weapon/reagent_containers/glass/bottle/cold
	name = "Rhinovirus culture bottle"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/cold(0)
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)

/*
/obj/item/weapon/reagent_containers/glass/bottle/gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/gbs
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data) -- No.
*/
/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/fake_gbs(0)
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)


/obj/item/weapon/reagent_containers/glass/bottle/brainrot
	name = "Brainrot culture bottle"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/brainrot(0)
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/magnitis
	name = "Magnitis culture bottle"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/magnitis(0)
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)


/obj/item/weapon/reagent_containers/glass/bottle/wizarditis
	name = "Wizarditis culture bottle"
	desc = "A small bottle. Contains a sample of Rincewindus Vulgaris."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/wizarditis(0)
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)



/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 30 units."
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"

	on_reagent_change()
		if(reagents.total_volume)
			icon_state = "beaker1"
		else
			icon_state = "beaker0"


/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone
	name = "beaker"
	desc = "A beaker. Can hold up to 30 units."
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("cryoxadone", 30)


//Syringes
/obj/item/weapon/reagent_containers/syringe/robot
	name = "Syringe (mixed)"
	desc = "Contains inaprovaline & anti-toxins."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("inaprovaline", 7)
		R.add_reagent("anti_toxin", 8)
		mode = "i"
		update_icon()

/obj/item/weapon/reagent_containers/syringe/inaprovaline
	name = "Syringe (inaprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("inaprovaline", 15)
		update_icon()

/obj/item/weapon/reagent_containers/syringe/antitoxin
	name = "Syringe (anti-toxin)"
	desc = "Contains anti-toxins."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("anti_toxin", 15)
		update_icon()

/obj/item/weapon/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("spaceacillin", 15)
		update_icon()


//////////////////////////////////////////////////
////////////////////////////////////////////Snacks
//////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Man, that shit looks good. I bet it's got nougat. Fuck."
	icon_state = "candy"
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	heal_amt = 1
	calories = 2

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	heal_amt = 1
	calories = 3
	New()
		..()
		if(rand(1,3) == 1)
			src.icon_state = "donut2"
			src.name = "frosted donut"
			src.heal_amt = 2
	heal(var/mob/M)
		if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective"))
			src.heal_amt *= 2
			..()
			src.heal_amt /= 2

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	amount = 1
	heal_amt = 1
	calories = 3

/obj/item/weapon/reagent_containers/food/snacks/flour
	name = "flour"
	desc = "Some flour"
	icon_state = "flour"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/humanmeat
	name = "-meat"
	desc = "A slab of meat"
	icon_state = "meat"
	var/subjectname = ""
	var/subjectjob = null
	amount = 1
	calories = 5

/* Commented out due to being completly useless. Goddamn goon humor.
/obj/item/weapon/reagent_containers/food/snacks/assburger
	name = "assburger"
	desc = "This burger gives off an air of awkwardness."
	icon_state = "assburger"
	amount = 5
	heal_amt = 2
*/

/obj/item/weapon/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	amount = 5
	heal_amt = 2
	calories = 4

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "faggot"
	desc = "A great meal all round."
	icon_state = "faggot"
	amount = 1
	heal_amt = 2
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	heal_amt = 1
	amount = 1
	var/warm = 0
	heal(var/mob/M)
		if(src.warm && M.reagents)
			M.reagents.add_reagent("tricordrazine",15)
		else
			M << "\red It's just not good enough cold.."
		..()

	proc/cooltime()
		if (src.warm)
			spawn( 4200 )
				src.warm = 0
				src.name = "donk-pocket"
		return

/obj/item/weapon/reagent_containers/food/snacks/humanburger
	name = "-burger"
	var/hname = ""
	var/job = null
	desc = "A bloody burger."
	icon_state = "hburger"
	amount = 5
	heal_amt = 2
	calories = 4
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger
	name = "monkeyburger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "mburger"
	amount = 5
	heal_amt = 2
	calories = 4

/obj/item/weapon/reagent_containers/food/snacks/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	amount = 30
	heal_amt = 6
	calories = 0.5
/*	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		R.add_reagent("cholesterol", 20)*/
	heal(var/mob/M)
		..()


/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	amount = 5
	heal_amt = 6
	calories = 0.5
/*	New()
		var/datum/reagents/R = new/datum/reagents(10)
		reagents = R
		R.my_atom = src
		R.add_reagent("cholesterol", 10)*/
	heal(var/mob/M)
		..()


/obj/item/weapon/reagent_containers/food/snacks/cheesewheel
	name = "Cheese wheel"
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	amount = 25
	heal_amt = 3
	calories = 0.5
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	name = "Cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	amount = 4
	heal_amt = 4
	calories = 0.5
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/omelette
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	amount = 15
	heal_amt = 3
	calories = 1
	heal(var/mob/M)
		..()
	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/kitchen/utensil/fork))
			W.icon = 'kitchen.dmi'
			W.icon_state = "forkloaded"
			world << "[user] takes a piece of omelette with his fork!"

/obj/item/weapon/reagent_containers/food/snacks/omeletteforkload
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	amount = 1
	heal_amt = 4
	calories = 1
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "Muffin"
	desc = "A delicious and spongy little cake"
	icon_state = "muffin"
	amount = 4
	heal_amt = 6
	calories = 1
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src
		R.add_reagent("nanites", 5)

/obj/item/weapon/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src
		R.add_reagent("xenomicrobes", 5)

/obj/item/weapon/reagent_containers/food/snacks/monkeymeat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	amount = 1
	calories = 4

/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "xenomeat"
	amount = 1
	calories = 4

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "custard pie"
	desc = "It smells delicious. You just want to plant your face in it."
	icon_state = "pie"
	amount = 3
	calories = 4

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles"
	icon_state = "waffles"
	amount = 5
	heal_amt = 2
	calories = 1

//Drinks
/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("coffee", 30)

/obj/item/weapon/reagent_containers/food/drinks/cola
	name = "space cola"
	desc = "Cola. in space."
	icon_state = "cola"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/beer
	name = "Space Beer"
	desc = "Beer. in space."
	icon_state = "beer"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("beer", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("ale", 30)

/obj/item/weapon/reagent_containers/food/drinks/milk
	name = "Space Milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	heal_amt = 2
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("milk", 50)

/obj/item/weapon/reagent_containers/food/snacks/ketchup
	name = "Ketchup"
	desc = "You feel more American already."
	icon_state = "ketchup"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/hotsauce
	name = "Hotsauce"
	desc = "You can almost TASTE the stomach ulcers now!"
	icon_state = "hotsauce"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/berryjam
	name = "Berry Jam"
	desc = "A delightfully sweat flavor of some indescernible berry... you think."
	icon_state = "berryjam"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/jellydonut
	name = "Jelly Donut"
	desc = "Oh so gooey on the inside."
	icon_state = "donut1" //Placeholder until I stop being lazy. ie. Never. -- Darem
	heal_amt = 2
	New()
		..()
		if(rand(1,3) == 1)
			src.icon_state = "donut2"
			src.name = "Frosted Jelly Donut"
			src.heal_amt = 3
	heal(var/mob/M)
		if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective"))
			src.heal_amt *= 2
			..()
			src.heal_amt /= 2

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent"
	amount = 5
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/soysauce
	name = "Soy Sauce"
	desc = "A salty soy-based flavoring."
	icon_state = "soysauce"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent"
	amount = 5
	heal_amt = 1


/obj/item/weapon/reagent_containers/food/snacks/coldsauce
	name = "Coldsauce"
	desc = "Leaves the tongue numb in it's passage."
	icon_state = "coldsauce"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/carrotcake
	name = "Carrot Cake"
	desc = "A favorite desert of a certain wascally wabbit. Also not a lie."
	icon_state = "carrotcake"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesecake
	name = "Cheese Cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/plaincake
	name = "Vanilla Cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	amount = 5
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/humeatpie
	name = "-pie"
	var/hname = ""
	var/job = null
	icon_state = "pie" //placeholder
	desc = "A delicious meatpie."
	amount = 3
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/momeatpie
	name = "Monkey-pie"
	icon_state = "pie"
	desc = "A delicious meatpie."
	amount = 3
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie
	name = "Xeno-pie"
	icon_state = "pie" //placeholder
	desc = "A delicious meatpie. Probably heretical."
	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src
		R.add_reagent("xenomicrobes", 5)

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src
		R.add_reagent("xenomicrobes", 5)

/obj/item/weapon/reagent_containers/food/snacks/chaosdonut
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut1"
	heat_amt = 25
	New()
		..()
		if(rand(1,3) == 1)
			src.icon_state = "donut2"
			src.name = "Frosted Chaos Donut"
			heat_amt = 0
			drug_amt = 25

/obj/item/weapon/reagent_containers/food/snacks/humankabob
	name = "-kabob"
	var/hname = ""
	var/job = null
	icon_state = "kabob"
	amount = 3
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeykabob
	name = "Monkey-kabob"
	icon_state = "kabob"
	amount = 3
	heal_amt = 2

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("gin", 100)

/obj/item/weapon/reagent_containers/food/drinks/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("whiskey", 100)

/obj/item/weapon/reagent_containers/food/drinks/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("vodka", 100)

/obj/item/weapon/reagent_containers/food/drinks/tequilla
	name = "Caccavo Guaranteed Quality Tequilla"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequillabottle"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("tequilla", 100)

/obj/item/weapon/reagent_containers/food/drinks/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("rum", 100)

/obj/item/weapon/reagent_containers/food/drinks/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("vermouth", 100)

/obj/item/weapon/reagent_containers/food/drinks/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("kahlua", 100)

/obj/item/weapon/reagent_containers/food/drinks/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("cognac", 100)

/obj/item/weapon/reagent_containers/food/drinks/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("wine", 100)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/weapon/reagent_containers/food/drinks/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	heal_amt = 2
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("orangejuice", 100)

/obj/item/weapon/reagent_containers/food/drinks/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	heal_amt = 2
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("cream", 100)

/obj/item/weapon/reagent_containers/food/drinks/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	heal_amt = 2
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("tomatojuice", 100)

/obj/item/weapon/reagent_containers/food/drinks/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	heal_amt = 2
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("limejuice", 100)

/obj/item/weapon/reagent_containers/food/drinks/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	heal_amt = 2
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("tonic", 50)

/obj/item/weapon/reagent_containers/food/drinks/sodawater
	name = "Soda Water"
	desc = "A can of soda water. Why not make a scotch and soda?"
	icon_state = "sodawater"
	heal_amt = 2
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("sodawater", 50)

/obj/item/weapon/reagent_containers/food/drinks/mojito
	name = "Mojito"
	desc = "A glass of Authentic Cuban Mojito made without the mint, but who cares?"
	icon_state = "mojito"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("mohito", 50)

/obj/item/weapon/reagent_containers/food/drinks/hell
	name = "Hell"
	desc = "Hell of a Cocktail"
	icon_state = "hell"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("hell", 50)

//Pills
/obj/item/weapon/reagent_containers/pill/antitox
	name = "Anti-toxins pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("anti_toxin", 50)

/obj/item/weapon/reagent_containers/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("toxin", 50)

/obj/item/weapon/reagent_containers/pill/stox
	name = "Sleeping pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("stoxin", 30)

/obj/item/weapon/reagent_containers/pill/kelotane
	name = "Kelotane pill"
	desc = "Used to treat burns."
	icon_state = "pill11"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("kelotane", 30)

/obj/item/weapon/reagent_containers/pill/inaprovaline
	name = "Inaprovaline pill"
	desc = "Used to stabilize patients."
	icon_state = "pill20"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("inaprovaline", 30)

//Dispensers
/obj/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("water",1000)

/obj/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("fuel",1000)

/obj/reagent_dispensers/fueltank/blob_act()
	explosion(src.loc,0,1,5,7,10)
	del(src)

/obj/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg"
	icon = 'objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("beer",1000)

/obj/reagent_dispensers/beerkeg/blob_act()
	explosion(src.loc,0,3,5,7,10)
	del(src)


//////////////////////////drinkingglass and shaker//

/obj/item/weapon/reagent_containers/food/drinks/shaker
	name = "Shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src


/obj/item/weapon/reagent_containers/food/drinks/drinkingglass
	name = "glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

	on_reagent_change()
/*		if(reagents.reagent_list.len > 1 )
			icon_state = "glass_brown"
			name = "Glass of Hooch"
			desc = "Two or more drinks, mixed together."
		else if(reagents.reagent_list.len == 1)
			for(var/datum/reagent/R in reagents.reagent_list)
				switch(R.id)*/
		if (reagents.reagent_list.len > 0)
			//mrid = R.get_master_reagent_id()
			switch(reagents.get_master_reagent_id())
				if("beer")
					icon_state = "beerglass"
					name = "Beer glass"
					desc = "A freezing pint of beer"
				if("ale")
					icon_state = "aleglass"
					name = "Ale glass"
					desc = "A freezing pint of delicious Ale"
				if("milk")
					icon_state = "glass_white"
					name = "Glass of milk"
					desc = "White and nutritious goodness!"
				if("cream")
					icon_state  = "glass_white"
					name = "Glass of cream"
					desc = "Ewwww..."
				if("cola")
					icon_state  = "glass_brown"
					name = "Glass of Space Cola"
					desc = "A glass of refreshing Space Cola"
				if("orangejuice")
					icon_state = "glass_orange"
					name = "Glass of Orange juice"
					desc = "Vitamins! Yay!"
				if("tomatojuice")
					icon_state = "glass_red"
					name = "Glass of Tomato juice"
					desc = "Are you sure this is tomato juice?"
				if("limejuice")
					icon_state = "glass_green"
					name = "Glass of Lime juice"
					desc = "A glass of sweet-sour lime juice."
				if("whiskey")
					icon_state = "whiskeyglass"
					name = "Glass of whiskey"
					desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
				if("gin")
					icon_state = "ginvodkaglass"
					name = "Glass of gin"
					desc = "A crystal clear glass of Griffeater gin."
				if("vodka")
					icon_state = "ginvodkaglass"
					name = "Glass of vodka"
					desc = "The glass contain wodka. Xynta."
				if("wine")
					icon_state = "wineglass"
					name = "Glass of wine"
					desc = "A very classy looking drink."
				if("cognac")
					icon_state = "cognacglass"
					name = "Glass of cognac"
					desc = "Damn, you feel like some kind of French aristocrat just by holding this."
				if ("kahlua")
					icon_state = "kahluaglass"
					name = "Glass of RR coffee Liquor"
					desc = "DAMN, THIS THING LOOKS ROBUST"
				if("vermouth")
					icon_state = "vermouthglass"
					name = "Glass of Vermouth"
					desc = "You wonder why you're even drinking this straight."
				if("tequilla")
					icon_state = "tequillaglass"
					name = "Glass of Tequilla"
					desc = "Now all that's missing is the weird colored shades!"
				if("rum")
					icon_state = "rumglass"
					name = "Glass of Rum"
					desc = "Now you want to Pray for a pirate suit, don't you?"
				if("gintonic")
					icon_state = "gintonicglass"
					name = "Gin and Tonic"
					desc = "A mild but still great cocktail. Drink up, like a true Englishman."
				if("whiskeycola")
					icon_state = "whiskeycolaglass"
					name = "Whiskey Cola"
					desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
				if("whiterussian")
					icon_state = "whiterussianglass"
					name = "White Russian"
					desc = "A very nice looking drink. But that's just, like, your opinion, man."
				if("screwdrivercocktail")
					icon_state = "screwdriverglass"
					name = "Screwdriver"
					desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
				if("bloodymary")
					icon_state = "bloodymaryglass"
					name = "Bloody Mary"
					desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."
				if("martini")
					icon_state = "martiniglass"
					name = "Classic Martini"
					desc = "Damn, the barman even stirred it, not shook it."
				if("vodkamartini")
					icon_state = "martiniglass"
					name = "Vodka martini"
					desc ="A bastardisation of the classic martini. Still great."
				if("gargleblaster")
					icon_state = "gargleblasterglass"
					name = "Pan-Galactic Gargle Blaster"
					desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
				if("bravebull")
					icon_state = "bravebullglass"
					name = "Brave Bull"
					desc = "Tequilla and Coffee liquor, brought together in a mouthwatering mixture. Drink up."
				if("tequillasunrise")
					icon_state = "tequillasunriseglass"
					name = "Tequilla Sunrise"
					desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
				if("toxinsspecial")
					icon_state = "toxinsspecialglass"
					name = "Toxins Special"
					desc = "Whoah, this thing is on FIRE"
				if("beepskysmash")
					icon_state = "beepskysmashglass"
					name = "Beepsky Smash"
					desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
				if("doctorsdelight")
					icon_state = "doctorsdelightglass"
					name = "Doctor's Delight"
					desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
				if("manlydorf")
					icon_state = "manlydorfglass"
					name = "The Manly Dorf"
					desc = "A manly concotion made from Ale and Beer. Intended for true men only."
				if("irishcream")
					icon_state = "irishcreamglass"
					name = "Irish Cream"
					desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
				if("cubalibre")
					icon_state = "cubalibreglass"
					name = "Cuba Libre"
					desc = "A classic mix of rum and cola."
				if("irishcream")
					icon_state = "irishcreamglass"
					name = "Irish Cream"
					desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
				if("cubalibre")
					icon_state = "cubalibreglass"
					name = "Cuba Libre"
					desc = "A classic mix of rum and cola."
				if("b52")
					icon_state = "b52glass"
					name = "B-52"
					desc = "Kahlua, Irish Cream, and congac. You will get bombed."
				if("mojito")
					icon_state = "mojito"
					name = "Mojito"
					desc = "Authentic Cuban Mojito made without the mint. But who cares?"
				if("longislandicedtea")
					icon_state = "longislandicedteaglass"
					name = "Long Island Iced Tea"
					desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
				if("margarita")
					icon_state = "margaritaglass"
					name = "Margarita"
					desc = "On the rocks with salt on the rim. Arriba~!"
				if("blackrussian")
					icon_state = "blackrussianglass"
					name = "Black Russian"
					desc = "For the lactose-intolerant. Still as classy as a White Russian."
				if("vodkatonic")
					icon_state = "vodkatonicglass"
					name = "Vodka and Tonic"
					desc = "For when a gin and tonic isn't russian enough."
				if("manhattan")
					icon_state = "manhattanglass"
					name = "Manhattan"
					desc = "The Detective's undercover drink of choice. He never could stomach gin..."
				if("ginfizz")
					icon_state = "ginfizzglass"
					name = "Gin Fizz"
					desc = "Refreshingly lemony, deliciously dry."
				if("irishcoffee")
					icon_state = "irishcoffeeglass"
					name = "Irish Coffee"
					desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
				if("hooch")
					icon_state = "glass_brown2"
					name = "Hooch"
					desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
				if("whiskeysoda")
					icon_state = "whiskeysodaglass2"
					name = "Whiskey Soda"
					desc = "Ultimate refreshment."
				if("tonic")
					icon_state = "glass_clear"
					name = "Glass of Tonic Water"
					desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
				if("sodawater")
					icon_state = "glass_clear"
					name = "Glass of Soda Water"
					desc = "Soda water. Why not make a scotch and soda?"
				if("water")
					icon_state = "glass_clear"
					name = "Glass of Water"
					desc = "Are you really that boring?"
				if("hell")
					icon_state = "hell"
					name = "Glass of Hell Cocktail"
					desc = "Do not drink me?"
				else
					icon_state ="glass_brown"
					name = "Glass of ..what?"
					desc = "You can't really tell what this is."
		else
			icon_state = "glass_empty"
			name = "Drinking glass"
			desc = "Your standard drinking glass"
			return

///jar

/obj/item/weapon/reagent_containers/food/drinks/jar
	name = "empty jar"
	desc = "A jar. You're not sure what it's supposed to hold."
	icon_state = "jar"
	item_state = "beaker"
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("metroid", 50)

	on_reagent_change()
		if (reagents.reagent_list.len > 0)
			switch(reagents.get_master_reagent_id())
				if("metroid")
					icon_state = "jar_metroid"
					name = "metroid jam"
					desc = "A jar of metroid jam. Delicious!"
				else
					icon_state ="jar_what"
					name = "jar of something"
					desc = "You can't really tell what this is."
		else
			icon_state = "jar"
			name = "empty jar"
			desc = "A jar. You're not sure what it's supposed to hold."
			return