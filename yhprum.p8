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
	--press 🅾️ for new game
	if btnp(5) then
		game_init()
	--press ❎ for main menu
	elseif btnp(4) then
		menu_init()
	end
end

function game_over_draw()
	cls()
	print("game over screen",0,0,14)
	print("press 🅾️ to play again!",18,72,6)
	print("press ❎ for main menu",18,84,6)
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
	-- draw collision boxes --
	rect(playerx+1,playery,playerx+6,playery+8,8)
	rect(enemy_1x+1,enemy_1y,enemy_1x+6,enemy_1x+8,11)

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
	
	--debug
	print('current weapon: '..player_weapon,0,8,15)
	print('p size: '..count(projectiles),0,16,15)
	print('e size: '..count(enemies),0,24,15)
	if overlap(playerx+1,playery,8,6,enemy_1x+1,enemy_1y,8,6) then
		print("overlapping enemy!",30,30,13)
	end
	
end

--move the player
function move_player()
		--check for out of bounds
	if playerx<0 then
		playerx=0
	elseif playerx>120 then
		playerx=120
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
			w=4
		}
		add(projectiles,p)
		cooldown_yellow=game_time+cooldown_yellow_cooldown
	
	--green weapon
	elseif weapon=='green' and cooldown_green<game_time then
		local p={
			name='green_bullet',
			sp=5,
			x=playerx+2,
			y=playery,
			h=4,
			w=4
		}		
		add(projectiles,p)
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

--global collision manager
function collision()
	for p in all(projectiles) do
		if overlap(p.x,p.y,p.h,p.w,enemy_1x+1,enemy_1y,8,6) then
				print("! hit !",enemy_1x-10,enemy_1y,10)
				del(projectiles,p)
		end
	end
end

function randint(_num)
	return flr(rnd(_num))
end
-->8
--enemy functions
function draw_enemy()
	--loop and draw enemies
	for e in all(enemies) do
		spr(e.sp,e.x,e.y)
	end
end

function enemy_manager()
	--level 1 enemy sequence
	if level_state==0 then
		if game_time%61==0 then
			add_enemy("redsquid")
		end
	end
	
	move_enemies()
	
end

function add_enemy(enemy_name)
	if enemy_name=="redsquid" then
		local _e={
			sp=8,
			x=randint(60),
			y=-8,
			hp=50,
			movespeed=0.5,
			target_y=70,
			name="redsquid"
		}
	end
	
	add(enemies,_e)
end

function move_enemies()
	for e in all(enemies) do
		if e.name=="redsquid" then
			--check if we've reached
			--our target
			if e.y<e.target_y then
				e.y+=e.movespeed
			end
		end
	end
end

__gfx__
0000000000a00d0000a0200000090d000aa000000bb0000008800000008008000800808000000000000000000000000000000000000000000000000000000000
0000000000a00d0000a0200000090d00a00a0000b00b000080080000008008000800808000000000000000000000000000000000000000000000000000000000
007007000aa00dd009a02d0000990d20a00a0000b00b000080080000088008800808808000000000000000000000000000000000000000000000000000000000
000770000a0000d00a000d0000a000d00aa000000bb0000008800000080000800888888000000000000000000000000000000000000000000000000000000000
00077000a90cc02d0a06cdd00aac60d0000000000000000000000000820cc028088cc88000000000000000000000000000000000000000000000000000000000
00700700a9a66d2d0a9c2dd00aa9c2d00000000000000000000000008286682808cccc8000000000000000000000000000000000000000000000000000000000
000000000a9ad2d0009ddd0000aaa20000000000000000000000000008288280008cc80000000000000000000000000000000000000000000000000000000000
0000000000600600006060000006060000000000000000000000000000a00a000008800000000000000000000000000000000000000000000000000000000000
