pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- pico nations
-- by goudagames

-- the ingame timer in seconds.
-- increasing this might lead to
-- lag due to larger
-- populations and cities.
timer=300

-- settings for map generation.
-- map generation is done using
-- a diamond square algorithm.
forest_size = 100
num_forests = 30

num_nations = 4

roughness = 1.4
r_start = 96

c_offset = 0
c_range = 112-c_offset

function _init()
	cls()
end

function start_game()
	cls()
	gen_map()
	timer_t=time()
	state = "game"
end

-->8
-- update functions

cx=0
cy=0
sel_x=0
sel_y=0
state="menu"

spawn_t = time()
function _update()
	srand(time())
	if state == "menu" then
		update_menu()
	elseif state == "game" then
		update_game()
	end
end

function update_menu()
	menu_input()
end

function update_game()
	input()

	if timer > 0 then
		timer -= time() - timer_t
		timer_t = time()

		if time() - spawn_t >= 1 then
			for v in all(cities) do
				if v.pop < min(flr(v.max_pop), 9) then
					if rnd() < 0.1 then
						make_pop(v.x*8+4, v.y*8+4, v)
					end
				end
			end
			spawn_t = time()
		end

		update_ai()

		update_jobs()
		update_pops()
		update_cities()
		update_buildings()

		if timer <= 0 then
			calculate_scores()
		end
	end
end

function menu_input()
	if(btnp(4))start_game()
end

function input()
	if(btnp(1))sel_x+=1
	if(btnp(0))sel_x-=1
	if(btnp(3))sel_y+=1
	if(btnp(2))sel_y-=1

	sel_x=mid(0, sel_x, 127)
	sel_y=mid(0, sel_y, 63)

	if btnp(5) then
		try_place_rally(sel_x, sel_y, player)
	end

	if btnp(4) then
		if not try_build(sel_x, sel_y, player) then
			try_settle(sel_x, sel_y, player)
		end
	end

	if btnp(5) and timer <= 0 then
		run()
	end

	cx=sel_x*8-60
	cy=sel_y*8-52
	
	cx=mid(0,cx,896) -- 128 * 7
	cy=mid(0,cy,400) -- 64 * 6 + 16
	camera(cx,cy)
end

function calculate_scores()

	max_score = 0
	winner = nil

	for n in all(nations) do
		score = 0
		for c in all(n.cities) do
			score += 3
			score += c.pop
		end

		score += flr(n.gold / 10)

		if score > max_score then
			max_score = score
			winner = n
		end

		n.score = score
	end

	if player.score == max_score then
		winner = player
	end
end

function sq_dist(x0, y0, x1, y1)
	return (x0-x1)*(x0-x1) + (y0-y1)*(y0-y1)
end

function update_buildings()
	for b in all(buildings) do
		b.update()
	end
end

