obj/door_assembly
	icon = 'door_assembly.dmi'

	name = "Airlock Assembly"
	icon_state = "door_as0"
	anchored = 0
	density = 1
	var/doortype = 0
	var/state = 0
	var/glass = 0
	var/obj/item/weapon/airlock_electronics/electronics = null

	door_assembly_0
		name = "Airlock Assembly"
		icon_state = "door_as1"
		anchored = 1
		density = 1
		doortype = 0
		state = 1
		glass = 0

	door_assembly_com
		name = "Command Airlock Assembly"
		icon_state = "door_as1_com"
		anchored = 1
		density = 1
		doortype = 1
		state = 1
		glass = 0

	door_assembly_sec
		name = "Security Airlock Assembly"
		icon_state = "door_as1_sec"
		anchored = 1
		density = 1
		doortype = 2
		state = 1
		glass = 0

	door_assembly_eng
		name = "Engineering Airlock Assembly"
		icon_state = "door_as1_eng"
		anchored = 1
		density = 1
		doortype = 3
		state = 1
		glass = 0

	door_assembly_med
		name = "Medical Airlock Assembly"
		icon_state = "door_as1_med"
		anchored = 1
		density = 1
		doortype = 4
		state = 1
		glass = 0

	door_assembly_mai
		name = "Maintenance Airlock Assembly"
		icon_state = "door_as1_mai"
		anchored = 1
		density = 1
		doortype = 5
		state = 1
		glass = 0

	door_assembly_ext
		name = "External Airlock Assembly"
		icon_state = "door_as1_ext"
		anchored = 1
		density = 1
		doortype = 6
		state = 1
		glass = 0

	door_assembly_g
		name = "Glass Airlock Assembly"
		icon_state = "door_as1_g"
		anchored = 1
		density = 1
		doortype = 7
		state = 1
		glass = 1

