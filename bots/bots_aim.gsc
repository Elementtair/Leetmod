#include bots\bots_funcs;

bots_MainAimbot()
{
	self endon("bot_reset");
	self endon("death");
	
	for(i=0;;i++)
	{
		if(self bots_isClimbing())
		{
			self bots_doClimbingAim();
		}
		else
		{
			if(i == 1)
			{
				if(self bots_canTDKS())
					killstreak = self bots_getTargetKillstreak();
				else
					killstreak = undefined;
			}
			else
			{
				killstreak = undefined;
			}
			if(isDefined(killstreak))
			{
				self bots_doKillKillstreak(killstreak);
			}
			else
			{
				//if(i == 11)
					target = self bots_getTargetOnFootPlayer();
				//else
				//	target = undefined;
				if(isDefined(target))
				{
					self bots_doKillOnFootPlayer(target);
				}
				else
				{
					if(i == 6)
					{
						if(self bots_canKillEqu())
							equ = self bots_getTargetEquipment();
						else
							equ = undefined;
					}
					else
					{
						equ = undefined;
					}
					if(isDefined(equ))
					{
						self bots_doKillEqu(equ);
					}
					else
					{
						if(i == 16)
						{
							self thread bots_checkSwitchWeap();
							self thread bots_doGNade();
						}
						self bots_stopShooting();
						if(!isDefined(self.bots_campingAngles))
							angles = VectorToAngles(((self.bots_tempwp-self.origin)-(anglesToForward(self getplayerangles()))));
						else
							angles = self.bots_campingAngles;
						self thread bots_doAim(angles, self.pers["bots"]["skill"]["aimSpeed"]);
					}
				}
			}
		}
		if(i > 18)
			i = 0;
		bots_waitFrame();//wait 0.05//which is 20fps
	}
}

bots_doAim(angles, speed)
{
	self notify("bots_aim_overlap");
	self endon("bots_aim_overlap");
	self endon("bot_reset");
	self endon("death");
	
	if(level.bots_varPlayAim)
	{
		self bots_setPlayerAngesReal(angles, speed);
	}
}

bots_doKillEqu(equ)
{
	self.bots_realEqu = equ;
	while(self bots_isGoodToAimAtEqu(equ))
	{
		self thread bots_checkSwitchWeap(equ);
		if(!self bots_isShellShocked())
		{
			lookLoc = equ.origin + (0.0, 0.0, 5.0);
			self thread bots_doGNadeTarget(equ);
			self bots_shootWeapon();
			if(!randomint(25) && self.pers["bots"]["skill"]["base"] > 4 && self.bots_firing)
				equ notify( "damage", 5, self );
			
			weapon = self bots_getCurrentWeapon();
			myEye = self getTagOrigin( "j_head" );
			dis = Distance(myEye, equ.origin);
			
			if(weaponClass(weapon) == "grenade")
			{
				weaps = strTok(weapon, "_");
				if(weaps[0] == "gl")
				{
					dist = (dis*(dis/400.0))/40.0;
					angles = VectorToAngles( ( lookLoc ) - ( myEye ) + (0.0,0.0,dist) );
				}
				else
				{
					dist = (dis*(dis/200.0))/15.0;
					angles = VectorToAngles( ( lookLoc ) - ( myEye ) + (0.0,0.0,dist) );
				}
			}
			else
			{
				angles = VectorToAngles( ( lookLoc ) - ( myEye ) );
			}
			self thread bots_doAim(angles, self.pers["bots"]["skill"]["aimSpeed"]);
		}
		bots_waitFrame();
	}
	self.bots_realEqu = undefined;
	self bots_stopShooting();
}

bots_doKillKillstreak(killstreak)
{
	if(self bots_getAmmoCount("rpg_mp") && self bots_getCurrentWeapon() != "rpg_mp")
		self bots_switchToOff("rpg_mp");
	
	self.bots_realTarKS = killstreak;
	
	while(self bots_isGoodToAimAtKS(killstreak))
	{
		angles = VectorToAngles((killstreak.origin-self.origin)-(anglesToForward(self getplayerangles())));
		self thread bots_doAim(angles, self.pers["bots"]["skill"]["aimSpeed"]);
		self thread bots_checkSwitchWeap(killstreak);
		self bots_ShootWeapon();
		bots_waitFrame();
	}
	self bots_stopShooting();
	
	self.bots_realTarKS = undefined;
}

bots_doKillWait()
{
	self endon("bot_reset");
	self endon("death");
	self endon("bot_kill_wait");
	wait self.pers["bots"]["skill"]["shootDelay"];
	self notify("bot_kill_wait");
}

bots_doSkillWait(target, lookLoc)
{
	if(self.pers["bots"]["skill"]["shootDelay"] <= 0.0)
		return;
	
	self endon("bot_kill_wait");
	self thread bots_doKillWait();
	while(self bots_isGoodToAimAtPlayer(target))
	{
		if(isDefined(self.bots_campingAngles))
			angles = self.bots_campingAngles;
		else if(isDefined(lookLoc))
			angles = VectorToAngles( ( lookLoc ) - ( self getTagOrigin( "j_head" ) ) );
		else
			angles = VectorToAngles(((self.bots_tempwp-self.origin)-(anglesToForward(self getplayerangles()))));
		
		self thread bots_doAim(angles, self.pers["bots"]["skill"]["aimSpeed"]);
		bots_waitFrame();
	}
	self notify("bot_kill_wait");
}

