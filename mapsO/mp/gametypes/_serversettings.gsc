//******************************************************************************
//  _____                  _    _             __
// |  _  |                | |  | |           / _|
// | | | |_ __   ___ _ __ | |  | | __ _ _ __| |_ __ _ _ __ ___
// | | | | '_ \ / _ \ '_ \| |/\| |/ _` | '__|  _/ _` | '__/ _ \
// \ \_/ / |_) |  __/ | | \  /\  / (_| | |  | || (_| | | |  __/
//  \___/| .__/ \___|_| |_|\/  \/ \__,_|_|  |_| \__,_|_|  \___|
//       | |               We don't make the game you play.
//       |_|                 We make the game you play BETTER.
//
//            Website: http://openwarfaremod.com/
//******************************************************************************

init()
{
	level.hostname = getdvar("sv_hostname");
	if(level.hostname == "")
		level.hostname = "^7CoD4:MW ^3OpenWarfare";
	setdvar("sv_hostname", level.hostname);
	setdvar("ui_hostname", level.hostname);
	makedvarserverinfo("ui_hostname", "^7CoD4:MW ^3OpenWarfare");

	level.motd = getdvar("scr_motd");
	if(level.motd == "")
		level.motd = "";
	setdvar("scr_motd", level.motd);
	setdvar("ui_motd", level.motd);
	makedvarserverinfo("ui_motd", "");

	level.allow_teamchange = getdvar("g_allow_teamchange");
	if(level.allow_teamchange == "")
		level.allow_teamchange = "1";
	setdvar("g_allow_teamchange", level.allow_teamchange);
	setdvar("ui_allow_teamchange", level.allow_teamchange);
	makedvarserverinfo("ui_allow_teamchange", "1");
	
	// If the host is "localhost", disable Add to favorites.
	if ( getdvar( "net_ip" ) == "localhost" ) {
		level.ui_favoriteAddress = "";
	} else {
		level.ui_favoriteAddress = getdvar("net_ip") + ":" + getdvar("net_port");
	}

	level.friendlyfire = maps\mp\gametypes\_tweakables::getTweakableValue( "team", "fftype" );
	setdvar("ui_friendlyfire", level.friendlyfire);
	makedvarserverinfo("ui_friendlyfire", "0");

	if(getdvar("scr_mapsize") == "")
		setdvar("scr_mapsize", "64");
	else if(getdvarFloat("scr_mapsize") >= 64)
		setdvar("scr_mapsize", "64");
	else if(getdvarFloat("scr_mapsize") >= 32)
		setdvar("scr_mapsize", "32");
	else if(getdvarFloat("scr_mapsize") >= 16)
		setdvar("scr_mapsize", "16");
	else
		setdvar("scr_mapsize", "8");
	level.mapsize = getdvarFloat("scr_mapsize");

	constrainGameType(getdvar("g_gametype"));
	constrainMapSize(level.mapsize);

	for(;;)
	{
		updateServerSettings();
		wait 5;
	}
}

updateServerSettings()
{
	sv_hostname = getdvar("sv_hostname");
	if(level.hostname != sv_hostname)
	{
		level.hostname = sv_hostname;
		setdvar("ui_hostname", level.hostname);
	}

	scr_motd = getdvar("scr_motd");
	if(level.motd != scr_motd)
	{
		level.motd = scr_motd;
		setdvar("ui_motd", level.motd);
	}

	g_allow_teamchange = getdvar("g_allow_teamchange");
	if(level.allow_teamchange != g_allow_teamchange)
	{
		level.allow_teamchange = g_allow_teamchange;
		setdvar("ui_allow_teamchange", level.allow_teamchange);
	}
	
	scr_friendlyfire = maps\mp\gametypes\_tweakables::getTweakableValue( "team", "fftype" );
	if(level.friendlyfire != scr_friendlyfire)
	{
		level.friendlyfire = scr_friendlyfire;
		setdvar("ui_friendlyfire", level.friendlyfire);
	}
}

constrainGameType(gametype)
{
	entities = getentarray();
	for(i = 0; i < entities.size; i++)
	{
		entity = entities[i];

		if(gametype == "dm")
		{
			if(isdefined(entity.script_gametype_dm) && entity.script_gametype_dm != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
		else if(gametype == "tdm")
		{
			if(isdefined(entity.script_gametype_tdm) && entity.script_gametype_tdm != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
		else if(gametype == "ctf")
		{
			if(isdefined(entity.script_gametype_ctf) && entity.script_gametype_ctf != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
		else if(gametype == "hq")
		{
			if(isdefined(entity.script_gametype_hq) && entity.script_gametype_hq != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
		else if(gametype == "sd")
		{
			if(isdefined(entity.script_gametype_sd) && entity.script_gametype_sd != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
		else if(gametype == "koth")
		{
			if(isdefined(entity.script_gametype_koth) && entity.script_gametype_koth != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
	}
}

constrainMapSize(mapsize)
{
	entities = getentarray();
	for(i = 0; i < entities.size; i++)
	{
		entity = entities[i];

		if(int(mapsize) == 8)
		{
			if(isdefined(entity.script_mapsize_08) && entity.script_mapsize_08 != "1")
			{
				//iprintln("DELETED(MapSize): ", entity.classname);
				entity delete();
			}
		}
		else if(int(mapsize) == 16)
		{
			if(isdefined(entity.script_mapsize_16) && entity.script_mapsize_16 != "1")
			{
				//iprintln("DELETED(MapSize): ", entity.classname);
				entity delete();
			}
		}
		else if(int(mapsize) == 32)
		{
			if(isdefined(entity.script_mapsize_32) && entity.script_mapsize_32 != "1")
			{
				//iprintln("DELETED(MapSize): ", entity.classname);
				entity delete();
			}
		}
		else if(int(mapsize) == 64)
		{
			if(isdefined(entity.script_mapsize_64) && entity.script_mapsize_64 != "1")
			{
				//iprintln("DELETED(MapSize): ", entity.classname);
				entity delete();
			}
		}
	}
}