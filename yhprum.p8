pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--yhprum
--by satiel

--initial function that runs
function _init()
	--keep track of gamestate
	game_over=false
	
	--load initial menu manager
	menu_init()
end

--initial menu manager
function menu_init()
	--change to main menu
	_update=menu_update
	_draw=menu_draw
end

--game screen initializer
function game_init()
	
	game_over=false
	make_player()
	make_enemy()
	_update=game_update
	_draw=game_draw
end

--gameover screen initializer
function game_over_init()
	_update=game_over_update
	_draw=game_over_draw
end

--global declarations
game_time=0

--global player declarations

--player stats
player_hp=100
player_score=0

--position
playerx=0
playery=0

--sprites
steer_left_sp=2
steer_right_sp=3
player_idle_sp=1

--player maneuvering
steering_left = false
steering_right = false
is_idle=false
player_speed=0
player_speed_max=1.47

-- tachometer
rpm = 0.15 -- current rev level (0 to 1)
rev_speed = 0.0095 -- how fast the revs increase/decrease
decay_rate = 0.05 -- how quickly rpm drops when no input
decay_factor = 0.98  -- rate at which the decay slows down over time

--projectile declarations
projectiles={}

--weapon cooldowns
cooldown_weaponswitch=0
cooldown_weaponswitch_cooldown=10
cooldown_yellow=0
cooldown_yellow_cooldown=2
cooldown_green=0
cooldown_green_cooldown=4
cooldown_red=0
cooldown_red_cooldown=8

--player weapon
player_weapon='yellow'
player_currentweap=1

--enemy declarations
enemy_1x=0
enemy_1y=0
enemies={}
side_enemies={}
enemy_projectiles={}

--gamestate
level_state=0
-->8
--main menu functions
--main menu updater
function menu_update()
	if btnp(5) then 
		game_init() 
	end -- press 🅾️ to start
end

--main menu drawer
function menu_draw()
	cls()
	--move_player()
	--draw_player()
	
	--print onto main menu
	print("main menu screen",0,0,14)
	print("yhprum",
	 37, 70, 14) 
	print("new game 🅾️",
	 42, 80, 12) 
end	

--game functions
function game_update()
	--keep track of gametime
	--purge at 17 minutes
	game_time=(game_time+1)%32000
	
	--check if player is alive
	if player_hp<1 then
		game_over=true
	end
	
	--check if game is over
	if not game_over then
		move_player()
		enemy_manager()
		--collision()
	else
		game_over_init()
	end
	
	--testing screen switches
	--[[if btnp(5) then
		game_over=true
	elseif btnp(4) then
		menu_init()
	end--]]
	

end

function game_draw()
	cls()
	draw_player()
	draw_enemy()
	collision()
	
	--print("gameplay screen",0,0,14) 
	print("gameplay screen",0,0,14) 
	--print("game over 🅾️",
	-- 42, 80, 12) 
	--print("main menu ❎",
	-- 42, 90, 12)  
	--print("player_speed: "..player_speed,0,8,14)
	--print("rpm: "..rpm,0,16,14)
end

--game over functions
function game_over_update()
	--press 🅾️ for main menu
	if btnp(5) then
		clear_history()
		menu_init()
	--press ❎ for main menu
	--[[elseif btnp(4) then
		clear_history()
		menu_init()--]]
	end
end

function game_over_draw()
	cls()
	print("game over screen",0,0,14)
	print("score: "..player_score,18,64,6)
	print("press 🅾️ for main menu",18,72,6)
	--print("press ❎ for main menu",18,84,6)
	spr(1,20,90)
end

function clear_history()
	
	--reset variables after death
	projectiles={}
	enemies={}
	enemy_projectiles={}
	side_enemies={}
	cls()
	player_hp=100
	player_score=0
	game_time=0
	cooldown_weaponswitch=0
	cooldown_yellow=0
	cooldown_green=0
	cooldown_red=0

	
end
-->8
--player functions
--create the player
function make_player()
	--set initial player location
	playerx=24
	playery=60
	player_speed=0
	
end

--create the first enemy (test)
function make_enemy()
	enemy_1x=64
	enemy_1y=64
end