/obj/door_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool) && W:welding && !anchored )
		if (W:get_fuel() < 1)
			user << "\blue Нужно больше горючки!"
			return
		W:use_fuel(1)
		user.visible_message("[user] разобирает дверную сборку.", "Ты начал разбирать дверную сборку.")
		playsound(src.loc, 'Welder2.ogg', 50, 1)
		var/turf/T = get_turf(user)
		sleep(100)
		if(get_turf(user) == T)
			user << "\blue Ты разобрал дверную сборку!"
			new /obj/item/weapon/sheet/metal(get_turf(src))
			new /obj/item/weapon/sheet/metal(get_turf(src))
			new /obj/item/weapon/sheet/metal(get_turf(src))
			new /obj/item/weapon/sheet/metal(get_turf(src))
			if(src.glass==1)
				new /obj/item/weapon/sheet/rglass(get_turf(src))
			del(src)
	else if(istype(W, /obj/item/weapon/wrench) && !anchored )
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] прикручивает дверную сборку к полу.", "Ты начал прикручивать дверную сборку к полу.")
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue Ты прикрутил дверную сборку!"
			src.name = "Secured Airlock Assembly"
			src.anchored = 1
	else if(istype(W, /obj/item/weapon/wrench) && anchored )
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] откручивает дверную сборку от двери.", "Ты начал откручивать дверную сборку от пола.")
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue Ты открутил дверную сборку!"
			src.name = "Airlock Assembly"
			src.anchored = 0
	else if(istype(W, /obj/item/weapon/cable_coil) && state == 0 && anchored )
		var/obj/item/weapon/cable_coil/coil = W
		var/turf/T = get_turf(user)
		user.visible_message("[user] подключает двери.", "Ты начал подключать двери.")
		sleep(40)
		if(get_turf(user) == T)
			coil.use(1)
			src.state = 1
			switch(src.doortype)
				if(0) src.icon_state = "door_as1"
				if(1) src.icon_state = "door_as1_com"
				if(2) src.icon_state = "door_as1_sec"
				if(3) src.icon_state = "door_as1_eng"
				if(4) src.icon_state = "door_as1_med"
				if(5) src.icon_state = "door_as1_mai"
				if(6) src.icon_state = "door_as1_ext"
				if(7) src.icon_state = "door_as1_g"
			user << "\blue Ты подключил двери!"
			src.name = "Wired Airlock Assembly"
	else if(istype(W, /obj/item/weapon/wirecutters) && state == 1 )
		playsound(src.loc, 'Wirecutter.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] вырезает провода из двери.", "Ты начал вырезать провода из двери.")
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue You cut the airlock wires.!"
			new/obj/item/weapon/cable_coil(T, 1)
			src.state = 0
			switch(doortype)
				if(0) src.icon_state = "door_as0"
				if(1) src.icon_state = "door_as0_com"
				if(2) src.icon_state = "door_as0_sec"
				if(3) src.icon_state = "door_as0_eng"
				if(4) src.icon_state = "door_as0_med"
				if(5) src.icon_state = "door_as0_mai"
				if(6) src.icon_state = "door_as0_ext"
				if(7) src.icon_state = "door_as0_g"
			src.name = "Secured Airlock Assembly"
	else if(istype(W, /obj/item/weapon/airlock_electronics) && state == 1 )
		playsound(src.loc, 'Screwdriver.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] подключает электронику к двери.", "Ты начал подключать электронику к дверви.")

		user.drop_item()
		W.loc = src

		sleep(40)
		if(get_turf(user) == T)
			user << "\blue Ты подключил электронику!"
			src.state = 2
			switch(src.doortype)
				if(0) src.icon_state = "door_as2"
				if(1) src.icon_state = "door_as2_com"
				if(2) src.icon_state = "door_as2_sec"
				if(3) src.icon_state = "door_as2_eng"
				if(4) src.icon_state = "door_as2_med"
				if(5) src.icon_state = "door_as2_mai"
				if(6) src.icon_state = "door_as2_ext"
				if(7) src.icon_state = "door_as2_g"
			src.name = "Near finished Airlock Assembly"
			src.electronics = W
		else
			W.loc = src.loc

			//del(W)
	else if(istype(W, /obj/item/weapon/crowbar) && state == 2 )
		playsound(src.loc, 'Crowbar.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] выламывает электронику из двери.", "Ты начал выламывать электронику из двери.")
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue Ты выломал электронику!"
			src.state = 1
			switch(src.doortype)
				if(0) src.icon_state = "door_as1"
				if(1) src.icon_state = "door_as1_com"
				if(2) src.icon_state = "door_as1_sec"
				if(3) src.icon_state = "door_as1_eng"
				if(4) src.icon_state = "door_as1_med"
				if(5) src.icon_state = "door_as1_mai"
				if(6) src.icon_state = "door_as1_ext"
				if(7) src.icon_state = "door_as1_g"
			src.name = "Wired Airlock Assembly"
			var/obj/item/weapon/airlock_electronics/ae
			if (!electronics)
				ae = new/obj/item/weapon/airlock_electronics( src.loc )
			else
				ae = electronics
				electronics = null
				ae.loc = src.loc
	else if(istype(W, /obj/item/weapon/sheet/rglass) && glass == 0)
		playsound(src.loc, 'Crowbar.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] вставлЯет стекло в дверь.", "Ты начал вставлЯть стекло в дверь.")
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue Ты вставил стекло в дверь!"
			src.glass = 1
			src.doortype = 7
			src.name = "Near finished Window Airlock Assembly"
			switch(src.state)
				if(0) src.icon_state = "door_as0_g"
				if(1) src.icon_state = "door_as1_g"
				if(2) src.icon_state = "door_as2_g"
				if(3) src.icon_state = "door_as3_g"
	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 )
		playsound(src.loc, 'Screwdriver.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user << "\blue Ты заканчиваешь собирать дверь."
		sleep(40)
		if(get_turf(user) == T)
			user << "\blue Ты собрал дверь!"
			var/obj/machinery/door/airlock/door
			if (!src.glass)
				switch(src.doortype)
					if(0) door = new/obj/machinery/door/airlock( src.loc )
					if(1) door = new/obj/machinery/door/airlock/command( src.loc )
					if(2) door = new/obj/machinery/door/airlock/security( src.loc )
					if(3) door = new/obj/machinery/door/airlock/engineering( src.loc )
					if(4) door = new/obj/machinery/door/airlock/medical( src.loc )
					if(5) door = new/obj/machinery/door/airlock/maintenance( src.loc )
					if(6) door = new/obj/machinery/door/airlock/external( src.loc )
			else
				door = new/obj/machinery/door/airlock/glass( src.loc )
			//door.req_access = src.req_access
			door.electronics = src.electronics
			door.req_access = src.electronics.conf_access
			src.electronics.loc = door
			del(src)
	else
		..()