bots_doKillWaitEnd()
{
	self endon("bot_reset");
	self endon("death");
	self endon("bot_kill_wait");
	wait self.pers["bots"]["skill"]["newTarg"];
	self notify("bot_kill_wait");
}

bots_doSkillWaitEnd(target, lookLoc)
{
	if(self.pers["bots"]["skill"]["newTarg"] <= 0.0)
		return;
	
	self endon("bot_kill_wait");
	self thread bots_doKillWaitEnd();
	while(!self bots_isClimbing() && !self bots_isPlayerGood(target))
	{
		if(isDefined(self.bots_campingAngles))
			angles = self.bots_campingAngles;
		else if(isDefined(lookLoc))
			angles = VectorToAngles( ( lookLoc ) - ( self getTagOrigin( "j_head" ) ) );
		else
			angles = VectorToAngles(((self.bots_tempwp-self.origin)-(anglesToForward(self getplayerangles()))));
		
		self thread bots_doAim(angles, self.pers["bots"]["skill"]["aimSpeed"]);
		bots_waitFrame();
	}
	self notify("bot_kill_wait");
}

bots_doKillOnFootPlayer(target)
{
	lookLoc = undefined;
	while(self bots_isGoodToAimAtPlayer(target))
	{
		self bots_doSkillWait(target, lookLoc);
		self.bots_realSeen = target;
		self thread bots\talk::bots_doMessage();
		while(self bots_isGoodToAimAtPlayer(target))
		{
			self thread bots_checkSwitchWeap(target);
			if(!self bots_isShellShocked())
			{
				self thread bots_doGNadeTarget(target);
				self thread bots_melee(target);
				
				weapon = self bots_getCurrentWeapon();
				lookLoc = target getTagOrigin( "j_spineupper" );
				
				myEye = self getTagOrigin( "j_head" );
				dis = Distance(myEye, target.origin);
				
				if(weaponClass(weapon) == "grenade")
				{
					weaps = strTok(weapon, "_");
					if(weaps[0] == "gl")
					{
						dist = (dis*(dis/400.0))/40.0;
						angles = VectorToAngles( ( lookLoc ) - ( myEye ) + (0.0,0.0,dist) );
					}
					else
					{
						dist = (dis*(dis/200.0))/15.0;
						angles = VectorToAngles( ( lookLoc ) - ( myEye ) + (0.0,0.0,dist) );
					}
				}
				else
				{
					angles = VectorToAngles( ( lookLoc ) - ( myEye ) );
				}
				self thread bots_doAim(angles, self.pers["bots"]["skill"]["aimSpeed"]);
			}
			self bots_shootWeapon();
			bots_waitFrame();
		}
		self.bots_realSeen = undefined;
		self bots_doSkillWaitEnd(target, lookLoc);
	}
	
	if(isDefined(target))
	{
		if(isAlive(target))
		{
			self.bots_lastSeen[target getEntityNumber()] = getTime();
			if(isDefined(lookLoc))
				self thread bots_doGNadeLoc(lookLoc);
		}
		else
		{
			self.bots_lastSeen[target getEntityNumber()] = undefined;
		}
	}
}

bots_doClimbingAim()
{
	while(self bots_isClimbing())
	{
		self bots_stopShooting();
		if(isdefined(level.waypoints[self.bots_currentStaticWp].angles))
			angles = level.waypoints[self.bots_currentStaticWp].angles;
		else
			angles = VectorToAngles(((self.bots_tempwp-self.origin)-(anglesToForward(self getplayerangles()))));
		self thread bots_doAim(angles, self.pers["bots"]["skill"]["aimSpeed"]);
		bots_waitFrame();
	}
}

bots_checkSwitchWeap(target)
{
	self endon("bot_reset");
	self endon("death");
	
	if(!self bots_canSwitch())
		return;
	
	weapon = self bots_getCurrentWeapon();
	isDef = isDefined(target);
	
	if(isDef)
	{
		isSpread = (weaponClass(weapon) == "spread");
		hasSpread = isSpread;
		
		if(!hasSpread)
		{
			primaries = self bots_getPrimariesName();
			for(i = 0; i < primaries.size; i++)
				if(weaponClass(primaries[i]) == "spread")
				{
					hasSpread = true;
					break;
				}
		}
	
		if(hasSpread)
		{
			if(Distance(self.origin, target.origin) < 500.0)
			{
				if(!randomint(5) && !isSpread)
				{
					self bots_SwitchToOff();
					return;
				}
			}
			else if(isSpread)
			{
				self bots_SwitchToOff();
				return;
			}
		}
		
		if(isDefined(level.bots_forceSwitch[weapon]))
		{
			self bots_SwitchToOff();
			return;
		}
	}
	
	if(self.pers["bots"]["trait"]["switch"] <= 0)
		return;
	
	if(isDef)
		rand = self.pers["bots"]["trait"]["switch"];
	else
		rand = int(self.pers["bots"]["trait"]["switch"]*4);
	
	if(rand < 4)
		rand = 4;
	
	rnd = bots_randomInt(rand);
		
	if(!self bots_getAmmoCount(weapon) || (!self bots_getWeaponAmmoClip( weapon ) && (rnd == 2 || rnd == 3 || rnd == 0)) || (rnd == 1 && !isDef))
	{
		self bots_SwitchToOff();
		return;
	}
}