--draw the player
function draw_player()
	--[[ draw collision boxes 

	for e in all(enemies) do
		rect(e.x+1,e.y,e.x+6,e.y+8)
	end--]]
	
		if steering_left then
		spr(steer_left_sp,playerx,playery)
	elseif steering_right then
		spr(steer_right_sp, playerx, playery)
	else
		spr(player_idle_sp, playerx, playery)	
	end
	
	--draw projectiles
	for p in all(projectiles) do
		spr(p.sp, p.x, p.y)
	end
	
	--draw enemy projectiles
	for ep in all(enemy_projectiles) do
		spr(ep.sp,ep.x,ep.y)
	end
	
	--debug
	--print('current weapon: '..player_weapon,0,8,15)
	--print('enemy p size: '..count(enemy_projectiles),0,16,15)
	--print('e size: '..count(enemies),0,24,15)
	--print('s_e size: '..count(side_enemies),0,32,15)
	--print('gametime: '..game_time,0,120,15)
	print('score: '..player_score,0,120,15)
	print('health: '..player_hp,60,120,8)
	--[[if overlap(playerx+1,playery,8,6,enemy_1x+1,enemy_1y,8,6) then
	 print("overlapping enemy!",30,30,13)
	end--]]
		--what level are we on?
	if level_state==1 then
		print("welcome to level 2",32,64,11)
	end
	
	rect(playerx+3,playery+4,playerx+4,playery+5,8)
	--rect(enemy_1x+1,enemy_1y,enemy_1x+6,enemy_1x+8,11)
	
end

--move the player
function move_player()
	--check score and jump levels
	check_gamestate()
		--check for out of bounds
	if playerx<0 then
		playerx=0
	end
	if playerx>120 then
		playerx=120
	end
	if playery<8 then
		playery=8
	end
	if playery>120 then
		playery=120
	end
	
	--basic movement left/right
	if btn(0) then 
		playerx-=player_speed
		steering_right=false
		steering_left=true 
	elseif btn(1) then 
		playerx+=player_speed
		steering_left=false
		steering_right=true
	else
		steering_left=false
		steering_right=false
	end
	
	--basic movement up/down
	if btn(2) then
		playery-=player_speed
	elseif btn(3) then
		playery+=player_speed
	end
	
	--weapon changing
	if btnp(5) then changeweapon() end
	
	--weapon firing
	if btn(4) then fire(player_weapon) end
	
	--simulate revving
	if btn(0) then
		if rpm>0.75 then
			--do nothing, don't increase accel.
		else
			--decrease accel
			rpm=min(1,rpm+rev_speed)
			decay_rate=0.01
			player_speed=player_speed_max*rpm+1
		end
	elseif btn(1) then
		if rpm>0.75 then
			--do nothing
		else
			rpm=min(1,rpm+rev_speed)
			decay_rate=0.01
			player_speed=player_speed_max*rpm+1
		end
	else
		if rpm>0.15 then
			rpm=max(0,rpm-decay_rate)
			decay_rate=decay_rate*decay_factor
			player_speed=player_speed_max*rpm+1
		end
	end
		
	--update projectiles
	
	--player projectiles
	for p in all (projectiles) do
		if p.name=='yellow_bullet' then
			p.y-=5
		elseif p.name=='green_bullet' then
			p.y-=2.5
		end
		
		--check if out of bounds
		if p.y>136 or p.y<-8 or p.x>136 or p.x<-8 then
			del(projectiles,p)	
		end
	end
	
	--enemy projectiles
	for ep in all(enemy_projectiles) do
		if ep.name=='redsquid' then
			ep.y+=1.7
			if overlap(playerx+3,playery+4,2,2,ep.x+2,ep.y+1,2,2) then
				del(enemy_projectiles,ep)
				player_hp-=20
				print("!! taking damage !!",72,18,8)
			end
		elseif ep.name=="greensquid" or ep.name=="greensquid_r" then
			if overlap(playerx+3,playery+4,2,2,ep.x,ep.y,4,4) then
				del(enemy_projectiles,ep)
				player_hp-=10
			end
			if ep.name=="greensquid" then
				ep.x+=4.5
			elseif ep.name=="greensquid_r" then
				ep.x-=6
			end
		end
		
		--check if out of bounds
		if ep.y>136 or ep.x>136 or ep.x<-8 then
			del(enemy_projectiles,ep)
		end
	end

