/mob/living/silicon/decoy/Life()
	if (src.stat == 2)
		return
	else
		if (src.health <= -100.0 && src.stat != 2)
			death()
			return


/mob/living/silicon/decoy/updatehealth()
	if (src.nodamage == 0)
		src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
	else
		src.health = 100
		src.stat = 0