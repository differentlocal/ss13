/mob/proc/say()
	return

/mob/verb/whisper()
	set name = "Whisper"
	return

/mob/verb/say_verb(message as text)
	set name = "Say"
	usr.say(message)

/mob/proc/say_dead(var/message)
	var/name = src.real_name
	var/alt_name = ""

	if (istype(src, /mob/living/carbon/human) && src.name != src.real_name)
		if (src:wear_id && src:wear_id:registered)
			alt_name = " (as [src:wear_id:registered])"
		else
			alt_name = " (as Unknown)"
	else if (istype(src, /mob/dead/observer))
		name = "Ghost"
		alt_name = " ([src.real_name])"
	else if (!istype(src, /mob/living/carbon/human))
		name = src.name

	message = src.say_quote(message)

	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name] <span class='message'>[message]</span></span>"

	for (var/mob/M in world)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat == 2 || (M.client && M.client.holder && M.client.deadchat)) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
			M.show_message(rendered, 2)

/mob/proc/say_understands(var/mob/other)
	if (src.stat == 2)
		return 1
	else if (istype(other, src.type))
		return 1
	else if(other.universal_speak || src.universal_speak)
		return 1
	return 0

/mob/proc/say_quote(var/text)
	var/ending = copytext(text, length(text))
	if (src.stuttering)
		return "заикается: \"[text]\"";
	if (src.brainloss >= 60)
		return "бормочет: \"[text]\"";
	if (ending == "?")
		return "спрашивает: \"[text]\"";
	else if (ending == "!")
		return "восклицает: \"[text]\"";

	return "говорит: \"[text]\"";

/mob/proc/emote(var/act)
	return
