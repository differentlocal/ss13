///////////////////////////////////////////////////////////////////////////////////////////////
// Brig Door control displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/September/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(access_brig)
	anchored = 1.0    		// can't pick it up
	density = 0       		// can walk through it.
	var/id = null     		// id of door it controls.
	var/childproof = 0		// boolean, when activating the door controls, locks door for 1 minute
	var/picture_state		// icon_state of alert picture, if not displaying text/numbers
	var/prepare_timer = 0

	var/open_after = 0
	var/associated_doors = list()


/obj/machinery/door_timer/initialize()
	..()
	for(var/obj/machinery/door/window/brigdoor/M in world)
		if (M.id == src.id)
			associated_doors += M
	opendoor()

//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/door_timer/process()
	..()
	if (open_after)
		var/t = open_after - world.time
		if (t <= 0)
			opendoor()
			open_after = 0

		src.updateDialog()
		src.update_icon()

	return

// has the door power sitatuation changed, if so update icon.
/obj/machinery/door_timer/power_change()
	update_icon()

// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.
/obj/machinery/door_timer/proc/opendoor()
	if(stat & (NOPOWER|BROKEN))
		return
	for (var/obj/machinery/door/window/brigdoor/M in associated_doors)
		if (M.density)
			spawn(0)
				M.autoclose = 0
				M.open()
	src.updateUsrDialog()
	src.update_icon()
	return

/obj/machinery/door_timer/proc/closedoor()
	if(stat & (NOPOWER|BROKEN))
		return
	for (var/obj/machinery/door/window/brigdoor/M in associated_doors)
		if (!M.density)
			spawn(0)
				M.autoclose = 1
				M.close()
	src.updateUsrDialog()
	src.update_icon()
	return


//Allows AIs to use door_timer, see human attack_hand function below
/obj/machinery/door_timer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

//Allows monkeys to use door_timer, see human attack_hand function below
/obj/machinery/door_timer/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

//Allows humans to use door_timer
//Opens dialog window when someone clicks on door timer
// Allows altering timer and the timing boolean.
// Flasher activation limited to 150 seconds
/obj/machinery/door_timer/attack_hand(var/mob/user as mob)
	if(..())
		return
	var/dat = "<HTML><BODY><TT><B>Управление камерой [src.id]</B>"
	user.machine = src
	var/d2

	var/time

	if (open_after)
		time = round((open_after - world.time) / 10)
		d2 = text("<A href='?src=\ref[];time=0'>сбросить</A><br>", src)
	else
		update_display("SET","TIME")
		time = prepare_timer
		d2 = text("<A href='?src=\ref[];time=1'>установить</A><br>", src)

	var/second = time % 60
	var/minute = (time - second) / 60
	dat += text("<br><HR>\nТаймер: [d2]\nВрем&#255;: [(minute ? text("[minute]:") : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>")
	for(var/obj/machinery/flasher/F in world)
		if(F.id == src.id)
			if(F.last_flash && world.time < F.last_flash + 150)
				dat += text("<BR><BR><A href='?src=\ref[];fc=1'>Ослепить (Зар&#255;жаетс&#255;)</A>", src)
			else
				dat += text("<BR><BR><A href='?src=\ref[];fc=1'>Ослепить</A>", src)
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=computer'>Закрыть</A></TT></BODY></HTML>", user)
	user << browse(dat, "window=computer;size=400x300")
	onclose(user, "computer")
	return

//Function for using door_timer dialog input, checks if user has permission
// href_list to
//  "time" turns on timer
//  "tp" value to modify timer
//  "fc" activates flasher
// Also updates dialog window and timer icon
/obj/machinery/door_timer/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if(src.allowed(usr))
			if (href_list["time"])
				if (href_list["time"])
					open_after = world.time + prepare_timer * 10
					prepare_timer = 0
					closedoor()
				else
					prepare_timer = round((open_after - world.time) / 10)
					open_after = 0
					opendoor()
			if (href_list["tp"])  //adjust timer, close door if not already closed
				var/tp = text2num(href_list["tp"])
				if (open_after)
					open_after += tp * 10
					open_after = min(max(open_after, world.time), world.time + 6000)
				else
					prepare_timer += tp
					prepare_timer = min(max(prepare_timer, 0), 600)
			if (href_list["fc"])
				for (var/obj/machinery/flasher/F in world)
					if (F.id == src.id)
						F.flash()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		src.update_icon()
	return

//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
/obj/machinery/door_timer/proc/update_icon()
	var/disp1
	var/disp2
	var/time = max(round((open_after - world.time) / 10), 0)

	disp1 = uppertext(id)
	disp2 = "[add_zero(num2text((time / 60) % 60),2)]~[add_zero(num2text(time % 60), 2)]"
	if(stat & (NOPOWER))
		icon_state = "frame"
		return
	else
		if(stat & (BROKEN))
			set_picture("ai_bsod")
			return
		else
			if (open_after)
				spawn(5)
					update_display(disp1, disp2)

// Adds an icon in case the screen is broken/off, stolen from status_display.dm
/obj/machinery/door_timer/proc/set_picture(var/state)
	picture_state = state
	overlays = null
	overlays += image('status_display.dmi', icon_state=picture_state)

//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/door_timer/proc/update_display(var/line1, var/line2)
	if(line2 == null)		// single line display
		overlays = null
		overlays += texticon(line1, 23, -13)
	else					// dual line display
		overlays = null
		overlays += texticon(line1, 23, -9)
		overlays += texticon(line2, 23, -17)
	// return an icon of a time text string (tn)
	// valid characters are 0-9 and :
	// px, py are pixel offsets

//Actual string input to icon display for loop, with 5 pixel x offsets for each letter.
//Stolen from status_display
/obj/machinery/door_timer/proc/texticon(var/tn, var/px = 0, var/py = 0)
	var/image/I = image('status_display.dmi', "blank")
	var/len = lentext(tn)

	for(var/d = 1 to len)
		var/char = copytext(tn, len-d+1, len-d+2)
		if(char == " ")
			continue
		var/image/ID = image('status_display.dmi', icon_state=char)
		ID.pixel_x = -(d-1)*5 + px
		ID.pixel_y = py

		I.overlays += ID

	return I


