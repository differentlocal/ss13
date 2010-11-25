/obj/item/weapon/airlock_electronics
	name = "Airlock Electronics"
	icon = 'door_assembly.dmi'
	icon_state = "door_electronics"

	req_access = list(access_engine)

	var
		list/conf_access = null
		last_configurator = null
		locked = 1

	attack_self(mob/user as mob)
		if (!ishuman(user))
			return ..(user)

		var/mob/living/carbon/human/H = user
		if(H.brainloss >= 60)
			return

		var/t1 = text("<B>��������� �������</B><br>\n")


		if (last_configurator)
			t1 += "����������: [last_configurator]<br>"

		if (locked)
			t1 += "<a href='?src=\ref[src];login=1'>�������� ID</a><hr>"
		else
			t1 += "<a href='?src=\ref[src];logout=1'>�������������</a><hr>"


			t1 += conf_access == null ? "<font color=red>���</font><br>" : "<a href='?src=\ref[src];access=all'>���</a><br>"

			t1 += "<br>"

			var/list/accesses = get_all_accesses()
			for (var/acc in accesses)
				var/aname = get_access_desc(acc)

				if (!conf_access || !conf_access.len || !(acc in conf_access))
					t1 += "<a href='?src=\ref[src];access=[acc]'>[aname]</a><br>"
				else
					t1 += "<font color=red>[aname]</font><br>"

		t1 += text("<p><a href='?src=\ref[];close=1'>�������</a></p>\n", src)

		user << browse(t1, "window=airlock_electronics")
		onclose(user, "airlock")

	Topic(href, href_list)
		..()
		if (usr.stat || usr.restrained())
			return
		if (href_list["close"])
			usr << browse(null, "window=airlock")
			return

		if (!ishuman(usr))
			return

		if (href_list["login"])
			var/obj/item/I
			if (istype(usr.l_hand, /obj/item/weapon/card/id)) I = usr.l_hand
			if (istype(usr.r_hand, /obj/item/weapon/card/id)) I = usr.r_hand
			if (I && src.check_access(I))
				src.locked = 0
				src.last_configurator = I:registered

		if (locked)
			return

		if (href_list["logout"])
			locked = 1

		if (href_list["access"])
			toggle_access(href_list["access"])

		attack_self(usr)

	proc
		toggle_access(var/acc)
			if (acc == "all")
				conf_access = null
			else
				var/req = text2num(acc)

				conf_access = list(req)
				/*
				if (conf_access == null)
					conf_access = list()

				if (!(req in conf_access))
					conf_access += req
				else
					conf_access -= req
				*/