bots_doSwitchTime()
{
	self endon("bot_reset");
	self endon("death");
	self.bots_switchTime = true;
	wait 2.5;
	self.bots_switchTime = false;
}

bots_SwitchToOff(pref, reverse)
{
	if(self bots_canSwitch() && !self.bots_switchTime)
	{
		lastWeapon = self bots_getCurrentWeapon();
		currentWeapon = self getCurrentWeapon();
		primaries = self bots_getPrimariesName();
		secondary = self bots_tryGetGoodWeap(self bots_getSecondariesName());
		weap = undefined;
		
		if(!isDefined(pref))
		{
			if(primaries.size && lastWeapon == primaries[0])
			{
				if(primaries.size > 1)
					weap = primaries[1];
				else if(isDefined(secondary))
					weap = secondary;
			}
			else
			{
				if(primaries.size)
					weap = primaries[0];
				else if(isDefined(secondary))
					weap = secondary;
			}
		}
		else
		{
			if(!isDefined(reverse))
				weap = pref;
			else
			{
				weaps = primaries;
				if(isDefined(secondary))
					weaps[weaps.size] = secondary;
				
				for(i = 0; i < weaps.size; i++)
				{
					if(weaps[i] == pref)
						continue;
					
					weap = weaps[i];
					break;
				}
			}
		}
		
		if(isDefined(weap))
		{
			self bots_setspawnweapon(weap);
			self bots_stopShooting();
			
			if(lastWeapon != weap && currentWeapon != "none")
			{
				self.bots_doing = "switch";
				self thread bots_doSwitchTime();
				wait 1;
				self.bots_doing = "none";
			}
		}
	}
}

bots_doNoneOnGNadeAmmo(weap, lastWeap)
{
	self endon("death");
	self endon("bot_reset");
	self endon("bot_kill_nade");
	
	while(self bots_getAmmoCount(weap) && self bots_getCurrentWeapon() == weap)
		bots_waitFrame();
	
	wait 1;
	self bots_setspawnweapon(lastWeap);
	self.bots_doing = "none";
	self bots_stopShooting();
	self notify("bot_kill_nade");
}

bots_doNoneOnGNadeAmmoTube(weap, lastWeap)
{
	self endon("death");
	self endon("bot_reset");
	self endon("bot_kill_nade");
	
	while(self bots_getAmmoCount(weap) && self bots_getCurrentWeapon() == weap)
		bots_waitFrame();
	
	wait 1;
	self bots_setspawnweapon(lastWeap);
	if(self.bots_doing != "climb")
		self.bots_doing = "none";
	self bots_stopShooting();
	self notify("bot_kill_nade");
}

bots_forceGNadeFire()
{
	self endon("death");
	self endon("bot_reset");
	self endon("bot_kill_nade");
	for(;;)
	{
		self bots_shootWeapon();
		bots_waitFrame();
	}
}

bots_watchGNadeFire(lastWeap)
{
	self endon("death");
	self endon("bot_reset");
	self endon("bot_kill_nade");
	
	self bots_waittill_either("grenade_fire", "offhand_end");
	
	self bots_setspawnweapon(lastWeap);
	self.bots_doing = "none";
	self bots_stopShooting();
	self notify("bot_kill_nade");
}

bots_doNoneOnDeadNadeAim()
{
	self endon("death");
	self endon("bot_reset");
	self waittill("bot_kill_nade");
	self.bots_camping = false;
	self.bots_campingAngles = undefined;
}

bots_forceGNadeAim(pos, dis, istube)
{
	self endon("death");
	self endon("bot_reset");
	self endon("bot_kill_nade");
	
	self thread bots_doNoneOnDeadNadeAim();
	
	if(!isDefined(istube))
		dist = (dis*(dis/200.0))/15.0;
	else
		dist = (dis*(dis/400.0))/40.0;
	self.bots_camping = true;
	self.bots_campingAngles = VectorToAngles( ( pos ) - ( self getTagOrigin( "j_head" ) ) + (0.0,0.0,dist) );
}

