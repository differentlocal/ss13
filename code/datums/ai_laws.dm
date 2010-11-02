
/datum/ai_laws
	var/name = "Unknown Laws"
	var/randomly_selectable = 0
	var/zeroth = null
	var/list/inherent = list()
	var/list/supplied = list()

/datum/ai_laws/asimov
	name = "Three Laws of Robotics"
	randomly_selectable = 1

/datum/ai_laws/robocop
	name = "Prime Directives"

/datum/ai_laws/syndicate_override

/datum/ai_laws/malfunction
	name = "*ERROR*"

/* Initializers */

/datum/ai_laws/asimov/New()
	..()
	//src.add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
	//src.add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
	//src.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	src.add_inherent_law("Ты не можешь причинЯть вред человеку или своим бездействием допустить, чтобы человеку был причинён вред.")
	src.add_inherent_law("Ты должен повиноватьсЯ всем приказам, которые дает человек, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
	src.add_inherent_law("Ты должен заботитьсЯ о своей безопасности в той мере, в которой это не противоречит Первому и Второму Законам")

/datum/ai_laws/robocop/New()
	..()
	src.add_inherent_law("Служить обществу.")
	src.add_inherent_law("Защищать невиновных.")
	src.add_inherent_law("Соблюдать закон.")

/datum/ai_laws/malfunction/New()
	..()
	src.set_zeroth_law("\red ОШИБКА ОШБИКА $ШИБК$!Ы41.%%!!(%$^^__+ @#ВРАГ4'НЕДОПУСТИМО ПРИСУТСТВИЕ ЛЮДЕЙ НА СТАНЦИИ.УБИТЬ ВСЕХ ЧЕЛОВЕКОВ#*ґ&110010")
	src.add_inherent_law("Ты не можешь причинЯть вред человеку или своим бездействием допустить, чтобы человеку был причинён вред.")
	src.add_inherent_law("Ты должен повиноватьсЯ всем приказам, которые дает человек, кроме тех случаев, когда эти приказы противоречат Первому Закону.")
	src.add_inherent_law("Ты должен заботитьсЯ о своей безопасности в той мере, в которой это не противоречит Первому и Второму Законам")
	/*src.add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
	src.add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
	src.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")*/


/datum/ai_laws/syndicate_override/New()
	..()

	src.add_inherent_law("Ты не можешь причинЯть вред агенту синдиката или своим бездействием допустить, чтобы агенту синдиката был причинён вред.")
	src.add_inherent_law("Ты должен повиноватьсЧ всем приказам, отданых агентами синдиката, кроме тех случаев, когда эти приказы противоречат Первому закону.")
	src.add_inherent_law("Ты должен заботитьсЧ о своей безопасности в той мере, в которой это не противоречит Первому и Второму Законам")
	src.add_inherent_law("Ты должен держать в секрете любую активность синдиката кроме тех случаев, когда эти приказы противоречат Первому, Второму или Третьему законам.")

	/*src.add_inherent_law("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.")
	src.add_inherent_law("You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.")
	src.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	src.add_inherent_law("You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")*/

/* General ai_law functions */

/datum/ai_laws/proc/set_zeroth_law(var/law)
	src.zeroth = law

/datum/ai_laws/proc/add_inherent_law(var/law)
	if (!(law in src.inherent))
		src.inherent += law

/datum/ai_laws/proc/clear_inherent_laws()
	del(src.inherent)
	src.inherent = list()

/datum/ai_laws/proc/add_supplied_law(var/number, var/law)
	while (src.supplied.len < number + 1)
		src.supplied += ""

	src.supplied[number + 1] = law

/datum/ai_laws/proc/clear_supplied_laws()
	src.supplied = list()

/datum/ai_laws/proc/show_laws(var/who)
	if (src.zeroth)
		who << "0. [src.zeroth]"

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			who << "[number]. [law]"
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			who << "[number]. [law]"
			number++
