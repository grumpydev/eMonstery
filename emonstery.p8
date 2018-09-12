pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- emonstery
-- by @grumpydev

--debug=true
--show_cpu = true

-- todo:
-- update web player to work with portrait mode properly
-- update web player to make buttons look more like the button graphics in-game

version="v0.12"

states = {}
welcome=1
intro=2
playing=3
dead=4
highscores=5
intro_idiots=6
resume_playing=7
results=8
nextlevel=9
intro_spotlight=10
easteregg=11
intro_grumpmeter=12

-- options
options = { ingame_music = 1 }
total_deaths = 0

-- transition
transition = {}
transition.transitioning = false
transition.current_size = 0
transition.size_delta = 3
transition.min_size = 0
transition.max_size = 512

-- constants
col_radius=4.5
drag = 0.97

-- all our monsters are the same radius, so pre-calc (r1+r2)^2 for collision
col_radius_square = (col_radius+col_radius)*(col_radius+col_radius) 

monster_min_x = 4
monster_min_y = 4
monster_max_x = 124
monster_max_y = 116

max_idiots = 4
max_monster_pairs = 10

--min_gun_x = 30
--max_gun_x = 98
min_gun_x = 4
max_gun_x = 124

pumpkin_sprite = 12
anger_sprite_top = 97
anger_sprite_bottom = 98

monster_types = {}
monster_types.pumpkin = 0
monster_types.moron = 1
monster_types.exec = 2
monster_types.skull = 3
monster_types.stein = 4
monster_types.wolf = 5
monster_types.bat = 6
monster_types.zombie = 7
monster_types.witch = 8
monster_types.ghost = 9
monster_types.vamp = 10
monster_types.devil = 11
monster_types.ogre = 12
monster_types.fluff = 13

animation_types = { reset=0, reverse=1 }

monster_def = { 
	{ type=monster_types.pumpkin, sprites={12,46}, animation_type=animation_types.reset, animation_delay=20, matches=false, idiot=false },
	{ type=monster_types.moron, sprites={141,142,143}, animation_type=animation_types.reverse, animation_delay=50, matches=false, idiot=true },
	{ type=monster_types.exec, sprites={156,157,158,159}, animation_type=animation_types.reset, animation_delay=40, matches=false, idiot=true },
	{ type=monster_types.skull, sprites={13,47,60}, animation_type=animation_types.reverse, animation_delay=30, matches=true, idiot=false },
	{ type=monster_types.stein, sprites={14,61,62}, animation_type=animation_types.reverse, animation_delay=40, matches=true, idiot=false },
	{ type=monster_types.wolf, sprites={15,63,76,77}, animation_type=animation_types.reset, animation_delay=50, matches=true, idiot=false },
	{ type=monster_types.bat, sprites={28,78,79}, animation_type=animation_types.reverse, animation_delay=10, matches=true, idiot=false },
	{ type=monster_types.zombie, sprites={29,92,93}, animation_type=animation_types.reverse, animation_delay=60, matches=true, idiot=false },
	{ type=monster_types.witch, sprites={30,94,95}, animation_type=animation_types.reverse, animation_delay=30, matches=true, idiot=false },
	{ type=monster_types.ghost, sprites={31,108,109}, animation_type=animation_types.reverse, animation_delay=10, matches=true, idiot=false },
	{ type=monster_types.vamp, sprites={44,110}, animation_type=animation_types.reverse, animation_delay=70, matches=true, idiot=false },
	{ type=monster_types.devil, sprites={45,111,124}, animation_type=animation_types.reverse, animation_delay=40, matches=true, idiot=false },
	{ type=monster_types.ogre, sprites={125,126}, animation_type=animation_types.reset, animation_delay=70, matches=true, idiot=false },
	{ type=monster_types.fluff, sprites={127,140}, animation_type=animation_types.reverse, animation_delay=70, matches=true, idiot=false }
}

pi=3.1415
ar=pi/270
a=0
wc=0
tmp = 0

left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

local intro_text = {
	"hi there human, my\n"..
	"name is 'bodge'!\n"..
	"\n"..
	"i have been assigned\n"..
	"as your advisor for\n"..
	"your exciting new\n"..
	"role as an emonstery\n"..
	"relationship synergy\n"..
	"consultant!",

	"it's a little known\n"..
	"fact in the human\n"..
	"world, but halloween\n"..
	"is valentine's day\n"..
	"for monsters!\n"..
	"\n"..
	"here at emonstery we\n"..
	"want to make sure\n"..
	"even the shy, lonely\n"..
	"monsters have\n"..
	"someone to be with\n"..
	"on this special day,\n"..
	"so we've invited a\n"..
	"load of them to our\n"..
	"party!",

	"unfortunately,\n"..
	"because they're shy,\n"..
	"they don't like to \n"..
	"mingle much, but we\n"..
	"can easily fix that\n"..
	"by throwing pumpkins\n"..
	"at them until they\n"..
	"meet their match!\n"..
	"\n"..
	"be careful though,\n"..
	"if you try and match\n"..
	"up different monsters\n"..
	"they might get\n"..
	"grumpy, and grumpy\n"..
	"customers are bad!",

	"use left and right\n"..
	"to move the pumpkin\n"..
	"launcher, and up and\n"..
	"down to change the\n"..
	"angle.\n"..
	"\n"..
	"once you're lined\n"..
	"up, hold \x97 to build\n"..
	"up power, and let go\n"..
	"to fire that pumpkin!\n"..
	"\n"..
	"hold \x8e while aiming\n"..
	"for more precision!\n"..
	"\n"..
	"ready? ok, let's go!\n"
}

intro_idiots_text = {
	"hello again human,\n"..
	"great job so far!\n"..
	"\n"..
	"unfortunately i've\n"..
	"just received word\n"..
	"from my supervisor\n"..
	"that we have some\n"..
	"new 'guests' joining\n"..
	"our parties.\n",

	"these new monsters\n"..
	"are not the type\n"..
	"we would normally\n"..
	"allow in, but they\n"..
	"are stinking rich,\n"..
	"and unfortunately,\n"..
	"even in monster\n"..
	"world, money talks!\n",

	"our new 'friends'\n"..
	"think that everyone\n"..
	"loves them, so will\n"..
	"try and match with\n"..
	"anyone, but in\n"..
	"reality nobody \n"..
	"actually likes them,\n"..
	"so the others will\n"..
	"get grumpy if you\n"..
	"try and match them\n"..
	"with one of these \n"..
	"two!\n",

	"don't worry though,\n"..
	"we don't expect you\n"..
	"to find matches for\n"..
	"them, just try your\n"..
	"best to work around\n"..
	"them and find\n"..
	"matches for everyone\n"..
	"else!\n"..
	"\n"..
	"our new 'friends'\n"..
	"will just do what\n"..
	"they do best - \n"..
	"get in the way!"
 }

intro_spotlight_text = {
	"hi there, it looks\n"..
	"like you're getting\n"..
	"the hang of things\n"..
	"nicely!\n"..
	"\n"..
	"there were a few \n"..
	"raised eyebrows\n"..
	"when we heard we\n"..
	"had our first human\n"..
	"employee at\n"..
	"emonstery, but you\n"..
	"are doing great!\n",

	"our parties have\n"..
	"been such a success\n"..
	"the boss monsters\n"..
	"have hired a\n"..
	"photographer!\n"..
	"\n"..
	"you will see their\n"..
	"spotlight moving\n"..
	"around the dance\n"..
	"floor, if you can\n"..
	"get a match with \n"..
	"both monsters in\n"..
	"the light we will\n"..
	"give you extra\n"..
	"credit!\n"
}

easteregg_text = {
	"oh no, your game is\n"..
	"over!\n"..
	"\n"..
	"not to worry though,\n"..
	"if you want more\n"..
	"lives just click the\n"..
	"like button below!!\n",

	"only kidding!\n"..
	"\n"..
	"imagine that, using\n"..
	"an addictive game\n"..
	"to gain more likes\n"..
	"to get more people\n"..
	"addicted..\n"..
	"\n"..
	"what's next? using\n"..
	"kids to try and get\n"..
	"their parents to \n"..
	"pay for ingame items?\n"..
	"\n"..
	"even monsters draw\n"..
	"the line somewhere!\n"
}

