/*
Special frequency list:
On the map:
1435 for status displays
1437 for atmospherics/fire alerts
1439 for engine components
1441 for atmospherics - supply tanks
1443 for atmospherics - distribution loop/mixed air tank
1445 for bot nav beacons
1447 for mulebot control
1449 for airlock controls
1451 for toxin lab access
1453 for engineering access
1455 for AI access
*/
#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1

var/const/RADIO_BROADCAST = 1
var/const/RADIO_VOICE = 2
var/const/RADIO_TAG = 4
var/const/RADIO_GROUP = 8

var/global/datum/controller/radio/radio_controller

datum/controller/radio
	var/list/datum/radio_frequency/frequencies = list()

	proc/add_object(obj/device, new_frequency, radio_mode = RADIO_BROADCAST, params)
		var/datum/radio_frequency/frequency = frequencies[new_frequency]

		if(!frequency)
			frequency = new
			frequency.frequency = new_frequency
			frequencies[new_frequency] = frequency

		frequency.add_device(device, radio_mode, params)

		//frequency.devices += device
		return frequency

	proc/remove_object(obj/device, old_frequency)
		var/datum/radio_frequency/frequency = frequencies[old_frequency]

		if(frequency)
			frequency.remove_device(device)

		return 1

	proc/return_frequency(frequency)
		return frequencies[frequency]

datum/radio_frequency
	var/frequency

	var/list/obj/voice = list()
	var/list/tags = list()
	var/list/groups = list()
	var/list/obj/broadcast = list()

	proc
		add_device(obj/device, radio_mode, params)
			if (radio_mode == RADIO_BROADCAST)
				broadcast += device
				return 0

			if (radio_mode == RADIO_VOICE)
				voice += device
				return voice

			if (istype(params, /list))
				if (radio_mode == RADIO_TAG || radio_mode == RADIO_GROUP)
					for (var/tag in params)
						add_device(device, radio_mode, tag)
				return 0

			if (radio_mode == RADIO_TAG)
				var/list/ctag = tags[params]
				if (!ctag)
					ctag = list()
					tags[params] = ctag
				ctag += device
				return 0

			if (radio_mode == RADIO_GROUP)
				var/list/cgroup = groups[params]
				if (!cgroup)
					cgroup = list()
					groups[params] = cgroup
				cgroup += device
				return 0

		remove_device(obj/device)
			voice -= device
			broadcast -= device
			for (var/tag in tags)
				var/ctag = tags[tag]
				ctag -= device
			for (var/group in groups)
				var/cgroup = groups[group]
				cgroup -= device

		post_signal(obj/source, datum/signal/signal, range, radio_mode = RADIO_BROADCAST, params)
			var/list/group

			if (istype(params, /list))
				if (radio_mode == RADIO_TAG || radio_mode == RADIO_GROUP)
					for (var/tag in params)
						post_signal(source, signal, range, radio_mode, tag)
				return 0

			if (radio_mode == RADIO_BROADCAST)
				group = broadcast
			if (radio_mode == RADIO_VOICE)
				group = voice
			if (radio_mode == RADIO_TAG)
				if (!params) params = signal.data["tag"]
				group = tags[params]
			if (radio_mode == RADIO_GROUP)
				if (!params) params = signal.data["group"]
				group = groups[params]

			if (!group)
				return 0

			if	(range)
				post_signal_ranged(group, source, signal, range)
			else
				post_signal_unranged(group, source, signal)

			del(signal)

		post_signal_alt(obj/source, datum/signal/signal, tag, group)
			if (tag)
				var/list/sgroup = tags[tag]
				if (sgroup)
					post_signal_unranged(sgroup, source, signal)

			if (group)
				var/list/sgroup = groups[group]
				if (sgroup)
					post_signal_unranged(sgroup, source, signal)

			del(signal)

		post_signal_ranged(list/cmdd, obj/source, datum/signal/signal, range)
			var/turf/start_point = get_turf(source)
			if (!start_point)
				return 0

			var/fromx = start_point.x - range
			var/tox = start_point.x + range
			var/fromy = start_point.y - range
			var/toy = start_point.y + range
			for(var/obj/device in cmdd)
				if (device != source)
					var/turf/end_point = get_turf(device)
					if (end_point && end_point.x >= fromx && end_point.x <= tox && end_point.y >= fromy && end_point.y <= toy)
						//if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)
						device.receive_signal(signal, TRANSMISSION_RADIO, frequency)


		post_signal_unranged(list/cmdd, obj/source, datum/signal/signal)
			for(var/obj/device in cmdd)
				if (device != source)
					device.receive_signal(signal, TRANSMISSION_RADIO, frequency)

obj/proc
	receive_signal(datum/signal/signal, receive_method, receive_param)
		return null

datum/signal
	var/obj/source

	var/transmission_method = 0
	//0 = wire
	//1 = radio transmission

	var/data = list()
	var/encryption

	proc/copy_from(datum/signal/model)
		source = model.source
		transmission_method = model.transmission_method
		data = model.data
		encryption = model.encryption