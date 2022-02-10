dev=1
ver="0.21"
latest_update="2022/02/11"

poke(0X5F5C, 12) poke(0X5F5D, 3) -- Input Delay(default 15, 4)
poke(0x5f2d, 0x1) -- Use Mouse input

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
	local mem=tostr(stat(0))
	local s=(cpu\100).."."..(cpu%100\10)..(cpu%10).."%"
	printa(s,128,2,0,1) printa(s,127,1,8,1)
	printa(mem,128,8,0,1) printa(mem,127,7,8,1)
end



-- <utilities> --------------------
function round(n) return flr(n+.5) end
function swap(v) if v==0 then return 1 else return 0 end end -- 1 0 swap
function clamp(a,min_v,max_v) return min(max(a,min_v),max_v) end
function rndf(lo,hi) return lo+rnd()*(hi-lo) end -- random real number between lo and hi
function rndi(n) return round(rnd()*n) end -- random int
function printa(t,x,y,c,align) -- 0.5 center, 1 right align
	x-=align*4*#t
	print(t,x,y,c)
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
		for i=1,3 do add(self.stars,make_star(i,1.2,3,4)) end
	else
		-- for i=1,4 do
		-- 	add(self.stars,make_star(i,4,0.3,0.3))
		-- end
		for i=1,4 do add(self.stars,make_star(i,0.1,0.3,0)) end
		for i=1,6 do add(self.stars,make_star(i,0.3,0.5,1)) end
		for i=1,4 do add(self.stars,make_star(i,0.6,0.9,2)) end
		for i=1,4 do add(self.stars,make_star(i,0.9,1,3)) end
	end

	self:show(true)
	self:on("update",self.on_update)
end

