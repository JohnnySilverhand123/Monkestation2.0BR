// Jukebox headphones
/obj/item/instrument/piano_synth/headphones/jukebox
	name = "epic headphones"
	desc = "These headphones seem have two modes, synthesizer and jukebox."
	actions_types = list(/datum/action/item_action)

	var/mob/wearer
	var/obj/machinery/media/jukebox/headphones/internal_jukebox

/obj/item/instrument/piano_synth/headphones/jukebox/Initialize(mapload)
	. = ..()
	internal_jukebox = new(src)
	RegisterSignal(internal_jukebox, COMSIG_JUKEBOX_UPDATE, PROC_REF(on_jukebox_toggle))

/obj/item/instrument/piano_synth/headphones/jukebox/Destroy()
	UnregisterSignal(internal_jukebox, COMSIG_JUKEBOX_UPDATE)
	QDEL_NULL(internal_jukebox)
	return ..()

/obj/item/instrument/piano_synth/headphones/jukebox/interact(mob/user)
	var/choice = show_radial_menu(user, src, list("jukebox" = internal_jukebox, "instrument" = src), custom_check = CALLBACK(src, PROC_REF(can_use), user), require_near = TRUE)
	switch(choice)
		if("jukebox")
			internal_jukebox.interact(user)
		if("instrument")
			..()

/obj/item/instrument/proc/can_use(mob/user)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/item/instrument/piano_synth/headphones/jukebox/proc/on_jukebox_toggle(playing)
	if(!playing)
		return
	stop_playing()

/obj/item/instrument/piano_synth/headphones/jukebox/start_playing()
	. = ..()
	internal_jukebox.StopPlaying()

/obj/machinery/media/jukebox/headphones
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_ALLOW_USER_LOCATION

/obj/machinery/media/jukebox/headphones/Initialize(mapload)
	if(!istype(loc, /obj/item/instrument/piano_synth/headphones/jukebox))
		if(usr)
			message_admins("Dear [key_name_admin(usr)], please do not spawn this variant.")
		return INITIALIZE_HINT_QDEL
	return ..()

/obj/machinery/media/jukebox/headphones/ui_host(mob/user)
	return loc
	
/obj/item/instrument/piano_synth/headphones/jukebox/equipped(mob/user, slot, initial)
	. = ..()
	if(wearer)
		return
	wearer = user
	RegisterSignal(wearer, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_wearer_premove))
	RegisterSignal(wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_wearer_move))

/obj/item/instrument/piano_synth/headphones/jukebox/dropped(mob/user, silent)
	. = ..()
	if(item_flags & IN_INVENTORY)
		return
	UnregisterSignal(wearer, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED))
	wearer = null

/obj/item/instrument/piano_synth/headphones/jukebox/proc/on_wearer_premove()
	if(internal_jukebox.playing)
		internal_jukebox.disconnect_media_source_area()

/obj/item/instrument/piano_synth/headphones/jukebox/proc/on_wearer_move()
	if(internal_jukebox.playing)
		internal_jukebox.update_volume()
