/client/proc/Display_Sector()
	set category = "Debug"
	set name = "Display Sector Data"
	if(!check_rights(R_DEBUG))	return


	var/dat = "Sector Data<BR><BR>"

	if(isnull(starMap) || !starMap)
		dat += "</b>No sector data found!</b><BR>"
	else
		for(var/C in starMap.all_nodes)
			if(istype(C,/datum/sm_node))
				if(C:mission_objective)
					dat += "<B>*MISSION* </B>"
				dat += "<B>> Node:</b>([C:x], [C:y], [C:z]) - "
				if(!C:sector_stuff.len)
					dat += " (empty)<BR>"
				else
					for(var/Q in C:sector_stuff)
						if(istype(Q,/datum/sector_object))
							if(istype(Q,/datum/sector_object/planet))
								dat += "*     [Q:obj_name] - [Q:faction] - [Q:descrip] - Class: [Q:planet_class], [Q:planet_type].<BR>"
							else
								dat += "*     [Q:obj_name] - [Q:faction] - [Q:descrip] - M:[Q:minerals] R:[Q:radiation]<BR>"
			else
				starMap.all_nodes -= C

	usr << browse(dat, "window=sectorlog")
	feedback_add_details("admin_verb","DST") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/create_universe()
	set category = "Debug"
	set name = "Create New Universe (Overwrites)"
	if(!check_rights(R_DEBUG))	return

	if (alert("Are you sure you want to make a new galaxy map? This will delete the old one!","Are you sure","Yes","No") == "No")
		return

	all_so_types = subtypesof(/datum/sector_object) //Hopefully the only time we need to ever do this.

	var/x_val = input("Enter X length:","X", 2) as num
	var/y_val = input("Enter Y length:","Y", 2) as num
	var/z_val = input("Enter Z length:","Z", 2) as num

	usr << "<b>Starmap initializing..</b>"
	var/datum/starmap/S = new()
	starMap = S
	log_admin("[key_name(usr)] started generating a new Starmap!")
	message_admins("<span class='adminnotice'>[key_name(usr)] started generating a new Starmap!</span>")
	var/corners = alert("Do you want a corner map? If no, the ship will start in the center.","Corner start","Yes","No")
	if(corners == "No")
		starMap.negative_allowed = 1
	else
		starMap.negative_allowed = 0

	starMap.max_x = x_val
	starMap.max_y = y_val
	starMap.max_z = z_val

	starMap.initiate()
	log_admin("New starmap generated")
	message_admins("<span class='adminnotice'>New starmap generated!</span>")
	feedback_add_details("admin_verb","CNW") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