end
-->8
-- math and other functions
--fire current weapon
function fire(weapon)
	--yellow weapon
	if weapon=='yellow' and cooldown_yellow<game_time then
		local p={
			name='yellow_bullet',
			sp=4,
			x=playerx+2,
			y=playery,
			h=4,
			w=4,
			damage=6
		}
		add(projectiles,p)
		sfx(0)
		cooldown_yellow=game_time+cooldown_yellow_cooldown
	
	--green weapon
	elseif weapon=='green' and cooldown_green<game_time then
		local p={
			name='green_bullet',
			sp=5,
			x=playerx+2,
			y=playery,
			h=4,
			w=4,
			damage=10
		}		
		add(projectiles,p)
		sfx(1)
		cooldown_green=game_time+cooldown_green_cooldown

	--red weapon
	end
end

--change current weapon
function changeweapon()
	--check if enough time has passed
	if cooldown_weaponswitch<game_time then
		player_currentweap+=1
		
		-- check if looped around
		if player_currentweap>2 then
			player_currentweap=1
		end
		
		--now change weapon names
		if player_currentweap==1 then
			player_weapon='yellow'
		elseif player_currentweap==2 then
			player_weapon='green'
		end
		
		--reset weapon change cd
		cooldown_weaponswitch=game_time+cooldown_weaponswitch_cooldown
	end
end

--collision detection
--checks (2) rectangles
--for overlap
function overlap(ax,ay,ah,aw,bx,by,bh,bw)
	return not(ax>bx+bw or ay>by+bh or ax+aw<bx or ay+ah<by)
end

--check for grazing
function graze_overlap(ax,ay,ah,aw,bx,by,bh,bw)
	-- check full overlap
	local full_overlap = not(ax>bx+bw or ay>by+bh or ax+aw<bx or ay+ah<by)

	-- define center hitbox of the 8x8 player sprite
	local center_x = ax + 3  -- start of center area
	local center_y = ay + 4  -- start of center area
	local center_w = 2
	local center_h = 2

	-- check if the projectile also overlaps with the center
	local center_overlap = not(center_x > bx + bw or center_y > by + bh or 
		center_x + center_w < bx or center_y + center_h < by)

	-- grazing happens when the projectile overlaps the ship but not the center
	return full_overlap and not center_overlap
end

--global collision manager
function collision()
	--loop through enemies
	--then projectiles
	--check for collisions
	--deal damage and delete p
	for e in all(enemies) do
		--check if our ship has 
		--collided with an enemy
		--and explode!!!
		if overlap(playerx+3,playery+4,2,2,e.x+2,e.y+4,4,4) then
			player_hp-=10
			del(enemies,e)
		end
		if graze_overlap(playerx,playery,8,8,e.x+1,e.y,8,6) then
			print("!! enemy_graze !!",72,18,11)
			player_score+=10
		end
		for p in all(projectiles) do
			if overlap(p.x,p.y,p.h,p.w,e.x+1,e.y,8,6) then
				print("! hit !",e.x-10,e.y,10)
				e.hp-=p.damage
				del(projectiles,p)
			end
		end
	end
	
	--check for projectile grazing
	for ep in all(enemy_projectiles) do
		if graze_overlap(playerx,playery,8,8,ep.x,ep.y,4,4) then
			print("!! graze !!",72,10,8)
			player_score+=5
		end
	end
end

function randint(_num)
	return flr(rnd(_num))
end

function check_gamestate()
	if player_score>5000 and level_state==0 then
		level_state=1
		projectiles={}
		enemies={}
		enemy_projectiles={}
		side_enemies={}
		cls()
		
	end	
end

-->8
--enemy functions
function draw_enemy()
	if level_state==0 then
		--loop and draw enemies
		for e in all(enemies) do
			spr(e.sp,e.x,e.y)
		end
		--loop and draw side enemies
		for s_e in all(side_enemies) do
			if s_e.name=="greensquid" then
				spr(s_e.sp,s_e.x,s_e.y)
			elseif s_e.name=="greensquid_r" then
				spr(s_e.sp,s_e.x,s_e.y,1.0,1.0,true)
			end
		end
	end
end

function enemy_manager()
	--level 1 enemy sequence
	if level_state==0 then
		if game_time%61==0 then
			add_enemy("redsquid")
		end
		if game_time%121==0 then
			add_enemy("greensquid")
			add_enemy("greensquid_r")
		else
			
		end
	move_enemies()
	
	elseif level_state==1 then
		--print("welcome to level 2",64,64,11)
		
	end
	
	
	
end

