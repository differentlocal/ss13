datum/computer/file/embedded_program
	var/list/memory = list()
	var/state
	var/obj/machinery/embedded_controller/master

	proc
		post_signal(datum/signal/signal, comm_line)
			if(master)
				master.post_signal(signal, comm_line)
			else
				del(signal)

		receive_user_command(command)

		receive_signal(datum/signal/signal, receive_method, receive_param)
			return null

		process()
			return 0

obj/machinery/embedded_controller
	var/datum/computer/file/embedded_program/program

	name = "Embedded Controller"
	density = 0
	anchored = 1

	var/on = 1

	attack_hand(mob/user)
		user << browse(return_text(), "window=computer")
		user.machine = src
		onclose(user, "computer")

	proc/update_icon()
	proc/return_text()

	proc/post_signal(datum/signal/signal, comm_line)
		return 0

	receive_signal(datum/signal/signal, receive_method, receive_param)
		if(!signal || signal.encryption) return

		if(program)
			return program.receive_signal(signal, receive_method, receive_param)

	Topic(href, href_list)
		if(..())
			return 0

		if(program)
			program.receive_user_command(href_list["command"])

		usr.machine = src

	process()
		if(program)
			program.process()

		update_icon()
		src.updateDialog()
		..()

	radio
		var/frequency
		var/datum/radio_frequency/radio_connection

		initialize()
			set_frequency(frequency)

		post_signal(datum/signal/signal)
			signal.transmission_method = TRANSMISSION_RADIO
			if(radio_connection)
				if (signal.data["tag"])
					return radio_connection.post_signal(src, signal, null, RADIO_TAG, signal.data["tag"])
				else
					return radio_connection.post_signal(src, signal)
			else
				del(signal)

		proc
			set_frequency(new_frequency)
				radio_controller.remove_object(src, "[frequency]")
				frequency = new_frequency
				radio_connection = radio_controller.add_object(src, "[frequency]", RADIO_GROUP, list("airlock", "vent"))