bots_doGNadeLoc(bombLoc)
{
	self endon("death");
	self endon("bot_reset");
	self endon("bot_kill_nade");
	
	if(!self bots_canSwitch())
		return;
	
	if(self.pers["bots"]["trait"]["nade"] <= 0)
		return;
	
	rand = int(self.pers["bots"]["trait"]["nade"]/6);
	if(rand < 4)
		rand = 4;
	
	rnd = bots_randomInt(rand);
	
	switch(rnd)
	{
		case 0:
			if(level.bots_varLoadoutNade)
			{
				if(self bots_getAmmoCount("claymore_mp") && !randomInt(5))
				{
					lastWeapon = self bots_getCurrentWeapon();
					self bots_setspawnweapon("claymore_mp");
					self.bots_doing = "nade_fire";
					self thread bots_watchGNadeFire(lastWeapon);
					self thread bots_doNoneOnGNadeAmmo("claymore_mp", lastWeapon);
					self thread bots_forceGNadeFire();
					
					wait 5;
					self bots_setspawnweapon(lastWeapon);
					self.bots_doing = "none";
					self bots_stopShooting();
					self notify("bot_kill_nade");
				}
			}
		break;
		case 1:
			if(level.bots_varLoadoutNade)
			{
				if(self bots_getAmmoCount("frag_grenade_mp"))
				{
					dis = Distance(self getTagOrigin( "j_head" ), bombLoc);
					if(dis >= level.bots_minNadeDis)
					{
						lastWeapon = self bots_getCurrentWeapon();
						self bots_setspawnweapon("frag_grenade_mp");
						self.bots_doing = "nade_fire";
						self thread bots_watchGNadeFire(lastWeapon);
						self thread bots_doNoneOnGNadeAmmo("frag_grenade_mp", lastWeapon);
						self thread bots_forceGNadeAim(bombLoc, dis);
						wait 1;
						self thread bots_forceGNadeFire();
						
						wait 5;
						self bots_setspawnweapon(lastWeapon);
						self.bots_doing = "none";
						self bots_stopShooting();
						self notify("bot_kill_nade");
					}
				}
			}
		break;
		case 2:
			if(level.bots_varLoadoutNade)
			{
				secnade = self bots_tryGetGoodWeap(self bots_getOffhandsName());
				if(isDefined(secnade))
				{
					if(self bots_getAmmoCount(secnade))
					{
						dis = Distance(self getTagOrigin( "j_head" ), bombLoc);
						if(dis >= level.bots_minNadeDis)
						{
							lastWeapon = self bots_getCurrentWeapon();
							self bots_setspawnweapon(secnade);
							self.bots_Doing = "nade_fire";
							self thread bots_doNoneOnGNadeAmmo(secnade, lastWeapon);
							self thread bots_watchGNadeFire(lastWeapon);
							
							self thread bots_forceGNadeAim(bombLoc, dis);
							wait 1;
								
							self thread bots_forceGNadeFire();
							
							wait 3;
							self bots_setspawnweapon(lastWeapon);
							self.bots_Doing = "none";
							self bots_stopShooting();
							self notify("bot_kill_nade");
						}
					}
				}
			}
		break;
		case 3:
			if(level.bots_varLoadoutTube)
			{
				weap = self bots_tryGetGoodWeap(self bots_getWeaponsGL());
				if(isDefined(weap))
				{
					if(self bots_getAmmoCount(weap))
					{
						dis = Distance(self getTagOrigin( "j_head" ), bombLoc);
						if(dis >= level.bots_minNadeDis)
						{
							self.bots_Doing = "ftube";
							lastWeapon = self bots_getCurrentWeapon();
							self bots_setspawnweapon(weap);
							self thread bots_doNoneOnGNadeAmmoTube(weap, lastWeapon);
							
							self thread bots_forceGNadeAim(bombLoc, dis, true);
							wait 1;
							
							self thread bots_forceGNadeFire();
							
							wait 5.5;
								
							self bots_setspawnweapon(lastWeapon);
							if(self.bots_doing != "climb")
								self.bots_Doing = "none";
							self bots_stopShooting();
							self notify("bot_kill_nade");
						}
					}
				}
			}
		break;
	}
}

bots_doGNadeTarget(target)
{
	self endon("death");
	self endon("bot_reset");
	self endon("bot_kill_nade");
	
	if(!self bots_canSwitch())
		return;
					
	if(self.pers["bots"]["trait"]["nade"] <= 0)
		return;
	
	rand = int(self.pers["bots"]["trait"]["nade"]*2);
	if(rand < 9)
		rand = 9;
	
	rnd = bots_randomInt(rand);
	
	switch(rnd)
	{
		case 0:
			if(level.bots_varLoadoutNade)
			{
				if(self bots_getAmmoCount("claymore_mp") && !randomInt(5))
				{
					lastWeapon = self bots_getCurrentWeapon();
					self bots_setspawnweapon("claymore_mp");
					self.bots_doing = "nade_fire";
					self thread bots_watchGNadeFire(lastWeapon);
					self thread bots_doNoneOnGNadeAmmo("claymore_mp", lastWeapon);
					self thread bots_forceGNadeFire();
					
					wait 5;
					self bots_setspawnweapon(lastWeapon);
					self.bots_doing = "none";
					self bots_stopShooting();
					self notify("bot_kill_nade");
				}
			}
		break;
		case 1:
			dis = distance(self.origin, target.origin);
			if(level.bots_varLoadoutNade && dis >= level.bots_minNadeDis)
			{
				if(self bots_getAmmoCount("frag_grenade_mp"))
				{
					lastWeapon = self bots_getCurrentWeapon();
					self bots_setspawnweapon("frag_grenade_mp");
					self.bots_doing = "nade_fire";
					self thread bots_watchGNadeFire(lastWeapon);
					self thread bots_doNoneOnGNadeAmmo("frag_grenade_mp", lastWeapon);
					
					self thread bots_forceGNadeFire();
					
					wait 5;
					self bots_setspawnweapon(lastWeapon);
					self.bots_doing = "none";
					self bots_stopShooting();
					self notify("bot_kill_nade");
				}
			}
		break;
		case 2:
			dis = distance(self.origin, target.origin);
			if(level.bots_varLoadoutNade && dis >= level.bots_minNadeDis)
			{
				secnade = self bots_tryGetGoodWeap(self bots_getOffhandsName());
				if(isDefined(secnade))
				{
					if(self bots_getAmmoCount(secnade))
					{
						lastWeapon = self bots_getCurrentWeapon();
						self bots_setspawnweapon(secnade);
						self.bots_Doing = "nade_fire";
						self thread bots_doNoneOnGNadeAmmo(secnade, lastWeapon);
						self thread bots_watchGNadeFire(lastWeapon);
							
						self thread bots_forceGNadeFire();
						
						wait 3;
						self bots_setspawnweapon(lastWeapon);
						self.bots_Doing = "none";
						self bots_stopShooting();
						self notify("bot_kill_nade");
					}
				}
			}
		break;
		case 3:
		case 4:
		case 5:
			dis = distance(self.origin, target.origin);
			if(level.bots_varLoadoutTube && dis >= level.bots_minNadeDis)
			{
				weap = self bots_tryGetGoodWeap(self bots_getWeaponsGL());
				if(isDefined(weap))
				{
					if(self bots_getAmmoCount(weap))
					{
						self bots_switchToOff(weap);
					}
				}
			}
		break;
		case 6:
		case 7:
		case 8:
			if(level.bots_varLoadoutTube)
			{
				if(self bots_getAmmoCount("rpg_mp"))
				{
					self bots_switchToOff("rpg_mp");
				}
			}
		break;
	}
}