function add_enemy(enemy_name)
	if enemy_name=="redsquid" then
		local _e={
			sp=8,
			x=randint(112)+8,
			y=-8,
			hp=50,
			movespeed=0.5,
			target_y=140,
			name="redsquid",
			fire_cooldown=randint(10),
			fire_start=0
		}
		
		add(enemies,_e)
	elseif enemy_name=="greensquid" then
		local _e={
			sp=11,
			x=0,
			y=-8,
			hp=1000,
			movespeed=3,
			target_y=randint(playery)+8,
			name="greensquid",
			fire_cooldown=randint(30)+30,
			fire_start=0
		}
		
		add(side_enemies,_e)
	elseif enemy_name=="greensquid_r" then
		local _e={
			sp=11,
			x=120,
			y=-8,
			hp=1000,
			movespeed=3,
			target_y=randint(playery)+8,
			name="greensquid_r",
			fire_cooldown=randint(30)+30,
			fire_start=0
		}
		
		add(side_enemies,_e)		
	end
	
	
end

function move_enemies()
	for e in all(enemies) do
		--check health
		if e.hp<1 then
			del(enemies,e)
			player_score+=50
			
		--redsquid updates
		elseif e.name=="redsquid" then

			--check if we've reached
			--our target
			if e.y<e.target_y then
				e.y+=e.movespeed
			elseif e.y>e.target_y then
				e.y=-8
			end

			--enemy firing countdown
			if e.fire_cooldown>0 then
				e.fire_start+=1

				--check if cooldown hit
				if e.fire_start>e.fire_cooldown then

					--fire sequence
					enemy_fire(e.x+4,e.y+4,e.name)

					--reset cooldown
					e.fire_start=0
					e.fire_cooldown=randint(60)+30					
				end
			end
		end
	end
	
	for s_e in all(side_enemies) do
		--greensquid enemies
		if s_e.name=="greensquid" or s_e.name=="greensquid_r" then
			--check if we've reached
			--our target
			if s_e.y<s_e.target_y then
				s_e.y+=s_e.movespeed
			end
		end
		
		--enemy firing cooldown'
		--check first if we're
		--in the firing position
		if s_e.y>s_e.target_y-5 then
			if s_e.fire_cooldown>0 then
				s_e.fire_start+=1
			
				--check if cooldown hit
				if s_e.fire_start>s_e.fire_cooldown then
				--fire sequence, check side
					if s_e.name=="greensquid" then
						enemy_fire(s_e.x+8,s_e.y+4,s_e.name)
					elseif s_e.name=="greensquid_r" then
						enemy_fire(s_e.x-8,s_e.y+4,s_e.name)
					end
				--reset cooldown
				s_e.fire_start=0
				end
			end
		end
	end
end

function enemy_fire(x,y,name)
	ep={
		x=x,
		y=y,
		name=name
	}
	
	if name=="redsquid" then
		ep.sp=10
		ep.dy=1
		add(enemy_projectiles,ep)
	elseif name=="greensquid" then
		ep.sp=6
		ep.dy=1
		add(enemy_projectiles,ep)
	elseif name=="greensquid_r" then
		ep.sp=6
		ep.dy=1
		add(enemy_projectiles,ep)
	end	
end

__gfx__
0000000000a00d0000a0200000090d000aa000000bb0000008800000008008000800008000900900a00a00000000333000000000000000000000000000000000
0000000000a00d0000a0200000090d00a00a0000b00b0000800800000080080008000080009009000a9000003333303000000000000000000000000000000000
007007000aa00dd009a02d0000990d20a00a0000b00b00008008000008800880080880800090090009a00000005cc00000000000000000000000000000000000
000770000a0000d00a000d0000a000d00aa000000bb00000088000000800008008888880099dd990a00a0000005cc00000000000000000000000000000000000
00077000a90cc02d0a06cdd00aac60d0000000000000000000000000820cc028088cc8809d9999d900000000005cc00000000000000000000000000000000000
00700700a9a66d2d0a9c2dd00aa9c2d00000000000000000000000008286682808cccc809cccccc9000000003333303000000000000000000000000000000000
000000000a9ad2d0009ddd0000aaa20000000000000000000000000008288280008cc80090cccc09000000000000333000000000000000000000000000000000
0000000000600600006060000006060000000000000000000000000000a00a000008800099000099000000000000000000000000000000000000000000000000
__sfx__
00020000115700e550075300050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200000b1700e1500e1300010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
