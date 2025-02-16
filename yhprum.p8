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
	--create player
	--make_player()
	
	--change to main menu
	_update=menu_update
	_draw=menu_draw
end

--game screen initializer
function game_init()
	game_over=false
	--make_player()
	_update=game_update
	_draw=game_draw
end

--gameover screen initializer
function game_over_init()
	_update=game_over_update
	_draw=game_over_draw
end

--declarations
game_time=0
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
		--move_player()
	else
		game_over_init()
	end
	
	--testing screen switches
	if btnp(5) then
		game_over=true
	elseif btnp(4) then
		menu_init()
	end
end

function game_draw()
	cls()
	--draw_player()
	
	print("gameplay screen",0,0,14) 
	print("game over 🅾️",
	 42, 80, 12) 
	print("main menu ❎",
	 42, 90, 12) 
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