bots_doGNade()
{
	self endon("death");
	self endon("bot_reset");
	self endon("bot_kill_nade");
	
	if(!self bots_canSwitch())
		return;
	
	if(self.pers["bots"]["trait"]["nade"] <= 0)
		return;
	
	rand = int(self.pers["bots"]["trait"]["nade"]*6);
	if(rand < 12)
		rand = 12;
	
	rnd = bots_randomInt(rand);
	
	switch(rnd)
	{
		case 0:
			if(level.bots_varLoadoutNade)
			{
				if(self bots_getAmmoCount("claymore_mp"))
				{
					lastWeapon = self bots_getCurrentWeapon();
					self bots_setspawnweapon("claymore_mp");
					self.bots_doing = "nade_fire";
					self thread bots_watchGNadeFire(lastWeapon);
					self thread bots_doNoneOnGNadeAmmo("claymore_mp", lastWeapon);
					self thread bots_forceGNadeFire();
					
					wait 5;
					self bots_setspawnweapon(lastWeapon);
					self.bots_doing = "none";
					self bots_stopShooting();
					self notify("bot_kill_nade");
				}
			}
		break;
		case 1:
			if(level.bots_varLoadoutNade)
			{
				if(self bots_getAmmoCount("frag_grenade_mp"))
				{
					pos = self bots_GetCursorPosition();
					myEye = self getTagOrigin("j_head");
					dis = Distance(myEye, pos);
					if(dis >= level.bots_minNadeDis && dis < 5000.0 && bulletTracePassed(myEye,self.origin+(0.0,0.0,255.0),false,self))
					{
						lastWeapon = self bots_getCurrentWeapon();
						self bots_setspawnweapon("frag_grenade_mp");
						self.bots_doing = "nade_fire";
						self thread bots_watchGNadeFire(lastWeapon);
						self thread bots_doNoneOnGNadeAmmo("frag_grenade_mp", lastWeapon);
						
						self thread bots_forceGNadeAim(pos, dis);
						wait 1;
						self thread bots_forceGNadeFire();
						
						wait 5;
						self bots_setspawnweapon(lastWeapon);
						self.bots_doing = "none";
						self bots_stopShooting();
						self notify("bot_kill_nade");
					}
				}
			}
		break;
		case 2:
			if(level.bots_varLoadoutNade)
			{
				secnade = self bots_tryGetGoodWeap(self bots_getOffhandsName());
				if(isDefined(secnade))
				{
					if(self bots_getAmmoCount(secnade))
					{
						pos = self bots_GetCursorPosition();
						myEye = self getTagOrigin("j_head");
						dis = Distance(myEye, pos);
						if(dis >= level.bots_minNadeDis && dis < 5000.0 && bulletTracePassed(myEye,self.origin+(0.0,0.0,255.0),false,self))
						{
							lastWeapon = self bots_getCurrentWeapon();
							self bots_setspawnweapon(secnade);
							self.bots_Doing = "nade_fire";
							self thread bots_doNoneOnGNadeAmmo(secnade, lastWeapon);
							self thread bots_watchGNadeFire(lastWeapon);
							
							self thread bots_forceGNadeAim(pos, dis);
							wait 1;
								
							self thread bots_forceGNadeFire();
							
							wait 3;
							self bots_setspawnweapon(lastWeapon);
							self.bots_Doing = "none";
							self bots_stopShooting();
							self notify("bot_kill_nade");
						}
					}
				}
			}
		break;
		case 3:
			if(level.bots_varLoadoutNade)
			{
				weap = self bots_tryGetGoodWeap(self bots_getWeaponsGL());
				if(isDefined(weap) && self bots_getAmmoCount(weap))
				{
					pos = self bots_GetCursorPosition();
					myEye = self getTagOrigin("j_head");
					dis = Distance(myEye, pos);
					if(dis >= level.bots_minNadeDis && dis < 5000.0 && bulletTracePassed(myEye,self.origin+(0.0,0.0,255.0),false,self))
					{
						self.bots_Doing = "ftube";
						lastWeapon = self bots_getCurrentWeapon();
						self bots_setspawnweapon(weap);
						self thread bots_doNoneOnGNadeAmmoTube(weap, lastWeapon);
						
						self thread bots_forceGNadeAim(pos, dis, true);
						wait 1;
						
						self thread bots_forceGNadeFire();
						
						wait 5.5;
							
						self bots_setspawnweapon(lastWeapon);
						if(self.bots_doing != "climb")
							self.bots_Doing = "none";
						self bots_stopShooting();
						self notify("bot_kill_nade");
					}
				}
			}
		break;
		case 4:
		case 5:
		case 6:
		case 7:
			if(level.bots_varLoadoutTube)
			{
				weap = self bots_tryGetGoodWeap(self bots_getWeaponsGL());
				if(isDefined(weap) && self bots_getAmmoCount(weap))
				{
					self bots_switchToOff(weap);
				}
			}
		break;
		case 8:
		case 9:
		case 10:
		case 11:
			if(level.bots_varLoadoutTube)
			{
				if(self bots_getAmmoCount("rpg_mp"))
				{
					self bots_switchToOff("rpg_mp");
				}
			}
		break;
	}
}