--ptcl_size_thrust="001111111000000"
ptcl_size_thrust="111223332332222222111111110000"
-- ptcl_thrust_col="c77aa99882211211" -- 우주
ptcl_thrust_col="c77aa9988282d2ddd6d66" -- 대기
ptcl_back_col="77666dd1d111"
ptcl_fire_col="89a7"
ptcl_size_explosion="3577767766666555544444333332222221111111000"
-- ptcl_col_explosion="77aaa99988888989994444441111"
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

	-- stars
	for i,v in pairs(self.stars) do
	-- for v in all(self.stars) do
		local x=v.x-self.spd_x*v.spd
		local y=v.y+self.spd_y*v.spd
		-- v.x=x>127 and x-127 or x<0 and x+127 or x
		-- v.y=y>127 and y-127 or y<0 and y+127 or y
		v.x=x>147 and x-167 or x<-20 and x+167 or x
		v.y=y>147 and y-167 or y<-20 and y+167 or y
		local x2=v.x+cx
		local y2=v.y+cy
		-- x2=x2>129 and x2-129 or x2<-2 and x2+129 or x2
		-- y2=y2>129 and y2-129 or y2<-2 and y2+129 or y2
			x2=x2>147 and x2-167 or x2<-20 and x2+167 or x2
			y2=y2>147 and y2-167 or y2<-20 and y2+167 or y2
		
		-- if v.size>1.9 then circfill(x2,y2,1,v.c)
		-- else pset(x2,y2,v.c) end
		if v.size==4 then
			
			if self.is_front then
				if i%2==0 then
					spr(64,x2-12,y2-2)
					sspr(0,48,16,16,x2-8,y2-8,16,16)
					sspr(16,48,16,16,x2+1,y2-7,16,16)
					spr(64,x2+12,y2-3)
				else
					sspr(0,48,16,16,x2-3,y2-6,16,16)
					sspr(0,48,16,16,x2-14,y2-8,16,16)
					spr(64,x2-2,y2-8)
					spr(65,x2-17,y2-2)
					spr(64,x2+9,y2-2)
					-- circ(x2,y2,18,11)
				end
				--[[ fillp(cover_pattern[5])
				circfill(x2-15,y2+1,9,7)
				circfill(x2,y2,11,7)
				circfill(x2+13,y2+2,7,7)
				fillp() ]]
			end
		elseif v.size==3 then
			if i%2==0 then
				spr(65,x2-13,y2-3)
				sspr(0,48,16,16,x2-10,y2-8,16,16)
				sspr(16,48,16,16,x2-2,y2-6,16,16)
				spr(64,x2+10,y2-4)
			else
				spr(65,x2-13,y2-3)
				sspr(16,48,16,16,x2-11,y2-7,16,16)
				sspr(16,48,16,16,x2-3,y2-8,16,16)
				spr(64,x2+8,y2-1)
				
			end
			--[[ circfill(x2-15,y2+3,4,7)
			circfill(x2-7,y2+2,5,7)
			circfill(x2,y2,7,7)
			circfill(x2+10,y2+2,5,7) ]]
		elseif v.size==2 then
			sspr(16,48,16,16,x2-6,y2-6,16,16)
			spr(65,x2-8,y2-1)
			spr(64,x2+4,y2-2)
			-- circ(x2,y2,14,11)
			-- circfill(x2-7,y2+1,5,7)
			-- circfill(x2,y2,6,7)
			-- circfill(x2+8,y2+1,4,7)
		elseif v.size<=1 then
			--[[ pal{[7]=6,[6]=6}
			spr(66,x2-7,y2-1)
			spr(64,x2-2,y2-2)
			spr(65,x2+4,y2-2)
			pal() ]]
			if(v.size==0) fillp(cover_pattern[5])
			if i%2==0 then
				circfill(x2-5,y2+1,3,6)
				circfill(x2,y2,4,6)
				circfill(x2+6,y2+2,2,6)
			else
				circfill(x2-7,y2+1,2,6)
				circfill(x2,y2,5,6)
				circfill(x2+7,y2+1,3,6)
			end
			fillp()
		end
	end

	-- particles
	-- for i,v in pairs(self.particles) do
	for v in all(self.particles) do
		if v.type=="thrust" then
			-- fillp(cover_pattern[5])
			-- circfill(v.x,v.y,
			-- 	sub(ptcl_size_thrust,v.age,_),
			-- 	tonum(sub(ptcl_thrust_col,v.age,_),0x1))
			-- pset(v.x,v.y,tonum(sub(ptcl_thrust_col,v.age,_),0x1))
			pset(v.x,v.y,7)
			-- circfill(v.x,v.y,sub(ptcl_size_thrust,v.age,_),13)
			-- fillp()
			-- v.x+=v.sx-self.spd_x
			-- v.y+=v.sy+self.spd_y
			v.x+=v.sx-self.spd_x+rnd(2)-1
			v.y+=v.sy+self.spd_y+rnd(2)-1
			-- v.sx*=0.94
			-- v.sy*=0.94
			if(v.age>v.age_max) del(self.particles,v)

		elseif v.type=="thrust-back" then
			circfill(v.x,v.y,
				sub(ptcl_size,v.age,_)*0.7,
				tonum(sub(ptcl_back_col,v.age,_),0x1))
			v.x+=v.sx-self.spd_x+rnd(2)-1
			v.y+=v.sy+self.spd_y+rnd(2)-1
			v.sx*=0.93
			v.sy*=0.93
			if(v.age>16) del(self.particles,v)

		elseif v.type=="bullet" or v.type=="bomb" then
			local ox,oy=v.x,v.y
			-- v.sy+=0.01
			v.x+=v.sx-self.spd_x
			v.y+=v.sy+self.spd_y
			local c=tonum(sub(ptcl_fire_col,1+round(v.age/16),_),0x1)
			if v.type=="bullet" then
				line(ox,oy,v.x,v.y,c)
			else
				spr(v.spr,v.x-4,v.y-4)
			end
			if(v.age>v.age_max or v.x>131 or v.y>131 or v.x<-4 or v.y<-4) del(self.particles,v)

			-- hit test bullet & enemy
			-- todo: 폭탄 임시 처리해 둔 상태
			local dmg=(v.type=="bomb") and 100 or 1
			local dist=(v.type=="bomb") and 9 or 6
			for j,e in pairs(_enemies.list) do
				if abs(v.x-e.x)<=dist and abs(v.y-e.y)<=dist and get_dist(v.x,v.y,e.x,e.y)<=dist then
					e.hp-=dmg
					if e.hp<=0 then
						add_explosion_eff(e.x,e.y,v.sx,v.sy,v.type=="bomb")
						del(_enemies.list,e)
						-- sfx(v.type=="bomb" and 0 or 3,3)
						sfx(3,3)
						_enemies:add(-140-rndi(5)*10,rndi(8)*10-35)
					else
						e.hit_count=4
						local a=atan2(e.x-v.x,e.y-v.y)
						add_hit_eff(v.x,v.y,a)
						sfx(22,3)
					end
					del(self.particles,v)
				end
			end

		elseif v.type=="explosion" then
			circfill(v.x,v.y,
				sub(ptcl_size_explosion,v.age,_)*v.size,
				tonum(sub(ptcl_col_explosion,v.age,_),0x1))
			v.x+=v.sx-self.spd_x+rnd(1)-0.5
			v.y+=v.sy+self.spd_y+rnd(1)-0.5
			v.sx*=0.95
			v.sy*=0.95
			v.sy+=0.02
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
	self.spd_max=1.2
	self.angle=0
	self.angle_acc=0
	self.angle_acc_pow=0.0004
	self.thrust=0
	self.thrust_acc=0
	self.thrust_max=1.4
	self.tail={x=0,y=0}
	self.head={x=0,y=0}
	self.fire_spd=2.4 -- 1.4 -> 3.0
	self.fire_intv=0
	self.fire_intv_full=8 -- 20 -> 5
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
	-- if f%6<3 then palt(7,true) end
	-- local s=get_spr(self.angle)
	-- spr(s.spr,cx-8,cy-8,2,2,s.fx,s.fy)
	-- pal()
	-- line(cx,cy,cx+x0*60,cy+y0*60,9)
	local s=get_spr2(self.angle)
	sspr(s.x,s.y,13,15,cx-6,cy-6,13,15,s.fx,s.fy)
	-- circ(cx,cy,8,11)

	self.tail.x=cx-x0*10
	self.tail.y=cy-y0*10
	self.head.x=cx+x0*10
	self.head.y=cy+y0*10
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
		local da1=self.angle-to_angle
		local da2=to_angle-self.angle
		da1=da1<0 and da1+1 or da1
		da2=da2<0 and da2+1 or da2
		if da1>da2 then self.angle_acc+=self.angle_acc_pow
		else self.angle_acc-=self.angle_acc_pow end
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
		sfx(24,-1)
		self.fire_intv=self.fire_intv_full
		local fire_spd_x=cos(self.angle)*self.fire_spd+self.spd_x
		local fire_spd_y=sin(self.angle)*self.fire_spd+self.spd_y
		add(_space_f.particles,
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
		add(_space_f.particles,
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
	-- 항상 엔진음, 분사효과 출력
	if(f%6==0) sfx(4,2)
	add(_space_f.particles,
		{
			type="thrust",
			-- x=self.tail.x-2+rnd(4),
			-- y=self.tail.y-2+rnd(4),
			x=self.tail.x-1+rnd(2),
			y=self.tail.y-1+rnd(2),
			sx=-self.spd_x*1.1,
			sy=-self.spd_y*1.1,
			age_max=30,
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
		if abs(e.x-cx)<=8 and abs(e.y-cy)<=8 and get_dist(e.x,e.y,cx,cy)<=8 then	
			-- simply speed change(don't consider hit direction)
			local sx=e.spd_x
			local sy=e.spd_y
			e.spd_x=self.spd_x*1.2
			e.spd_y=self.spd_y*1.2
			self.spd_x=sx*1.2
			self.spd_y=sy*1.2

			

			sfx(2,3)
			self.hit_count=8
			e.hit_count=8
			e.hp-=1
			local d=atan2(e.x-cx,e.y-cy)
			add_hit_eff((cx+e.x)/2,(cy+e.y)/2,d)
		end
	end

	-- space speed update
	_space.spd_x=self.spd_x
	_space.spd_y=-self.spd_y
	_space_f.spd_x=self.spd_x
	_space_f.spd_y=-self.spd_y
	
	-- space center move(use space speed & ship direction)
	local tcx=64-self.spd_x*14-cos(self.angle)*10
	local tcy=64-self.spd_y*14-sin(self.angle)*10
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
		self:add(x*70,y*70)
		self:add(x*100,y*100)
	end

	self:show(true)
end
function enemies:_draw()
	--for i,e in pairs(self.list) do
	for e in all(self.list) do
		e.space_x+=e.spd_x-_space.spd_x
		e.space_y+=e.spd_y+_space.spd_y
		e.x=e.space_x+cx
		e.y=e.space_y+cy
		e.spd_x+=e.acc_x
		e.spd_y+=e.acc_y
		e.spd_x*=0.99
		e.spd_y*=0.99

		e.spd_x=0.2+rnd()*0.4 -- 임시로 순항속도 설정
		
		if e.x<-4 then
			spr(80,0,clamp(e.y-4,4,118))
		elseif e.x>131 then
			spr(80,120,clamp(e.y-4,4,118),1,1,true)
		elseif e.y<-4 then
			spr(81,clamp(e.x-4,4,118),0)
		elseif e.y>131 then
			spr(81,clamp(e.x-4,4,118),120,1,1,false,true)
		else
			if e.hit_count>0 then
				e.hit_count-=1
				pal({6,6,6,6,6,7,7,6,7,7,7,7,7,7,7,6})
				spr(8,e.x-8,e.y-8,2,2)
			else
				if(e.type==2) pal({[3]=8,[15]=9,[5]=4})
				if f%6<3 then palt(7,true) end
				spr(8,e.x-8,e.y-8,2,2)
			end
		end
		pal()


	end

	-- head to ship
	--[[ for e in all(self.list) do
		e.think_count-=1
		if e.think_count<=0 then
			local a=atan2(cx-e.x,cy-e.y)
			local sx=cos(a)
			local sy=sin(a)
			e.acc_x=sx*0.004
			e.acc_y=sy*0.004
			e.think_count=60
			-- todo: attack ship! *************************
		end
	end ]]

	-- hit test between enemies
	--[[ for i,e1 in pairs(self.list) do
		for j=i+1,#self.list do
			local e2=self.list[j]
			if abs(e1.x-e2.x)<=8 and abs(e1.y-e2.y)<=8 and get_dist(e1.x,e1.y,e2.x,e2.y)<=8 then
				-- 대충하는 충돌 처리
				-- todo: 최대 속도 제한 + 좀 더 정확한 물리 계산
				local sx,sy=e1.spd_x,e1.spd_y
				e1.spd_x=e2.spd_x*1.2
				e1.spd_y=e2.spd_y*1.2
				e2.spd_x=sx*1.2
				e2.spd_y=sy*1.2
				e1.hit_count=8
				e2.hit_count=8
				e1.hp-=1
				e2.hp-=1
				local hx,hy=(e1.x+e2.x)/2,(e1.y+e2.y)/2
				if hx>0 and hx<127 and hy>0 and hy<127 then
					local d=atan2(e1.x-e2.x,e1.y-e2.y)
					add_hit_eff(hx,hy,d)
					sfx(2,3)
				end
			end
		end
	end ]]

end
function enemies:add(x,y)
	local hp,type=1,1
	if(rnd()>0.9) hp,type=10,2
		
	local e={
		x=0,
		y=0,
		spd_x=(rnd(1)-0.5)/4,
		spd_y=(rnd(1)-0.5)/4,
		acc_x=0,
		acc_y=0,
		space_x=x,
		space_y=y,
		hp=hp,
		hit_count=0,
		think_count=120+rndi(120),
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

-- enemy airplane sprites
function get_spr(angle)
	local s,fx,fy=0,false,false
	-- angle=value_loop(angle,0,1)+0.0312
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

function add_explosion_eff(x,y,spd_x,spd_y,is_bomb)
	local count=is_bomb and 32 or 16
	for i=1,count do
		local sx=cos(i/count+rnd()*0.1)
		local sy=sin(i/count+rnd()*0.1)
		if is_bomb then sx*=1.6 sy*=1.6 end
		add(_space_f.particles,
		{
			type="explosion",
			x=x+rnd(6)-3,
			y=y+rnd(6)-3,
			sx=sx*(0.5+rnd()*1.2)+spd_x*0.7,
			sy=sy*(0.5+rnd()*1.2)+spd_y*0.7,
			size=is_bomb and 1.5 or 1,
			age=1+rndi(16)
		})
		add(_space_f.particles,
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
		--local a=angle+round(i/8)/2-0.25
		local a=angle+round(i/8)*0.8-0.4
		local sx=cos(a)
		local sy=sin(a)
		add(_space_f.particles,
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



-- <constants> --------------------



--------------------------------------------------
f=0 -- every frame +1
dim_pal={} -- 이게 있으면 stage 렌더링 시작할 때 팔레트 교체
stage=sprite.new() -- scene graph top level object
cx,cy=64,64 -- space center

function _init()
	--music(13,2000,2)

	_space=space.new()
	_ship=ship.new()
	_enemies=enemies.new(4)
		
	stage:add_child(_space)
	stage:add_child(_ship)
	stage:add_child(_enemies)
	--[[ 
	_enemies={}
	for i=1,10 do
		local e=enemy.new(rnd(127)-64,rnd(127)-64)
		add(_enemies,e)
		stage:add_child(e)
	end
 ]]
	_space_f=space.new(true) -- front layer
	stage:add_child(_space_f)
end
function _update60()
	f+=1
	stage:emit_update()
end
function _draw()
	cls(12)
	pal()

	if(#dim_pal>0) pal(dim_pal,0)
	stage:render(0,0)

	-- 개발용
	if dev==1 then
		print_log()
		print_system_info()
	end
end