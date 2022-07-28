dev=0
ver="0.6 - under development" -- 2022/07/28

-- 원작 참고
-- https://youtu.be/JPBkZHX3ju8
-- https://youtu.be/v_OzRECVOk8
-- https://youtu.be/ir58VpJV-8Q (리메이크?)

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



-- <record & playback> --------------------
--[[ _b0=btn
function record() _bm=1 _bp=1 _bt=0 _bd="" end
function playback() _bm=2 _bp=1 _bt=0 end
function btn(p)
  local b=_b0()
  if _bm==1 then -- record
    if b!=_bl then
      if _bd>"" then _bd=_bd.._bt.."," else _bd="" _bt=0 _bp=1 end
      _bl=b _bd=_bd..b.."," _bt=0
    else _bt+=1 end
    if _b0()==4096 then -- tab to stop recording
      printh("btnpb={"..sub(_bd,1,#_bd-1).."}\n","@clip")
      stop()
    end
    return _b0(p)
  elseif _bm==2 then -- playback
    if _bt>0 then _bt-=1 
    else
      _bs=btnpb[_bp]
      _bt=btnpb[_bp+1]
      _bp+=2
      if _bt==nil then
				_bm=0
				if playback_repeat then
					start_playback()
				end
			end
    end
    if p==nil then return _bs
    elseif band(_bs,2^p)>0 then return true
    else return false end
  else
    return _b0(p)
  end
end ]]



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
function rndi(n) return flr(rnd(n)) end -- random int
function printa(t,x,y,c,align,shadow,shadow_color) -- 0.5 center, 1 right align
	x-=(align or 0)*4*#(tostr(t))
	if (shadow) ?t,x+1,y+1,shadow_color or 0
	?t,x,y,c
end



-- <space> --------------------
space=class(sprite)
function space:on_update() end
function space:init(is_front)
	self.spd_x=0
	self.spd_y=0
	self.spd_cx=0
	self.spd_cy=0
	self.stars={}
	self.particles={}
	self.is_front=is_front

	local function make_cloud(i,spd,spd_max,size)
		return {
			x=rnd(127),
			y=rnd(127),
			spd=spd+rnd()*(spd_max-spd),
			size=size
		}
	end
	local ss=self.stars
	if is_front then
		for i=1,2 do add(ss,make_cloud(i,2,2.8,4)) end
		for i=1,2 do add(ss,make_cloud(i,3,4,4)) end
	else
		for i=1,4 do add(ss,make_cloud(i,0.1,0.3,0)) end
		for i=1,6 do add(ss,make_cloud(i,0.3,0.5,1)) end
		for i=1,4 do add(ss,make_cloud(i,0.6,0.9,2)) end
		for i=1,4 do add(ss,make_cloud(i,0.9,1,3)) end
	end

	self:show(true)
	self:on("update",self.on_update)
end

-- ptcl_size_enemy="010111010100"
-- ptcl_size_thrust="001011212222121211111110101000000"
-- ptcl_thrust_col="777aa99ee8844d4dd6d666"
ptcl_fire_col="89a7"
ptcl_size_explosion="3577767766666555544444333332222221111111000"
ptcl_col_explosion="77aaa99a99888988999494445555666"
ptcl_col_explosion_dust="779856"
ptcl_col_hit="cc7a82"

function space:_draw()
	-- 하단 그라데이션
	--[[ if not self.is_front then
		for i=0,8 do
			fillp(cover_pattern[9-i])
			local y=(cy+64)/2+66
			rectfill(0,y-(i+1)*5,127,y-i*5,9)
		end
		fillp()
	end ]]

	-- 구름
	pal({[7]=ss.cloud_color,[10]=ss.cloud_color,[6]=ss.cloud_far_color,[9]=ss.cloud_far_color}) -- 구름 색을 스테이지 정보에 맞춤
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
				-- 비행기 가리는 구름은 망점 처리
				x2=flr(x2) y2=flr(y2)
				if abs(cx-x2)<24 and abs(cy-y2)<16 then
					if (x2-y2)%2<1 then palt(9,true) palt(10,true)
					else palt(6,true) palt(7,true) end
				end
				if i%2==0 then
					spr(67,x2-16,y2-2)
					spr(64,x2-12,y2-4)
					sspr(0,48,16,16,x2-8,y2-8,16,16)
					spr(64,x2+6,y2-2)
				else
					spr(66,x2-12,y2-2)
					spr(64,x2-8,y2-4)
					sspr(0,48,16,16,x2-4,y2-8,16,16)
					spr(64,x2+8,y2-2)
				end
				palt()
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
		elseif v.size<=1 then -- 원경 단색 구름
			color(ss.cloud_far_color)
			if(v.size==0) fillp(cover_pattern[5])
			if i%2==0 then circfill(x2-5,y2+1,2) circfill(x2,y2,4) circfill(x2+6,y2+1,2)
			else circfill(x2-5,y2+1,2) circfill(x2,y2,3) circfill(x2+4,y2+1,2)
			end
			fillp()
		end
	end
	pal()

	-- 온갖 이펙트 파티클들
	for v in all(self.particles) do
		if v.type=="thrust" then
			fillp(cover_pattern[10-clamp(round((v.age/v.age_max)^2*9),0,9)])
			circfill(v.x,v.y,1,ss.cloud_color)
			fillp()
			v.x+=v.sx-self.spd_x+rnd(0.6)-0.3
			v.y+=v.sy+self.spd_y+rnd(0.6)-0.3

		elseif v.type=="smoke" then
			fillp(cover_pattern[10-clamp(flr(v.age*0.1),0,9)])
			circfill(v.x,v.y,1.5+(v.age/60)*6,0)
			fillp()
			v.x+=v.sx-self.spd_x+self.spd_cx+rnd(2)-1
			v.y+=v.sy+self.spd_y+self.spd_cy+rnd(2)-1
		
		elseif v.type=="enemy_trail" then
			pset(v.x,v.y,ss.cloud_color)
			v.x+=v.sx-self.spd_x+self.spd_cx+rnd(0.4)-0.2
			v.y+=v.sy+self.spd_y+self.spd_cy+rnd(0.4)-0.2

		elseif v.type=="bullet" or v.type=="bullet_enemy" then
			local ox,oy=v.x,v.y
			v.x+=v.sx-self.spd_x+self.spd_cx
			v.y+=v.sy+self.spd_y+self.spd_cy
			local c=tonum(sub(ptcl_fire_col,1+round(v.age/16),_),0x1)
			
			-- if(v.age>v.age_max or v.x>131 or v.y>131 or v.x<-4 or v.y<-4) del(self.particles,v)
			if(not is_inside(v.x,v.y,4)) del(self.particles,v) -- 화면 밖으로 나간 총알은 제거

			-- 총알 그리기 & 총알과 적 충돌처리(조종 가능할 때만)
			if v.type=="bullet" and gg.control then
				line(ox,oy,v.x,v.y,c)
				local dist=6
				for e in all(_enemies.list) do
					if(e.type==999) goto continue -- 낙하산은 아래 처리 건너뜀
					if abs(v.x-e.x)<=e.w/2 and abs(v.y-e.y)<=e.h/2 then -- 개별 적의 w,h 거리만 비교
						e.hp-=1
						if e.hp<=0 then
							if e.type==801 then -- 미사일
								add_score(300)
								_enemies.msl_counter-=1
							elseif e.type<100 then -- 자코
								_ui.kill_zako+=1
								add_score(100)
							elseif e.type<200 then -- 중간보스
								add_score(1500)
								add_score_eff(e.x,e.y,1500)
								_enemies:mid_kill()
							elseif e.type<300 then -- 보스
								_ui.kill_boss+=1
								add_score(5000)
								add_score_eff(e.x,e.y,5000)
								_enemies:boss_kill()
							end
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
				circ(v.x,v.y,1,9+rndi(3))
				circfill(v.x,v.y,0,8)
				if gg.control and not _ship.is_killed and abs(v.x-cx)<=3 and abs(v.y-cy)<=3 then
						_ship:kill()
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

		elseif v.type=="explosion_dust" then
			local c=tonum(sub(ptcl_col_explosion_dust,1+flr(v.age/5),_),0x1)
			pset(v.x,v.y,c)
			v.x+=v.sx-self.spd_x
			v.y+=v.sy+self.spd_y
			v.sx*=0.96
			v.sy*=0.96
			v.sy+=0.02

		elseif v.type=="hit" then
			local c=tonum(sub(ptcl_col_hit,1+flr(v.age/3),_),0x1)
			pset(v.x,v.y,c)
			v.x+=v.sx-self.spd_x
			v.y+=v.sy+self.spd_y
			v.sx*=0.94
			v.sy*=0.94
		
		elseif v.type=="circle" then
			v.size+=0.6
			circ(cx,cy,v.size,8+rndi(7))

		elseif v.type=="score" then
			printa(v.value,v.x,v.y,7,0.5,true)
			v.x-=self.spd_x*1.5
			v.y+=self.spd_y*1.2

		elseif v.type=="bonus" then
			local s=v.is_first and "1st bonus!" or "bonus!"
			printa(s,68,118-cos((60-v.age)/120)*5,8+flr(f/5%5),0.5,true)

		elseif v.type=="stage_info" then
			printa(v.t1,63,45,7,0.5,true)
			printa(v.t2,63,77,8+flr(f/5%5),0.5,true)
			-- printa(gg.phase,63,90,7,0.5,true)

		elseif v.type=="time_jump" then
			local delay=60 -- 초반 딜레이만큼 기다림
			if v.age>delay and f%5<3 then
				local w=min(50,(v.age-delay)*0.6)+rnd(20)
				if(v.age>180+delay) w=(240+delay-v.age)/2
				circfill(cx,cy,min(w,8+rnd(3)),7)
				ovalfill(cx-w/3,cy-4,cx+w/3,cy+4,7)
				ovalfill(cx-w/1.5,cy-2,cx+w/1.5,cy+2,7)
				ovalfill(cx-w,cy-1,cx+w,cy+1,7)
				line(cx-w*1.4,cy,cx+w*1.4,cy,7)
				do -- 방사형 라인 짜릿짜릿
					local r,l=rnd(),10+rnd()*w
					local x,y=cos(r)*l,sin(r)*l
					line(cx-x,cy-y,cx+x,cy+y,7)
				end
			end
		end

		if(v.age>v.age_max) del(self.particles,v)
		v.age+=1
	end
end




-- <ship> --------------------
ship=class(sprite)
function ship:init()
	self.spd=0
	self.spd_x=0
	self.spd_y=0
	self.spd_cx=0
	self.spd_cy=0
	self.spd_max=0.7
	self.angle=0
	self.angle_acc=0
	self.angle_acc_pow=0.0006
	self.thrust=0
	self.thrust_acc=0
	self.thrust_max=1.4
	self.tail={x=0,y=0}
	self.head={x=0,y=0}
	self.fire_spd=2.2
	self.fire_intv=0
	self.fire_intv_full=6
	self.hit_count=0
	self.is_killed=false
	self.killed_angle=0.65
	self.timer_killed=0
	self.time_jump_mode=false
	self.time_jump_count=0
	self:show(true)
	self:on("update",self.on_update)
end

-- guide_pattern_str=[[
-- 0b1111011111111101.1,
-- 0b0111110111111111.1,
-- 0b1101111101111111.1,
-- ]]
-- guide_pattern=split(guide_pattern_str,",")

function ship:_draw()
	local x0=cos(self.angle)
	local y0=sin(self.angle)
	local x1=cx+0.5-x0*2
	local y1=cy+0.5-y0*2

	-- ship body
	if self.time_jump_mode then
		self.time_jump_count+=1
		if self.time_jump_count>120 or f%7>3 then
			pal({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
		end
	elseif self.hit_count>0 then
		pal({6,6,6,6,6,7,7,6,7,7,7,7,7,7,7,6})
		self.hit_count-=1
	end
	local s=get_spr2(self.angle)
	sspr(s.x,s.y,13,15,cx-4,cy-4,13*0.7,15*0.7,s.fx,s.fy) -- 스케일 줄여 봄
	pal()

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
	if self.is_killed then
		to_angle=self.killed_angle+cos(f/60)*0.03
	elseif gg.control then
		if btn(1) and btn(2) then to_angle=0.125
		elseif btn(2) and btn(0) then to_angle=0.375
		elseif btn(0) and btn(3) then to_angle=0.625
		elseif btn(3) and btn(1) then to_angle=0.875
		elseif btn(0) then to_angle=0.5
		elseif btn(1) then to_angle=0
		elseif btn(2) then to_angle=0.25
		elseif btn(3) then to_angle=0.75 end
	elseif gg.control_waiting>0 then
		gg.control_waiting-=1
		if(gg.control_waiting<=0) gg.control=true
	end
	
	-- 회전 거리가 짧은 쪽으로 회전
	if abs(to_angle-self.angle)>0.02 then
		self.angle_acc+=self.angle_acc_pow*get_rotate_dir(self.angle,to_angle)
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
	
	if(self.is_killed) goto continue -- 죽었으면 공격 불가

	-- fire
	self.fire_intv-=1
	if btn(4) and self.fire_intv<=0 and gg.control then
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
	end

	-- 보스 잡은 것처럼 해보자
	if dev==1 and btn(5) and _enemies.boss_killed==false then
		_enemies:boss_kill()
	end

	::continue::

	-- 분사효과 or 검은연기
	if self.is_killed then
		add_smoke_eff(self.tail.x+rnd(0.6)-0.3,self.tail.y+rnd(0.6)-0.3,-self.spd_x*1.5,-self.spd_y*1.5)
	elseif not _cover.is_stage_clear then
		add_thrust_eff(self.tail.x,self.tail.y,-self.spd_x*1.3,-self.spd_y*1.3,40)
	end

	-- 나와 적의 충돌 체크
	if not self.is_killed then
		for e in all(_enemies.list) do
			if abs(e.x-cx)<=e.w/2 and abs(e.y-cy)<=e.h/2 then -- 적의 w,h만으로 거리 계산(내 크기 고려 안 함)
				if e.type==999 then -- 낙하산 먹기
					_enemies:para_kill()
					_ui.kill_para+=1
					sfx(32,-1)
					add(_space.particles,{type="circle",size=3,age=1,age_max=32})
					add_explosion_eff(e.x,e.y,self.spd_x,self.spd_y,true)
					add_score(5000)
					add_score_eff(e.x,e.y,5000)
					del(_enemies.list,e)
				else
					self:kill()
				end
			end
		end
	end

	-- space speed update
	_space.spd_x=self.spd_x
	_space.spd_y=-self.spd_y
	_space_f.spd_x=self.spd_x
	_space_f.spd_y=-self.spd_y
	
	-- Space의 중심을 살짝 옮겨서 전방 시야 확보(비행기 방향만 고려)
	-- 단, gg.control_waiting이 있을 때는 정중앙에 표시하다가 서서히 옮겨 감
	local dst=
		gg.scene=="title" and 0 or
		self.is_killed and max(-50,-self.timer_killed/2) or
		max(0,40-gg.control_waiting)/40*14
	local tcx=64-cos(self.angle)*dst
	local tcy=64-sin(self.angle)*dst
	_space.spd_cx=(tcx-cx)*0.12
	_space.spd_cy=(tcy-cy)*0.12
	_space_f.spd_cx=_space.spd_cx
	_space_f.spd_cy=_space.spd_cy
	cx=cx+(tcx-cx)*0.12
	cy=cy+(tcy-cy)*0.12
end

function ship:kill()
	music(-1,1000,3)
	sfx(3,-1)
	shake()
	add_explosion_eff(self.tail.x,self.tail.y,self.spd_x,self.spd_y,false,true)
	self.is_killed=true
	self.timer_killed=0
	self.killed_angle=(self.angle>0.25 and self.angle<0.75) and 0.65 or 0.85
	gg.control=false
	gg.planes-=1
	_ui:show(false)
	_cover:cover_killed()
end

function ship:rebirth()
	music(18,1000,3)
	self.is_killed=false
	self.timer_killed=0
	self.angle=0
	self.time_jump_mode=false
	self.time_jump_count=0
	gg.control=true
	_ui:show(true)
end



-- <enemies> --------------------
enemies=class(sprite)
function enemies:init()
	self:reset()
	self:show(true)
end
function enemies:reset()
	self.list={}
	self.appear_wait=5
	self.mid_appear=false
	self.boss_appear=false
	self.para_appear=false
	self.para_chker=0
	self.msl_counter=0
	self.boss_killed=false
end
function enemies:clear() -- 조용히 제거만 하는 것(죽고 다시 시작할 때)
	self.list={}
	self.appear_wait=5
	self.mid_appear=false
	self.boss_appear=false
	self.para_appear=false
	self.para_chker=0
	self.msl_counter=0
end
function enemies:mid_kill()
	self.mid_appear=false
end
function enemies:boss_kill() -- 보스 킬(적, 총알 싹 제거 + 스테이지 클리어 단계로 넘어가기)
	_space.particles={}
	_space_f.particles={}
	self.boss_killed=true
	for e in all(self.list) do add_explosion_eff(e.x,e.y,0,0) end
	self.list={}

	gg.control=false
	add(_space.particles,{type="time_jump",age=0,age_max=300})
	_ship.time_jump_mode=true
	_cover:cover_cleared()
end
function enemies:para_kill()
	self.para_appear=false
	self.para_chker=0
end
function enemies:group_update() -- 적들의 수를 일정하게 관리
	if(self.appear_wait>0) self.appear_wait-=1
	if
		gg.is_gameover or
		not gg.control or
		self.appear_wait>0 or
		self.boss_killed then return end
	srand(f%101)

	-- 자코 출격!
	if #self.list<ss.max_zako then
		local is_left=_ship.angle>0.25 and _ship.angle<0.75 -- 전방에서 등장
		local x=is_left and -85 or 85
		local angle=is_left and 0 or 0.5
		self:add(x,-50+rnd(100),ss.zako_type,angle)
	end

	-- 중간보스 출격! (보스 나오기 전까지만)
	if not self.mid_appear and ss.mid_type>0 and _ui.kill_zako<=ss.zako_to_boss then
		self:add(-85,-50+rnd(100),ss.mid_type,0)
		self.mid_appear=true
	end
	
	-- 보스 출격! (중간보스 없어야 함)
	if not self.boss_appear and _ui.kill_zako>=ss.zako_to_boss and not self.mid_appear then
		self:add(-85,-50+rnd(100),ss.boss_type,0)
		self.boss_appear=true
	end

	-- 낙하산
	if not self.para_appear then
		self.para_chker+=1
		if self.para_chker>=30 then -- 낙하산 출현 빈도
			self:add(0,-85,999,0)
			self.para_appear=true
			self.para_chker=0
		end
	end
end

function enemies:_draw()
	if(f%37==0) self:group_update() -- 주기적으로 적 생성

	for i,e in pairs(self.list) do
		e.space_x+=e.spd_x-_space.spd_x
		e.space_y+=e.spd_y+_space.spd_y
		e.x=e.space_x+cx
		e.y=e.space_y+cy
		
		if e.type==801 then -- 유도미사일: 항상 나를 향함
			if (f+i*5)%20==0 then
				local to_angle=atan2(cx-e.x,cy-e.y)
				local angle_dist=value_loop_0to1(e.angle-to_angle)
				if angle_dist>0.1 then
					e.angle_acc=0.003*get_rotate_dir(e.angle,to_angle)
				else
					e.angle_acc=0
				end
			end

		elseif e.type<100 then -- 자코: 정기적으로 비행 방향 업데이트 + 공격
			if (f+i*10)%90==0 then
				local to_angle=atan2(cx-e.x,cy-e.y)
				local angle_dist=value_loop_0to1(e.angle-to_angle)
				if angle_dist>0.2 then
					e.angle_acc=0.0022*get_rotate_dir(e.angle,to_angle)
				else
					e.angle_acc=0
				end
				
				-- 전방에 보인다 싶으면 공격
				-- todo: 너무 가까울 때는 안쏴야 할 듯한.....????
				if angle_dist<0.2 then
					if e.x>0 and e.y>0 and e.x<127 and e.y<127 then
						add_enemy_bullet(e.x+e.spd_x*16,e.y+e.spd_y*16,cos(e.angle)*0.7,sin(e.angle)*0.7,150)
						sfx(25,-1)
					end
					-- line(e.x,e.y,cx,cy,11) -- 나를 향해 선을 그려보자
				end
			end

		elseif e.type>100 and e.type<300 then -- 중간보스,보스는 전방위로 공격
			if is_inside(e.x,e.y,0) and f%60==0 then
				if e.type==203 then -- 미사일 공격 타입
					if(self.msl_counter<ss.max_msl) self:add(e.x-cx,e.y-cy+6,801,0) sfx(25,-1)
				else
					local to_angle=atan2(cx-e.x,cy-e.y)+rnd(0.08)-0.04
					local sx,sy=cos(to_angle)*0.4,sin(to_angle)*0.4
					add_enemy_bullet(e.x+sx*12,e.y+sy*12,sx,sy,150)
					sfx(25,-1)
				end
			end
		end

		-- 방향에 맞게 x,y속도 설정
		if e.type==999 then -- 낙하산은 좌우 흔들흔들
			e.spd_x=sin(f/100)*0.5
			e.spd_y=0.2
		else
			e.angle=value_loop_0to1(e.angle+e.angle_acc)
			e.spd_x=cos(e.angle)*e.spd
			e.spd_y=sin(e.angle)*e.spd
		end

		-- 타입에 맞는 트레일 추가(낙하산 제외)
		if e.type==801 then -- 유도미사일
			if(f%2==0) add_trail_eff(e.x,e.y,-e.spd_x*1.3,-e.spd_y*1.3,60)
		elseif f%3==0 and e.type!=999 then
			local x,y=e.x-e.spd_x*12,e.y-e.spd_y*12
			local sx,sy=-e.spd_x*1.8,-e.spd_y*1.8
			if e.type>100 and e.type<300 then -- 중간보스, 보스(오른쪽으로만 비행)
				x=e.x-9
				y=e.y+rnd()
				sx=-0.9
				sy=0
			end
			add_trail_eff(x,y,sx,sy,14)
		end

		-- 화면 밖으로 멀어지면 가까운 곳으로 옮김(플레이어 방향 고려)
		--[[ if e.x<-120 or e.y<-120 or e.x>247 or e.y>247 then
			local a=_ship.angle+rnd()*0.1-0.05
			local x=cos(a)*130
			local y=sin(a)*130
			e.space_x=x
			e.space_y=y
			e.x=x+cx
			e.y=y+cy
		end ]]
		-- 화면 밖으로 많이 멀어지면 제거(자동으로 리필되니까)
		-- local mg=120
		-- if e.x<-4-mg or e.y<-4-mg or e.x>131+mg or e.y>131+mg then
		if not is_inside(e.x,e.y,120) then
			if(e.type>100 and e.type<200) self.mid_appear=false
			if(e.type>200 and e.type<300) self.boss_appear=false
			if(e.type==801) self.msl_counter-=1
			del(self.list,e)
		end
		
		-- 화면 밖 인디케이터용 색상
		-- if(e.type==2) pal{[11]=8} -- 빨간 자코
		-- if(e.type>200 and e.type<300) pal{[11]=10} -- 보스(노란색)

		if not is_inside(e.x,e.y,20) then -- 화면 밖에 있을 때는 인디케이터만 표시
			if e.type>100 then -- 자코 제외
				if e.x<-4 then
					spr(80,0,clamp(e.y-4,4,118-7))
				elseif e.x>131 then
					spr(80,120,clamp(e.y-4,4,118-7),1,1,true)
				elseif e.y<-4 then
					spr(81,clamp(e.x-4,4,118),0)
				elseif e.y>131-7 then
					spr(81,clamp(e.x-4,4,118),120-7,1,1,false,true)
				end
			end

		else -- 화면 안에 들어왔을 때
			if e.hit_count>0 then -- 총알 맞으면 흰색으로 표시
				e.hit_count-=1
				pal({6,6,6,6,6,7,7,6,7,7,7,7,7,7,7,6})
			else
				if(e.type==2) pal({[3]=8,[15]=9,[5]=4}) -- 자코 빨간 비행기 색상
				if(e.type==3) pal({[3]=12,[15]=6,[5]=13}) -- 자코 파란 비행기 색상
				if(e.type==4) pal({[3]=9,[15]=6,[5]=13}) -- 자코 주황 비행기 색상
				if(e.type==102) pal({[15]=13,[14]=5,[2]=4,[12]=1}) -- 회색 열기구
				if(e.type==202) pal({[3]=9,[5]=4,[11]=10}) -- 주황 폭격기
				if(e.type==203) pal({[3]=8,[5]=2,[11]=14}) -- 빨간 폭격기
				if f%6<3 then palt(12,true) pal{[10]=7} else palt(10,true) pal{[12]=7} end -- 프로펠러 회전(팔레트로 처리)
			end

			if e.type==999 then -- 낙하산 흔들흔들(스프라이트 교체, 좌우반전 활용)
				pal()
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

			elseif e.type>100 and e.type<300 then -- 중간보스, 보스(회전 없이 고정 스프라이트 출력)
				if(e.type==102 or e.type==201) spr(32,e.x-7,e.y-7,2,2) -- 기구 타입
				if(e.type==101 or e.type==202 or e.type==203) spr(34,e.x-7-4,e.y-7,3,2) -- 폭격기 타입
				if e.hp<e.hp_max and f%(4+flr(e.hp/e.hp_max*16))==0 then -- hp가 낮으면 연기 추가(4~20프레임에 한 번씩)
					add_smoke_eff(e.x-e.spd_x*25,e.y-2,-e.spd_x*(1.2+rnd(0.8)),-0.2-rnd(0.4))
				end

			elseif e.type==801 then -- 유도미사일
				local s=get_spr(e.angle)
				if(f%8<4) pal{[8]=11,[2]=3,[15]=7}
				sspr(40+(s.spr/2)*8,16,8,8,e.x-3,e.y-3,8,8,s.fx,s.fy)
				pal()

			else -- 자코(방향에 맞는 스프라이트 골라서 출력)
				local s=get_spr(e.angle)
				sspr(s.spr*8,0,16,16,e.x-4,e.y-4,16*0.6,16*0.6,s.fx,s.fy)
			end

			-- 충돌박스 표시
			-- if(dev and f%8<1) rect(e.x-e.w/2,e.y-e.h/2,e.x+e.w/2,e.y+e.h/2,8)
		end
		pal()
	end
end

function enemies:add(x,y,t,ang)
	local hp,spd,w,h=1,1,8,8
	local app,atk,fly,trail=1,1,1,1
	if(t==1) spd=0.3 -- 자코(초록 비행기)
	if(t==2) spd=0.4 -- 자코(빨간 비행기)
	if(t==3) spd=0.5 -- 자코(파란 비행기)
	if(t==4) hp,spd=2,0.55 -- 자코(주황 비행기)

	if(t==101) hp,spd,w,h=10,0.3,24,10 -- 중간보스(초록 폭격기) / stage 2
	if(t==102) hp,spd,w,h=15,0.2,16,14 -- 중간보스(회색 열기구) / stage 3

	if(t==201) hp,spd,w,h=15,0.2,16,14 -- 보스(열기구) / stage 1
	if(t==202) hp,spd,w,h=30,0.3,24,10 -- 임시보스(주황 폭격기) / stage 2
	if(t==203) hp,spd,w,h=50,0.3,24,10 -- 임시보스(빨간 폭격기) / stage 3

	if(t==801) w,h,spd=6,6,0.6 self.msl_counter+=1 -- 유도미사일
	if(t==999) w,h=14,14 -- 낙하산 충돌영역 넉넉하게

	hp=(t<100 or t==801) and hp or hp*gg.phase -- 페이즈 진행할수록 적 피통 커짐(자코, 미사일 제외)

	local e={
		x=0,
		y=0,
		w=w,
		h=h,
		spd=spd,
		spd_x=0,
		spd_y=0,
		acc_x=0,
		acc_y=0,
		angle=ang or rnd(),
		angle_acc=0,
		space_x=x,
		space_y=y,
		hp=hp, 
		hp_max=hp,
		hit_count=0,
		type=t,
		-- app_type=1, -- 외형 타입: 1 프로펠러기, 2 미래전투기(플레이어), 3 헬기, 4 비행선, 5 폭격기, 6 UFO ...
		-- atk_type=atk, -- 공격 타입: 1 내 전방, 2 무조건 플레이어 방향, 3 유도미사일
		-- fly_type=1, -- 비행 타입: 1 프로펠러기, 2 수평등속비행(열기구, 폭격기), 3 헬리콥터, 4 유도미사일
		-- trail_type=1, -- 비행운 타입: 1 일반 쩜쩜, 2 유도미사일 분사
	}
	add(self.list,e)
end



-- <cover> --------------------
cover=class(sprite)
function cover:init()
	self.timer=0
	self.use_dim=false
	self.cover_w=0
	self.cover_h=0
	self.cx=0
	self.cy=0
	self.show_gameover=false
	self.is_stage_clear=false
end
function cover:cover_killed() -- 죽었을 때 커버 씌우기
	self:show(true)
	self.timer=0
	self.use_dim=true
	ss.sky_color=12 ss.cloud_color=7 ss.cloud_shade_color=6 ss.cloud_far_color=6 -- 단색화 전에 원경 색상 보정
	self:on("update",self.on_cover)
end
function cover:cover_cleared()
	self:show(true)
	self.timer=-100 -- 처음에 딜레이를 좀 준다
	self.is_stage_clear=true
	self:on("update",self.on_cover)
end

function cover:_draw()
	if self.use_dim then pal(dim_pal,1) else pal() end
	draw_outcover(self.cover_w,self.cover_h,0,self.cx,self.cy,4)

	-- 게임오버면 여기서 입력 대기
	if self.show_gameover then
		self.cx=62+rnd(4)
		self.cy=62+rnd(4)
		local t="gameover"
		for i=1,#t do
			printa("\^w\^t"..sub(t,i,_),rnd(2)+16+i*9+(i>4 and 5 or 0),45+rnd(4),0,0,true,12)
		end
		printa("\^istage "..gg.stage..", score ".._ui.score_str,67+rnd(1.6),63+rnd(1.6),0,0.5,true,12)
		if(f%60<40) printa("press 🅾️❎ to coutinue",19+rnd(2),73+rnd(2),0,0,true,12)
		self.timer+=1
		if (btn(4) or btn(5)) and self.timer>120 then
			self.timer=0
			self.show_gameover=false
			self:on("update",self.on_cover_to_title)
			sfx(6,-1)
		end
	end
end
function cover:on_cover()
	_ship.timer_killed+=1
	self.timer+=1

	-- 게임오버면 커버를 완전히 덮지 않고 추락 상황을 계속 유지하면서 game over 표기
	-- 그게 아니면 완전히 닫고 부활 or 다음 스테이지로...
	local is_gameover=gg.planes<0
	self.cover_w=max(0,500-self.timer*2.5)
	self.cover_h=self.cover_w
	self.cx=cx
	self.cy=cy

	if is_gameover then
		self.cx=64
		self.cy=64
		self.cover_h=self.cover_w
		if self.cover_w<=110 then
			self.timer=0
			self.show_gameover=true
			self:remove_handler("update",self.on_cover)
			-- 여기서 멈추고 입력 대기(_draw에서 처리)
		end

	elseif self.cover_w<=0 then -- 커버 완전히 덮임
		self.timer=0
		self.use_dim=false
		self.cx=64
		self.cy=64

		-- 죽고 다시 시작할 준비(부활, 적들 제거, 총알이나 파티클 제거)
		_ship:rebirth()
		_enemies:clear()
		_space.particles={}
		_space_f.particles={}
		gg.control=false
		gg.control_waiting=240

		-- 스테이지 클리어라면? 다음 스테이지로 넘어갈 준비
		if self.is_stage_clear then
			gg.stage+=1
			gg.phase=(gg.stage-1)\#ss_data+1
			_ui:reset()
			_enemies:reset()
		end

		ss_set(gg.stage) -- 원경 색 스테이지에 맞게 셋팅(+죽었을 때 임시로 바꾼 팔래트 원복)
		self:on("update",self.on_uncover)
		self:remove_handler("update",self.on_cover)
	end
end
function cover:on_cover_to_title()
	self.cover_w-=4
	self.cover_h-=4
	if self.cover_w<=-100 then
		-- 타이틀 화면으로 갈 준비(부활, 적들 제거, 총알과 파티클 제거)
		self.use_dim=false
		_ship:rebirth()
		_enemies:clear()
		_ui:reset()
		_space.particles={}
		_space_f.particles={}
		gg_reset()

		self:on("update",self.on_uncover)
		self:remove_handler("update",self.on_cover_to_title)
	end
end
function cover:on_uncover()
	self.timer+=1
	self.cover_w=self.timer*3-90
	self.cover_h=self.cover_w
	if self.cover_w>=160 then -- 커버 다 사라짐
		self.is_stage_clear=false
		if(gg.scene!="title") add_stage_info_eff()
		self:show(false)
		self:remove_handler("update",self.on_uncover)
	end
end



-- <ui> --------------------
ui=class(sprite)
function ui:init()
	self:show(true)
	self:reset()
end
function ui:reset()
	self.kill_zako=0
	self.kill_boss=0
	self.kill_para=0
	self.score_str="0"
end
function ui:_draw()
	rectfill(-3,121,130,130,0)

	-- 남은 자코 게이지
	for i=0,8 do spr(84,1+i*6,122) end
	local w=9*6-1
	-- rectfill(1+w-(w*min(1,self.kill_zako/ss.zako_to_boss)),122,1+w,126,0)
	-- 무거운 방식의 게이지(픽셀 단위로 칠하기)
	for i=1+w-(w*min(1,self.kill_zako/ss.zako_to_boss)),1+w do
		for j=122,126 do
			pset(i,j,pget(i,j)==0 and 0 or 1)
		end
	end

	spr(207,61,122)
	?gg.planes,70,122,8
	self.score_str=print_score(gg.score,8,82,122)
	?"pts",116,122,5
end



-- <title> --------------------
title=class(sprite)
function title:init()
	self:reset()
	self:show(true)
end
function title:reset()
	self.to_sky=false
	self.tran_timer=30
	self.tran_timer_max=30
end
function title:_draw()
	if(gg.scene=="title") self:draw_title()
end
function title:draw_title()
	local r=((self.tran_timer_max-self.tran_timer)/self.tran_timer_max)^1.6 -- 다음 장면으로 넘어가는 비율
	
	local d1,d2,d3=sin(f%90/90),cos(f%90/90),cos((f-3)%90/90)
	draw_outcover(116+d1*8+r*20,60+d2*8+r*76,0)
	palt(3,true) palt(0,false) sspr(32,48,97,16,14,25-d2*6-r*54) palt()
	printa("demake 2022",64,39-d3*6-r*48,7,0.5,true)

	if not self.to_sky then
		if(f%60<40 and f>60) printa("press 🅾️❎ to play",63,86+d2*4,0,0.5)
		?"1st bonus \f410000\f5 pts",26,98+d2*4,5
		?"& every \f450000\f5 pts",30,104+d2*4,5
		?"……… by 🐱seimon,♪gruber ………",-4,122,5
		
		?"v"..ver,1,1,1
		if (btn(4) or btn(5)) and f>60 then
			self.to_sky=true
			self.tran_timer=self.tran_timer_max
			sfx(6,-1)
		end
	end

	-- 장면 전환하다가 타이머 0되면 씬 이름 변경(=더 이상 title을 그리지 않음)
	if self.to_sky then
		self.tran_timer-=1
		if self.tran_timer<=0 then
			self:reset()
			gg.scene="sky"
			gg.control_waiting=150
			add_stage_info_eff()
		end
	end
end



-- <etc. functions> --------------------
-- 화면 흔들기
function shaking()
	if shake_t>0 then
		local n=0.3+shake_t/10
		if(shake_t%2==0) camera(rnd(n)-n/2,rnd(n)-n/2)
		shake_t-=1
	else
		camera(0,0)
		stage:remove_handler("update",shaking)
	end
end
function shake()
	shake_t=90
	stage:on("update",shaking)
end

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

function get_spr(angle) -- 자코 기체
	local s,fx,fy,a=0,false,false,value_loop_0to1(angle+0.0312)
	if a<0.0625 then s=8 -- right
	elseif a<0.125 then s=6
	elseif a<0.1875 then s=4
	elseif a<0.25 then s=2
	elseif a<0.3125 then s=0 -- top
	elseif a<0.375 then s=2 fx=true
	elseif a<0.4375 then s=4 fx=true
	elseif a<0.5 then s=6 fx=true
	elseif a<0.5625 then s=8 fx=true -- left
	elseif a<0.625 then s=10 fx=true
	elseif a<0.6875 then s=12 fx=true
	elseif a<0.75 then s=14 fx=true
	elseif a<0.8125 then s=0 fx=true fy=true -- bottom
	elseif a<0.875 then s=14
	elseif a<0.9375 then s=12
	else s=10 end
	return {spr=s,fx=fx,fy=fy}
end

function get_spr2(angle) -- 플레이어 기체
	-- 13x15 size
	local x,y,fx,fy,a=0,97,false,false,value_loop_0to1(angle-0.015)
	if a<0.25 then
		x=flr(a*4*9)*13
	elseif a<0.5 then
		x=clamp(flr(8-(a-0.25)*4*9),0,9)*13
		fx=true
	elseif a<0.75 then
		x=clamp(flr((a-0.5)*4*8),0,8)*13
		y=113
		fx=true
	else
		x=clamp(flr(7-(a-0.75)*4*8),0,8)*13
		y=113
	end
	return {x=x,y=y,fx=fx,fy=fy}
end

-- todo: 버그가 있는......듯??????
--[[ function value_loop(v,min,max)
  if v<min then v=(v-min)%(max-min)+min
  elseif v>max then v=v%max+min end
  return v
end ]]

-- function value_loop_0to1(v) return v<0 and v+1 or v>1 and v-1 or v end
function value_loop_0to1(v) return v%1 end

function coord_loop(a)
	local x,y=a.x,a.y
	x=x>131 and x-131 or x<-4 and x+131 or x
	y=y>131 and y-131 or y<-4 and y+131 or y
	a.x=x a.y=y
end

function is_inside(x,y,mg)
	return not (x<-mg or x>127+mg or y<-mg or y>127+mg)
end

function get_dist(x1,y1,x2,y2) return sqrt((x2-x1)^2+(y2-y1)^2) end

function add_score_eff(x,y,score)
	add(_space_f.particles,{type="score",x=x,y=y,value=score,age=1,age_max=60})
end
function add_stage_info_eff()
	add(_space_f.particles,{type="stage_info",t1="s t a g e  "..gg.stage,t2="a.d. "..ss.year,age=1,age_max=180})
end
function add_thrust_eff(x,y,sx,sy,mx)
	add(_space.particles,{type="thrust",x=x,y=y,sx=sx,sy=sy,age_max=mx,age=1})
end
function add_trail_eff(x,y,sx,sy,mx)
	add(_space.particles,{type="enemy_trail",x=x,y=y,sx=sx,sy=sy,age_max=mx,age=1})
end
function add_enemy_bullet(x,y,sx,sy,mx)
	add(_space.particles,{type="bullet_enemy",x=x,y=y,sx=sx,sy=sy,age_max=mx,age=1})
end
function add_explosion_eff(x,y,spd_x,spd_y,is_white,is_front)
	local count=20
	local layer=is_front and _space_f or _space
	for i=1,count do
		local sx=cos(i/count+rnd()*0.1)
		local sy=sin(i/count+rnd()*0.1)
		if is_bomb then sx*=1.6 sy*=1.6 end
		local type=is_white and "explosion_white" or "explosion"
		add(layer.particles,
		{
			type=type,
			x=x+rnd(6)-3,
			y=y+rnd(6)-3,
			sx=sx*(0.5+rnd()*1.2)+spd_x*0.7,
			sy=sy*(0.5+rnd()*1.2)+spd_y*0.7,
			size=is_bomb and 1.5 or 1,
			age=1+rndi(16),
			age_max=40
		})
		add(layer.particles,
		{
			type="explosion_dust",
			x=x+rnd(4)-2,
			y=y+rnd(4)-2,
			sx=sx*(1+rnd()*2)+spd_x,
			sy=sy*(1+rnd()*2)+spd_y,
			age=1+rndi(16),
			age_max=30
		})
	end
end
function add_hit_eff(x,y,angle)
	for i=1,6 do
		local a=angle+round(i/6)*0.8-0.4
		local sx=cos(a)
		local sy=sin(a)
		add(_space.particles,
		{
			type="hit",
			x=x+rnd(4)-2,
			y=y+rnd(4)-2,
			sx=sx*(1+rnd()*2),
			sy=sy*(1+rnd()*2),
			age=1+rndi(5),
			age_max=10
		})
	end
end
function add_smoke_eff(x,y,sx,sy,mx)
	add(_space_f.particles,{type="smoke",x=x,y=y,sx=sx,sy=sy,age=1,age_max=mx or 80})
end

function add_score(num)
	gg.score=min(gg.score+num/10000,10000)
	-- bonus
	if gg.bonus_earned<=0 then
		if gg.score>=1 then
			gg.bonus_earned=1
			gg.planes+=1
			add(_space_f.particles,{type="bonus",is_first=true,age=1,age_max=120})
		end
	elseif gg.score\5+1>gg.bonus_earned then
		gg.bonus_earned=gg.score\5+1
		gg.planes+=1
		add(_space_f.particles,{type="bonus",age=1,age_max=120})
	end
end

function print_score(num,len,x,y)
	-- score는 9999.99를 x100한 후 "00"을 붙여서 표현
	-- number의 최대값이 32767.9999라서 더 큰 숫자를 표현하기 위한 것
	-- 0.01+0.01=0.0199인 경우가 있어서 소숫점 2자리까지만 사용함
	-- 최대 327679900점까지 표현 가능하고 9999999까지만 표시함

	local t
	if num>=10000 then t="99999999"
	else
		local t1,t2=round(num%1*100),flr(num)
		if(t1>=100) t1,t2=0,t2+1
		t=t1<=0 and "0" or tostr(t1).."00"
		if t2>0 then
			while #t<4 do t="0"..t end
			t=t2..t
		end
	end

	

	local t0="" for i=1,len-#t do t0=t0.."_" end
	printa(t0,x,y,5,0)
	printa(t,x+len*4,y,9,1)
	return t
end

function draw_outcover(w,h,c,cx,cy,mg)
	local cx=cx or 64
	local cy=cy or 64
	local mg=mg or 0 -- 화면 밖까지 그릴 마진(화면 진동할 때 필요)
	if (cy-1-h/2>=-mg) rectfill(-mg,-mg,127+mg,cy-1-h/2,c)
	if (cy+h/2<128+mg) rectfill(-mg,cy+h/2,127+mg,127+mg,c)
	if (cx-1-w/2>=-mg) rectfill(-mg,cy-h/2,cx-1-w/2,cy-1+h/2,c)
	if (cx+w/2<128+mg) rectfill(cx+w/2,cy-h/2,127+mg,cy-1+h/2,c)

	local ww="6421100"
	local x1,y1=cx-w/2,cy-1-h/2
	for i=1,#ww do line(x1,y1+i,x1+sub(ww,i,_),y1+i,c) end
	x1=cx-1+w/2
	for i=1,#ww do line(x1-sub(ww,i,_),y1+i,x1,y1+i,c) end
	y1=cy+h/2
	for i=1,#ww do line(x1-sub(ww,i,_),y1-i,x1,y1-i,c) end
	x1=cx-w/2
	for i=1,#ww do line(x1,y1-i,x1+sub(ww,i,_),y1-i,c) end
end





--------------------------------------------------
f=0 -- every frame +1
stage=sprite.new() -- scene graph top level object
cx,cy=64,64 -- space center

dim_colors="0020028088222280"
dim_pal={}
for i=1,16 do dim_pal[i]=sub(dim_colors,i,_) end

ss={}
ss_set=function(n)
	n=(n-1)%#ss_data+1
	for i,v in pairs(ss_data[n]) do ss[i]=v end
	-- 페이즈 진행에 따라 난이도 올리기
	ss.zako_to_boss=min(ss_data[n].zako_to_boss*gg.phase,300)
	ss.max_msl=min(ss_data[n].max_msl+gg.phase-1,8)
end
ss_data={ -- 스테이지 데이타
	{
		zako_type=1, -- 자코는 1~99
		mid_type=0, -- 중간보스는 101~199
		boss_type=201, -- 보스는 201~299
		max_zako=6, -- 적 최대 동시 출현 수
		zako_to_boss=20, -- 자코 몇 마리 잡아야 보스가 나올까?
		max_msl=1, -- 화면에 나올 수 있는 미사일 최대
		year="1 9 1 0",
		sky_color=12, -- 하늘 색
		cloud_far_color=6, -- 원경 구름 색
		cloud_color=7, -- 구름 밝은쪽 색
		cloud_shade_color=6, -- 구름 그늘진 색
	},
	{
		zako_type=2,
		mid_type=101, -- 초록 폭격기
		boss_type=202, -- 주황 폭격기
		max_zako=7,
		zako_to_boss=25,
		max_msl=1,
		year="1 9 2 0",
		sky_color=13,cloud_far_color=5,cloud_color=6,cloud_shade_color=13,
	},
	{
		zako_type=3,
		mid_type=102, -- 회색 열기구
		boss_type=203, -- 빨간 폭격기
		max_zako=8,
		zako_to_boss=30,
		max_msl=1,
		year="1 9 7 0",
		sky_color=5,cloud_far_color=4,cloud_color=9,cloud_shade_color=4,
	},
	{
		zako_type=3,
		mid_type=102,
		boss_type=203,
		max_zako=8,
		zako_to_boss=35,
		max_msl=2,
		year="1 9 8 2",
		sky_color=4,cloud_far_color=5,cloud_color=9,cloud_shade_color=5,
	},
	{
		zako_type=4,
		mid_type=102,
		boss_type=203,
		max_zako=8,
		zako_to_boss=35,
		max_msl=3,
		year="2 0 0 1",
		sky_color=1,cloud_far_color=0,cloud_color=2,cloud_shade_color=0,
	},
}
gg={} -- 게임 데이타
gg_reset=function()
	gg={
		scene="title",
		is_gameover=false,
		control=false,
		control_waiting=0,
		stage=1,
		phase=1, -- 막판 클리어하면 1씩 올라감(난이도 증가)
		planes=2,
		score=0,
		bonus_earned=0,
		highscore=0,
	}
	ss_set(gg.stage)
	f=0
end

function _init()
	gg_reset()
	music(0,nil,3)
	music(18,1000,3)
	_space=space.new()
	_ship=ship.new()
	_enemies=enemies.new()
	_space_f=space.new(true) -- front layer
	_ui=ui.new()
	_title=title.new()
	_cover=cover.new()
	stage:add_child(_space)
	stage:add_child(_ship)
	stage:add_child(_enemies)
	stage:add_child(_space_f)
	stage:add_child(_ui)
	stage:add_child(_title)
	stage:add_child(_cover)
end
function _update60()
	f+=1
	stage:emit_update()
end
function _draw()
	cls(ss.sky_color)
	stage:render(0,0)

	-- 개발용
	if dev==1 then
		print_log()
		print_system_info()
	end
end




--[[ 오늘의 업데이트(7/27~28)
- ******** 점수 버그 있음!!!!!! ******** (2만점, 3만점 되는 순간 자릿수가 바뀌는데....???) -> 고쳤다!
- 구름 스프라이트 망점 처리
- 적 타입 여러가지 추가
- 유도미사일 타입 추가(3~5스테이지 보스가 발사)
- 스테이지별 미사일 최대 수 설정(페이즈 올라갈 때마다 많아짐)
- 페이즈 추가(막판 클리어할 때마다 1씩 올라감, 난이도도 같이 상승)
- 게임오버 화면에 스테이지, 점수 표기
]]

--[[ 오늘의 업데이트(7/26)
- 내가 죽으면 내가 쏜 총알이 적을 맞히지 않음(충돌체크 건너뜀)
- 입력 대기시간 추가(타이틀 1초, 게임오버 2초)
- 중간보스 추가(폭격기)
- 자코는 화면 밖 인디케이터 표시하지 않음
- 화면 밖으로 많이 나간 적들은 제거
- 적의 w,h 값을 사용해서 충돌 처리(총알, 동체 충돌 모두)
- 중간보스,보스 hp 비율에 맞게 검은연기 뿜기
- 타임점프할 때 빛선 연출 추가
- 조종 가능한 상태에서만 총알이 발사됨
]]

--[[ todo list
- 보스 죽이는 순간에 총알 맞으면 상황 꼬인다! -> 내가 죽었을 때 내 총알의 충돌처리 안 하는 걸로 해결...?(상황 재발하는지 지켜봐야 함)
- 소리, BGM 제대로...(죽거나 클리어, 미사일 발사 등)
- UI의 자코 게이지 자코 타입에 맞게 표시
- 적의 공격 타입을 정의해놓고 공격할 때 쓰는 게 좋을 듯?
- 화면밖 인디케이터 색상을 적에 맞는 걸로...
- 중간보스 이상은 화면 밖에 있을 때도 검은연기 뿜뿜하자(우하단만 처리해도 될 듯?)
- 적 여러가지 타입으로
  - 1: 전투기 + 열기구(보스)
	- 2: 전투기 + 폭격기(중간보스 1500점) + 폭격기(보스)
	- 3: 헬기(유도미사일 자코) + 치누크(뭘 쏘는지 모르겠는 보스)
	- 4: 나랑 같은 전투기(유도미사일 자코) + 신형 폭격기(뭘 쏘는지 모르겠는 보스)
	- 5(우주): UFO(2종류 총알) + 대형 UFO(보스)
- 적 움직임, 총 쏘는 간격 등이 허술한 상태
- 스코어 시스템 교체(아스테로이드에 쓴 변수 2개 쓰는 방식)
- 자코들 출격할 때 편대비행?
- X 버튼 기능 추가(뭐인지 원작 살펴봐야 함) -> 원작에 암것도 없는데?????
- 녹화&재생 기능
]]