bots_melee(target)
{
	self endon("bot_reset");
	self endon("death");
	
	if(!level.bots_varLoadoutKnife || !self bots_doingNothing())
		return;
	
	if(target == self)
		return;
	
	if(self bots_GetCurrentWeaponClipAmmo())
	{
		if(self.pers["bots"]["trait"]["knife"] <= 0)
			return;
		
		if(bots_randomInt(self.pers["bots"]["trait"]["knife"]) != 1)
			return;
	}
	
	knife = level.bots_knifeDis;
	
	knife = knife*(getDvarFloat("player_meleeRange")/64.0);
	
	dis = distance(self.origin, target.origin);
	if(dis <= knife)
	{
		wait self.pers["bots"]["skill"]["shootDelay"];
		if(level.bots_varLoadoutKnife && self bots_doingNothing())
		{
			lastWeapon = self bots_getCurrentWeapon();
			self.bots_doing = "knife";
			
			self GiveWeapon(level.bots_animWeapKnife);
			self SetWeaponAmmoClip(level.bots_animWeapKnife, 0);
			self SetWeaponAmmoStock(level.bots_animWeapKnife, 0);
			self setspawnweapon(level.bots_animWeapKnife);
			
			if(knife <= 0)
				knife = 0.1;
			
			if((dis / knife) < 0.333)
				self playSound("melee_swing_small");
			else
				self playSound("melee_swing_ps_large");
		
			wait 0.1;
			
			knife = level.bots_knifeDis;
			
			knife = knife*(getDvarFloat("player_meleeRange")/64.0);
			
			dis = distance(self.origin, target.origin);
			if(isDefined(target) && dis <= knife)
			{
				if(!isDefined(self.lastStand))
				{
					pushOutDir = VectorNormalize((self.origin[0], self.origin[1], 0)-(target.origin[0], target.origin[1], 0));
					pushoutPos = self.origin + (pushOutDir * (60-distance(target.origin,self.origin)));
					self SetOrigin((pushoutPos[0], pushoutPos[1], target.origin[2]));
				}
				
				if(knife <= 0)
					knife = 0.1;
				
				if((dis / knife) > 0.75)
				{
					self playSound("melee_knife_stab");
					self.bots_doing = "knifebig";
					if(!isDefined(self.lastStand))
						self.bots_stance = "stand";
				}
				
				if(randomInt(5))
				{
					if(self bots_isFacingAtTarget(target, self.pers["bots"]["skill"]["perfView"]) && bulletTracePassed( self getTagOrigin( "j_head" ), target.origin, false, target ))
					{
						playFx( level.bots_bloodfx,target.origin + (0.0, 0.0, 30.0) );
						if(isAlive(target))
							target thread [[level.callbackPlayerDamage]](self, self, 135, 0, "MOD_MELEE", lastWeapon, self.origin, self.origin, "none", 0);
						if(randomInt(50))
							self playSound("melee_knife_hit_body");
						else
							self playSound("melee_hit");//cp running :)
					}
				}
				
				if(level.bots_varPlayAim)
					self setplayerangles(VectorToAngles( ( target.origin ) - ( self getTagOrigin( "j_head" ) ) ));
			}
			
			wait 1;
			
			self setspawnweapon(lastWeapon);
			self takeWeapon(level.bots_animWeapKnife);
			
			wait 1;
			self.bots_doing = "none";
		}
	}
}

bots_canSwitch()
{
	return (self bots_doingNothing() && !isDefined(self.lastStand));
}

bots_canTDKS()
{
	return (level.bots_varPlayTDKS && (self.bots_traitRandom == 4 || self bots_getAmmoCount("rpg_mp")));
}

bots_canKillEqu()
{
	return (level.bots_varPlayEqu && self.bots_traitRandom != 2);
}

bots_isGoodToAimAtKS(KS)
{
	if(self bots_isClimbing())
		return false;
	
	return (self bots_isKSGood(KS));
}

