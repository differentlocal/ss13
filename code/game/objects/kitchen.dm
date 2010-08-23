/obj/kitchenspike/attack_paw(mob/user as mob)
	return src.attack_hand(usr)

/obj/kitchenspike/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(!istype(G, /obj/item/weapon/grab))
		return
	if(istype(G.affecting, /mob/living/carbon/monkey))
		if(src.occupied == 0)
			src.icon_state = "spikebloody"
			src.occupied = 1
			src.meat = 5
			src.meattype = 1
			var/mob/dead/observer/newmob
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [user] has forced [G.affecting] onto the spike, killing them instantly!"))
			if (G.affecting.client)
				newmob = new/mob/dead/observer(G.affecting)
				G.affecting:client:mob = newmob
				newmob:client:eye = newmob
			del(G.affecting)
			del(G)

		else
			user << "\red The spike already has something on it, finish collecting its meat first!"
	else if(istype(G.affecting, /mob/living/carbon/alien))
		if(src.occupied == 0)
			src.icon_state = "spikebloodygreen"
			src.occupied = 1
			src.meat = 5
			src.meattype = 2
			var/mob/dead/observer/newmob
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [user] has forced [G.affecting] onto the spike, killing them instantly!"))
			if (G.affecting.client)
				newmob = new/mob/dead/observer(G.affecting)
				G.affecting:client:mob = newmob
				newmob:client:eye = newmob
			del(G.affecting)
			del(G)
		else
			user << "\red The spike already has something on it, finish collecting its meat first!"
	else
		user << "\red They are too big for the spike, try something smaller!"
		return


/obj/kitchenspike/attack_hand(mob/user as mob)
	if(..())
		return
	if(src.occupied)
		if(src.meattype == 1)
			if(src.meat > 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/monkeymeat( src.loc )
				usr << "You remove some meat from the monkey."
			else if(src.meat == 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/monkeymeat(src.loc)
				usr << "You remove the last piece of meat from the monkey!"
				src.icon_state = "spike"
				src.occupied = 0
		else if(src.meattype == 2)
			if(src.meat > 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/xenomeat( src.loc )
				usr << "You remove some meat from the alien."
			else if(src.meat == 1)
				src.meat--
				new /obj/item/weapon/reagent_containers/food/snacks/xenomeat(src.loc)
				usr << "You remove the last piece of meat from the alien!"
				src.icon_state = "spike"
				src.occupied = 0