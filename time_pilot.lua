dev=1
ver="0.28" -- 2022/04/26

-- 원작 참고
-- https://youtu.be/JPBkZHX3ju8
-- https://youtu.be/v_OzRECVOk8

poke(0X5F5C, 12) poke(0X5F5D, 3) -- Input Delay(default 15, 4)

-- screen cover pattern 0->100%
cover_pattern_str=[[
0b1111111111111111.1,
0b1111011111111101.1,
0b1111010111110101.1,
0b1011010111100101.1,
0b1010010110100101.1,
0b0010010110000101.1,
0b0000010100000101.1,
0b0000010000000001.1,
0b0000010000000000.1,
0b0000000000000000.1
]]
cover_pattern=split(cover_pattern_str,",")

-- particla data
-- x,y,color pre calculated value
p_data={}
p_str=[[
3,1,7,4,1,7,5,1,7,6,1,7,6,1,10,7,1,10,8,2,10,9,2,9,9,2,9,10,2,4,10,2,5,11,2,5,11,2,2,11,2,2/
2,2,7,2,2,7,2,3,7,3,3,7,3,3,7,4,4,7,4,4,7,4,5,10,5,5,10,5,5,10,5,6,10,6,6,10,6,6,9,6,7,9,6,7,9,7,7,4,7,7,4,7,8,4,7,8,5/
1,3,7,1,4,7,1,4,7,1,5,7,2,6,10,2,7,10,2,7,10,2,8,10,2,9,9,2,9,9,3,10,4,3,10,5,3,11,5,3,11,2,3,11,2/
-1,3,7,-1,3,7,-1,4,7,-2,5,7,-2,6,10,-2,6,10,-2,7,10,-2,7,10,-3,8,9,-3,9,9,-3,9,4,-3,10,4,-3,10,5,-3,10,5,-3,11,2,-4,11,2/
-2,1,7,-3,1,7,-4,1,7,-4,2,7,-5,2,7,-5,2,7,-6,2,10,-6,3,10,-7,3,10,-7,3,10,-8,3,10,-8,3,9,-9,3,9,-9,4,4,-9,4,4,-10,4,4,-10,4,5,-10,4,5,-11,4,2/
-3,-1,7,-4,-1,7,-4,-1,7,-5,-1,7,-6,-1,10,-7,-1,10,-7,-1,10,-8,-2,10,-9,-2,9,-9,-2,9,-10,-2,4,-10,-2,4,-11,-2,5,-11,-2,5,-11,-2,2,-11,-2,2/
-1,-3,7,-2,-3,7,-2,-4,7,-3,-5,7,-3,-5,10,-3,-6,10,-4,-7,10,-4,-7,10,-4,-8,9,-5,-8,9,-5,-9,4,-5,-9,5,-5,-10,5,-5,-10,2,-6,-10,2/
0,-3,7,0,-3,7,0,-4,7,-1,-4,7,-1,-5,7,-1,-5,7,-1,-6,10,-1,-6,10,-1,-7,10,-1,-7,10,-1,-8,10,-1,-8,9,-1,-9,9,-1,-9,9,-1,-10,4,-1,-10,4,-1,-10,4,-1,-11,5,-1,-11,5/
2,-2,7,2,-3,7,3,-4,7,3,-5,7,4,-6,10,4,-6,10,4,-7,10,5,-7,9,5,-8,9,5,-9,4,6,-9,5,6,-9,5,6,-10,2,6,-10,2/
2,-1,7,3,-1,7,3,-1,7,4,-1,7,4,-1,7,5,-2,7,5,-2,7,6,-2,10,6,-2,10,7,-2,10,7,-2,10,8,-3,10,8,-3,9,9,-3,9,9,-3,9,9,-3,4,10,-3,4,10,-3,4,10,-3,5
]]



-- <class helper> --------------------
function class(base)
	local nc={}
	if (base) setmetatable(nc,{__index=base}) 
	nc.new=function(...) 
		local no={}
		setmetatable(no,{__index=nc})
		local cur,q=no,{}
		repeat
			local mt=getmetatable(cur)
			if not mt then break end
			cur=mt.__index
			add(q,cur,1)
		until cur==nil
		for i=1,#q do
			if (rawget(q[i],'init')) rawget(q[i],'init')(no,...)
		end
		return no
	end
	return nc
end

-- event dispatcher
event=class()
function event:init()
	self._evt={}
end
function event:on(event,func,context)
	self._evt[event]=self._evt[event] or {}
	-- only one handler with same function
	self._evt[event][func]=context or self
end
function event:remove_handler(event,func,context)
	local e=self._evt[event]
	if (e and (context or self)==e[func]) e[func]=nil
end
function event:emit(event,...)
	for f,c in pairs(self._evt[event]) do
		f(c,...)
	end
end

-- sprite class for scene graph
sprite=class(event)
function sprite:init()
	self.children={}
	self.parent=nil
	self.x=0
	self.y=0
end
function sprite:set_xy(x,y)
	self.x=x
	self.y=y
end
function sprite:get_xy()
	return self.x,self.y
end
function sprite:add_child(child)
	child.parent=self
	add(self.children,child)
