/mob/living/carbon/monkey
	name = "monkey"
	voice_name = "monkey"
	voice_message = "бормочет"
	say_message = "бормочет"
	icon = 'monkey.dmi'
	icon_state = "monkey1"
	gender = NEUTER
	flags = 258.0

	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie

/mob/living/carbon/monkey/rpbody // For admin RP
	update_icon = 0
	voice_message = "говорит"
	say_message = "говорит"