function update_ai()

	for n in all(nations) do
		if n != player then

			for city in all(n.cities) do

				if city.pop >= 3 then
					if time() - city.settle_time >= 5 then
						city.settle_time = time()
						x = flr(rnd(21) + city.x - 10)
						y = flr(rnd(21) + city.y - 10)

						try_settle(x, y, n)
					end
				end
				
				if city.attacking_nation != nil then
					city.rx = city.x
					city.ry = city.y
				elseif #city.jobs == 0 then

					if n.mills == 0 then
						for x = city.x - 5, city.x + 5 do
							for y = city.y - 5, city.y + 5 do
								if is_tile_at(x, y, forest) then
									try_build(x, y, n)
									goto break_out
								end
							end
						end
						::break_out::
					else
						x = flr(rnd(11) + city.x - 5)
						y = flr(rnd(11) + city.y - 5)
						if not (is_tile_at(x, y, ground)
								and (n.farms > #n.cities * (6 + flr(n.wood / 24))) or city.farms >= 18) then
							try_build(x, y, n)
						end
					end
				end
			end
		end
	end
end

prod_per_pop = 7.5
time_since_job = 0
function update_jobs()
	if time() - time_since_job > 0.5 then
		for j in all(jobs) do
			if (j.can_continue()) then
				has_enemy = false
				has_ally = false
				for pop in all(pop_map[j.x + 1][j.y + 1]) do
					if pop.city.nation != j.nation then
						has_enemy = true
					else
						has_ally = true
					end
				end
				if has_enemy and not has_ally then
					j.done = true
					del(jobs, j)
				elseif not has_enemy then
					present = 0
					for pop in all(j.assigned) do
						if pop.tile_x == j.x and pop.tile_y == j.y then
							present += 1
						end
					end
					j.progress += present * prod_per_pop
					if j.progress >= j.required then
						j.done = true
						j.on_done(j.x, j.y, j.nation, j.cities)
						del(jobs, j)
					end
				end
			else
				j.done = true
				del(jobs, j)
			end
		end
		time_since_job = time()
	end
end

city_attack_time = time()
function update_cities()
	attacking = false
	if time() - city_attack_time > 0.5 then
		attacking = true
		city_attack_time = time()
	end

	for c in all(cities) do
		rem={}
		for j in all(c.jobs) do
			if(j.done) add(rem,j)
		end

		for j in all(rem) do
			del(c.jobs, j)
		end

		if attacking then
			has_allies = false
			num_enemies = 0
			enemy_nation = nil
			for pop in all(pop_map[c.x + 1][c.y + 1]) do
				if pop.city.nation == c.nation then
					has_allies = true
					break
				else
					num_enemies += 1
					if enemy_nation == nil then
						enemy_nation = pop.city.nation
					end
				end
			end

			if num_enemies > 0 then
				if not has_allies then
					c.takeover += num_enemies / 2.0
					c.attacking_nation = enemy_nation

					if c.takeover >= 100 then
						take_city(c, enemy_nation)
					end
				end
			else
				if c.takeover > 0 then
					c.takeover -= 2
				else
					c.attacking_nation = nil
				end
			end
		end
	end
end

function take_city(city, enemy_nation)

	x = city.x
	y = city.y

	remove_territory(city.nation, x-5, y-5, x+5, y+5)
	remove_expansion_area(city.nation, x-10, y-10, x+10, y+10)

	for c in all(city.nation.cities) do
		if c != city then
			add_expansion_area(city.nation, x-10, y-10, x+10, y+10)
		end
	end

	add_territory(enemy_nation, x-5, y-5, x+5, y+5)
	add_expansion_area(enemy_nation, x-10, y-10, x+10, y+10)

	for b in all(buildings) do
		xdist = abs(b.x - x)
		ydist = abs(b.y - y)

		if xdist <= 5 and ydist <= 5 then
			if b.nation == city.nation then
				b.nation = enemy_nation

				if b.type == "farm" then

					for c in all(city.nation.cities) do
						if c != city then
							cxdist = abs(b.x-x)
							cydist = abs(b.y-y)

							if cxdist <= 5 or cydist <= 5 then
								c.max_pop -= 0.5
								c.max_pop = max(1, c.max_pop)
							end
						end
					end

					for c in all(enemy_nation.cities) do
						cxdist = abs(b.x-x)
						cydist = abs(b.y-y)

						if cxdist <= 5 or cydist <= 5 then
							c.max_pop += 0.5
							c.max_pop = max(1, c.max_pop)
						end
					end
				end
			end
		end
	end

	gold_taken = flr(city.nation.gold * 0.1)
	enemy_nation.gold += gold_taken
	city.nation.gold -= gold_taken

	del(city.nation.cities, city)
	add(enemy_nation.cities, city)

	city.nation = enemy_nation
	city.takeover = 0
	city.attacking_nation = nil
end

pop_speed = 0.75
function update_pops()
	t = time()
	for pop in all(pops) do

		tile_x = mid(0, flr(pop.x / 8), 127)
		tile_y = mid(0, flr(pop.y / 8), 63)

		if t - pop.t > 1 then

			if pop.job != nil then
				if pop.job.done then
					pop.job = nil
				end
			end

			if pop.job == nil then
				if #pop.city.jobs > 0 then
					pop.job = pop.city.jobs[1]
					add(pop.job.assigned, pop)
				end
			end

			rx = pop.city.rx
			ry = pop.city.ry
			if pop.job != nil then
				rx = pop.job.x
				ry = pop.job.y
			end

			dist = sq_dist(pop.tx, pop.ty, pop.x, pop.y)
			if dist < 4 then
				pop.tx = mid(0, flr(pop.x + rnd(12) - 6), 1031)
				pop.ty = mid(0, flr(pop.y + rnd(12) - 6), 519)
			end

			rally_dist = sq_dist(pop.tx, pop.ty, rx*8+4, ry*8+4)
			if rally_dist > 16 then
				pop.tx = rx*8 + flr(rnd(8))
				pop.ty = ry*8 + flr(rnd(8))
			end

			pop.t = t
		end

		xf = flr(pop.x)
		xy = flr(pop.y)
		xdif = pop.tx - xf
		ydif = pop.ty - xy
		dist = sqrt(sq_dist(pop.tx, pop.ty, xf, xy))
		if dist != 0 then
			xdif /= dist
			ydif /= dist
			pop.x += xdif * pop_speed
			pop.y += ydif * pop_speed
		end

		pop.tile_x = mid(0, flr(pop.x / 8), 127)
		pop.tile_y = mid(0, flr(pop.y / 8), 127)

		if tile_x != pop.tile_x or tile_y != pop.tile_y then
			del(pop_map[tile_x + 1][tile_y + 1], pop)
			add(pop_map[pop.tile_x + 1][pop.tile_y + 1], pop)
		end

		if pop.hp <= 0 then
			del(pops, pop)
			del(pop.city.pops, pop)
			if pop.job != nil then
				del(pop.job.assigned, pop)
			end
			del(pop_map[pop.tile_x + 1][pop.tile_y + 1], pop)
			pop.city.pop -= 1
			return
		end

		
		if t - pop.attack_t > 1 then
			pop.attack_t = t + rnd()

			enemies = {}
			for p in all(pop_map[pop.tile_x + 1][pop.tile_y + 1]) do
				if pop.city.nation != p.city.nation then
					add(enemies, p)
				end
			end
			if #enemies > 0 then
				e = enemies[ceil(rnd(#enemies))]
				e.hp -= pop.damage
				if rnd() < 0.2 then
					pop.hp -= e.damage
				end
			else
				if pop.hp < 10 then
					pop.hp += 1
				end
			end
		end
	end
end


function remove_territory(nation, x0, y0, x1, y1)
	for x = x0+1,x1+1 do
		for y = y0+1,y1+1 do
			if x > 0 and x <= 128 and y > 0 and y <= 64 then
				nation.territory[x][y] = false
			end
		end
	end
end

function add_territory(nation, x0, y0, x1, y1)

	for x = x0+1,x1+1 do
		for y = y0+1,y1+1 do
			if x > 0 and x <= 128 and y > 0 and y <= 64 then
				overlap = false
				for n in all(nations) do
					if n != nation then
						if (n.territory[x][y]) overlap = true
					end
				end
				if not overlap then
					nation.territory[x][y] = true
					nation.expansion_area[x][y] = true
				end
			end
		end
	end
end

function remove_expansion_area(nation, x0, y0, x1, y1)
	for x = x0+1,x1+1 do
		for y = y0+1,y1+1 do
			if x > 0 and x <= 128 and y > 0 and y <= 64 then
				nation.expansion_area[x][y] = false
			end
		end
	end
end

function add_expansion_area(nation, x0, y0, x1, y1)
	for x = x0+1,x1+1 do
		for y = y0+1,y1+1 do
			if x > 0 and x <= 128 and y > 0 and y <= 64 then
				nation.expansion_area[x][y] = true
			end
		end
	end
end

function try_place_rally(x, y, nation)

	target_city = nil

	for c in all(cities) do
		if c.x == x and c.y == y then
			target_city = c
			break
		end
	end

	if target_city == nil then
		if nation.expansion_area[x+1][y+1] then
			min_dist = 10000
			city = nil
			for c in all(nation.cities) do
				dist = sqrt(sq_dist(c.x, c.y, x, y))

				if dist < min_dist then
					city = c
					min_dist = dist
				end
 			end

			city.rx = x
			city.ry = y
		end	
	elseif target_city.nation == nation then
		if target_city.rx != target_city.x and target_city.ry != target_city.y then
			target_city.rx = x
			target_city.ry = y
		else
			for c in all(nation.cities) do
				x_dist = abs(c.x - x)
				y_dist = abs(c.y - y)
				if x_dist <= 10 and y_dist <= 10 then
					c.rx = x
					c.ry = y
				end
			end
		end
	else
		for c in all(nation.cities) do
			x_dist = abs(c.x - x)
			y_dist = abs(c.y - y)
			if x_dist <= 10 and y_dist <= 10 then
				c.rx = x
				c.ry = y
			end
		end
	end
end

build = 0
settle = 1

jobs = {}
function try_settle(x, y, nation)
	if not is_tile_at(x, y, ground) or not nation.expansion_area[x+1][y+1] then
		return false
	end

	for n in all(nations) do
		if n.territory[x+1][y+1] then
			return false
		end
	end

	for j in all(jobs) do
		if j.x == x and j.y == y then
			return false
		end
	end

	if nation.wood < nation.settle_cost then
		return false
	end

	local job = {}
	job.x = x
	job.y = y
	job.assigned = {}
	job.progress = 0
	job.required = 500
	job.can_continue = function()
		overlap = false
		for n in all(nations) do
			if n.territory[x+1][y+1] then
				overlap = true
			end
		end
		return is_tile_at(x, y, ground) and not overlap
	end
	job.done = false
	job.type = settle
	job.nation = nation

	candidate = nil
	min_dist = 10000
	for c in all(nation.cities) do
		dist = sqrt(sq_dist(c.x, c.y, x, y))
		print(dist)

		if dist < min_dist then
			min_dist = dist
			candidate = c
		end
	end

	if candidate != nil and candidate.pop >= 3 then
		local job_pops = {}

		for pop in all(candidate.pops) do
			if pop.job == nil or pop.job.type != settle then
				add(job_pops, pop)
			end
			if #job_pops >= 2 then
				break
			end
		end

		if #job_pops != 2 then
			return false
		end
		job.assigned = job_pops

		for p in all(job_pops) do
			p.job = job
		end

		job.on_done = function()
			city = make_city(job.x, job.y, job.nation)
			for p in all(job_pops) do
				p.city.pop -= 1
				del(p.city.pops, p)
				p.city = city
				add(city.pops, p)
				city.pop += 1
			end
		end

		add(jobs, job)
		nation.wood -= nation.settle_cost
		nation.settle_cost += 15
		return true
	end

	return false
end

function try_build(x, y, nation)

	local build_mapping = get_build_mapping(x, y)

	if is_tile_at(x, y, water) then
		if build_mapping == nil or not nation.expansion_area[x+1][y+1] then
			return false
		end

		for n in all(nations) do
			if n.territory[x+1][y+1] then
				return false
			end
		end
	else
		if build_mapping == nil or not nation.territory[x+1][y+1] then
			return false
		end
	end

	for j in all(jobs) do
		if j.x == x and j.y == y then
			return false
		end
	end

	cost = build_mapping["cost"]
	if cost["wood"] > nation.wood or cost["gold"] > nation.gold then
		return false
	end
	
	local job = {}
	job.x = x
	job.y = y
	job.assigned = {}
	job.progress = 0
	job.required = 200
	job.can_continue = function()
		local bmap = get_build_mapping(x, y)
		if is_tile_at(x, y, water) then
			for n in all(nations) do
				if n.territory[x+1][y+1] then
					return false
				end
			end
			return bmap == build_mapping and nation.expansion_area[x+1][y+1]
		else
			return bmap == build_mapping and nation.territory[x+1][y+1]
		end
	end
	job.done = false
	job.on_done = build_mapping["func"]
	job.type = build
	job.nation = nation

	added = false
	local cities = {}
	if is_tile_at(x, y, water) then
		min_dist = 10000
		city = nil
		for c in all(nation.cities) do
			dist = sq_dist(c.x, c.y, x, y)
			if dist < min_dist then
				min_dist = dist
				city = c
			end
		end

		add(cities, city)
		add(city.jobs, job)
		added = true
	else
		for c in all(nation.cities) do
			xdist = abs(c.x - x)
			ydist = abs(c.y - y)

			if xdist <= 5 and ydist <= 5 then
				add(c.jobs, job)
				add(cities, c)
				added = true
			end
		end
	end
	
	job.cities = cities
	if added then
		add(jobs, job)
		nation.wood -= cost["wood"]
		nation.gold -= cost["gold"]
		return true
	end
	return false
end

-->8
-- draw functions

function _draw()
	if state == "menu" then
		draw_menu()
	elseif state == "game" then
		draw_game()
	end
end

function draw_game()
	cls()
	clip(0, 0, 128, 112)
	px = cx - 4
	py = cy - 4
	if(cx == 896 or cx == 0) px = cx
	if(cy == 400 or cy == 0) py = cy
	map(flr(cx/8), flr(cy/8), px, py, 17, 15)
	camera(cx, cy)
	draw_cities()
	draw_buildings()

	draw_selection(sel_x, sel_y, sel_x, sel_y, 8)

	draw_pops()
	draw_borders()
	draw_jobs()
	draw_job_progress()

	if sel_city != nil then
		print(sel_city.pop .. "/" .. min(flr(sel_city.max_pop), 9), 
				sel_city.x * 8 - 2, sel_city.y * 8 + 10, 7)
	end

	clip()
	camera()

	if timer <= 0 then
		if winner == player then
			draw_text_outline("you won!", 48, 48, 10)
		else
			draw_text_outline("you lost...", 42, 48, 7)
			winnerstr = "winner's score: " .. tostr(winner.score)
			draw_text_outline(winnerstr,  64 - #winnerstr * 2, 68, winner.color)
		end
		scorestr = "your score: " .. tostr(player.score)
		draw_text_outline(scorestr, 64 - #scorestr * 2, 58, 7)

		draw_text_outline("press ❎ to return to menu", 14, 100, 7)
	end

	draw_ui()
end

anim_t = time()
logo_y = 20
text_y = 90
function draw_menu()
	cls()
	clip()
	map(0, 0, 0, 0, 16, 16)

	if time() - anim_t >= 0.5 then
		anim_t = time()

		if logo_y == 20 then
			logo_y = 21
		else
			logo_y = 20
		end

		if text_y == 90 then
			text_y = 91
		else
			text_y = 90
		end
	end


	draw_text_outline("press 🅾️ to start", 30, text_y, 7)

	palt(0, false)
	palt(11, true)
	sspr(0, 32, 49, 27, 15, logo_y, 98, 54)
	palt()
end

function draw_text_outline(text, x, y, col, outline_col) 
	if(not outline_col) outline_col = 0
	print(text, x + 1, y, outline_col)
	print(text, x, y + 1, outline_col)
	print(text, x - 1, y, outline_col)
	print(text, x, y - 1, outline_col)
	print(text, x, y, col)
end

function draw_ui()
	spr(35, 4, 116)
	print(player.wood, 14, 118, 7)
	
	spr(36, 36, 116)
	print(player.gold, 46, 118, 7)

	spr(51, 100, 117)
	print(ceil(timer), 110, 118, 7)
end

sel_city = nil
function draw_cities()

	for c in all(cities) do
		pal(7, c.nation.color)
		spr(6, c.x*8, c.y*8)
		pal()

		w = flr(c.takeover/100 * 9) - 1

		if w >= 0 then
			rectfill(c.x*8, c.y*8, c.x*8+w, c.y*8+7, c.attacking_nation.color)
		end
	end

	sel_city = nil
	for c in all(player.cities) do
		if not (c.rx == c.x and c.ry == c.y) then 
			spr(19, c.rx*8, c.ry*8) 
		end

		if sel_x == c.x and sel_y == c.y then
			sel_city = c
		end
	end
end

function draw_buildings()

	for b in all(buildings) do
		if b.sprite != nil then
			pal(7, b.nation.color)
			spr(b.sprite, b.x*8, b.y*8)
			pal()
		end
	end
end

function draw_borders()

	draw_nation_borders()

	draw_bitmap_outline(player.expansion_area, 5)
end

function draw_jobs()
	for j in all(jobs) do
		x = j.x*8
		y = j.y*8
		spr(20 + j.type, x, y)
	end
end

function draw_job_progress()
	for j in all(jobs) do
		x = j.x*8
		y = j.y*8

		w = flr(j.progress/j.required * 9) - 1
		if w >= 0 then
			rectfill(x, y-3, x+w, y-2, 8)
		end
	end
end

function draw_pops()
	srand(1)
	for pop in all(pops) do
		if is_tile_at(flr(pop.x / 8), flr(pop.y / 8), water) then
			pset(pop.x, pop.y, 4)
			pset(pop.x-1, pop.y, 4)
			pset(pop.x+1, pop.y, 4)
			pset(pop.x, pop.y-1, pop.city.nation.color)
		else
			pset(pop.x, pop.y, pop.city.nation.color)
		end
	end
end

last_t=time()
patt=0b1010010110100101.1
function draw_selection(x0, y0, x1, y1, c)
	tx = x0 * 8-1
	ty = y0 * 8-1
	fillp(patt)
	if time() - last_t >= 0.5 then
		patt = bor(bnot(patt),0b.1)
		last_t = time()
	end
	rect(tx, ty, x1*8+8, y1*8+8, c)
	fillp()
end

function draw_nation_borders()
	fillp(patt)

	for x = max(0,flr(cx/8)),min(flr(cx/8) + 16, 127) do
		for y = max(0,flr(cy/8)),min(flr(cy/8) + 14, 63) do
			for n in all(nations) do
				if n.territory[x+1][y+1] then
					if x > 0 then
						if not n.territory[x][y+1] then
							line(x * 8 - 1, y * 8, x * 8 - 1, y * 8 + 7, n.color)
						end
					end
					if x < 127 then
						if not n.territory[x+2][y+1] then
							line(x * 8 + 8, y * 8, x * 8 + 8, y * 8 + 7, n.color)
						end
					end
					if y > 0 then
						if not n.territory[x+1][y] then
							line(x * 8, y * 8 - 1, x * 8 + 7, y * 8 - 1, n.color)
						end
					end
					if y < 63 then
						if not n.territory[x+1][y + 2] then
							line(x * 8, y * 8 + 8, x * 8 + 7, y * 8 + 8, n.color)
						end
					end
				end
			end
		end
	end
	fillp()
end

function draw_bitmap_outline(bitmap, c)
	fillp(patt)
	
	for x = 0,#bitmap-1 do
		for y = 0,#bitmap[x+1]-1 do
			if bitmap[x+1][y+1] then
				if x > 0 then
					if not bitmap[x][y+1] then
						line(x * 8 - 1, y * 8, x * 8 - 1, y * 8 + 7, c)
					end
				end
				if x < #bitmap - 1 then
					if not bitmap[x+2][y+1] then
						line(x * 8 + 8, y * 8, x * 8 + 8, y * 8 + 7, c)
					end
				end
				if y > 0 then
					if not bitmap[x+1][y] then
						line(x * 8, y * 8 - 1, x * 8 + 7, y * 8 - 1, c)
					end
				end
				if y < #bitmap[x+1]-1 then
					if not bitmap[x+1][y + 2] then
						line(x * 8, y * 8 + 8, x * 8 + 7, y * 8 + 8, c)
					end
				end
			end
		end
	end

	fillp()
end

-->8
-- map generation

grd_size = 129

ground={1}
forest={2,18,34,50}
beach={3}
mountain={4, 22, 23}
water={5}
village={6}
farm={8,24,40,56}
ship={9}

sgen={32,48,120,120}

function tile_in_area(x0,y0,x1,y1,tile)
	local x,y
	for x=x0,x1 do
		for y=y0,y1 do
			if(is_tile_at(x,y,tile))return true
		end
	end
	return false
end

function find_spawnpoints()
	points = {}
	for x = 0,127 do
		for y = 0,63 do
			if is_tile_at(x,y,ground) then
				
				if not overlap then
					if tile_in_area(x-5,y-5,x+5,y+5,forest) then
						add(points, {x=x, y=y})
					end
				end
			end
		end
	end
	return points
end

function gen_map()
	cls()
	print("generating...",38,60,4)
	flip()
	grid=dsquare_noise()
	pop_map = {}
	ys = ceil(rnd(64))
	for x=1,128 do
		pop_col = {}
		for y=ys,ys+64 do
			c = grid[x][y]
			tile=0
			if c < sgen[1] then tile=water
			elseif c<sgen[2] then tile=beach
			elseif c<sgen[3] then tile=ground
			else tile=mountain end
			tileset(x-1,y-1-ys,tile)
			add(pop_col, {})
		end
		add(pop_map, pop_col)
	end
	gen_forests()
	
	
	spawn_points = find_spawnpoints()

	if #spawn_points < num_nations then
		return gen_map()
	end

	for i = 0, num_nations - 1 do
		repeat
			p = spawn_points[ceil(rnd(#spawn_points))]
			del(spawn_points, p)
			if #spawn_points < num_nations - #nations then
				return gen_map()
			end

			overlap = false
			for n in all(nations) do
				if n.expansion_area[p.x+1][p.y+1] or n.territory[p.x+1][p.y+1] then
					overlap = true
				end
			end
		until(not overlap)

		sx = p.x
		sy = p.y

		local nation = make_nation()
		city = make_city(sx, sy, nation)
		make_pop(sx*8+4, sy*8+4, city)
	end
	
	player = nations[ceil(rnd(#nations))]
	
	sel_x = player.cities[1].x
	sel_y = player.cities[1].y
end

function tileset(x,y,tile)
	local i=ceil(rnd(#tile))
	mset(x,y,tile[i])
end

function is_tile(t,tile)
	local v
	for v in all(tile) do
		if(t==v)return true
	end
	return false
end

function is_tile_at(x,y,tile)
	local val=mget(x,y)
	return is_tile(val,tile)
end

function gen_forests() 
	for i=0,num_forests do
		x=flr(rnd(128))
		y=flr(rnd(64))
		
		if is_tile_at(x,y,ground) then
			tileset(x,y,forest)
			for j=0,forest_size do
				local a = 0
				repeat
					xo=flr(rnd(3))-1
					yo=flr(rnd(3))-1
					a+=1
				until(not is_tile_at(x+xo,y+yo,forest) or a>8)
 			
 			t = mget(x+xo,y+yo)
				if is_tile(t,ground) or is_tile(t,mountain) then
					x+=xo
					y+=yo
					tileset(x,y,forest)
				end
			end
		end
	end
end

function dsquare_noise()
	
	grid = {}
	for i=0,grd_size-1 do
		local col={}
		for j=0,grd_size-1 do
			add(col,0)
		end
		add(grid,col)
	end
	grid[1][1]=c_offset + rnd(c_range)
	grid[grd_size][1]=c_offset + rnd(c_range)
	grid[grd_size][grd_size]=c_offset + rnd(c_range)
	grid[1][grd_size]=c_offset + rnd(c_range)
	
	step=grd_size-1
	r=r_start
	while step>1 do
		for x=1,grd_size-1,step do
			for	y=1,grd_size-1,step do
				do_step(grid, x, y, step,r)
			end
		end
		step /= 2
		r/=roughness
	end
	
	return grid
end

function get(grid,x,y)
	local c,r=x,y
	if(c<=0)c+=grd_size-1
	if(r<=0)r+=grd_size-1
	if(c>grd_size)c-=grd_size
	if(r>grd_size)r-=grd_size
	return grid[c][r]
end

function do_step(grid,x,y,step,r)
	local h=step/2
	grid[x+h][y+h]=diamond(grid,x,y,step,r)
	grid[x+h][y]=square(grid,x+h,y,h,r)
	grid[x+h][y+step]=square(grid,x+h,y+step,h,r)
	grid[x][y+h]=square(grid,x,y+h,h,r)
	grid[x+step][y+h]=square(grid,x+step,y+h,h,r)
end

function diamond(grid,x,y,step,r)
	local sum=0
	for xo=0,step+1,step do
		for yo=0,step+1,step do
			sum+=get(grid,x+xo,y+yo)
		end
	end
	return mid(0,sum/4 + (rnd(2)-1)*r,128)
end

function square(grid,x,y,h,r)
	local sum=0
	sum += get(grid,x+h,y)
	sum += get(grid,x-h,y)
	sum += get(grid,x,y+h)
	sum += get(grid,x,y-h)
	return mid(0,sum/4 + (rnd(2)-1)*r/1.5,128)
end

-->8
-- make functions
buildings = {}

pops = {}
function make_pop(x, y, city)
	local pop = {}
	pop.x = x
	pop.y = y
	pop.hp = 10
	pop.damage = 1
	pop.attack_t = time()
	pop.tile_x = flr(x / 8)
	pop.tile_y = flr(y / 8)
	pop.tx = x
	pop.ty = y
	pop.city = city
	pop.job = nil

	pop.t = time()
	add(pops, pop)
	add(city.pops, pop)
	add(pop_map[pop.tile_x + 1][pop.tile_y + 1], pop)
	city.pop += 1
	return pop
end

cities = {}
function make_city(x, y, nation)
	local city = {}
	city.max_pop = 2
	city.pop = 0
	city.jobs = {}
	city.pops = {}
	city.nation = nation
	city.settle_time = 0
	city.farms = 0
	city.takeover = 0
	city.attacking_nation = nil
	city.x = x
	city.y = y
	city.rx = x
	city.ry = y

	add_territory(nation, x-5, y-5, x+5, y+5)
	add_expansion_area(nation, x-10, y-10, x+10, y+10)
	
	add(nation.cities, city)

	for b in all(buildings) do
		if b.type == "farm" and b.nation == nation then
			xdist = abs(b.x-x)
			ydist = abs(b.y-y)

			if xdist <= 5 and ydist <= 5 then
				city.farms += 1
				city.max_pop += 0.5
				city.max_pop = max(1, city.max_pop)
			end
		end
	end

	add(cities, city)
	tileset(x, y, village)
	return city
end

nations = {}
nation_colors = {1, 2, 8, 9, 13, 14, 15}
function make_nation()
	local nation = {}
	nation.cities={}
	nation.wood=45
	nation.gold=5
	nation.settle_cost = 15
	nation.mills = 0
	nation.farms = 0
	nation.mines = 0
	nation.score = 0
	nation.color = nation_colors[ceil(rnd(#nation_colors))]
	del(nation_colors, nation.color)
	nation.territory=make_bitmap(128, 64)
	nation.expansion_area=make_bitmap(128, 64)
	add(nations, nation)
	return nation
end

function make_bitmap(cols, rows)
	local map = {}
	for x = 1, cols do
		local col = {}
		for y = 1, rows do
			add(col, false)
		end
		add(map, col)
	end

	return map
end

function make_building(x, y, nation)
	local building = {}
	building.x = x
	building.y = y
	building.nation = nation
	building.update = function() end
	building.sprite = nil
	add(buildings, building)
	return building
end

function make_lumbermill(x, y, nation, job_cities)
	local mill = make_building(x, y, nation)
	mill.last_t = time()
	mill.type = "mill"
	mill.sprite = 7
	mill.update = function()
		if time() - mill.last_t > 5 then
			nation.wood += 1
			mill.last_t = time()
		end
	end

	nation.mills += 1

	mset(x, y, 7)
end

function make_farm(x, y, nation, job_cities)
	local farm_building = make_building(x, y, nation)
	farm_building.type = "farm"
	for c in all(job_cities) do
		c.max_pop += 0.5
		c.max_pop = max(1, c.max_pop)
		c.farms += 1
	end

	nation.farms += 1

	tileset(x, y, farm)
end

function make_ship(x, y, nation)
	local ship_building = make_building(x, y, nation)
	ship_building.type = "ship"

	add_expansion_area(nation, x - 5, y - 5, x + 5, y + 5)
	tileset(x, y, ship)
end

function make_mine(x, y, nation, job_cities)
	local mine_building = make_building(x, y, nation)
	mine_building.last_t = time()
	mine_building.type = "mine"
	mine_building.update = function()
		if time() - mine_building.last_t > 5 then
			nation.gold += 1
			mine_building.last_t = time()
		end
	end

	nation.mines += 1

	val = mget(x, y)
	if val == 4 then
		mset(x, y, 10)
	elseif val == 22 then
		mset(x, y, 26)
	elseif val == 23 then
		mset(x, y, 42)
	end
end

buildmap = {}
buildmap[forest] = {func=make_lumbermill, cost={wood=5, gold=0}}
buildmap[ground] = {func=make_farm, cost={wood=8, gold=0}}
buildmap[water] = {func=make_ship, cost={wood=25, gold=0}}
buildmap[mountain] = {func=make_mine, cost={wood=15, gold=5}}

function get_build_mapping(x, y)
	val = mget(x, y)
	for k,v in pairs(buildmap) do
		for i in all(k) do
			if val == i then
				return v
			end
		end
	end
	return nil
end

__gfx__
00000000333333333b33bbb3ffffffff33373333cccccccc35333333b33b333333333333ccc757cc333773330000000000000000000000000000000000000000
0000000033333333bbb3bbb3ffffffff33377333cccccccc545333533b33353334b434b3cc77477c333773330000000000000000000000000000000000000000
007007003333333332333433ff6fffff33777733cccccccc44433545bbb354533b4b3b43c7774777337777330000000000000000000000000000000000000000
00077000333333333bbb3333ffffffff35755773cccccccc4453344434334443333334b3c7774ccc557507730000000000000000000000000000000000000000
00077000333333333bbb33b3ffffff6f56655563cccccccc354534443333444334a43b4344cc4c445544f5630000000000000000000000000000000000000000
00700700333333333bbb3bbbffffffff66555655cccccccc34443333b33644433a4a34b344444444665556050000000000000000000000000000000000000000
000000003333333333433bbbff6fffff55556655cccccccc344433333333333334a43b4322444442055064450000000000000000000000000000000000000000
000000003333333333333323ffffffff33555553cccccccc3333333333b4444b33333333cc22222c335444530000000000000000000000000000000000000000
000000006666666633333bbb00000000660660660000000033733333333333333333333300000000337333330000000000000000000000000000000000000000
000000006666666633bb3bbb00008000600000060002200033733333377733333b4b4a4300000000337333330000000000000000000000000000000000000000
000000006666666633bbb343000880000006600000222200377733733766773334b4b4a300000000377733730000000000000000000000000000000000000000
00000000666666663334333300888000600066060222222036573653766655633b4a4b4300000000365736030000000000000000000000000000000000000000
00000000666666663b33b33b000080006006060602222220565566555565555534a4b4b300000000560566450000000000000000000000000000000000000000
0000000066666666bbb3333300008000006000000202202065555565555655553b4b4a4300000000654450650000000000000000000000000000000000000000
0000000066666666343333b3000080006000000602022220555556555555555534b4b4b30000000055554f450000000000000000000000000000000000000000
00000000666666663333333300000000660660660000000033355553355555533333333300000000333555530000000000000000000000000000000000000000
00000000000000003bb3333300444400000000000000000000000000000000003333333300000000333333330000000000000000000000000000000000000000
00000000000000003bbb333304ffff400000000000000000000000000000000034a334b300000000377733330000000000000000000000000000000000000000
00000000000000003bbb333304ffff40009999000000000000000000000000003a433b4300000000376077330000000000000000000000000000000000000000
000000000000000033433bb30444444009aaaa9000000000000000000000000034a334b300000000766445630000000000000000000000000000000000000000
00000000000000003333bbb3024242409a9999990000000000000000000000003a433b430000000050665f550000000000000000000000000000000000000000
00000000000000003333bbb3024242409a9aaaa900000000000000000000000034a334b300000000444455050000000000000000000000000000000000000000
00000000000000003333343304424440999999990000000000000000000000003a433b4300000000555554450000000000000000000000000000000000000000
00000000000000003333333300444400000000000000000000000000000000003333333300000000355555530000000000000000000000000000000000000000
000000000000000033333bbb00111000000000000000000000000000000000003333333300000000000000000000000000000000000000000000000000000000
0000000000000000b3333bbb01010100000000000000000000000000000000003b4b4b4300000000000000000000000000000000000000000000000000000000
000000000000000033b33343100100100000000000000000000000000000000034b4b4b300000000000000000000000000000000000000000000000000000000
00000000000000003333333310010010000000000000000000000000000000003b4b4b4300000000000000000000000000000000000000000000000000000000
00000000000000003b33bb3310001010000000000000000000000000000000003333333300000000000000000000000000000000000000000000000000000000
0000000000000000bbb3bbb301000100000000000000000000000000000000003b4b4b4300000000000000000000000000000000000000000000000000000000
000000000000000034333433001110000000000000000000000000000000000034b4b4b300000000000000000000000000000000000000000000000000000000
00000000000000003333333300000000000000000000000000000000000000003333333300000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbdddddddddddddddddddddddddbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbd111d111d111d1d1d111d111dbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbd1d1d1d1d1ddd1d1d1dddd1ddbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbd111d1d1d1dbb11dd111dd1dbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbd1ddd1d1d1ddd1d1d1dddd1dbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbd1dbd111d111d1d1d111dd1dbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbddddddddddddddddddddddddbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbd1dd11dbdd1dbbbbddddddbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbdddd1dd11ddd1ddddddd1dd1dbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbd1111111dd1111111d1dd1d1dbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbdddd1ddddddddd1dddd1dd1ddbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbd1d1d1dbbbbdd1dbbddd1ddbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbdd1d1d1dddddd1ddbddd1ddbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbd1dd1dd1dd111ddbbd11ddbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbddddddddddddddddddddddddddbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbd1dbbbbdddd1dddd111d111dbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbd1dddbbd1111111d1d1d1d1dbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbd111ddddd1ddd1dd111d111dbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbd1dd11ddd1ddd1dd1d1d1d1dbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbd1ddddbbdd1d1ddd111d111dbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbd1dbbbbbddd1dddd1ddd1d1dbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbd1dbbbbbd11d11dddd11d11dbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbddddddddddddddddddddddddddddbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbd111d1d1d1dd111d1d1d11dd111dbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbd1ddd1d1d1ddd1dd1d1d111d11ddbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbd111d111d11dd1dd111d1d1d111dbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbddddddddddddddddddddddddddddbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
ccccccccccccccccccccccccaaaaaaaa333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
ccccccccccccccccccccccccaaaaaaaa333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
ccccccccccccccccccccccccaaaaaaaa333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
ccccccccccccccccccccccccaaaaaaaa333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
ccccccccccccccccccccccccaaaaaaaa333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
ccccccccccccccccccccccccaaaaaaaa333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
ccccccccccccccccccccccccaaaaaaaa333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
ccccccccccccccccccccccccaaaaaaaa333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
ccc747ccccccccccaaaaaaaaaaaaaaaa3333333333333333333333333333333333333bbb333333333b33bbb333333bbb33333bbb333333333333333333333333
cc77477cccccccccaaaaaaaaaaaaaaaa33333333333333333333333333333333b3333bbb33333333bbb3bbb3333b3bbb333b3bbb333333333333333333333333
c7774777ccccccccaaaaaaaaaaaaaaaa3333333333333333333333333333333333333343333333333433343333bbb34333bbb343333333333333333333333333
c7774cccccccccccaaaaaaaaaaaaaaaa333333333333333333333333333333333333bb333333333333b333333334333333343333333333333333333333333333
44cc4c44ccccccccaaaaaaaaaaaaaaaa333333333333333333333333333333333b3bbb33333333333bbb3bbbbbb3b33bbbb3b33b333333333333333333333333
c4444444ccccccccaaaaaaaaaaaaaaaa33333333333333333333333333333333bbb34333333333333bbb3bbbbbb33333bbb33333333333333333333333333333
c1444441ccccccccaaaaaaaaaaaaaaaa33333333333333333333333333333333343333b33333333333433bbb343333b3343333b3333333333333333333333333
cc11111cccccccccaaaaaaaaaaaaaaaa333333333333333333333333333333333333333333333333333333433333333333333333333333333333333333333333
ccccccccaaaaaaaaaaaaaaaa333333333333333333b3333333b3333333333bbb333333333333333333333333333333333b33bbb333333bbb3b33bbb333333333
ccccccccaaaaaaaaaaaaaaaa33333333333333333bbb33333bbb3333b3333bbb33333333333333333333333333333333bbb3bbb3b3333bbbbbb3bbb333333333
ccccccccaaaaaaaaaaaaaaaa33333333333333333bbb33333bbb3333333333433333333333333333333333333333333334333433333333433433343333333333
ccccccccaaaaaaaaaaaaaaaa333333333333333333433b3333433b333333bb333333333333333333333333333333333333b333333333bb3333b3333333333333
ccccccccaaaaaaaaa000000000000000000000033333bbb33333bbb33b3bbb33333333333333333333333333333333333bbb3bbb3b3bbb333bbb3bbb33333333
ccccccccaaaaaaaaa000000000000000000000033333bbb33333bbb3bbb34333333333333333333333333333333333333bbb3bbbbbb343333bbb3bbb33333333
ccccccccaaaaaaa00999999999999999999999900333343333333433343333b33333333333333333333333333333333333433bbb343333b333433bbb33333333
ccccccccaaaaaaa00999999999999999999999900333333333333333333333333333333333333333333333333333333333333343333333333333334333333333
ccccccccaaaaaaa0099888888888888888888990033333333b33bbb3333333333000000000000000033333333b33bbb3b33b3333b33b333333333bbb33b33333
ccccccccaaaaaaa009988888888888888888899003333333bbb3bbb333333333300000000000000003333333bbb3bbb33b3337333b333733333b3bbb3bbb3333
ccccccccaaaaaaa009988888888888888888899000000000000000000000000009999999999999999000000000000000000000000000047333bbb3433bbb3333
ccccccccaaaaaaa00998888888888888888889900000000000000000000000000999999999999999900000000000000000000000000004433334333333433b33
ccccccccaaaaaaa0099888888888888888888999999999999999999999999999999888888888888999999999999999999999999999999003bbb3b33b3333bbb3
ccccccccaaaaaaa0099888888888888888888999999999999999999999999999999888888888888999999999999999999999999999999003bbb333333333bbb3
ccccccccaaaaaaa009988888899999988888899aa99aa9988888899aa99aa9999888888888888888899aa99aa99998888888888888899990043333b333333433
ccccccccaaaaaaa009988888899999988888899aa99aa9988888899aa99aa9999888888888888888899aa99aa999988888888888888999900333333333333333
aaaaaaaa33b333300998888889999998888889999aa99998888889999aa99aa9988888888888888889999aa99998888888888888888889900333333333333333
aaaaaaaa3bbb33300998888889999998888889999aa99998888889999aa99aa9988888888888888889999aa99998888888888888888889900333333333333333
aaaaaaaa3bbb333009988888899999988888899aa99aa9988888899aa99aa9999888888999988888899aa99aa998888888888888888889900333333333333333
aaaaaaaa33433b3009988888899999988888899aa99aa9988888899aa99aa9999888888999988888899aa99aa998888888888888888889900333333333333333
aaaaaaaa3333bbb00998888888888888888889999aa99999999999999aa99aa9988888899999999999999aa99998888889999998888889900333333333333333
aaaaaaaa3333bbb00998888888888888888889999aa99999999999999aa99aa9988888899999999999999aa99998888889999998888889900333333333333333
aaaaaaaa3333343009988888888888888888899aa99aa9999999999aa99aa99998888889999aa99aa99aa99aa998888889999998888889900333333333333333
aaaaaaaa3333333009988888888888888888899aa99aa9999999999aa99aa99998888889999aa99aa99aa99aa998888889999998888889900333333333333333
3b33bbb33b33bbb00998888888888888888889999aa99998888889999aa99aa9988888899aa99aa99aa99aa99998888889999998888889900337333333333333
bbb3bbb3bbb3bbb00998888888888888888889999aa99998888889999aa99aa9988888899aa99aa99aa99aa99998888889999998888889900337733333333333
343334333433343009988888899999999999999aa99aa9988888899aa99aa9999888888999999999999aa99aa998888889999998888889900377773333333333
33b3333333b3333009988888899999999999999aa99aa9988888899aa99aa9999888888999999999999aa99aa998888889999998888889900575077333333333
3bbb3bbb3bbb3bb00998888889999aa99aa99aa99aa99998888889999aa99aa9988888899998888889999aa99998888889999998888889900544456333333333
3bbb3bbb3bbb3bb00998888889999aa99aa99aa99aa99998888889999aa99aa9988888899998888889999aa99998888889999998888889900655560533333333
33433bbb33433bb009988888899aa99aa99aa99aa99aa9988888899aa99aa9999888888888888888899aa99aa998888888888888888889900550644533333333
333333433333334009988888899aa99aa99aa99aa99aa9988888899aa99aa9999888888888888888899aa99aa998888888888888888889900354445333333333
3b33bbb3aaaaaaa00998888889999aa99aa99aa99aa99998888889999aa99aa9988888888888888889999aa99998888888888888888889900337333333333333
bbb3bbb3aaaaaaa00998888889999aa99aa99aa99aa99998888889999aa99aa9988888888888888889999aa99998888888888888888889900337733333333333
34333433aaaaaaa009988888899aa99aa99aa99aa99aa9988888899aa99aa9999998888888888889999aa99aa999988888888888888999900377773333333333
33b33333aaaaaaa009988888899aa99aa99aa99aa99aa9988888899aa99aa9999998888888888889999aa99aa999988888888888888999900575577333333333
3bbb3bbbaaaaaaa00999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999990035665556333333333
3bbb3bbbaaaaaaa00999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999990056655565533333333
33433bbbaaaaaaaac009922992299229922992299229922992299229922992299229922992299229922992299229922992299229922990055555665533333333
33333343aaaaaaaac009922992299229922992299229922992299229922992299229922992299229922992299229922992299229922990033355555333333333
3b33bbb333333333a002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220033333333333333333
bbb3bbb333333333a002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220033777333337773333
3433343333333333a002277777722227766222277776666222277777766666622777722227777662222777777222277662222777766220033766773337667733
33b3333333333333a002277777722227766222277776666222277777766666622777722227777662222777777222277662222777766220037666556376665563
3bbb3bbb33333333a002277666666226666227766666666662266666666dddd22776622776666666622776666662266662277662222220055565555555655555
3bbb3bbb33333333a002277666666226666227766666666662266666666dddd22776622776666666622776666662266662277662222220055556555555565555
33433bbb33333333a00226666dd666666662266662222666622222266dd2222226666227766226666226666dd66666666226666dd22220055555555555555555
3333334333333333a00226666dd666666662266662222666622222266dd2222226666227766226666226666dd66666666226666dd22220033555555335555553
3333333333333333a002266dd22dd6666dd226666666666dd22002266dd22002266dd2277662266dd2266dd22dd6666dd22226666dd2200333b3333333333333
3333333333333333a002266dd22dd6666dd226666666666dd22002266dd22002266dd2277662266dd2266dd22dd6666dd22226666dd220033bbb333337773333
3333333333333333a002266dd2222dd66dd226666dddd66dd22002266dd22002266dd2266666666dd2266dd2222dd66dd22222266dd220033bbb333337667733
3333333333333333a002266dd2222dd66dd226666dddd66dd22002266dd22002266dd2266666666dd2266dd2222dd66dd22222266dd2200333433b3376665563
3333333333333333a002266dd222222dddd2266dd2222dddd22002266dd22002266dd222266dddd222266dd222222dddd227777dd222200b3333bbb355655555
3333333333333333a002266dd222222dddd2266dd2222dddd22002266dd22002266dd222266dddd222266dd222222dddd227777dd222200b3333bbb355565555
3333333333333333a00222222220022222222222222222222220022222222002222222222222222222222222200222222222222222200bbb3333343355555555
3333333333333333a002222222200222222222222222222222200222222220022222222222222222222222222002222222222222222003433333333335555553
33333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000733333337333333733333
33333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000773333337733333733333
333333333333333333333333333333333333333333333333333333333333333333bbb3433bbb33333bbb3333343334333bbb3333337777333377773337773373
33333333333333333333333333333333333333333333333333333333333333333334333333433b3333433b3333b3333333433b33357557733575577336573653
3333333333333333333333333333333333333333333333333333333333333333bbb3b33b3333bbb33333bbb33bbb3bbb3333bbb3566555635665556356556655
3333333333333333333333333333333333333333333333333333333333333333bbb333333333bbb33333bbb33bbb3bbb3333bbb3665556556655565565555565
3333333333333333333333333333333333333333333333333333333333333333343333b3333334333333343333433bbb33333433555566555555665555555655
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333334333333333335555533355555333355553
3333333333333333333333333333333333b33333333333333333333333333bbb33333bbb33333bbb33b3333333b3333333333bbb333333333337333333733333
333333333333333333333333333333333bbb33333333333333333333333b3bbb333b3bbb333b3bbb3bbb33333bbb3333333b3bbb333333333337733333733333
333333333333333333333333333333333bbb3333333333333333333333bbb34333bbb34333bbb3433bbb33333bbb333333bbb343333333333377773337773373
3333333333333333333333333333333333433b33333333333333333333343333333433333334333333433b3333433b3333343333333333333575577336573653
333333333333333333333333333333333333bbb33333333333333333bbb3b33bbbb3b33bbbb3b33b3333bbb33333bbb3bbb3b33b333333335665556356556655
333333333333333333333333333333333333bbb33333333333333333bbb33333bbb33333bbb333333333bbb33333bbb3bbb33333333333336655565565555565
33333333333333333333333333333333333334333333333333333333343333b3343333b3343333b33333343333333433343333b3333333335555665555555655
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333355555333355553
33333333333333333333333333333333333333333333333333333333b33b33333333333333b3333333333bbb33333bbb33333bbb3b33bbb33333333333333333
3333333334b434b33b44b4333333330003000300033003300333333000003733330003300bbb333003000b0003000b0003303bbbbbb3bbb33333333333333333
333333333b4b3b4334b44b3333333077707770777007700770333307777704733077700770bb3307707770777077707770070343343334333333333333333333
33333333333334b33b44b4333333307070707070007000700333307700077043330700707043307003070070707070070307033333b333333333333333333333
3333333334a33b4334b44b333333307770770077007770777033307707077043330700707033b07770070077707703070b07033b3bbb3bbb3333333333333333
333333333a4334b33b44b4333333307000707070030070007033307700077043330700707033bb0070070070707070070bb033333bbb3bbb3333333333333333
3333333334a33b4334b44b33333330703070707770770077033333077777033333070077033330770407007070707007040703b333433bbb3333333333333333
333333333333333333333333333333033303030003003300333333300000333b3330330033333300333033030303033033303333333333433333333333333333
333333333333333333333333373333333333333333333333b33b333333333bbb333333333333333333333bbb33333333333333333b33bbb333b333333b33bbb3
333333333b44b4333b4b4b437473337333333333333333333b333733333b3bbb3333333333333333b3333bbb3333333333333333bbb3bbb33bbb3333bbb3bbb3
3333333334b44b3334b4b4b3444337473333333333333333bbb3747333bbb3433333333333333333333333433333333333333333343334333bbb333334333433
333333333b44b4333b4b4b43447334443333333333333333343344433334333333333333333333333333bb33333333333333333333b3333333433b3333b33333
3333333334b44b333333333337473444333333333333333333334443bbb3b33b33333333333333333b3bbb3333333333333333333bbb3bbb3333bbb33bbb3bbb
333333333b44b4333b4b3b43344433333333333333333333b3364443bbb333333333333333333333bbb3433333333333333333333bbb3bbb3333bbb33bbb3bbb
3333333334b44b3334b434b334443333333333333333333333333333343333b33333333333333333343333b3333333333333333333433bbb3333343333433bbb
33333333333333333333333333333333333333333333333333b3333b333333333333333333333333333333333333333333333333333333433333333333333343
333333333333333333333333333333333333333333333333b33b33333333333333333bbb33333bbb33333bbb33333bbb33333333333333333333333333333333
3333333334a334b334a334b33b44b4333b44b433333333333b33373333333333333b3bbb333b3bbbb3333bbbb3333bbb33333333333333333333333333333333
333333333a433b433a433b4334b44b3334b44b3333333333bbb374733333333333bbb34333bbb343333333433333334333333333333333333333333333333333
3333333334a334b334a334b33b44b4333b44b43333333333343344433333333333343333333433333333bb333333bb3333333333333333333333333333333333
333333333a433b433a433b4334b44b3334b44b33333333333333444333333333bbb3b33bbbb3b33b3b3bbb333b3bbb3333333333333333333333333333333333
3333333334a334b334a334b33b44b4333b44b43333333333b336444333333333bbb33333bbb33333bbb34333bbb3433333333333333333333333333333333333
333333333a433b433a433b4334b44b3334b44b33333333333333333333333333343333b3343333b3343333b3343333b333333333333333333333333333333333
33333333333333333333333333333333333333333333333333b3333b333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333bbb33b3333333b3333333333bbb33333333aaaaaaaaaaaaaaaa
333333333333333334b434b33b4b4b433333333333333333333333333333333333333333333b3bbb3bbb33333bbb3333333b3bbb33333333aaaaaaaaaaaaaaaa
33333333333333333b4b3b4334b4b4b3333333333333333333333333333333333333333333bbb3433bbb33333bbb333333bbb34333333333aaaaaaaaaaaaaaaa
3333333333333333333334b33b4b4b4333333333333333333333333333333333333333333334333333433b3333433b333334333333333333aaaaaaaaaaaaaaaa
333333333333333334a33b43333333333333333333333333333333333333333333333333bbb3b33b3333bbb33333bbb3bbb3b33b33333333aaaaaaaaaaaaaaaa
33333333333333333a4334b33b4b3b433333333333333333333333333333333333333333bbb333333333bbb33333bbb3bbb3333333333333aaaaaaaaaaaaaaaa
333333333333333334a33b4334b434b33333333333333333333333333333333333333333343333b33333343333333433343333b333333333aaaaaaaaaaaaaaaa
3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333aaaaaaaaaaaaaaaa
3333333333333333333333333333333333333333333333333333333333333bbb33333bbb33333bbb33333bbb33333bbb33b33333aaaaaaaa33333333aaaaaaaa
333333333b44b43334a334b33b4b4b4334b434b33333333333333333333b3bbb333b3bbbb3333bbbb3333bbbb3333bbb3bbb3333aaaaaaaa33333333aaaaaaaa
3333333334b44b333a433b4334b4b4b33b4b3b43333333333333333333bbb34333bbb3433333334333333343333333433bbb3333aaaaaaaa33333333aaaaaaaa
333333333b44b43334a334b33b4b4b43333334b3333333333333333333343333333433333333bb333333bb333333bb3333433b33aaaaaaaa33333333aaaaaaaa
3333333334b44b333a433b433333333334a33b433333333333333333bbb3b33bbbb3b33b3b3bbb333b3bbb333b3bbb333333bbb3aaaaaaaa33333333aaaaaaaa
333333333b44b43334a334b33b4b3b433a4334b33333333333333333bbb33333bbb33333bbb34333bbb34333bbb343333333bbb3aaaaaaaa33333333aaaaaaaa
3333333334b44b333a433b4334b434b334a33b433333333333333333343333b3343333b3343333b3343333b3343333b333333433aaaaaaaa33333333aaaaaaaa
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333aaaaaaaa33333333aaaaaaaa

__map__
0505050301010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0905030301010101320102121201010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0503030101222232010101010232020101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0503030122010201010801020707122201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0503320201011238082232221232011622000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09030101010101281212123806120a2222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050301010101320212071a283804040217000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050308060801320116022a122a1a173204000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0503382801013202121216220116161216000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050301011a04010112220a022204040216000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0503010122041a12121222221201041617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0308180101010407012212121202010116000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0318380601010712010132010102030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0128281818010701121232320303030505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101083801010101011222030305050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0118283808010112123232030505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 01424344