end
function sprite:remove_child(child)
	del(self.children,child)
	child.parent=nil
end
function sprite:remove_self()
	if self.parent then
		self.parent:remove_child(self)
	end
end
-- logical xor
function lxor(a,b) return not a~=not b end
-- common draw function
function sprite:_draw(x,y,fx,fy)
	spr(self.spr_idx,x+self.x,y+self.y,self.w or 1,self.h or 1,lxor(fx,self.fx),lxor(fy,self.fy))
end
function sprite:show(v)
	self.draw=v and self._draw or nil
end
function sprite:render(x,y,fx,fy)
	if (self.draw) self:draw(x,y,fx,fy)
	for i=1,#self.children do
		self.children[i]:render(x+self.x,y+self.y,lxor(fx,self.fx),lxor(fy,self.fy))
	end
end
function sprite:emit_update()
	self:emit("update")
	for i=1,#self.children do
		local child=self.children[i]
		if child then child:emit_update() end
	end
end



-- <log, system info> --------------------
log_d=nil
log_counter=0
function log(...)
	local s=""
	for i,v in pairs{...} do
		s=s..v..(i<#{...} and "," or "")
	end
	if log_d==nil then log_d=s
	else log_d=sub(s.."\n"..log_d,1,200) end
	log_counter=3000
end
function print_log()
	if(log_d==nil or log_counter<=1) log_d=nil return
	log_counter-=1
	?log_d,2,2,0
	?log_d,1,1,8
end
function print_system_info()
	local cpu=round(stat(1)*10000)
	local mem=tostr(round(stat(0)))
	local s=(cpu\100).."."..(cpu%100\10)..(cpu%10).."%"
	printa(s,128,2,0,1) printa(s,127,1,11,1)
	printa(mem,98,2,0,1) printa(mem,97,1,11,1)
end



-- <utilities> --------------------
function round(n) return flr(n+.5) end
function swap(v) if v==0 then return 1 else return 0 end end -- 1 0 swap
function clamp(a,min_v,max_v) return min(max(a,min_v),max_v) end
function rndf(lo,hi) return lo+rnd()*(hi-lo) end -- random real number between lo and hi
function rndi(n) return round(rnd()*n) end -- random int
function printa(t,x,y,c,align,shadow) -- 0.5 center, 1 right align
	x-=align*4*#(tostr(t))
	if (shadow) ?t,x+1,y+1,0
	?t,x,y,c
end



-- <space> --------------------
space=class(sprite)
function space:init(is_front)
	self.spd_x=0
	self.spd_y=0
	self.stars={}
	self.particles={}
	self.is_front=is_front

	local function make_star(i,spd,spd_max,size)
		-- local col={1,1,1,1,5,13}
		return {
			x=rnd(127),
			y=rnd(127),
			-- c=7,
			-- spd=spd+i/max*spd,
			spd=spd+rnd()*(spd_max-spd),
			size=size
		}
	end
	if is_front then
		-- for i=1,4 do add(self.stars,make_star(i,1.2,3,4)) end
		for i=1,2 do add(self.stars,make_star(i,2,2.8,4)) end
		for i=1,2 do add(self.stars,make_star(i,3,4,4)) end
	else
		for i=1,4 do add(self.stars,make_star(i,0.1,0.3,0)) end
		for i=1,6 do add(self.stars,make_star(i,0.3,0.5,1)) end
		for i=1,4 do add(self.stars,make_star(i,0.6,0.9,2)) end
		for i=1,4 do add(self.stars,make_star(i,0.9,1,3)) end
	end

	self:show(true)
	self:on("update",self.on_update)
end

ptcl_size_enemy="010111010100"
ptcl_size_thrust="001011212222121211111110101000000" -- smaller
ptcl_thrust_col="777aa99ee8844d4dd6d666" -- 대기
-- ptcl_back_col="77666dd1d111"
ptcl_fire_col="89a7"
ptcl_size_explosion="3577767766666555544444333332222221111111000"
ptcl_col_explosion="77aaa99a99888988999494445555666"
ptcl_col_explosion_dust="779856"
ptcl_col_hit="cc7a82"

function space:_draw()
	-- vignetting
	--[[ if not self.is_front then
		cls(13)
		for i=1,5 do
			fillp(cover_pattern[i*2])
			circfill(cx,cy,130-i*(7+i*2),12)
		end
		fillp()
	end ]]
	
	-- 더 넓은 비네팅
	--[[ if not self.is_front then
		cls(13)
		for i=1,5 do
			fillp(cover_pattern[i*2])
			circfill(cx,cy,124-i*(0+i*2),12)
		end
		fillp()
	end ]]

	-- 하단 그라데이션
	if not self.is_front then
		for i=0,8 do
			fillp(cover_pattern[9-i])
			local y=(cy+64)/2+66
			rectfill(0,y-(i+1)*5,127,y-i*5,13)
		end
		fillp()
	end

	-- 구름
	for i,v in pairs(self.stars) do
		local x=v.x-self.spd_x*v.spd
		local y=v.y+self.spd_y*v.spd
		v.x=x>147 and x-167 or x<-20 and x+167 or x
		v.y=y>147 and y-167 or y<-20 and y+167 or y
		local x2=v.x+cx
		local y2=v.y+cy
		x2=x2>147 and x2-167 or x2<-20 and x2+167 or x2
		y2=y2>147 and y2-167 or y2<-20 and y2+167 or y2
		if v.size==4 then
			if self.is_front then
				if i%2==0 then
					spr(67,x2-17,y2-2)
					spr(64,x2-12,y2-4)
					sspr(0,48,16,16,x2-8,y2-8,16,16)
					spr(64,x2+5,y2-3)
				else
					spr(64,x2-10,y2)
					spr(66,x2-6,y2-4)
					sspr(0,48,16,16,x2-3,y2-6,16,16)
					spr(64,x2+9,y2-1)
				end
			end
		elseif v.size==3 then
			if i%2==0 then
				spr(65,x2-4,y2-3)
				sspr(16,48,16,16,x2-2,y2-7,16,16)
				spr(64,x2+9,y2-4)
				spr(65,x2+14,y2-2)
			else
				spr(65,x2-8,y2-2)
				sspr(16,48,16,16,x2-5,y2-7,16,16)
				spr(64,x2+6,y2-2)
			end
		elseif v.size==2 then
			spr(65,x2-4,y2-2)
			spr(64,x2,y2-2)
			spr(66,x2+6,y2-1)
		elseif v.size<=1 then
			if(v.size==0) fillp(cover_pattern[5])
			if i%2==0 then
				circfill(x2-5,y2+1,2,6)
				circfill(x2,y2,4,6)
				circfill(x2+6,y2+1,2,6)
			else
				circfill(x2-5,y2+1,2,6)
				circfill(x2,y2,3,6)
				circfill(x2+4,y2+1,2,6)
			end
			fillp()
		end
	end

	-- particles
	-- for i,v in pairs(self.particles) do
	for v in all(self.particles) do
		if v.type=="thrust" then
			fillp(cover_pattern[10-clamp(flr(v.age*0.38),0,9)])
			circfill(v.x,v.y,1,7)
			v.x+=v.sx-self.spd_x+rnd(0.6)-0.3
			v.y+=v.sy+self.spd_y+rnd(0.6)-0.3
			fillp()
			if(v.age>v.age_max) del(self.particles,v)
		
		elseif v.type=="enemy_trail" then
			pset(v.x,v.y,7)
			v.x+=v.sx-self.spd_x+self.spd_cx+rnd(0.6)-0.3
			v.y+=v.sy+self.spd_y+self.spd_cy+rnd(0.6)-0.3
			if(v.age>v.age_max) del(self.particles,v)

		elseif v.type=="bullet" or v.type=="bullet_enemy" then
			local ox,oy=v.x,v.y
			v.x+=v.sx-self.spd_x+self.spd_cx
			v.y+=v.sy+self.spd_y+self.spd_cy
			local c=tonum(sub(ptcl_fire_col,1+round(v.age/16),_),0x1)
			
			if(v.age>v.age_max or v.x>131 or v.y>131 or v.x<-4 or v.y<-4) del(self.particles,v)

			-- draw & hit test bullet & enemy
			if v.type=="bullet" then
				line(ox,oy,v.x,v.y,c)
				local dist=6
				for j,e in pairs(_enemies.list) do
					if(e.type==4) goto continue
					if(e.type==3) dist=8
					if abs(v.x-e.x)<=dist and abs(v.y-e.y)<=dist and get_dist(v.x,v.y,e.x,e.y)<=dist then
						e.hp-=1
						if e.hp<=0 then
							if(e.type==1) ui.kill_1+=1 gamedata.score+=1
							if(e.type==2) ui.kill_2+=1 gamedata.score+=3
							if(e.type==3) ui.kill_3+=1 gamedata.score+=15 add(_space.particles,{type="score",value=1500,x=e.x,y=e.y,age=1})
							_enemies:add(-140-rndi(5)*10,rndi(8)*10-35,e.type)
							add_explosion_eff(e.x,e.y,v.sx,v.sy)
							del(_enemies.list,e)
							sfx(3,-1)
						else
							e.hit_count=4
							local a=atan2(e.x-v.x,e.y-v.y)
							add_hit_eff(v.x,v.y,a)
							sfx(22,-1)
						end
						del(self.particles,v)
					end
					::continue::
				end

			elseif v.type=="bullet_enemy" then
				circfill(v.x,v.y,1,9+rndi(3))
				circfill(v.x,v.y,0,8)

				-- todo: 플레이어와 충돌 처리를 하자!

				local dist=5
				if abs(v.x-cx)<=dist and abs(v.y-cy)<=dist and get_dist(v.x,v.y,cx,cy)<=dist then
					_ship.hit_count=8
					add_hit_eff(v.x,v.y,atan2(cx-v.x,cy-v.y))
					del(self.particles,v)
					sfx(2,-1)
				end
			end

		elseif v.type=="explosion" or v.type=="explosion_white" then
			local c=(v.type=="explosion_white") and 7 or tonum(sub(ptcl_col_explosion,v.age,_),0x1)
			circfill(v.x,v.y,
				sub(ptcl_size_explosion,v.age,_)*v.size,c)
			v.x+=v.sx-self.spd_x+self.spd_cx+rnd(1)-0.5
			v.y+=v.sy+self.spd_y+self.spd_cy+rnd(1)-0.5
			v.sx*=0.92
			v.sy*=0.92
			v.sy+=0.01
			if(v.age>40) del(self.particles,v)

		elseif v.type=="explosion_dust" then
			local c=tonum(sub(ptcl_col_explosion_dust,1+flr(v.age/5),_),0x1)
			pset(v.x,v.y,c)
			v.x+=v.sx-self.spd_x
			v.y+=v.sy+self.spd_y
			v.sx*=0.96
			v.sy*=0.96
			v.sy+=0.02
			if(v.age>30) del(self.particles,v)

		elseif v.type=="hit" then
			local c=tonum(sub(ptcl_col_hit,1+flr(v.age/3),_),0x1)
			pset(v.x,v.y,c)
			v.x+=v.sx-self.spd_x
			v.y+=v.sy+self.spd_y
			v.sx*=0.94
			v.sy*=0.94
			if(v.age>12) del(self.particles,v)
		
		elseif v.type=="circle" then
			v.size+=0.6
			circ(cx,cy,v.size,8+rndi(7))
			if(v.age>32) del(self.particles,v)

		elseif v.type=="score" then
			printa(v.value,v.x,v.y,7,0.5,true)
			v.x-=self.spd_x*1.5
			v.y+=self.spd_y*1.2
			if(v.age>45) del(self.particles,v)

		end

		v.age+=1
	end
end

function space:on_update()
end



-- <ship> --------------------
ship=class(sprite)
function ship:init()
	self.spd=0
	self.spd_x=0
	self.spd_y=0
	self.spd_cx=0
	self.spd_cy=0
	-- self.spd_max=0.8
	self.spd_max=0.7
	self.angle=0
	self.angle_acc=0
	self.angle_acc_pow=0.0004
	self.thrust=0
	self.thrust_acc=0
	self.thrust_max=1.4
	self.tail={x=0,y=0}
	self.head={x=0,y=0}
	self.fire_spd=2.2 -- 1.4 -> 3.0
	self.fire_intv=0
	self.fire_intv_full=6 -- 20 -> 5
	self.bomb_spd=0.7
	self.bomb_intv=0
	self.bomb_intv_full=60
	self.hit_count=0
	self:show(true)
	self:on("update",self.on_update)
end

guide_pattern_str=[[
0b1111011111111101.1,
0b0111110111111111.1,
0b1101111101111111.1,
]]
guide_pattern=split(guide_pattern_str,",")

function ship:_draw()
	local x0=cos(self.angle)
	local y0=sin(self.angle)
	local x1=cx+0.5-x0*2
	local y1=cy+0.5-y0*2

	-- local x2=cx+cos(self.angle-0.40)*6
	-- local y2=cy+sin(self.angle-0.40)*6
	-- local x3=cx+cos(self.angle+0.40)*6
	-- local y3=cy+sin(self.angle+0.40)*6

	-- guide line
	--[[ do
		local len=50
		local c=7
		fillp(guide_pattern[1+round(f/6)%3])
		line(cx-1,cy-1,cx-1+x0*len,cy-1+y0*len,c)
		line(cx-1,cy,cx-1+x0*len,cy+y0*len,c)
		line(cx,cy-1,cx+x0*len,cy-1+y0*len,c)
		line(cx,cy,cx+x0*len,cy+y0*len,c)
		line(cx-1,cy-1,cx-1+x0*len,cy-1+y0*len,c)
		fillp()
	end ]]

	-- ship body
	if self.hit_count>0 then
		pal({6,6,6,6,6,7,7,6,7,7,7,7,7,7,7,6})
		self.hit_count-=1
	end
	local s=get_spr2(self.angle)
	-- sspr(s.x,s.y,13,15,cx-6,cy-6,13,15,s.fx,s.fy)
	sspr(s.x,s.y,13,15,cx-4,cy-4,13*0.7,15*0.7,s.fx,s.fy) -- 스케일 줄여 봄
	-- circ(cx,cy,6,11)

	self.tail.x=cx-x0*4
	self.tail.y=cy-y0*4
	self.head.x=cx+x0*7
	self.head.y=cy+y0*7
end
function ship:on_update()
	
	-- rotation
	-- 좌우 키를 이용해서 회전
	-- if btn(0) then self.angle_acc+=self.angle_acc_pow
	-- elseif btn(1) then self.angle_acc-=self.angle_acc_pow end

	-- 상하좌우 키를 이용해서 회전
	local to_angle=self.angle
	if btn(1) and btn(2) then to_angle=0.125
	elseif btn(2) and btn(0) then to_angle=0.375
	elseif btn(0) and btn(3) then to_angle=0.625
	elseif btn(3) and btn(1) then to_angle=0.875
	elseif btn(0) then to_angle=0.5
	elseif btn(1) then to_angle=0
	elseif btn(2) then to_angle=0.25
	elseif btn(3) then to_angle=0.75 end

	
	-- 회전 거리가 짧은 쪽으로 회전
	if abs(to_angle-self.angle)>0.02 then
		self.angle_acc+=self.angle_acc_pow*get_rotate_dir(self.angle,to_angle)
		-- local da1=self.angle-to_angle
		-- local da2=to_angle-self.angle
		-- da1=da1<0 and da1+1 or da1
		-- da2=da2<0 and da2+1 or da2
		-- if da1>da2 then self.angle_acc+=self.angle_acc_pow
		-- else self.angle_acc-=self.angle_acc_pow end
	else
		self.angle=to_angle
		self.angle_acc=0
	end
	

	local a=self.angle+self.angle_acc
	self.angle=a>1 and a-1 or a<0 and a+1 or a
	self.angle_acc*=0.94
	if(abs(self.angle_acc)<0.0001) self.angle_acc=0

	-- acceleration
	-- if btn(2) then
	-- 	self.thrust_acc+=0.0006
	-- elseif btn(3)
	-- 	then self.thrust_acc-=0.0003
	-- end
	--[[ self.thrust_acc+=0.0005 -- Time Pilot에서는 항상 가속
	self.thrust=clamp(self.thrust+self.thrust_acc,-self.thrust_max,self.thrust_max)
	self.thrust_acc*=0.8
	self.thrust*=0.9
	local thr_x=cos(self.angle)*self.thrust
	local thr_y=sin(self.angle)*self.thrust
	self.spd_x+=thr_x
	self.spd_y+=thr_y
	self.spd_x*=0.995
	self.spd_y*=0.995 ]]
	-- Time Pilot에서는 대기비행 스타일로
	local spd=self.spd_max+sin(self.angle)*0.2 -- 하강속도 약간 더 빠르게
	self.spd_x=cos(self.angle)*spd
	self.spd_y=sin(self.angle)*spd

	-- fire
	self.fire_intv-=1
	if btn(4) and self.fire_intv<=0 then
		-- sfx(24,-1)
		sfx(1,-1)
		self.fire_intv=self.fire_intv_full
		local a=self.angle+rnd()*0.016-0.008
		local fire_spd_x=cos(a)*self.fire_spd+self.spd_x
		local fire_spd_y=sin(a)*self.fire_spd+self.spd_y
		add(_space.particles,
		{
			type="bullet",
			x=self.head.x,
			y=self.head.y,
			sx=fire_spd_x,
			sy=fire_spd_y,
			age_max=60,
			age=1
		})
		-- 총 쏠 때 연기
		--[[ for i=1,6 do
			add(_space_f.particles,
			{
				type="thrust",
				x=self.head.x,
				y=self.head.y,
				sx=-fire_spd_x*0.3,
				sy=-fire_spd_y*0.3,
				age_max=16,
				age=1+rndi(6)
			})
		end ]]
	end

	-- bomb
	-- todo: 폭탄 인터벌이든 뭐든 처리해야 함
	self.bomb_intv-=1
	if btn(5) and self.bomb_intv<=0 then
		sfx(6,-1)
		self.bomb_intv=self.bomb_intv_full
		local fire_spd_x=cos(self.angle)*self.bomb_spd+self.spd_x
		local fire_spd_y=sin(self.angle)*self.bomb_spd+self.spd_y
		add(_space.particles,
		{
			type="bomb",
			x=self.head.x,
			y=self.head.y,
			sx=fire_spd_x,
			sy=fire_spd_y,
			spr=16+round(self.angle*8-0.0625)%8,
			age_max=120,
			age=1
		})
	end

	-- add effect
	-- if(f%6==0) sfx(4,1) -- 항상 엔진음, 
	-- 분사효과
	add(_space.particles,
		{
			type="thrust",
			x=self.tail.x+rnd(0.6)-0.3,
			y=self.tail.y+rnd(0.6)-0.3,
			sx=-self.spd_x*1.5,
			sy=-self.spd_y*1.5,
			age_max=50,
			age=1
		})

	--[[ 
	if self.thrust_acc>0 then
		if(f%6==0) sfx(4,2)
		add(_space_f.particles,
		{
			type="thrust",
			x=self.tail.x-2+rnd(4),
			y=self.tail.y-2+rnd(4),
			sx=-thr_x*130,
			sy=-thr_y*130,
			age_max=16,
			age=1
		})
	elseif self.thrust_acc<-0.0001 then
		sfx(5,2)
		add(_space_f.particles,
		{
			type="thrust-back",
			x=self.head.x-2+rnd(4),
			y=self.head.y-2+rnd(4),
			sx=-thr_x*120,
			sy=-thr_y*120,
			age=1
		})
	else
		sfx(-1,2)
	end
	]]

	-- speed limit
	--[[ local spd=sqrt(self.spd_x^2+self.spd_y^2)
	if spd>self.spd_max then
		local r=self.spd_max/spd
		self.spd_x*=r
		self.spd_y*=r
	end ]]

	-- hit test with enemies
	-- for i,e in pairs(_enemies.list) do
	for e in all(_enemies.list) do
		local dist=(e.type==4) and 10 or (e.type==3) and 8 or 6
		if abs(e.x-cx)<=dist and abs(e.y-cy)<=dist and get_dist(e.x,e.y,cx,cy)<=dist then
			if e.type==4 then
				-- 낙하산 먹기
				ui.kill_4+=1
				sfx(32,-1)
				_enemies:add(rndi(227)-50,-160,4)
				add(_space.particles,{type="circle",size=3,age=1})
				add_explosion_eff(e.x,e.y,self.spd_x,self.spd_y,true)
				add(_space.particles,{type="score",value=5000,x=e.x,y=e.y,age=1})
				del(_enemies.list,e)
				gamedata.score+=50
			else
				sfx(2,-1)
				self.hit_count=8
				e.hit_count=8
				e.hp-=1
				local d=atan2(e.x-cx,e.y-cy)
				add_hit_eff((cx+e.x)/2,(cy+e.y)/2,d)
			end
		end
	end

	-- space speed update
	_space.spd_x=self.spd_x
	_space.spd_y=-self.spd_y
	_space_f.spd_x=self.spd_x
	_space_f.spd_y=-self.spd_y
	
	-- space center move(use space speed & ship direction)
	local tcx=64-self.spd_x*8-cos(self.angle)*10
	local tcy=64-self.spd_y*8-sin(self.angle)*10
	_space.spd_cx=(tcx-cx)*0.12
	_space.spd_cy=(tcy-cy)*0.12
	cx=cx+(tcx-cx)*0.12
	cy=cy+(tcy-cy)*0.12
end



-- <enemies> --------------------
enemies=class(sprite)
function enemies:init(enemies_num)
	self.list={}
	for i=1,enemies_num do
		local x=cos(i/enemies_num)
		local y=sin(i/enemies_num)
		self:add(x*100,y*100,(i==enemies_num) and 3 or (i==enemies_num-1) and 2 or nil)
	end
	self:add(64,-50,4)
	self:show(true)
end

function enemies:_draw()
	for i,e in pairs(self.list) do
		e.space_x+=e.spd_x-_space.spd_x
		e.space_y+=e.spd_y+_space.spd_y
		e.x=e.space_x+cx
		e.y=e.space_y+cy

		-- 정기적으로 회전 방향 업데이트
		if e.type==1 or e.type==2 then
			if (f+i*8)%60==0 then
				local to_angle=atan2(cx-e.x,cy-e.y)
				local angle_dist=value_loop_0to1(e.angle-to_angle)
				if angle_dist>0.2 then
					e.angle_acc=0.0022*get_rotate_dir(e.angle,to_angle)
				else
					e.angle_acc=0
				end
				
				-- 전방에 보인다 싶으면 공격
				if angle_dist<0.2 then
					if e.x>0 and e.y>0 and e.x<127 and e.y<127 then
						sfx(25,-1)
						add(_space.particles,
						{
							type="bullet_enemy",
							x=e.x+e.spd_x*16,
							y=e.y+e.spd_y*16,
							sx=cos(e.angle)*0.8,
							sy=sin(e.angle)*0.8,
							age_max=120,
							age=1
						})
					end
					-- line(e.x,e.y,cx,cy,11)
				end
			end
		elseif e.type==3 then
			-- 전방위 공격
			if e.x>0 and e.y>0 and e.x<127 and e.y<127 and f%60==0 then
				local to_angle=atan2(cx-e.x,cy-e.y)+rnd(0.08)-0.04
				local sx,sy=cos(to_angle)*0.7,sin(to_angle)*0.7
				sfx(25,-1)
				add(_space.particles,
				{
					type="bullet_enemy",
					x=e.x+sx*12,
					y=e.y+sy*12,
					sx=sx,
					sy=sy,
					age_max=120,
					age=1
				})
			end
		end

		-- 방향에 맞게 속도 설정
		if e.type==4 then
			e.spd_x=sin(f/100)*0.5
			e.spd_y=0.2
		else
			e.angle=value_loop_0to1(e.angle+e.angle_acc)
			e.spd_x=cos(e.angle)*e.spd
			e.spd_y=sin(e.angle)*e.spd
		end

		-- 타입에 맞는 트레일 추가
		if f%3==0 and e.type!=4 then
			local x,y=e.x-e.spd_x*12,e.y-e.spd_y*12
			local sx,sy=-e.spd_x*1.8,-e.spd_y*1.8
			if e.type==3 then
				x,y=e.x-9
				y=e.y+rnd()
				sx=-0.9
				sy=0
			end
			add(_space.particles,
			{
				type="enemy_trail",
				x=x,
				y=y,
				sx=sx,
				sy=sy,
				age_max=14,
				age=1
			})
		end

		-- 화면 밖으로 멀어지면 가까운 곳으로 옮김(플레이어 방향 고려)
		if e.x<-120 or e.y<-120 or e.x>247 or e.y>247 then
			local a=_ship.angle+rnd()*0.1-0.05
			local x=cos(a)*130
			local y=sin(a)*130
			e.space_x=x
			e.space_y=y
			e.x=x+cx
			e.y=y+cy
		end
		
		if(e.type==2) pal{[11]=8}
		if(e.type==3) pal{[11]=10}
		-- if(e.type==4) pal{[11]=12} -- 잘 안 보이게(...)
		if e.x<-4 then
			spr(80,0,clamp(e.y-4,4,118-7))
		elseif e.x>131 then
			spr(80,120,clamp(e.y-4,4,118-7),1,1,true)
		elseif e.y<-4 then
			spr(81,clamp(e.x-4,4,118),0)
		elseif e.y>131-7 then
			spr(81,clamp(e.x-4,4,118),120-7,1,1,false,true)
		else
			if e.hit_count>0 then
				e.hit_count-=1
				pal({6,6,6,6,6,7,7,6,7,7,7,7,7,7,7,6})
			else
				if(e.type==2) pal({[3]=8,[15]=9,[5]=4})
				if f%6<3 then palt(12,true) pal{[10]=7} else palt(10,true) pal{[12]=7} end
			end

			if e.type==4 then
				pal()
				-- pal(dim_pal)
				sspr(40,32,9,5,e.x-4,e.y-4)
				if abs(e.spd_x)>0.3 then
					sspr(40,37,9,3,e.x-4,e.y+1)
					rect(e.x-1,e.y+4,e.x+1,e.y+5,2)
				elseif e.spd_x<0 then
					sspr(49,37,9,3,e.x-3,e.y+1)
					rect(e.x-2,e.y+4,e.x,e.y+5,2)
				else
					sspr(49,37,9,3,e.x-5,e.y+1,9,3,true)
					rect(e.x,e.y+4,e.x+2,e.y+5,2)
				end
			elseif e.type==3 then
				-- pal()
				spr(32,e.x-7,e.y-7,2,2)
			else
				local s=get_spr(e.angle)
				sspr(s.spr*8,0,16,16,e.x-4,e.y-4,16*0.6,16*0.6,s.fx,s.fy)
			end
			-- circ(e.x,e.y,22,11)
		end
		pal()
		-- pal(dim_pal)
	end
end

function enemies:add(x,y,t)
	-- local hp,type,spd=1,1,0.4
	local hp,type,spd=1,1,0.3
	-- if(t==2) hp,type,spd=8,2,0.6
	if(t==2) hp,type,spd=8,2,0.4
	if(t==3) hp,type,spd=20,3,0.2
	if(t==4) type=4

	local e={
		x=0,
		y=0,
		spd=spd,
		spd_x=0,
		spd_y=0,
		acc_x=0,
		acc_y=0,
		angle=(type==3) and 0 or rnd(),
		angle_acc=0,
		space_x=x,
		space_y=y,
		hp=hp,
		hit_count=0,
		type=type
	}
	add(self.list,e)
end



-- <etc. functions> --------------------
-- function is_near(x1,y1,x2,y2,r)
-- 	if(abs(x2-x1)>r) return false
-- 	if(abs(y2-y1)>r) return false
-- 	return true
-- end

-- 회전할 방향 구하기(반시계 1, 시계 -1)
function get_rotate_dir(from,to)
	from=value_loop_0to1(from)
	to=value_loop_0to1(to)
	local da1=from-to
	local da2=to-from
	da1=da1<0 and da1+1 or da1
	da2=da2<0 and da2+1 or da2
	return da1>da2 and 1 or -1
end

-- enemy airplane sprites
function get_spr(angle)
	local s,fx,fy=0,false,false
	angle=value_loop_0to1(angle)+0.0312
	if angle<0.0625 then s=8 -- right
	elseif angle<0.125 then s=6
	elseif angle<0.1875 then s=4
	elseif angle<0.25 then s=2
	elseif angle<0.3125 then s=0 -- top
	elseif angle<0.375 then s=2 fx=true
	elseif angle<0.4375 then s=4 fx=true
	elseif angle<0.5 then s=6 fx=true
	elseif angle<0.5625 then s=8 fx=true -- left
	elseif angle<0.625 then s=10 fx=true
	elseif angle<0.6875 then s=12 fx=true
	elseif angle<0.75 then s=14 fx=true
	elseif angle<0.8125 then s=0 fx=true fy=true -- bottom
	elseif angle<0.875 then s=14
	elseif angle<0.9375 then s=12
	else s=10 end
	return {spr=s,fx=fx,fy=fy}
end

function get_spr2(angle)
	-- 13x15 size
	local x,y,fx,fy=0,97,false,false
	angle=value_loop_0to1(angle-0.015)
	if angle<0.25 then
		x=flr(angle*4*9)*13
	elseif angle<0.5 then
		x=clamp(flr(8-(angle-0.25)*4*9),0,9)*13
		fx=true
	elseif angle<0.75 then
		x=clamp(flr((angle-0.5)*4*8),0,8)*13
		y=113
		fx=true
	else
		x=clamp(flr(7-(angle-0.75)*4*8),0,8)*13
		y=113
	end
	return {x=x,y=y,fx=fx,fy=fy}
end

-- todo: 버그가 있는......듯??????
function value_loop(v,min,max)
  if v<min then v=(v-min)%(max-min)+min
  elseif v>max then v=v%max+min end
  return v
end

function value_loop_0to1(v)
	return v<0 and v+1 or v>1 and v-1 or v
end

function coord_loop(a)
	local x,y=a.x,a.y
	x=x>131 and x-131 or x<-4 and x+131 or x
	y=y>131 and y-131 or y<-4 and y+131 or y
	a.x=x a.y=y
end

function get_dist(x1,y1,x2,y2)
	return sqrt((x2-x1)^2+(y2-y1)^2)
end

function add_explosion_eff(x,y,spd_x,spd_y,is_white)
	local count=20
	for i=1,count do
		local sx=cos(i/count+rnd()*0.1)
		local sy=sin(i/count+rnd()*0.1)
		if is_bomb then sx*=1.6 sy*=1.6 end
		local type=is_white and "explosion_white" or "explosion"
		add(_space.particles,
		{
			type=type,
			x=x+rnd(6)-3,
			y=y+rnd(6)-3,
			sx=sx*(0.5+rnd()*1.2)+spd_x*0.7,
			sy=sy*(0.5+rnd()*1.2)+spd_y*0.7,
			size=is_bomb and 1.5 or 1,
			age=1+rndi(16)
		})
		add(_space.particles,
		{
			type="explosion_dust",
			x=x+rnd(4)-2,
			y=y+rnd(4)-2,
			sx=sx*(1+rnd()*2)+spd_x,
			sy=sy*(1+rnd()*2)+spd_y,
			age=1+rndi(16)
		})
	end
end
function add_hit_eff(x,y,angle)
	for i=1,8 do
		local a=angle+round(i/8)*0.8-0.4
		local sx=cos(a)
		local sy=sin(a)
		add(_space.particles,
		{
			type="hit",
			x=x+rnd(4)-2,
			y=y+rnd(4)-2,
			sx=sx*(1+rnd()*3),
			sy=sy*(1+rnd()*3),
			age=1+rndi(5)
		})
	end
end

function print_score(num,suffix,len,x,y)
	local t=tostr(num)
	t=t=="0" and "0" or t..suffix
	local t1="" for i=1,len-#t do t1=t1.."0" end
	printa(t1,x,y,1,0)
	printa(t,x+len*4,y,6,1)
end


-- <ui> --------------------
ui={
	kill_1=0,
	kill_2=0,
	kill_3=0,
	kill_4=0,
}
ui._draw=function()
	rectfill(0,121,127,127,0)

	--[[ 
	local v1=tostr(min(999,ui.kill_1))
	local v2=tostr(min(999,ui.kill_2))
	local v3=tostr(min(999,ui.kill_3))
	local v4=tostr(min(999,ui.kill_4))

	spr(84,1,122)
	print_score(v1,"",3,7,122)

	pal{[3]=8} spr(84,22,122) pal(dim_pal)
	print_score(v2,"",3,28,122)

	spr(85,43,122)
	print_score(v3,"",3,50,122)

	-- spr(86,64,122)
	-- print_score(v4,"",3,70,122)
	]]

	for i=0,8 do spr(84,1+i*6,122) end
	local w=9*6-1
	rectfill(1+w-(w*min(1,ui.kill_1/30)),122,1+w,126,0)

	print_score(gamedata.score,"00",8,70,122)


	if dev==1 then
		printa("v"..ver,128,122,5,1)
	end
end

function draw_title()
	rectfill(0,0,127,30,0)
	rectfill(0,97,127,127,0)
	rectfill(0,31,10,96,0)
	rectfill(127-10,31,127,96,0)
	-- fillp(cover_pattern[5])
	-- rectfill(0,30,127,34,0)
	-- rectfill(0,97-4,127,127-30,0)
	-- rectfill(10,31,14,96,0)
	-- rectfill(127-14,31,127-10,96,0)
	-- fillp()
	
	print("\^w\^ttime pilot",25,36,0)
	print("\^w\^ttime pilot",24,35,9)
	printa("demake 2022",65,49,0,0.5)
	printa("demake 2022",64,48,9,0.5)

	if f%30<20 then
		-- printa("press any key",65,102,0,0.5)
		printa("press any key",64,101,12,0.5)
	end


end



-- <constants> --------------------



--------------------------------------------------
f=0 -- every frame +1
dim_pal_colors="1212114522311140"
dim_pal={} -- 이게 있으면 stage 렌더링 시작할 때 팔레트 교체
stage=sprite.new() -- scene graph top level object
cx,cy=64,64 -- space center

gamedata={
	ships=5,
	score=0,
}

function _init()
	music(0,nil,3)
	music(18,1000,3)

	_space=space.new()
	_space_f=space.new(true) -- front layer
	_ship=ship.new()
	_enemies=enemies.new(7)
	-- _enemies:add(80,64,3)

	stage:add_child(_space)
	stage:add_child(_ship)
	stage:add_child(_enemies)
	stage:add_child(_space_f)
end
function _update60()
	f+=1
	stage:emit_update()
end
function _draw()
	cls(12)
	
	
	-- dim_pal={1,2,1,2,1,1,4,5,2,2,3,1,1,1,4,0} -- 임시
	-- dim_pal={2,2,2,2,2,2,5,5,2,2,5,2,2,2,5,0} -- 임시
	if(#dim_pal>0) pal(dim_pal,0)

	rectfill(0,0,127,127,12)
	stage:render(0,0)
	ui._draw()
	
	-- draw_title()

	-- 개발용
	if dev==1 then
		print_log()
		print_system_info()
	end
end