intro_grumpmeter_text = {
	"wow human, you are\n"..
	"doing amazingly\n"..
	"well!\n"..
	"\n"..
	"our parties are\n"..
	"getting pretty \n"..
	"famous in monster\n"..
	"world, and we even\n"..
	"made the front page\n"..
	"of the new dark\n"..
	"times!\n",

	"all this great\n"..
	"press though has\n"..
	"put us under the\n"..
	"spotlight of the \n"..
	"higher up monsters\n"..
	"at emonstery, and\n"..
	"they have raised\n"..
	"concerns about the\n"..
	"amount of badly \n"..
	"matched grumpy\n"..
	"monsters we are \n"..
	"getting.\n",

	"from now on we need\n"..
	"to be careful not\n"..
	"to get on the bad\n"..
	"side of too many\n"..
	"monsters. to help\n"..
	"you out i have\n"..
	"set you up with a\n"..
	"grump-o-meter 2000,\n"..
	"which will show\n"..
	"you how grumpy the\n"..
	"monsters in the\n"..
	"room are - if it \n"..
	"gets too high we\n"..
	"will have to\n"..
	"cancel the party!\n",

	"we will give you a\n"..
	"bit more leeway for\n"..
	"the next few \n"..
	"parties, to give you\n"..
	"a bit more practice,\n"..
	"so make sure you\n"..
	"keep an eye on the\n"..
	"meter!\n"..
	"\n"..
	"good luck!\n"
}

function _init()
	cartdata("emonstery")
	high_score_table.load_scores()

	states[welcome]=createstate("welcome", welcome_init, welcome_update, welcome_draw)
	states[intro]=createstate("intro", create_intro_init(intro_text), create_intro_update(playing), create_intro_draw(nil))
	states[playing]=createstate("playing", playing_init, playing_update, playing_draw)
	states[dead]=createstate("dead", dead_init, dead_update, dead_draw)
	states[highscores]=createstate("highscores", high_score_init, high_score_update, high_score_draw)
	states[intro_idiots]=createstate("intro_idiots", create_intro_init(intro_idiots_text), create_intro_update(resume_playing), create_intro_draw(render_idiots))
	states[resume_playing]=createstate("playing", function() music(8) end, playing_update, playing_draw)
	states[results]=createstate("results", results_init, results_update, results_draw)
	states[nextlevel]=createstate("playing", nextlevel_init, playing_update, playing_draw)
	states[intro_spotlight]=createstate("intro_spotlight", create_intro_init(intro_spotlight_text), create_intro_update(resume_playing), create_intro_draw(nil))
	states[easteregg]=createstate("easteregg", create_intro_init(easteregg_text), create_intro_update(highscores), create_intro_draw(easteregg_draw))
	states[intro_grumpmeter]=createstate("grumpmeter", create_intro_init(intro_grumpmeter_text, intro_grumpmeter_init), create_intro_update(resume_playing), create_intro_draw(intro_grumpmeter_draw))

	randomise_monsters()
	find_idiots()

	register_menus()

	setstate(welcome)	
end