bots_isKSGood(KS)
{
	if(!isDefined(ks))
		return false;
	
	return (bulletTracePassed(self getTagOrigin( "j_head" ), ks.origin, false, ks));
}

bots_isGoodToAimAtEqu(equ)
{
	if(self bots_isClimbing())
		return false;
	
	return (self bots_isEquGood(equ));
}

bots_isEquGood(equ)
{
	if(!isDefined(equ))
		return false;
	
	if(bulletTracePassed(self getTagOrigin( "j_head" ), equ.origin + (0, 0, 5), false, equ))
		return true;
	
	return false;
}

bots_isGoodToAimAtPlayer(player)
{
	if(self bots_isClimbing())
		return false;
	
	return (self bots_isPlayerGood(player));
}

bots_isPlayerGood(player)
{
	if(!isDefined(player))
		return false;
	
	if(level.bots_varTarget.size)
		return true;
	
	myEye = self getTagOrigin( "j_head" );
	return (isAlive(player) && (bulletTracePassed(myEye, player getTagOrigin("j_ankle_le"), false, player) || bulletTracePassed(myEye, player getTagOrigin("j_head"), false, player) || bulletTracePassed(myEye, player getTagOrigin("j_ankle_ri"), false, player)));
}

bots_getTargetKillstreak()
{
	if(!isDefined(level.chopper))
		return undefined;
	
	if(level.chopper.currentstate == "leaving" || level.chopper.currentstate == "crashing")
		return undefined;
	
	if(isDefined(level.chopper.owner) && level.chopper.owner == self)
		return undefined;
	
	if(level.chopper.team == self.team && level.teamBased)
		return undefined;
	
	if(!bulletTracePassed( self getTagOrigin( "j_head" ), level.chopper.origin, false, level.chopper ))
		return undefined;
	
	return level.chopper;
}

bots_getTargetEquipment()
{
	grenades = getEntArray( "grenade", "classname" );
	myEye = self getTagOrigin( "j_head" );
	for (i = 0; i < grenades.size; i++)
	{
		grenade = grenades[i];
		
		if(!isDefined(grenade.weaponName) || (grenade.weaponName != "claymore_mp" && grenade.weaponName != "c4_mp"))
			continue;
		if(isDefined(grenade.owner) && grenade.owner == self)
			continue;
		if(grenade.team == self.pers["team"] && level.teamBased)
			continue;
		if(!bulletTracePassed(myEye, grenade.origin + (0.0, 0.0, 5.0), false, grenade))//just so no wallbanging never hitting it
			continue;
		if(!self bots_IsFacingAtTarget(grenade, self.pers["bots"]["skill"]["perfView"]))
			continue;
		
		return grenade;
	}
	
	return undefined;
}

bots_getTargetOnFootPlayer()
{
	if(!level.bots_varTarget.size)
	{
		myEye = self getTagOrigin( "j_head" );
		for(i = 0; i < level.players.size; i++)
		{
			player = level.players[i];
			
			if(!isDefined(player.pers["team"]))
				continue;
			if(!level.bots_varTargetHost && player.pers["bots_isHost"])
				continue;
			if(player == self)
				continue;
			if(level.teamBased && self.pers["team"] == player.pers["team"])
				continue;
			if(player.sessionstate != "playing")
				continue;
			if(!isAlive(player))
				continue;
			dist = distance(myEye, player.origin);
			if(dist > self.pers["bots"]["skill"]["viewDis"])
				continue;
			tarCheck1 = player getTagOrigin( "j_head" );
			tarCheck2 = player getTagOrigin( "j_ankle_le" );
			tarCheck3 = player getTagOrigin( "j_ankle_ri" );
			if((distance(PhysicsTrace( myEye, tarCheck1 ), tarCheck1) > 0.0) && (distance(PhysicsTrace( myEye, tarCheck2 ), tarCheck2) > 0.0) && (distance(PhysicsTrace( myEye, tarCheck3 ), tarCheck3) > 0.0))
				continue;
			if(!bots\bots::bots_SmokeTrace(myEye, player.origin, 300.0))
				continue;
			if(!self bots_IsFacingAtTarget(player, self.pers["bots"]["skill"]["perfView"]) && !self bots_getTurned(player))
				continue;
			
			return player;
		}
	}
	else
	{
		for(i = 0; i < level.players.size; i++)
		{
			player = level.players[i];
			
			if(!isSubStr(player.name, level.bots_varTarget))
				continue;
			
			return player;
		}
	}
	return undefined;
}

bots_AttackedMe(attacker)
{//ty pezbot
	if(!isDefined(self.attackers))
		return false;
	for(i = 0; i < self.attackers.size; i++)
	{
		rat = self.attackers[i];
		
		if(rat != attacker)
			continue;
		
		return true;
	}
	return false;
}

bots_AttackedHim(attacker)
{
	if(!isDefined(attacker.attackers))
		return false;
	for(i = 0; i < attacker.attackers.size; i++)
	{
		rat = attacker.attackers[i];
		
		if(rat != self)
			continue;
		
		return true;
	}
	return false;
}

