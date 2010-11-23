/mob/living/carbon/human/emote(var/act)
	var/param = null

	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	var/m_type = 1

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	var/message

	switch(act)
		if ("airguitar")
			if (!src.restrained())
				message = "<B>[src]</B> is strumming the air and headbanging like a safari chimp."
				m_type = 1

		if ("blink")
			message = "<B>[src]</B> слепнет."
			m_type = 1

		if ("blink_r")
			message = "<B>[src]</B> стремительно слепнет."
			m_type = 1

		if ("bow")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> bows to [param]."
				else
					message = "<B>[src]</B> bows."
			m_type = 1

		if ("custom")
			var/input = input("Choose an emote to display.")
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = 1
			else if (input2 == "Hearable")
				if (src.miming)
					return
				m_type = 2
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			message = "<B>[src]</B> [input]"


		if ("salute")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> salutes to [param]."
				else
					message = "<B>[src]</b> salutes."
			m_type = 1

		if ("choke")
			if (!muzzled)
				message = "<B>[src]</B> chokes!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a strong noise."
				m_type = 2

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = 2
		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings."
				m_type = 2

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings ANGRILY!"
				m_type = 2

		if ("drool")
			message = "<B>[src]</B> сморкаетс&#ff;."
			m_type = 1

		if ("eyebrow")
			message = "<B>[src]</B> raises an eyebrow."
			m_type = 1

		if ("chuckle")
			if (!muzzled)
				message = "<B>[src]</B> chuckles."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("twitch")
			message = "<B>[src]</B> сильно дрожит."
			m_type = 1

		if ("twitch_s")
			message = "<B>[src]</B> дрожит."
			m_type = 1

		if ("faint")
			message = "<B>[src]</B> faints."
			src.sleeping = 1
			m_type = 1

		if ("cough")
			if (!muzzled)
				message = "<B>[src]</B> кашл&#ff;ет!"
				m_type = 2
			else
				message = "<B>[src]</B> конвульсивно дёргаетс&#ff; с зав&#ff;занным ртом."
				m_type = 2

		if ("frown")
			message = "<B>[src]</B> frowns."
			m_type = 1

		if ("nod")
			message = "<B>[src]</B> nods."
			m_type = 1

		if ("blush")
			message = "<B>[src]</B> blushes."
			m_type = 1

		if ("gasp")
			if (!muzzled)
				message = "<B>[src]</B> задыхаетс&#ff;!"
				m_type = 2
			else
				message = "<B>[src]</B> тихо хрипит."
				m_type = 2

		if ("deathgasp")
			message = "<B>[src]</B> замирает, его глаза остекленели и безжизненны..."
			m_type = 1

		if ("giggle")
			if (!muzzled)
				message = "<B>[src]</B> хихикает."
				m_type = 2
			else
				message = "<B>[src]</B> издаёт веселые невн&#ff;тные звуки."
				m_type = 2

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> glares at [param]."
			else
				message = "<B>[src]</B> glares."

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> stares at [param]."
			else
				message = "<B>[src]</B> stares."

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break

			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> смотрит на [param]."
			else
				message = "<B>[src]</B> смотрит."
			m_type = 1

		if ("grin")
			message = "<B>[src]</B> grins."
			m_type = 1

		if ("cry")
			if (!muzzled)
				message = "<B>[src]</B> плачет."
				m_type = 2
			else
				message = "<B>[src]</B> тихо и печально хрипит."
				m_type = 2

		if ("sigh")
			if (!muzzled)
				message = "<B>[src]</B> вздыхает."
				m_type = 2
			else
				message = "<B>[src]</B> издаёт невн&#ff;тный звук."
				m_type = 2

		if ("laugh")
			if (!muzzled)
				message = "<B>[src]</B> смеётс&#ff;."
				m_type = 2
			else
				message = "<B>[src]</B> издаёт невн&#ff;тные звуки."
				m_type = 2

		if ("mumble")
			message = "<B>[src]</B> mumbles!"
			m_type = 2

		if ("grumble")
			if (!muzzled)
				message = "<B>[src]</B> grumbles!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("groan")
			if (!muzzled)
				message = "<B>[src]</B> groans!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a loud noise."
				m_type = 2

		if ("moan")
			message = "<B>[src]</B> moans!"
			m_type = 2

		if ("johnny")
			var/M
			if (param)
				M = param
			if (!M)
				param = null
			else
				message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows his name out in smoke."
				m_type = 2

		if ("point")
			if (!src.restrained())
				var/mob/M = null
				if (param)
					for (var/atom/A as mob|obj|turf|area in view(null, null))
						if (param == A.name)
							M = A
							break

				if (!M)
					message = "<B>[src]</B> указывает."
				else
					M.point()

				if (M)
					message = "<B>[src]</B> показывает на [M]."
				else
			m_type = 1

		if ("raise")
			if (!src.restrained())
				message = "<B>[src]</B> поднимает руку."
			m_type = 1

		if("shake")
			message = "<B>[src]</B> мотает головой."
			m_type = 1

		if ("shrug")
			message = "<B>[src]</B> пожимает плечами."
			m_type = 1

		if ("signal")
			if (!src.restrained())
				var/t1 = round(text2num(param))
				if (isnum(t1))
					if (t1 <= 5 && (!src.r_hand || !src.l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
					else if (t1 <= 10 && (!src.r_hand && !src.l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
			m_type = 1

		if ("smile")
			message = "<B>[src]</B> улыбаетс&#ff;."
			m_type = 1

		if ("shiver")
			message = "<B>[src]</B> shivers."
			m_type = 2

		if ("pale")
			message = "<B>[src]</B> goes pale for a second."
			m_type = 1

		if ("tremble")
			message = "<B>[src]</B> trembles in fear!"
			m_type = 1

		if ("sneeze")
			if (!muzzled)
				message = "<B>[src]</B> чихает."
				m_type = 2
			else
				message = "<B>[src]</B> резко дёргаетс&#ff; и издаёт странный звук."
				m_type = 2

		if ("sniff")
			message = "<B>[src]</B> sniffs."
			m_type = 2

		if ("snore")
			if (!muzzled)
				message = "<B>[src]</B> храпит."
				m_type = 2
			else
				message = "<B>[src]</B> издаёт хрюкающие звуки."
				m_type = 2

		if ("whimper")
			if (!muzzled)
				message = "<B>[src]</B> хнычет."
				m_type = 2
			else
				message = "<B>[src]</B> тихо хрипит."
				m_type = 2

		if ("wink")
			message = "<B>[src]</B> подмигивает."
			m_type = 1

		if ("yawn")
			if (!muzzled)
				message = "<B>[src]</B> зевает."
				m_type = 2

		if ("collapse")
			if (!src.paralysis)
				src.paralysis += 2
			message = "<B>[src]</B> обессилен!"
			m_type = 2

		if("hug")
			m_type = 1
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					message = "<B>[src]</B> обнимает [M]."
				else
					message = "<B>[src]</B> обнимает себ&#ff;."

		if ("handshake")
			m_type = 1
			if (!src.restrained() && !src.r_hand)
				var/mob/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if (M.canmove && !M.r_hand && !M.restrained())
						message = "<B>[src]</B> пожимает руку [M]."
					else
						message = "<B>[src]</B> убирает руку от [M]."

		if("daps")
			m_type = 1
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M)
					message = "<B>[src]</B> gives daps to [M]."
				else
					message = "<B>[src]</B> sadly can't find anybody to give daps to, and daps \himself. Shameful."

		if ("scream")
			if (!muzzled)
				message = "<B>[src]</B> громко орёт!"
				m_type = 2
			else
				message = "<B>[src]</B> издаёт сильный хрип&#ff;щий звук."
				m_type = 2

		if ("help")
			src << "blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough,\ncry, custom, deathgasp, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,\ngrin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,\nsigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, tremble, twitch, twitch_s, whimper,\nwink, yawn"

		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."

	if (message)
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