function randomise_monsters()
	for i=1,#monster_def*2 do
		local index1 = flr(rnd(#monster_def-4)+4.5)
		local index2 = flr(rnd(#monster_def-4)+4.5)

		if (index1 != index2) then
			local tmp = monster_def[index1]
			monster_def[index1] = monster_def[index2]
			monster_def[index2] = tmp
		end		
	end
end

function dump_monster_defs()
	local message = ""
	for monster in all(monster_def) do
		message = message..monster.type.."\n"
	end
	? message
end

function register_menus()
	if (options.ingame_music == 1) then
		menuitem(1, "ingame \x8d [on]", toggle_music)
	else
		menuitem(1, "ingame \x8d [off]", toggle_music)
	end
end

function toggle_music()
	options.ingame_music = -options.ingame_music
	register_menus()
	if (state.name == "playing") then
		if (options.ingame_music == 1) then
			music(8)
		else
			music(-1)
		end
	end
end

function createstate(name, init, update, draw)
	state = {}
	state.name = name
	state.init = init
	state.update = wrap(update, core_update)
	state.draw = wrap(draw, core_draw)
	
	return state
end

function setstate(stateid)
	state = states[stateid]

	if (state.init != nil) state.init()

	_update60 = state.update
	_draw = state.draw
end

function wrap(current, next)
	local function wrapper()
		if (not transition.transitioning or transition.direction == 1) current()
		next()
	end

	return wrapper
end

function core_update()
	if(peek(0x5f83)==1) then
		extcmd("pause")
		poke(0x5f83,0)
	end

	transition.update()
end

function core_draw()
	transition.draw()

	if (show_cpu) then
		local debug_text = "cpu: "..flr(stat(1)*100)
		? debug_text, 64-#debug_text*2, 115,11
	end
end

function welcome_init()
	a=0
	lightning = 0
	starting=false
	countdown = 20*60
	music(0)
end

function welcome_update()
	if (lightning > 0) then
		lightning -= 1
	else
		local flash = flr(rnd(50))
		if (flash == 0) lightning = rnd(5)+4
	end

	a+=ar

 	if btn(fire2) then 
	 	starting = true
	end

	if (starting == true and not btn(fire2)) then
		transition.do_transition()

		setstate(intro)
	end

	countdown -= 1
	if (countdown == 0) then
		transition.do_transition()

		setstate(highscores)
	end
end

function draw_house()
	if (lightning > 0) then
		pal(4,7)
		pal(8,10)

		pal(11,7)
		pal(6,10)

		pal(5,1)
	else
		pal(4,0)
		pal(8,0)

		pal(11,1)
		pal(6,9)

		pal(5,13)
	end

	palt(0,false)
	sspr(0,74,63,127,0,0,128,256)
	palt(0,true)

	local credits_string = "by @grumpydev"
	? credits_string, 64-#credits_string*2, 2, 5

	pal(11,11)
	pal(6,6)
	pal(4,4)
	pal(8,8)
	pal(5,5)



end

function welcome_draw()
	cls(7)

	draw_house()

	for i=0, 46 do
		ax = flr(sin(a+(i/100))*10)
		ay = flr(cos(a+(i/70))*5)

		sspr(0, i, 90, 1, 18+ax, 28+i+ay, 90, 5)
	end
	
	? version,108,1,5

	? "press \x97 to start",30,120,6	
end

function playing_init()
	level = 1
	a = 0
	shots = 0
	shake = { power = 0, fade = 0 }
	high_score_table.current_score = 0
	
	if (options.ingame_music == 1) then
		music(8)
	else
		music(-1)
	end

	start_level()
end

function start_level()
	power = 0

	shot_angle=0.75

	gun_x = 64

	local left_over_shots = shots
	shots = max(max(0, 6-level) + 3 + left_over_shots, 6)

	last_hit = shots

	local pumpkin = create_monster(monster_def[1])
	pumpkin.visible = false

	-- all our monsters are the same radius, so pre-calc (r1+r2)^2 for matching
	if (level <= 10) then
		bad_hit_loss = 10
	elseif (level <= 15) then
		bad_hit_loss = 15
	elseif (level <= 20) then
		bad_hit_loss = 20
	else 
		bad_hit_loss = 30
	end
	-- removed different match radius for now, seems to make it way too hard
	match_radius=6
	match_radius_square = (match_radius+match_radius)*(match_radius+match_radius)

	monsters = {}
	add(monsters, pumpkin)
	add_monsters()
	add_idiots()
	bad_hits = {}

	local gun_length_multiplier = 1

	if (level == 1)	gun_length_multiplier = 15
	if (level == 2)	gun_length_multiplier = 5
	if (level == 3)	gun_length_multiplier = 3
	if (level > 3 and level < 10) gun_length_multiplier = 1.5

	gun_length=17*gun_length_multiplier

	level_stats = {
		good_matches = 0,
		bad_matches = 0,
		shots_taken = 0,
		perfect = 0,
		misses = 0,
		spotlight = 0
	}

	spotlight = {
		x = 64+sin(a) * 35,
		y = 64+cos(a) * 35,
		radius = 38,
		visible = (level > 3),
		colour = 14
	}

	grump_meter = {
		current = 0,
		max = get_max_grumpyness(),
		visible = (level >= 10)
	}

	if (level == 4) setstate(intro_spotlight)
	if (level == 6) setstate(intro_idiots)
	if (level == 10) setstate(intro_grumpmeter)
end

function get_max_grumpyness()
	if (level <= 13) return 50
	if (level <= 15) return 40
	return 30
end

function find_idiots()
	idiots = {}
	for def in all(monster_def) do
		if (def.idiot) add(idiots, def)
	end
	assert(#idiots>0, "no idiots found!")
end

function add_monsters()
	randomise_monsters()

	local type = {}
	for i=1,min(level,max_monster_pairs) do
		if (i < #monster_def) then
			type = monster_def[i+3]
		else
			type = monster_def[flr(rnd(#monster_def-4))+4]
		end
		add(monsters, create_monster(type))
		add(monsters, create_monster(type))
	end
end

function add_idiots()
	local min_level = 6
	if (level < min_level) return

	local num_idiots = min(flr((level-min_level+0.5)/2)+1,max_idiots)

	for i=0,num_idiots-1 do
		add(monsters, create_monster(idiots[flr(rnd(#idiots)+1)]))
	end
end

function create_monster(def)
	local monster = {}

	setmetatable(monster, def)
	def.__index = def

	monster.current_sprite = flr(rnd(#def.sprites-1)+1)
	monster.animation_direction = 1
	monster.current_tick = flr(rnd(def.animation_delay))
	monster.visible = true
	monster.angry_counter = 0

	local min_x = monster_min_x
	local min_y = monster_min_y
	local max_x = monster_max_x
	local max_y = monster_max_y

	if (level <= 3) then
		min_x += 20
		min_y += 20
		max_x -= 20
		max_y -= 20
	end

	repeat
		monster.x = rnd(max_x - min_x) + min_x
		monster.y = rnd(max_y - min_x) + min_y
		local redo = too_close_to_existing_monster(monster)
	until (redo == false)

	monster.dx = 0
	monster.dy = 0

	return monster
end

function too_close_to_existing_monster(new_monster)
	for m in all (monsters) do
		if distance(m, new_monster) <= 16 then
			return true
		end
	end
	return false
end

function distance(p0, p1)
	dx=p0.x-p1.x dy=p0.y-p1.y
	return sqrt(dx*dx+dy*dy)
end

function playing_update()
	if (transition.transitioning) return

	if (debug and btnp(fire1)) then
		shots = 0
		level += 1
		start_level()
	end

	local pumpkin = monsters[1]
	local da=0.0016
	local dgx=1
	local dp=0.2

	if (btn(fire1)) then 
		dgx/=2
		da/=8
		dp/=4
	end

	if (btn(down)) shot_angle = max(shot_angle-da, 0.50)
	if (btn(up)) shot_angle = min(shot_angle+da,1)

	if (btn(left)) gun_x = max(gun_x-dgx, min_gun_x)
	if (btn(right)) gun_x = min(gun_x+dgx, max_gun_x)

	if (pumpkin.visible and all_stopped()) then
		pumpkin.visible = false
		
		if (good_hits > 0) then
			shots += 1

			local missed_shots = last_hit - shots

			level_stats.misses += missed_shots
			local multiplier = 100
			if (missed_shots == 0) then
				level_stats.perfect += 1
				multiplier += 10
			end

			high_score_table.add_current_score(multiplier*good_hits)
			high_score_table.add_current_score(50*spotlight_hits)

			last_hit = shots
		end

		high_score_table.add_current_score(-#bad_hits * bad_hit_loss)
		
		if (high_score_table.current_score < 0) high_score_table.current_score = 0

		if (all_gone()) then
			level += 1
			setstate(results)
		end

		if (shots <= 0) then
			dead_reason = "(no more pumpkins!)"

			setstate(dead)
		end
	end

	move_stuff()

	if (not pumpkin.visible and btn(fire2)) then
		power = min(power+dp, 10)
	end

	if (not pumpkin.visible and power > 1 and not btn(fire2)) then
		sfx(2)
		shots-=1
		level_stats.shots_taken += 1
		bad_hits = {}
		good_hits = 0
		spotlight_hits = 0
		pumpkin.x = gun_x
		pumpkin.y = 120
		pumpkin.dx, pumpkin.dy = get_fire_direction(shot_angle, power)
		pumpkin.visible = true
		reset_angry_monsters()
		power = 0
	end

	for monster in all(monsters) do
		update_monster_frame(monster)
	end

	update_spotlight()

	a+=0.017/10
	count_down_angry_monsters()
end

function update_spotlight()
	if (not spotlight.visible) return

	spotlight.x = 64+sin(a) * 35
	spotlight.y = 64+cos(a) * 35
end

function update_monster_frame(monster)
	monster.current_tick += 1

	if (monster.current_tick % monster.animation_delay == 0) then 
		monster.current_sprite += monster.animation_direction
		if (monster.current_sprite <= 0) then 
			if (monster.animation_type == animation_types.reset) monster.current_sprite = #monster.sprites
			if (monster.animation_type == animation_types.reverse) then
				monster.animation_direction = -monster.animation_direction
				monster.current_sprite = min(2,#monster.sprites)
			end
		end

		if (monster.current_sprite > #monster.sprites) then 
			if (monster.animation_type == animation_types.reset) monster.current_sprite = 1
			if (monster.animation_type == animation_types.reverse) then
				monster.animation_direction = -monster.animation_direction
				monster.current_sprite = max(#monster.sprites-1, 1)
			end
		end
	end
end

function all_stopped()
	for monster in all(monsters) do
		if (monster.dx != 0 or monster.dy != 0) return false
	end

	return true
end

function playing_draw()
	cls()
	draw_dance_floor()

	shake_screen()

	render_hud()

	line(gun_x,120,cos(shot_angle)*gun_length+gun_x,120-sin(shot_angle)*gun_length,9)

	foreach(monsters, draw_monster)
	foreach(monsters, show_anger)

	rect(1,121,23,126,0)
	rectfill(2, 122, power*2+2, 125, get_power_colour())
	spr(pumpkin_sprite,gun_x-4,119)

	if (debug) then
		local debug_string = "last hit: "..last_hit.." missed shots: "..max(last_hit - shots, 1)
		? debug_string, 64-#debug_string*2, 64, 8
	end
end

function get_power_colour()
	if (power > 8) return 8
	if (power > 4) return 9
	return 11
end

function render_hud()

	local shots_text = ""..shots

	sspr(96,0,8,8,126-#shots_text*4-8,119)
	
	? shots_text, 128-#shots_text*4, 122,0
	? shots_text, 127-#shots_text*4, 121,11

	local score_text = "score: "..high_score_table.get_current_score_text()
	? score_text, 128-#score_text*4, 2,0
	? score_text, 127-#score_text*4, 1,11

	? "level: "..level,2,2,0
	? "level: "..level,1,1,11

	render_grump_meter()
end

function render_grump_meter()
	if (not grump_meter.visible) return;

	local grump_meter_height = 20
	local grump_level = flr(grump_meter_height * grump_meter.current / grump_meter.max)

	rectfill(122,119,126,119-grump_meter_height,7)
	sspr(9,49,5,4,122,119-grump_meter_height/2-2)
	rect(122,119,126,119-grump_meter_height,0)
	rectfill(123, 118, 125, 118-grump_level, get_grump_meter_color())
end

function get_grump_meter_color()
	local current_ratio = (grump_meter.current / grump_meter.max)

	if (current_ratio > 0.6) return 8
	if (current_ratio > 0.3) return 9
	return 11
end

function draw_dance_floor()
	cls(2)

	fillp(0xde7b)
	rectfill(min_gun_x-4,123,max_gun_x+3,127,37)
	fillp(0)
	rect(min_gun_x-4,123,max_gun_x+3,129,5)

	if (spotlight.visible) circfill(spotlight.x, spotlight.y, spotlight.radius, spotlight.colour)
end

function set_angry(monster)
	level_stats.bad_matches += 1
	grump_meter.current += 1
	monster.angry_counter = 3*60

	if (grump_meter.visible and grump_meter.current >= grump_meter.max) then
		dead_reason = "(too much grumpyness!)"
		setstate(dead)
	end
end

function show_anger(monster)
	if (monster.angry_counter == 0 or monster.visible == false) return
	
	local sprite,x,y,fx=anger_sprite_top,monster.x+4,monster.y-12,false

	if (x > 64) then
		x = monster.x-12
		fx = true
	end

	if (y < 12) then
		y = monster.y+4
		sprite = anger_sprite_bottom
	end

	spr(sprite,x, y,1,1,fx,false)
end

function count_down_angry_monsters()
	for monster in all(monsters) do
		if (monster.angry_counter > 0) monster.angry_counter -= 1
	end
end

function reset_angry_monsters()
	for monster in all(monsters) do
		monster.angry_counter = 0
	end
end

function add_shake(power, fade)
	shake.power = power
	shake.fade = fade
end

function shake_screen()
	if (shake.power <= 0)  then
		camera()
		return
	end

  	local shakex=(16-rnd(32)) * shake.power
 	local shakey=(16-rnd(32)) * shake.power

	camera(shakex,shakey)
 
 	shake.power *= shake.fade

 	if (shake.power < 0.05) shake.power=0
end

function get_fire_direction(angle, speed)
    return cos(angle)*speed,-sin(angle)*speed
end

function draw_monster(monster)
	if (monster.visible) then
		if (debug) then
			circfill(monster.x, monster.y, match_radius, 3)
			circfill(monster.x, monster.y, col_radius, 1)
		end
		spr(monster.sprites[monster.current_sprite], monster.x-4, monster.y-4)
	end
end

function check_pair_smash(monster1, monster2)
	-- maths like this has long since left my brain, luckily there's websites like this:
	-- https://ericleong.me/research/circle-circle/ :)

	-- if we're not visible we don't care
	if (not monster1.visible or not monster2.visible) return

	-- if we aren't moving, we can't hit anything
	if (monster1.dx == 0 and monster1.dy == 0 and monster2.dx == 0 and monster2.dy == 0) return

	local dx = monster1.x-monster2.x
	local dy = monster1.y-monster2.y
	local sdist = dx*dx+dy*dy
	
	if sdist <= match_radius_square and sdist > 0 then
		if monster1.type == monster2.type and monster1.matches and monster2.matches then
			monster1.visible = false
			monster2.visible = false
			monster1.dx = 0
			monster1.dy = 0
			monster2.dx = 0
			monster2.dy = 0

			add_shake(0.5, 0.7)

			level_stats.good_matches += 1
			good_hits += 1
			grump_meter.current = max(0,grump_meter.current - 5)

			if (is_in_spotlight(monster1) and is_in_spotlight(monster2)) then
				sfx(19)

				spotlight_hits += 1
				level_stats.spotlight += 1
			else
				sfx(4)
			end
		end
	end

	if sdist <= col_radius_square and sdist > 0 then
		sfx(1)

		local dist_moved = sqrt(sdist)
		local nx = dx/dist_moved
		local ny = dy/dist_moved

		local p = 2 * (monster1.dx * nx + monster1.dy * ny - monster2.dx * nx - monster2.dy * ny) / 2

		monster1.dx = monster1.dx - p * nx
		monster1.dy = monster1.dy - p * ny
		monster2.dx = monster2.dx + p * nx
		monster2.dy = monster2.dy + p * ny

		local midpoint_x = (monster1.x + monster2.x) / 2; 
		local midpoint_y = (monster1.y + monster2.y) / 2;

		-- need to kick the monsters out of each others way, otherwise we can end up being stuck together
		-- kick them slightly further than is accurate (dist_moved*0.9) to give them a bit of "bounce"
		monster1.x = flr((midpoint_x + col_radius * (monster1.x - monster2.x) / (dist_moved*0.8)) + 0.5)
		monster1.y = flr((midpoint_y + col_radius * (monster1.y - monster2.y) / (dist_moved*0.8)) + 0.5)
		monster2.x = flr((midpoint_x + col_radius * (monster2.x - monster1.x) / (dist_moved*0.8)) + 0.5)
		monster2.y = flr((midpoint_y + col_radius * (monster2.y - monster1.y) / (dist_moved*0.8)) + 0.5)

		if (monster1.type != monster_types.pumpkin and monster2.type != monster_types.pumpkin) and ((monster1.idiot or monster2.idiot) or (monster1.type != monster2.type)) then
			if not already_bad_hit(monster1, monster2) then
				local hit_object = { monster1 = monster1, monster2 = monster2 }
				add(bad_hits, hit_object)
				set_angry(monster1)
				set_angry(monster2)
			end
		end
	end
end

function is_in_spotlight(monster)
	if (not spotlight.visible) return false

	local dx = spotlight.x - monster.x
	local dy = spotlight.y - monster.y

	local ds = dx*dx+dy*dy
	
	local rs = abs(spotlight.radius - col_radius)
	local rss = rs*rs

	return (ds < rss)
end

function check_smash(monster_number)
	local monster1 = monsters[monster_number]

	if (not monster1.visible) return

	-- if we move our full distance each time we can pass over the edge
	-- of another object before detecting the collision, which ends up with
	-- shots where you clip another object actually sending that object backwards.
	-- we normalise the vector and move that amount each time, and check collisiosn etc.
	-- until we've moved the correct amount
	local norm = flr(sqrt(monster1.dx*monster1.dx+monster1.dy*monster1.dy)+0.5)
	local passes = mid(1, norm, 10)

	local ddx = monster1.dx/passes
	local ddy = monster1.dy/passes

	for i=1,passes do
		monster1.oldx = x
		monster1.oldy = y

		monster1.x += ddx
		monster1.y += ddy

		if (monster1.x >= monster_max_x and monster1.dx > 0) or (monster1.x <= monster_min_x and monster1.dx < 0) then
			sfx(1)
			monster1.dx = -monster1.dx
			ddx = -ddx
		end

		if (monster1.y >= monster_max_y and monster1.dy > 0) or (monster1.y <= monster_min_y and monster1.dy < 0) then
			sfx(1)
			monster1.dy = -monster1.dy
			ddy = -ddy
		end

		for monster2 in all(get_potential_hits(monster_number, monster1)) do
			check_pair_smash(monster1, monster2)
		end
	end
end

function get_potential_hits(monster_number, monster)
	local potentials = {}

	for j=monster_number+1,#monsters do
		add(potentials, monsters[j])
	end

	return potentials
end

function smash_stuff()
	for i=1,#monsters do
		check_smash(i)
	end
end

function already_bad_hit(monster1, monster2)
	for hit in all(bad_hits) do
		if (hit.monster1 == monster1 and hit.monster2 == monster2) or (hit.monster1 == monster2 and hit.monster2 == monster1) then
			return true
		end
	end
end

function all_gone()
	for monster in all(monsters) do
		if (monster.matches and monster.visible) return false
	end

	return true
end

function move_stuff()
	smash_stuff()

	for monster in all(monsters) do
		monster.dx *= drag
		monster.dy *= drag

		if (abs(monster.dx) < 0.01 and abs(monster.dy) < 0.01) then
			monster.dx = 0
			monster.dy = 0
		end
	end
end

function dead_init()
	dead_time = 0
	total_deaths += 1
end

function dead_update()
	dead_time += 1

	if (dead_time >= 60*5) then
		transition.do_transition()

		local has_high_score = high_score_table.check_current_score()

		if (total_deaths == 3) then
			setstate(easteregg)
		else
			setstate(highscores)
		end
	end
end

function dead_draw()
	local game_over_text = "game over"

	rectfill(0,54,127,70,orange)

	? game_over_text,64-(4*#game_over_text)/2,56,0
	? dead_reason,64-(4*#dead_reason)/2,64,0
end

function transition:do_transition()
	transition.current_size = 0
	transition.size_delta = 12
	transition.transitioning = true
	transition.direction = 0
end

function transition:update()
	if (transition.transitioning) then
		transition.current_size += transition.size_delta

		if (transition.current_size > transition.max_size) then
			transition.size_delta = -transition.size_delta
			transition.direction = 1
		end

		if (transition.current_size <= transition.min_size) then
			transition.transitioning = false
		end
	end
end

function transition:draw()
	if (not transition.transitioning) return

	local current_position = 64-transition.current_size/2

	sspr(80,84,48,44,current_position,current_position, transition.current_size, transition.current_size)
end


function high_score_init()
	if (score_entry.entering) then
		music(60)
	else
		music(-1)
	end
	starting = false
	high_score_table_countdown = 10*60
end

function high_score_update()
	if (not score_entry.entering) then
		music(-1, 500)

		if btnp(fire2) then 
			starting = true
		end

		if (starting == true and not btn(fire2)) then
			transition.do_transition()

			setstate(intro)
		end

		high_score_table_countdown -= 1
		if (high_score_table_countdown == 0) then
			transition.do_transition()
			setstate(welcome)
		end
	end
	high_score_table.update()
end

function high_score_draw()
	cls()
	high_score_table.draw()
	if (not score_entry.entering) then
		? "press \x97 to start",30,120,6	
	end
end

function create_intro_init(intro_texts, next)
	return function()
		music(-1)
		eyes_closed = false
		mouth_open = false
		intro_counter = 0
		current_text = ""
		talking = false
		final_wait = 0

		fns = { }
		for text in all(intro_texts) do
			add(fns, cocreate(function() show_text(text) end))
			add(fns, cocreate(function() pause_for(5) end))
		end

		current_fn = 1

		if (next != nil) next()
	end
end

function create_intro_update(next_state)
	return function()
		if (transition.transitioning) return

		coresume(fns[current_fn])
		if (costatus(fns[current_fn]) == "dead") then
			current_fn += 1
			if (current_fn > #fns) then
				transition.do_transition()
				setstate(next_state)
			end
		end

		intro_counter += 1

		if (intro_counter % 10 == 0) mouth_open = not mouth_open
		if (intro_counter % 50 == 0 and not eyes_closed) then
			eyes_closed = not eyes_closed
		else
			if (intro_counter % 30 == 0 and eyes_closed) eyes_closed = not eyes_closed
		end
	end
end

function create_intro_draw(next)
	return function()
		cls(2)
		rectfill(36,4,125,100,7)
		pset(36,4,2)
		pset(125,4,2)
		pset(36,100,2)
		pset(125,100,2)
		spr(96,36,100)
		local base_x, base_y = 2,93

		render_boss(base_x, base_y)

		? current_text,40,8,1
		? "press \x97 to skip", 51, 110, 14

		if (next != nil) next()
	end
end

function pause_for(delay_in_seconds)
	current_delay_count = 0

	while current_delay_count < delay_in_seconds*60 do
		if (btnp(fire2)) then
			break
		end
		current_delay_count += 1
		yield()
	end
end

function show_text(text)
		current_text = ""
		last_character = ""
		talking = true
		wait_counter = 0

 		for i=1, #text do
			local pause = 0.05 * 60
			talking = true
			if (last_character == ",") pause = 0.075 * 60
			if (last_character == "!" or last_character == ".") then
				pause = 2 * 60
				talking = false
			end

			while (wait_counter < pause) do
			 	wait_counter += 1

				if (btnp(fire2)) then
					current_text = text
					break
				end
			  	yield()
			end

			wait_counter = 0
			last_character = sub(text,i,i)
 			current_text = sub(text,1,i)
 			if (btnp(fire2)) then
 				current_text = text
 				break
 			end
 			yield()
 		end
 	
 	talking=false
end

function render_boss(base_x, base_y)
	sspr(64,49,32,32,base_x,base_y)

	if (eyes_closed) sspr(42,56,21,5,base_x+5,base_y+11)
	if (talking) then
		if (mouth_open) sspr(50,49,14,7,base_x+9,base_y+20)
	if (stat(19) != 3) sfx(3,3)
	else 
		sfx(-1,3)
	end
end

function render_idiots()
	if (idiot1 == nil) idiot1 = create_monster(monster_def[2])
	if (idiot2 == nil) idiot2 = create_monster(monster_def[3])

	update_monster_frame(idiot1)
	update_monster_frame(idiot2)

	spr(idiot1.sprites[idiot1.current_sprite], 14, 35)
	spr(idiot2.sprites[idiot1.current_sprite], 14, 51)
end

function results_init()
	results_counter = 0

	add_shake(4, 0.7)
	
	sfx(32)
end

function results_update()
	results_counter += 1

	if (results_counter >= 10*60 or btnp(fire2)) then
		setstate(nextlevel)
	end
end

function results_draw()
	shake_screen()

	cls(8)
	sspr(80,80,48,48,16,16, 95, 95)

	centre_text("level complete!", 64, 34, 7)
	centre_text("shots: "..level_stats.shots_taken, 64, 46, 7)
	centre_text("remaining: "..shots, 64, 53, 7)
	centre_text("perfect: "..level_stats.perfect, 64, 60, 7)
	centre_text("missed: "..level_stats.misses, 64, 67, 7)
	if (spotlight.visible) then
		centre_text("photos: "..level_stats.spotlight, 64, 74, 7)
	else
		centre_text("matches: "..level_stats.good_matches, 64, 74, 7)
	end

	centre_text("grumpy: "..level_stats.bad_matches, 64, 81, 7)

	centre_text("press \x97 to continue", 64, 120, 14)
end

function centre_text(text, x, y, c)
	? text,x-#text*2+1,y+1, 0
	? text,x-#text*2,y, c
end

function nextlevel_init()
	start_level()
	transition.do_transition()
end

function easteregg_draw()
	if (#current_text >= 104 and current_fn == 1) sspr(0,58,32,16, 80-16,96-16)
end	

function intro_grumpmeter_init()
	demo_grumpmeter_d = 0.5
	demo_grumpmeter_current = 0
end

function intro_grumpmeter_draw()
	demo_grumpmeter_current += demo_grumpmeter_d
	if (demo_grumpmeter_current >= 28 or demo_grumpmeter_current <= 0) demo_grumpmeter_d = -demo_grumpmeter_d

	local grump_meter_height = 20
	local grump_level = flr(grump_meter_height * demo_grumpmeter_current / 30)

	rectfill(15,55,19,55-grump_meter_height,7)
	sspr(9,49,5,4,15,55-grump_meter_height/2-2)
	rect(15,55,19,55-grump_meter_height,0)
	rectfill(16, 54, 18, 54-grump_level, get_intro_grump_meter_color())
end

function get_intro_grump_meter_color()
	local current_ratio = (demo_grumpmeter_current / 28)

	if (current_ratio > 0.6) return 8
	if (current_ratio > 0.3) return 9
	return 11
end

-->8
-- high score code
high_score_table = { magic_number = 42, pad_digits = 8, base_address=0, a=0, current_score = 0 }
high_score_table.characters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " " }
score_entry = { entering = false, entry_number=1, entry_character=1, cycle_colours={10,9,8,14}, current_colour=1, cycle_count=0 }

high_score_table.scores = {}

function high_score_table.update()
	if (score_entry.entering) then
		score_entry.cycle_count += 1

		if (score_entry.cycle_count > 5) then
			score_entry.cycle_count = 0
			score_entry.current_colour += 1
			if (score_entry.current_colour > #score_entry.cycle_colours) score_entry.current_colour=1
		end

		if (btnp(up)) then
			score_entry.characters[score_entry.entry_character] += 1
			if (score_entry.characters[score_entry.entry_character] > #high_score_table.characters) score_entry.characters[score_entry.entry_character] = 1
		end

		if (btnp(down)) then
			score_entry.characters[score_entry.entry_character] -= 1
			if (score_entry.characters[score_entry.entry_character] < 1) score_entry.characters[score_entry.entry_character] = #high_score_table.characters
		end

		if (btnp(right)) score_entry.entry_character = min(3, score_entry.entry_character+1)
		if (btnp(left)) score_entry.entry_character = max(1, score_entry.entry_character-1)

		if (btnp(fire2)) then
			high_score_table.scores[score_entry.entry_number].name = high_score_table.array_to_string(score_entry.characters)
			score_entry.entering = false
			high_score_table.save_scores()
		end
	end

	high_score_table.a += 0.0157
end

function high_score_table.draw()
	local title_text = "high scores"
	? title_text, 64-#title_text*2, 10, 8

	for i=0, #high_score_table.scores-1 do
		local score = high_score_table.scores[i+1]
		local score_name = score.name
		local score_c = 8

		if (score_entry.entering and score_entry.entry_number == i+1) then
			score_name = high_score_table.array_to_string(score_entry.characters)
			score_c = score_entry.cycle_colours[score_entry.current_colour]
		end

		local score_text = score_name.."...."..high_score_table.get_score_text(score.score)
		local score_x = 64-#score_text*2
		if (not score_entry.entering) score_x += sin(high_score_table.a+i/10)*5
		 
		? score_text, score_x, 8*i+30, score_c

		if (score_entry.entering and score_entry.entry_number == i+1) then
			local start_x = score_x+(score_entry.entry_character-1)*4
			line (start_x, 8*i+36, start_x+2, 8*i+36,score_c)
		end
	end
end

-- adding scores using bit shifting to allow for higher values
-- taken from this thread https://www.lexaloffle.com/bbs/?tid=3577
function high_score_table.add_current_score(addition)
	high_score_table.current_score += shr(addition, 16)
end

function high_score_table.get_current_score_text()
	return high_score_table.get_score_text(high_score_table.current_score)
end

function high_score_table.check_current_score()
	for i=1,10 do
		if (high_score_table.current_score > high_score_table.scores[i].score) then
			for j=10,i+1,-1 do
				high_score_table.scores[j] = high_score_table.scores[j-1]
			end
			score_entry.entering = true
			score_entry.entry_number = i
			score_entry.entry_character = 1
			score_entry.characters = {1,1,1}
			high_score_table.scores[i] = {name="aaa", score=high_score_table.current_score}
			return true
		end
	end
	return false
end

function high_score_table.load_scores()
	local value = dget(high_score_table.base_address)

	if (value != high_score_table.magic_number) then
		for i=1,10 do
			high_score_table.scores[i] = { name = "aaa", score = shr((11000-i*1000),16)}
		end
		return false
	end

	local current_address = high_score_table.base_address + 1
	high_score_table.scores = { }
	for i=1,10 do
		local digits = ""
		score = dget(current_address)
		digits = digits..high_score_table.int_to_char(dget(current_address+1))
		digits = digits..high_score_table.int_to_char(dget(current_address+2))
		digits = digits..high_score_table.int_to_char(dget(current_address+3))
		high_score_table.scores[i] = { name=digits, score=score }
		current_address += 4
	end
	
	return true
end

function high_score_table.save_scores()
	dset(high_score_table.base_address, high_score_table.magic_number)

	local current_address = high_score_table.base_address + 1
	for i=1,10 do
		dset(current_address, high_score_table.scores[i].score)

		dset(current_address+1, high_score_table.char_to_int(sub(high_score_table.scores[i].name,1,1)))
		dset(current_address+2, high_score_table.char_to_int(sub(high_score_table.scores[i].name,2,2)))
		dset(current_address+3, high_score_table.char_to_int(sub(high_score_table.scores[i].name,3,3)))

		current_address += 4
	end
end

function high_score_table.get_score_text(score_value)
	if (score_value == nil) return "0"

	local s = ""
    local v = abs(score_value)
    repeat
      s = shl(v % 0x0.000a, 16)..s
      v /= 10
    until (v==0)

	for p=1,high_score_table.pad_digits-#s do
		s = "0"..s
	end

    if (score_value<0)  s = "-"..s
    return s 
end

function high_score_table.char_to_int(char)
	for k,v in pairs(high_score_table.characters) do
		if (v == char) return k
	end

	return -1
end

function high_score_table.int_to_char(int)
	for k,v in pairs(high_score_table.characters) do
		if (k == int) return v
	end

	return ""
end

function high_score_table.array_to_string(array)
	local string = ""
	for i=1,#array do
		string = string..high_score_table.int_to_char(array[i])
	end
	return string
end


__gfx__
000000000000000000000000000eeeeeeeeeeee00000000ffffffffffff000000000000000000000000000000000000000003b00067777600b3333b004900940
0000000000000000000000000eeeeeeeeeeeeeeee0000ffffffffffffffff000000000000000000000000000000000000003b00067777776b333333b04444440
000000000000000000000000eeeeeeeeeeeeeeeeee00ffffffffffffffffff00000000000000000000000000000000000a9999907c77c7773833833347744774
00000000000000000000000eeeeeeeeeeeeeeeeeeeeffffffffffffffffffff000000000000000000000000000000000a9449449777777773333333347144714
00000000000000000000000eeeeeeeeeeeeeeeeeeeeffffffffffffffffffff00000000000000000000000000000000099499949077777700333333044499444
0000000000000000000000ddeeeeeeeeeeeeeeeeeeccffffffffffffffffff990000000000000000000000000000000099999999007517005034130544444444
000000000000000000000ddddeeeeeeeeeeeeeeeeccccffffffffffffffff999900000000000000000000000000000009949494a007157005531435544676744
00000000000000000000ddddddeeeeeeeeeeeeeeccccccffffffffffffff999999000000000000000000000000000000099494a0007777005033330504444440
00000000000000000000dddddddeeeeeeeeeeeeccccccccffffffffffff999999900000000000000000000000000000000500500094444900005555000067000
0000000000000000000dddddddddeeeeeeeeeeccccccccccffffffffff9999999990000000000000000000000000000050055005944444490055550000677700
0000000000000000000ddddddddddeeeeeeeeccccccccccccffffffff999999999900000000000000000000000000000050aa0504b4454440555555006177170
0000000000000000000dddddddddddeeeeeeccccccccccccccffffff999999999990000000000000000000000000000000555500444444440555555006177170
0000000000000000000ddddddddddddeeeeccccccccccccccccffff9999999999990000000000000000000000000000000555500044444400999999067777777
0000000000000000000dddddddddddddeeccccccccccccccccccff99999999999990000000000000000000000000000000555500004a1400dddddddd61777717
0000000000000000000ddddddddddddddcccccccccccccccccccc9999999999999900000000000000000000000000000044554400041a4000bcbbcb067111177
0000000000000000000ddddddddddddd33cccccccccccccccccc2299999999999990000000000000000000000000000094000049004444000bbbbbb067777777
0000000000000000000dddddddddddd3333cccccccccccccccc2222999999999999000000000000000000000000000000555555004000040003b000006777760
0000000000000000000ddddddddddd333333cccccccccccccc222222999999999990000000000000000000000000000056555565048888400003b00067777776
0000000000000000000dddddddddd33333333cccccccccccc2222222299999999990000000000000000000000000000066655666888888880a99999077c77c77
0000000000000000000ddddddddd3333333333cccccccccc22222222229999999990000000000000000000000000000066b66b668a88a888a944944977777777
00000000000000000000ddddddd333333333333cccccccc222222222222999999900000000000000000000000000000066666666088888809949994907777770
00000000000000000000dddddd33333333333333cccccc2222222222222299999900000000000000000000000000000066788766008888009999999900715700
000000000000000000000dddd3333333333333333cccc22222222222222229999000000000000000000000000000000066888866008998009949494a00751700
0000000000000000000000dd333333333333333333cc22222222222222222299000000000000000000000000000000000666666000888800099494a000777700
000000000000000000000003333333333333333333322222222222222222222000000000000000000000000000000000067777600b3333b00b3333b049000094
00000000000000000000000033333333333333333311222222222222222222000000000000000000000000000000000067777776b333333bb333333b04444440
000000000000000000000000033333333333333331111222222222222222200000000000000000000000000000000000777c77c7338338333338338347744774
00000000000000000000000000333333333333331111112222222222222200000000000000000000000000000000000077777777333333333333333341744174
00000000000888880008888800033333333333311111111222222222222880000000000000000000000000000000000007777770033333300333333044499444
00000000000888885008888850003333333333111111111122222222228885000000000000000000000000000000000000751700503143055034130544444444
00000000000888885008888850000333333331111111111112222222208885000000000000000000000000000000000000715700553413555531435544676744
00888888000888885008888850008888833318888888811118888882088888800888888000888888888000088800000000777700503333055033330504444440
08888888800888888088888850088888888118888888881188888888088888858888888800888888888800888850000004900940490000940050050000500500
08885588850888888588888850888878888518888588885888858888508885558885588850888858588850888550000004444440044444400005500000055000
8888508885088888858888885088879788881888551888588888155550888508888508885088855058885088850000004174417447144714000aa000000aa000
88888888880888888888588858888919888858885118885188888880008885088888888880888500088888888500000047744774477447745555555500555500
88888888885888588888588858888919888858885118885118888888008885088888888885888500008888885500000044499444444994440055550005555550
88885555555888588888588850888797888858885118885111558888508885088885555555888500008888885000000044444444444444440055550050555505
08888088800888588888588850888878888558885118885888800888508885008888088800888500008888885000000044676744446767440445544004455440
08888888850888588885588850088888885508885118885188888888508888808888888850888500000888855000000004444440044444409400004994000049
00888888550888508885088850008888855008885118885008888885500888850888888550888500000888850000000009444490094444900005500005555000
00055555500055500555005550000555550000555111555000555555000055550055555500055500000888850000000094444449944444490055550000555500
00000000000000000000000000000000000000000111100000000000000000000000000000000000008888550000000044b44544444b44540555555005555550
00000000000000000000000000000000000000000011000000000000000000000000000000000000888888500000000044444444444444440555555005555550
00000000000000000000000000000000000000000000000000000000000000000000000000000000088885500000000004444440044444400999999009999990
0000000000000000000000000000000000000000000000000000000000000000000000000000000000555500000000000041a400004a1400dddddddddddddddd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004a14000041a4000bbbbbb00bcbbcb0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444400004444000bcbbcb00bbbbbb0
00007777006770006700000000000000000000000000000000000000000000000000000000000000000000000000000000067000000670000555555004000040
00007777067877000670000000000000000000000000000000555775557755550888888888888888888888888888888000677700006777005655556504888840
00007770067877000067700000000000000000000000000000555775557755558888888888888888888888888888888806177670061776706665566688888888
00077770067777000678770000000000000000000000000000555555555555558822222222222222222222222222228806177170061776706636636688a88a88
00077700067877000678770000000000000000000000000000555555555555558822222222222222222222222222228867777777677777776666666608888880
00777000007770000677770000000000000000000000000000555555555555558822222222223333333322222222228861777717617777176666666600888800
0777000006700000067877000000000000000000000000000055778858877555882222222233b333333333222222228867188177671881776678876600899800
770000006700000000777000000000000000000000000000000577888887755088222222233b3333333333322222228867777777677887770666666000888800
00000000000000000000000000000000000000000008888888800008888888808822222233b33333333333332222228804000040040000400400004000ddcc00
0000000000000000000000000000000000000000008833333388008833333388882222233b33333333333333322222880488884004333340043333400dccccc0
0dddddddddddddddddddddddddddddd00000000000833333333888833333333888222223b33333333333333332222288888888880373373003733730dccccccc
d666666666666666666666666666666d00000000008bbbbbbbb8888bbbbbbbb888222223333333333333333332222288888a88a83783387337833873c77cc77c
d6666666d6666666666666666666666d0000000000883333338800883333338888222288888888333388888888222288088888803333333333333333c17cc17c
d666666d6d666666666666666666666d0000000000088888888000088888888088222887777778833887777778822288008888003161161331111113cccccccc
d666666d6d666666666666666666666d00000000000000000000000000000000882228777c11778888777c11778222880089980033333333316116130cc1ccc0
d666666d6d666661666616166161116d000000000000000000000000000000008822287771c17788887771c17782228800888800033333300333333000cccc00
d666666d6d666661666616161661666d000000000000000000000000000000008822288771117883388771117882228800ddcc00000aaaaa00aaaa00aaaaa000
d61111d66dddd661666616161661666d00000000000000000000000000000000882222888888883333888888882222880dccccc000aaaaa00aaaaaa00aaaaa00
d61111666666d661666616116661166d0000000000000000000000000000000088222223333333333333333332222288dccccccc0a9999a00a9999a00a9999a0
d6111166666d6661666616161661666d0000000000000000000000000000000088222223333333333333333332222288c77cc77c99c99c9999c99c9999c99c99
d61171666666d661666616166161666d0000000000000000000000000000000088222223333333333333333332222288c71cc71c099999900999999009999990
d6611166666d6661111616166161116d0000000000000000000000000000000088222223333333333333333332222288cccccccc094999900994999009994990
d66611d66666d666666666666666666d00000000000000000000000000000000882222233555775557755553322222880ccc1cc0009999000099990000999900
d666666ddddd6666666666666666666d000000000000000000000000000000008822222335557755577555533222228800cccc00557887555578875555788755
d666666666666666666666666666666d000000000000000000000000000000008822222335555555555555533222228804444440044444400444444004444440
0dddddddddddddddddddddddddddddd000000000000000000000000000000000882222233557788588775553322222884ffffff44ffffff44ffffff44ffffff4
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000882222233357788888775533322222884f7777f44f7777f44fb7b7f44f7b7bf4
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000882222233333333333333333322222886f7b7bf66fb7b7f66f7777f66f7777f6
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000088222223333333333333333332222288ffffffffffffffffffffffffffffffff
bbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000088222223333333333333333332222288ff7777ffff7777ffff7777ffff7777ff
bbbbbbbbbb77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000882222233333333333333333322222880ffffff00ffffff00ffffff00ffffff0
bbbbbbbbbb777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000088888888888888888888888888888888557cc755557cc755557cc755557cc755
bbbbbbbbbb777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000888888888888888888888888888888000000000000000000000000000000000
bbbbbbbbb7777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb77777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb006606600000000000000000000000000000000000000000000000000000000000000000000000000
bbbb7777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00660660000000000000000000000000000000000eeeeeeeeeeee00000000ffffffffffff00000000
bbbbb77777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000eeeeeeeeeeeeeeee0000ffffffffffffffff000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00660660000000000000000000000000000000eeeeeeeeeeeeeeeeee00ffffffffffffffffff00000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0066066000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeffffffffffffffffffff0000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0066066000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeffffffffffffffffffff0000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000ddeeeeeeeeeeeeeeeeeeccffffffffffffffffff99000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000ddddeeeeeeeeeeeeeeeeccccffffffffffffffff999900
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000ddddddeeeeeeeeeeeeeeccccccffffffffffffff9999990
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000dddddddeeeeeeeeeeeeccccccccffffffffffff99999990
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000dddddddddeeeeeeeeeeccccccccccffffffffff999999999
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000ddddddddddeeeeeeeeccccccccccccffffffff9999999999
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000dddddddddddeeeeeeccccccccccccccffffff99999999999
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000ddddddddddddeeeeccccccccccccccccffff999999999999
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000dddddddddddddeeccccccccccccccccccff9999999999999
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000ddddddddddddddcccccccccccccccccccc99999999999999
bbbbbbbbb00bbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000ddddddddddddd33cccccccccccccccccc229999999999999
bbbbbb00b0bbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000dddddddddddd3333cccccccccccccccc2222999999999999
bbbbbbb000bbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000ddddddddddd333333cccccccccccccc22222299999999999
0bbbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000dddddddddd33333333cccccccccccc222222229999999999
00bbbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000ddddddddd3333333333cccccccccc2222222222999999999
b00bbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000660666000000000000000000000000000000000ddddddd333333333333cccccccc22222222222299999990
bb0000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000660666000000000000000000000000000000000dddddd33333333333333cccccc222222222222229999990
bb0000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000dddd3333333333333333cccc2222222222222222999900
bbbb000000bb000bbbbbbbbbbbbbbbbbbbbbbbb00066066600000000000000000000000000000000000dd333333333333333333cc22222222222222222299000
bbbb000000000bbbbbb0bbbbbbbbbbbbbbbbbbb00066066600000000000000000000000000000000000033333333333333333333222222222222222222220000
bbbb00000b000bbbbbb00bbbb0bbbbbbbbbbbbb00066066600000000000000000000000000000000000003333333333333333331122222222222222222200000
bbbb00000bb000bbbbbb00b000bbbbbbbbbbbbb00000000000000000000000000000000000000000000000333333333333333311112222222222222222000000
bbbb0a0a0bbbb0bbbbbbb0000bbbbbbbbbbbbbb00000000000000000000000000000000000000000000000033333333333333111111222222222222220000000
bbbb00000bbbbbbbbbbbb000bbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000003333333333331111111122222222222200000000
bbbb00000bbbbbbbbbbb00000bbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000333333333311111111112222222222000000000
bbbb00000bbbbbbbbbb00bb00bbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000033333333111111111111222222220000000000
bbb0000000bbbbbbbbb0bbbb00bbbbbbbbbbbbb00000000000000000000000000000000000000000000000000003333331111111111111122222200000000000
bbb00000000bbbbbbbbbbbbbb00bbbbbbbbbbbb00000000000000000000000000000000000000000000000000000333311111111111111112222000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033111111111111111111220000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111111111100000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111110000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111110000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011110000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000505055500000550055
11111111111111111111111111111111111111ddd1d1d111111d111dd1ddd1d1d1ddd1ddd1d1d1dd11ddd1d1d111111111110000000000505050500000050050
11111111111111111111111111111111111111d1d1d1d11111d1d1d111d1d1d1d1ddd1d1d1d1d1d1d1d111d1d111111111110000000000505050500000050050
11111111111111111111111111111111111111dd11ddd11111d1d1d111dd11d1d1d1d1ddd1ddd1d1d1dd11d1d111111111110000000000555050500000050050
11111111111111111111111111111111111111d1d111d11111d111d1d1d1d1d1d1d1d1d11111d1d1d1d111ddd111111111110000000000050055500500555055
11111111111111111111771111111111111111ddd1ddd111111dd1ddd1d1d11dd1d1d1d111ddd1ddd1ddd11d1111111111000000000000000000000000000000
11111111111111111111771111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000
11111111111111111111777711111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000
11111111111111111111777711111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000
11111111111111111111777777111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000
11111111111111111111777777111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000
11111111111111111111777777111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000
11111111111111111111777777111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000
11111111111111111177777777111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000000000
11111111111111111177777777111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000000000
11111111111111117777777777111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000
11111111111111117777777777111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000000
11111177777777777777777711111111111111111111111111111111111111111111111111111111111111111111111000009999009999000000000000000000
11111177777777777777777711111111111111111111111111111111111111111111111111111111111111111111111000009999009999000000000000000000
11111111777777777777771111111111111111111111111111111111111111111111111111111111111111111111111000009999009999000000000000000000
11111111777777777777771111111111111111111111111111111111111111111111111111111111111111111111111000009999009999000000000000000000
11111111117777777777111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000
11111111117777777777111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000009999009999000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000009999009999000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000009999009999000000000000000000
111111111111111111111111111111111111111111111111111111eeeeeeeeeeee11111111ffffffffffff111111111000009999009999000000000000000000
1111111111111111111111111111111111111111111111111111eeeeeeeeeeeeeeee1111ffffffffffffffff1111111000009999009999000000000000000000
111111111111111111111111111111111111111111111111111eeeeeeeeeeeeeeeeee11ffffffffffffffffff111111000009999009999000000000000000000
111111111111111111111111111111111111111111111111111eeeeeeeeeeeeeeeeee11ffffffffffffffffff111111000000000000000000000000000000000
11111111111111111111111111111111111111111111111111eeeeeeeeeeeeeeeeeeeeffffffffffffffffffff11111000000000000000000000000000000000
11111111111111111111111111111111111111111111111111eeeeeeeeeeeeeeeeeeeeffffffffffffffffffff11111000000000000000000000000000000000
11111111111111111111111111111111111111111111111111eeeeeeeeeeeeeeeeeeeeffffffffffffffffffff11111000000000000000000000000000000000
1111111111111111111111111111111111111111111111111ddeeeeeeeeeeeeeeeeeeccffffffffffffffffff990000000000000000000000000000000000000
111111111111111111111111111111111111111111111111ddddeeeeeeeeeeeeeeeeccccffffffffffffffff9999000000000000000000000000000000000000
111111111111111111111111111111111111111111111111ddddeeeeeeeeeeeeeeeeccccffffffffffffffff9999000000000000000000000000000000000000
11111111111111111111111111111111111111111111111ddddddeeeeeeeeeeeeeeccccccffffffffffffff99999900000000000000000000000000000000000
11111111111111111111111111111111111111111111111dddddddeeeeeeeeeeeeccccccccffffffffffff999999900000000000000000000000000000000000
1111111111111111111111111111111111111111111111dddddddddeeeeeeeeeeccccccccccffffffffff9999999990000000000000000000000000000000000
1111111111111111111111111111111111111111111111dddddddddeeeeeeeeeeccccccccccffffffffff9999999990000000000000000000000000000000000
1111111111111111111111111111111111111111111111ddddddddddeeeeeeeeccccccccccccffffffff99999999990000000000000000000000000000000000
111111111111111111111111111111111111111111111dddddddddddeeeeeeccccccccccccccffffff9999999999990000000000000000000000000000000000
111111111111111111111111111111111111111111111ddddddddddddeeeeccccccccccccccccffff99999999999990000000000000000000000000000000000
111111111111111111111111111111111111111111111ddddddddddddeeeeccccccccccccccccffff99999999999990000000000000000000000000000000000
111111111111111111111111111111111111111111111dddddddddddddeeccccccccccccccccccff999999999999990000000000000000000000000000000000
11111111111111111111111111111111111111111111ddddddddddddddcccccccccccccccccccc99999999999999900000000000000000000000000000000000
11111111111111111111111111111111111111111111ddddddddddddd33cccccccccccccccccc229999999999999900000000000000000000000000000000000
1111111111111111111111111111111111111111111dddddddddddd3333cccccccccccccccc22229999999999999900000000000000000000000000000000000
1111111111111111111111111111111111111111111ddddddddddd333333cccccccccccccc222222999999999999900000000000000000000000000000000000
111111111111111111000011111111111111111111dddddddddd33333333cccccccccccc22222222999999999999000000000000000000000000000000000000
111111111111111111000011111111111111111111ddddddddd3333333333cccccccccc222222222299999999999000000000000000000000000000000000000
111111111111000011001111111111111111111111ddddddd333333333333cccccccc22222222222299999999990000000000000000000000000000000000000
111111111111000011001111111111111111111111dddddd33333333333333cccccc222222222222229999999990000000000000000000000000000000000000
111111111111110000001111111111111111111111dddd3333333333333333cccc22222222222222229999999900000000000000000000000000000000000000
111111111111110000001111111111111111111111ddd333333333333333333cc222222222222222222999999900000000000000000000000000000000000000
001111111111111100111111111111111111111111d3333333333333333333322222222222222222222999990000000000000000000000000000000000000000
001111111111111100111111111111111111111111d3333333333333333331122222222222222222222999990000000000000000000000000000000000000000
000011111111110000111111111111111111111111d3333333333333331111112222222222222222222999000000000000000000000000000000000000000000
00001111111111000011111111118888811188888113333333333333111111112222222222228822222990000000000000000000000000000000000000000000
11000011111100001111111111188888551888885513333333333111111111111222222222888552222009999009999999000000000000000000000000000000
11000011111100001188888811188888551888885513888883331888888881111888888228888882288888899088888888800008880000000000000000000000
11110000000000088855888518888885888888558888788885188885888858888588885288855588855888598888585888508885880000000000000000000000
11110000000008888888888588888888858885888891988885888511888518888888555888558888888888588855588888888855880000000000000000000000
11110000000008888888888588858888858885888891988885888511888511888888855888558888888888588855588888888555880000000000000000000000
11110000000088888588855888588888588855888878888558885118885888858888558885588888588855888555588888885555880000000000000000000000
11110000000088888885558885888855888555888888555588851188851888888855588888588888885558885555588888555555800000000000000000000000
11111111000085555555555555855555555555855555555555511115551855555555585555585555555555555555888855555555000000000000000000000000
11111111000085555555555555855555555555855555555555511115551855555555585555585555555555555888888555555550000000000000000000000000
11111111000085555555555555855555555551855555555555511115551855555555585555585555555555555885555555555000000000000000000000000000
11111111000085555555505555855555555511855555555155511115551855555555185555585555555505555885555555550000000000000000000000000000
11111111000005555551005550155511555111155555111155511115511155555511115555115555550005559885555555000000000000000000000000000000
11111111000000000011000000111111111111100001111111111111111111111111111111111110000009999885555599000000000000000000000000000000
11111111000000000011110000001111111111111000011000000111111111111111111111111110000000000085555500000000000000000000000000000000
11111111000000000011110000001111111111111000011000000111111111111111111111111110000000000000000000000000000000000000000000000000
1111111100aa00aa0011111111001111111111111110000000011111111111111111111111111110000000000000000000000000000000000000000000000000
1111111100aa00aa0011111111001111111111111110000000011111111111111111111111111110000000000000000000000000000000000000000000000000
11111111000000000011111111111111111111111110000001111111111111111111111111111110000000000000000000000000000000000000000000000000
11111111000000000011111111111111111111111110000001111111111111111111111111111110000000000000000000000000000000000000000000000000
11111111000000000011111111111111111111111000000000011111111111111111111111111110000000000000000000000000000000000000000000000000
11111111000000000011111111111111111111111000000000011111111111111111111111111110000000000000000000000000000000000000000000000000
11111111000000000011111111111111111111100001111000011111111111111111111111111110000000000000000000000000000000000000000000000000
11111111000000000011111111111111111111100001111000011111111111111111111111111110000000000000000000000000000000000000000000000000
11111100000000000000111111111111111111100111111110000111111111111111111111111110000000000000000000000000000000000000000000000000
11111100000000000000111111111111111111100111111110000111111111111111111111111110000000000000000000000000000000000000000000000000
11111100000000000000001111111111111111111111111111100001111111111111111111111110000000000000000000000000000000000000000000000000
11111100000000000000001111111111111111111111111111100001111111111111111111111110000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000066606660666006600660000006666600000066600660000006606660666066606660000000000000000000000000000000
00000000000000000000000000000060606060600060006000000066060660000006006060000060000600606060600600000000000000000000000000000000
00000000000000000000000000000066606600660066606660000066606660000006006060000066600600666066000600000000000000000000000000000000
00000000000000000000000000000060006060600000600060000066060660000006006060000000600600606060600600000000000000000000000000000000
00000000000000000000000000000060006060666066006600000006666600000006006600000066000600606060600600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
012f00110675007750077500775008750087500875007750057500575005750057500375003750037500375001750017500175000000000000000000000000000000000000000000000000000000000000000000
000100000375004750047500375003750037500170006700067000570000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100002c7502a750287502d75025750247502275000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b000014c1013c300cc4011c2016c0015c000bc5012c0015c000dc200dc5010c2011c400ec0024c0024c000fc300ec500fc3010c1010c400fc000ec000dc300dc600ec3010c2037c0038c0017c0015c000dc00
000100001e5501e5501c550195501b5501d5501f5502255022550215502255023550255502655028550325503555037550005003a550335500050039550005003455000500005003855000500365500050000500
010f00001852300500295200050014520245002452000500165200050028520005001352000500235202252018523005002952000500145202450024520005001652000500285200050013520005002352022520
010f00001852300500235200050013520245002852000500165200050024520005001452000500295201852018523005002352000500135202450028520005001652000500245200050014520005002952018520
010f00001852300500355210050020522245003052200500225220050034522005001f522005002f5222e5221852300500355210050020522245003052200500225220050034522005001f522005002f5222e522
010f000018523005002f521005001f522245003452200500225220050030522005002052200500355222452218523005002f521005001f5222450034522005002252200500305220050020522005003552224522
010f0000180230000018023000001802300000180230000018023000001802300000180230000018023180231a023000001a023000001a023000001a023000001a023000001a023000001a023000001a0231a023
010f00001a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a71118711187111871118711187111871118711187111871118711187111871118711187111871118711
010f00001571115711157111571115711157111571115711157111571115711157111571115711157111571118711187111871118711187111871118711187111871118711187111871118711187111871118711
000f00101b75000700317503170015750157002975029700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
010f002014052000001c0520000018052000002205200002000020000200002000020000200000000000000214052000021c05200002180520000224052000002205200002280020000200002000020000200002
010f00001a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a7111a71118711187111871118711187111871118711187111871118711187111871118711187111871118711
010f00001571115711157111571115711157111571115711157111571115711157111571115711157111571118711187111871118711187111871118711187111871118711187111871118711187111871118711
010f00200805300000080530000008053000000805300000080530000008053000000805300000080530805308053000000805300000080530000008053000000805300000080530000008053000000805308053
010f000013052000000f0520000018052000002205200002000020000200002000020000200000000020000013052000020f05200002180520000224052000002205200002280020000200002000020000200002
010f00002685200000268520000026852000002685200000268520000026852000002686200000000000000026852000002685200000268520000026852000002685200000268520000026852000002685200000
0001000021050260502c050350503a050390500000034050000002d0500000000000000002505000000000001e05000000000001a050170501605015050180501b0501e050270502e05000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001f0522105225052290521b0001f0002c0002600027052290522c05231052390522c00003000010003305034050380503a0523c0523e0523d0523e0523d0523d0523e0523d0523e0523d0523e0523c050
__music__
03 00424344
01 00424344
00 00424344
00 01424344
02 01424344
00 01424344
02 01424344
00 41424344
01 05494c44
00 05424344
00 050a4344
00 050a4344
00 060b4344
00 060b4344
00 050a4344
00 050a4344
00 060b4344
00 060b4950
00 074b4344
00 074b4344
00 080b4344
00 080b4c44
00 080b0944
00 080b0944
00 080b0910
02 080b0910
00 4c494344
02 4c494344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 0c424344
00 0c494344
00 0c094344
02 0c094344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
01 0d125044
00 0d125044
00 11124344
02 11124344

