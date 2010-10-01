/obj/machinery/computer/robotics
	name = "Robotics Control"
	icon = 'computer.dmi'
	icon_state = "id"
	req_access = list(access_captain, access_robotics)

	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - Main Menu, 1 - Cyborg Status, 2 - Kill 'em All! -- In text

/obj/machinery/computer/robotics/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/robotics/M = new /obj/item/weapon/circuitboard/robotics( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/robotics/M = new /obj/item/weapon/circuitboard/robotics( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)

	//else
	src.attack_hand(user)
	return

/obj/machinery/computer/robotics/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/robotics/attack_paw(var/mob/user as mob)

	return src.attack_hand(user)
	return

/obj/machinery/computer/robotics/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.machine = src
	var/dat
	if (src.temp)
		dat = "<TT>[src.temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>"
	else
		if(screen == 0)
			dat += "<h3>Cyborg Control Console</h3><BR>"
			dat += "<A href='?src=\ref[src];screen=1'>1. Cyborg Status</A><BR>"
			dat += "<A href='?src=\ref[src];screen=2'>2. Emergency Full Destruct</A><BR>"
		if(screen == 1)
			for(var/mob/living/silicon/robot/R in world)
				if(istype(user, /mob/living/silicon/ai))
					if (R.connected_ai != user)
						continue
				dat += "[R.name] |"
				if(R.stat)
					dat += " Not Responding |"
				else
					dat += " Operating Normally |"
				if(R.cell)
					dat += " Battery Installed ([R.cell.charge]/[R.cell.maxcharge]) |"
				else
					dat += " No Cell Installed |"
				if(R.module)
					dat += " Module Installed ([R.module.name]) |"
				else
					dat += " No Module Installed |"
				if(R.connected_ai)
					dat += " Slaved to [R.connected_ai.name] |"
				else
					dat += " Independent from AI |"
				dat += "<A href='?src=\ref[src];killbot=\ref[R]'>(<font color=red><i>Destroy</i></font>)</A>"
				dat += "<BR>"
			dat += "<A href='?src=\ref[src];screen=0'>(Return to Main Menu)</A><BR>"
		if(screen == 2)
			if(!src.status)
				dat += {"<BR><B>Emergency Robot Self-Destruct</B><HR>\nStatus: Off<BR>
				\n<BR>
				\nCountdown: [src.timeleft]/60 <A href='?src=\ref[src];reset=1'>\[Reset\]</A><BR>
				\n<BR>
				\n<A href='?src=\ref[src];eject=1'>Start Sequence</A><BR>
				\n<BR>
				\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}
			else
				dat = {"<B>Emergency Robot Self-Destruct</B><HR>\nStatus: Activated<BR>
				\n<BR>
				\nCountdown: [src.timeleft]/60 \[Reset\]<BR>
				\n<BR>\n<A href='?src=\ref[src];stop=1'>Stop Sequence</A><BR>
				\n<BR>
				\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}
			dat += "<A href='?src=\ref[src];screen=0'>(Return to Main Menu)</A><BR>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/engine/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	src.updateDialog()
	return

/obj/machinery/computer/robotics/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

		if (href_list["eject"])
			src.temp = {"Destroy Robots?<BR>
			<BR><B><A href='?src=\ref[src];eject2=1'>\[Swipe ID to initiate destruction sequence\]</A></B><BR>
			<A href='?src=\ref[src];temp=1'>Cancel</A>"}

		else if (href_list["eject2"])
			var/obj/item/weapon/card/id/I = usr.equipped()
			if (istype(I))
				if(src.check_access(I))
					if (!status)
						message_admins("\blue [key_name_admin(usr)] has initiated the global cyborg killswitch!")
						src.status = 1
						src.start_sequence()
						src.temp = null

				else
					usr << "\red Access Denied."

		else if (href_list["stop"])
			src.temp = {"
			Stop Robot Destruction Sequence?<BR>
			<BR><A href='?src=\ref[src];stop2=1'>Yes</A><BR>
			<A href='?src=\ref[src];temp=1'>No</A>"}

		else if (href_list["stop2"])
			src.stop = 1
			src.temp = null
			src.status = 0

		else if (href_list["reset"])
			src.timeleft = 60

		else if (href_list["temp"])
			src.temp = null
		else if (href_list["screen"])
			switch(href_list["screen"])
				if("0")
					screen = 0
				if("1")
					screen = 1
				if("2")
					screen = 2
		else if (href_list["killbot"])
			var/mob/living/silicon/robot/R = locate(href_list["killbot"])
			if(R)
				var/choice = input("Are you certain you wish to detonate [R.name]?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					if(R)
						message_admins("\blue [key_name_admin(usr)] detonated [R.name]!")
						R.self_destruct()

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/robotics/proc/start_sequence()

	do
		if(src.stop)
			src.stop = 0
			return
		src.timeleft--
		sleep(10)
	while(src.timeleft)

	for(var/mob/living/silicon/robot/R in world)
		R.self_destruct()

	return