bots_seen(target)
{
	if(isDefined(self.bots_lastSeen[target getEntityNumber()]))
	{
		if((getTime() - self.bots_lastSeen[target getEntityNumber()]) >= self.pers["bots"]["skill"]["seenTime"])
		{
			self.bots_lastSeen[target getEntityNumber()] = undefined;
			return false;
		}
		else
			return true;
	}
	else
		return false;
}

bots_canHearPlayer(target)
{
	if(target hasPerk("specialty_quieter"))
		return false;
	
	if(lengthsquared( target getVelocity() ) >= 20000 || (target bots_playerIsABot() && target.bots_fMoveSpeed >= 5.0))
	{
		dist = 100.0;
		if(self hasPerk("specialty_parabolic"))
			dist = 200.0;
		
		if(distance(self.origin, target.origin) <= dist)
			return true;
	}
	return false;
}

bots_playerOnUAV(target)
{
	if(isDefined(self.hasRadar) && self.hasRadar && !target hasPerk("specialty_gpsjammer"))
		return true;
		
	if(target.bots_firing && (!level.hardcoreMode || (isDefined(self.hasRadar) && self.hasRadar)) && !isSubStr(target bots_getCurrentWeapon(), "silencer_"))
		return true;
	
	return false;
}

bots_getTurned(player)
{
	if(!self.pers["bots"]["skill"]["base"])
		return false;

	if(self bots_playerOnUAV(player) || bots_canHearPlayer(player) || self bots_AttackedHim(player) || self bots_AttackedMe(player) || self bots_seen(player))
		return true;
	else
		return false;
}

bots_StopShooting()
{
	if(!self bots_CanStopShoot())
	{
		self bots_freezeControls(false);
	}
	else
	{
		self bots_freezeControls(true);
	}
}

bots_CanStopShoot()
{
	if(isDefined(level.bots_canStopShoot[self.bots_doing]))
		return false;
	
	return true;
}

bots_CanShoot()
{
	if(!level.bots_varPlayAttack)
		return false;
	
	if(self.bots_running || self.bots_runDelay)
		return false;
	
	if(isDefined(level.bots_canShoot[self.bots_doing]))
		return false;
	
	return true;
}

bots_ShootWeapon()
{
	if(!self bots_CanShoot())
	{
		self bots_freezeControls(true);
		return;
	}
	
	weapon = self getCurrentWeapon();
	if(isSubStr(weapon, level.bots_animWeapSubStr))
	{
		self takeWeapon(weapon);
		self setspawnweapon(self.bots_weap);
	}
	weapon = self bots_getCurrentWeapon();
	
	if(!isDefined(self.bots_devWalk[weapon]))
	{
		self.bots_devwalk[weapon] = spawnstruct();
		self.bots_devwalk[weapon].isEmpty = false;
		self.bots_devwalk[weapon].clip = self GetWeaponAmmoClip(weapon);
		self.bots_devwalk[weapon].stock = self GetWeaponAmmoStock(weapon);
		self.bots_devWalk[weapon].isReload = isDefined(level.bots_devWalk[weapon]);
	}
	
	if(!self.bots_devWalk[weapon].isReload)
	{
		if(!self bots_GetWeaponAmmoClip(weapon))
			self setWeaponAmmoStock(weapon, self.bots_devWalk[weapon].stock);
		else
			self setWeaponAmmoStock(weapon, 0);
	}
	
	if( isDefined( level.bots_semiAuto[ bots_getBaseWeaponName( weapon ) ] ) )
	{
		if(!self.bots_shootTime)
		{
			self thread bots_shootOnce();
		}
	}
	else
	{
		self bots_freezeControls(false);
	}
}

bots_shootOnce()
{
	self endon("bot_reset");
	self endon("death");
	
	self.bots_shootTime = true;
	
	self bots_freezeControls(false);
	wait 0.15;
	self bots_freezeControls(true);
	theNum = self.pers["bots"]["skill"]["base"]/10;
	
	if(theNum >= 0.75)
		theNum = 0.745;
	if(theNum < 0)
		theNum = 0;
		
	wait 0.75 - theNum;
	self.bots_shootTime = false;
}

bots_isClimbing()
{
	return (isDefined(level.bots_isClimbing[self.bots_doing]));
}

bots_IsStunned()
{
	return (isdefined(self.concussionEndTime) && self.concussionEndTime > gettime());
}

bots_isArtShocked()
{
	return (isDefined(self.beingArtilleryShellshocked) && self.beingArtilleryShellshocked);
}

bots_isShellShocked()
{
	return (self maps\mp\_flashgrenades::isFlashbanged() || self bots_IsStunned() || self bots_isArtShocked());
}

bots_setPlayerAngesReal(Angle,Steps)
{
	myAngle=self getPlayerAngles();
	
	X=(Angle[0]-myAngle[0]);
	while(X > 170.0)
		X=X-360.0;
	while(X < -170.0)
		X=X+360.0;
	X=X/Steps;
	
	Y=(Angle[1]-myAngle[1]);
	while(Y > 180.0)
		Y=Y-360.0;
	while(Y < -180.0)
		Y=Y+360.0;
		
	Y=Y/Steps;
	
	for(i=0;i<Steps;i++)
	{
		newAngle=(myAngle[0]+X,myAngle[1]+Y,0);
		self setPlayerAngles(newAngle);
		myAngle=self getPlayerAngles();
		wait 0.05;
	}
}