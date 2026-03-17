#include <amxmodx>

new ctwin = 0, twin = 0;

public plugin_init() {
	register_plugin("HUD Scores", "1.0", "ToRRent")
	register_event("TeamScore","calc_teamscore","a")
	register_event("DeathMsg", "on_player_death", "a")
	set_task(5.0,"Update_ScoresBoard",_,_,_,"b")
}

public plugin_precache()
{
	precache_sound("buttons/bell1.wav");
}

public calc_teamscore()
{
		new parm[16]
		read_data(1,parm,charsmax(parm))
		if (parm[0] == 'T')
			twin = read_data(2)
		else
			ctwin = read_data(2)
}

// Helper function to generate ASCII bar for round wins (1 char = 1 round)
stock get_win_bar(wins, maxwins)
{
	new bar[32]
	
	// If winlimit is 0 or >= 20, don't show bar
	if (maxwins <= 0 || maxwins >= 20)
	{
		bar[0] = EOS
		return bar
	}
	
	// Bar length = maxwins, each char represents 1 round
	bar[0] = '^0'
	for (new i = 0; i < maxwins; i++)
	{
		if (i < wins)
			formatex(bar[strlen(bar)], charsmax(bar) - strlen(bar), "|")
		else
			formatex(bar[strlen(bar)], charsmax(bar) - strlen(bar), "-")
	}
	return bar
}

public Update_ScoresBoard()
{
	if(get_cvar_num("mp_forcerespawn") > 0) return
	new Players[32], total, i, id
	new fCvar = get_cvar_num("mp_winlimit");

	get_players(Players, total, "c") // Get all players

	// Generate ASCII bars for both teams
	new t_bar[32], ct_bar[32]
	copy(t_bar, charsmax(t_bar), get_win_bar(twin, fCvar))
	copy(ct_bar, charsmax(ct_bar), get_win_bar(ctwin, fCvar))

	for (i=0; i<total; i++)
	{
		id = Players[i]
		if(!is_user_connected(id) || !is_user_alive(id)) continue
		set_dhudmessage(255, 255, 215, 0.12, 0.04, 0, 0.0, 5.2, 0.0, 1.0)
		
		// If bar is empty (winlimit 0 or >= 20), only show scores
		if (strlen(t_bar) == 0)
			show_dhudmessage(id, "CT %i^nTT %i", ctwin, twin)
		else
			show_dhudmessage(id, "CT %i %s ^nTT %i %s^nFirst To %i", ctwin, ct_bar, twin, t_bar, fCvar)
	}
}

public on_player_death()
{
	if(get_cvar_num("mp_forcerespawn") > 0) return

	new killer = read_data(1)
	new victim = read_data(2)
	if (killer != victim && is_user_connected(killer))
		client_cmd(killer, "spk buttons/bell1.wav")
	new Players[32], cts, ts, total, i
	get_players(Players, cts, "ae", "CT")
	get_players(Players, ts, "ae", "TERRORIST")
	get_players(Players, total, "c")

	if (cts < 3 || ts < 3)
	{
		for (i = 0; i < total; i++)
		{
			new id = Players[i]
			// Terrorists alive (red), left of center
			set_dhudmessage(255, 50, 50, 0.48, 0.37, 0, 0.0, 0.5, 0.0, 1.0)
			show_dhudmessage(id, "%i", ts)
			// "vs" (white), center
			set_dhudmessage(255, 255, 255, 0.50, 0.37, 0, 0.0, 0.5, 0.0, 1.0)
			show_dhudmessage(id, "v")
			// CTs alive (blue), right of center
			set_dhudmessage(50, 100, 255, 0.52, 0.37, 0, 0.0, 0.5, 0.0, 1.0)
			show_dhudmessage(id, "%i", cts)
		}
	}
}
