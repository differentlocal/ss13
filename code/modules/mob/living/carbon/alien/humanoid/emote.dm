/mob/living/carbon/alien/humanoid/emote(var/act)

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	var/m_type = 1
	var/message

	switch(act)
		if("sign")
			if (!src.restrained())
				message = text("<B>The alien</B> signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = 1
		if ("burp")
			if (!muzzled)
				message = "<B>[src]</B> burps."
				m_type = 2
		if ("deathgasp")
			message = "<B>[src]</B> lets out a waning guttural screech, green blood bubbling from its maw..."
			m_type = 1
		if("scratch")
			if (!src.restrained())
				message = "<B>The [src.name]</B> почесываестся."
				m_type = 1
		if("whimper")
			if (!muzzled)
				message = "<B>The [src.name]</B> скулит."
				m_type = 2
		if("roar")
			if (!muzzled)
				message = "<B>The [src.name]</B> рычит."
				m_type = 2
		if("tail")
			message = "<B>The [src.name]</B> виляет хвостом."
			m_type = 1
		if("gasp")
			message = "<B>The [src.name]</B> ловит ртвом воздух."
			m_type = 2
		if("shiver")
			message = "<B>The [src.name]</B> дрожит."
			m_type = 2
		if("drool")
			message = "<B>The [src.name]</B> рыгает."
			m_type = 1
		if("scretch")
			if (!muzzled)
				message = "<B>The [src.name]</B> scretches."
				m_type = 2
		if("choke")
			message = "<B>The [src.name]</B> давится."
			m_type = 2
		if("moan")
			message = "<B>The [src.name]</B> стонет!"
			m_type = 2
		if("nod")
			message = "<B>The [src.name]</B> кивает головой."
			m_type = 1
		if("sit")
			message = "<B>The [src.name]</B> садится."
			m_type = 1
		if("sway")
			message = "<B>The [src.name]</B> пошатывается."
			m_type = 1
		if("sulk")
			message = "<B>The [src.name]</B> растроенно надувается."
			m_type = 1
		if("twitch")
			message = "<B>The [src.name]</B> яростно подергивается."
			m_type = 1
		if("dance")
			if (!src.restrained())
				message = "<B>The [src.name]</B> радостно танцует."
				m_type = 1
		if("roll")
			if (!src.restrained())
				message = "<B>The [src.name]</B> вертится."
				m_type = 1
		if("shake")
			message = "<B>The [src.name]</B> трясет головой."
			m_type = 1
		if("gnarl")
			if (!muzzled)
				message = "<B>The [src.name]</B> бормочет и скалится."
				m_type = 2
		if("jump")
			message = "<B>The [src.name]</B> прыгает!"
			m_type = 1
		if("collapse")
			if (!src.paralysis)	src.paralysis += 2
			message = text("<B>[]</B> коллапсирует!", src) // Leprostyle
			m_type = 2
		if("help")
			src << "choke, collapse, dance, drool, gasp, shiver, gnarl, jump, moan, nod, roar, roll, scratch,\nscretch, shake, sign-#, sit, sulk, sway, tail, twitch, whimper"
		else
			src << text("Invalid Emote: []", act)
	if ((message && src.stat == 0))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)
	return