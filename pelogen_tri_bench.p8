pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--triangle fill thunderdome rnd 2
--by musurca and p01

count_triangles = 256
--count_triangles = 10
count_repeat = 60
method_index = 1

ntable={}
flattable={}
--extentx=0
--extenty=127
extentx=-50
extenty=127+50

--high fps
--_set_fps(60)

-- added srand in hopes of making it more consistent
srand(4)
--srand(16)

function rndextents() return flr(extentx+rnd(extenty-extentx)) end

function flat2n(t)
  return {{t[1], t[2]},{t[3], t[4]}, {t[5], t[6]}, t[7]}
end

for i=1,count_triangles do
local t={
  rndextents(), rndextents(),
  rndextents(), rndextents(),
  rndextents(), rndextents(),
  flr(rnd(2))
}
ntable[i] = flat2n(t)
flattable[i] = t
end



--@catatafish
-- expects an array in the form { x0, y0, x1, y1, x2, y2, color }
function gfx_draw(vbuf)
 local v0x, v0y, v1x, v1y, v2x, v2y = vbuf[1], vbuf[2], vbuf[3], vbuf[4], vbuf[5], vbuf[6]
 if v1y<v0y then
  v0x,v1x = v1x,v0x
  v0y,v1y = v1y,v0y
 end
 if v2y<v0y then
  v0x,v2x = v2x,v0x
  v0y,v2y = v2y,v0y
 end
 if v2y<v1y then
  v1x,v2x = v2x,v1x
  v1y,v2y = v2y,v1y
 end
 color(vbuf[7])
 if v0y == v1y then -- flat top
  rasterizetri_top(v0x,v0y,v1x,v2x,v2y)
 elseif v1y == v2y then -- flat bottom
  rasterizetri_bottom(v0x,v0y,v1x,v2x,v2y)
 else -- general case
  local newx = v0x + ((v1y-v0y)*(v2x-v0x)/(v2y-v0y))
  rasterizetri_bottom(v0x,v0y,newx,v1x,v1y)
  rasterizetri_top(v1x,v1y,newx,v2x,v2y)
 end -- triangle cases
 --end -- triangle loop
end

function rasterizetri_top(v0x,v0y, v1x, v2x,v2y)
if (v1x<v0x) v0x, v1x = v1x, v0x
local height=v2y-v0y
local dx_left, dx_right = (v2x-v0x)/height, (v2x-v1x)/height
if v0y<0 then
v0x-=dx_left*v0y
v1x-=dx_right*v0y
v0y=0
end
if (v2y>128) v2y=128
if(v0y<v2y) then
for y=v0y,v2y do
rectfill(v0x,y,v1x,y)
v0x+=dx_left
v1x+=dx_right
end
end
end

function rasterizetri_bottom(v0x,v0y, v1x,v2x,v2y)
 if (v2x<v1x) v1x, v2x = v2x, v1x
 local height=v2y-v0y
 local dx_left, dx_right, xend = (v1x-v0x)/height, (v2x-v0x)/height, v0x
 if v0y<0 then
  v0x -=dx_left*v0y
  xend-=dx_right*v0y
  v0y=0
 end
 if (v2y>128) v2y=128
 if(v0y<v2y) then
  for y=v0y,v2y do
   rectfill(v0x,y,xend,y)
   v0x+=dx_left
   xend+=dx_right
  end
 end
end


--@p01
function p01_triangle_163(x0,y0,x1,y1,x2,y2,col)
 color(col)
 if(y1<y0)x0,x1,y0,y1=x1,x0,y1,y0
 if(y2<y0)x0,x2,y0,y2=x2,x0,y2,y0
 if(y2<y1)x1,x2,y1,y2=x2,x1,y2,y1
 col=x0+(x2-x0)/(y2-y0)*(y1-y0)
 p01_trapeze_h(x0,x0,x1,col,y0,y1)
 p01_trapeze_h(x1,col,x2,x2,y1,y2)
end
function p01_trapeze_h(l,r,lt,rt,y0,y1)
 lt,rt=(lt-l)/(y1-y0),(rt-r)/(y1-y0)
 if(y0<0)l,r,y0=l-y0*lt,r-y0*rt,0
 y1=min(y1,128)
 for y0=y0,y1 do
  rectfill(l,y0,r,y0)
  l+=lt
  r+=rt
 end
end
function p01_trapeze_w(t,b,tt,bt,x0,x1)
 tt,bt=(tt-t)/(x1-x0),(bt-b)/(x1-x0)
 if(x0<0)t,b,x0=t-x0*tt,b-x0*bt,0
 x1=min(x1,128)
 for x0=x0,x1 do
  rectfill(x0,t,x0,b)
  t+=tt
  b+=bt
 end
end
function p01_triangle_335(x0,y0,x1,y1,x2,y2,col)
 color(col)
 if(y1<y0)x0,x1,y0,y1=x1,x0,y1,y0
 if(y2<y0)x0,x2,y0,y2=x2,x0,y2,y0
 if(y2<y1)x1,x2,y1,y2=x2,x1,y2,y1
 if max(x2,max(x1,x0))-min(x2,min(x1,x0)) > y2-y0 then
  col=x0+(x2-x0)/(y2-y0)*(y1-y0)
  p01_trapeze_h(x0,x0,x1,col,y0,y1)
  p01_trapeze_h(x1,col,x2,x2,y1,y2)
 else
  if(x1<x0)x0,x1,y0,y1=x1,x0,y1,y0
  if(x2<x0)x0,x2,y0,y2=x2,x0,y2,y0
  if(x2<x1)x1,x2,y1,y2=x2,x1,y2,y1
  col=y0+(y2-y0)/(x2-x0)*(x1-x0)
  p01_trapeze_w(y0,y0,y1,col,x0,x1)
  p01_trapeze_w(y1,col,y2,y2,x1,x2)
 end
end



--@nusan
function clip(v)
 return max(-1,min(128,v))
end

function steptri(x1,y1,x2,y2,x3,y3,c)
 if(y2<y1) then
  if(y3<y2) then
   y1,y3=y3,y1
   x1,x3=x3,x1
  else
   y1,y2=y2,y1
   x1,x2=x2,x1
  end
 else if(y3<y1) then
  y1,y3=y3,y1
  x1,x3=x3,x1
 end
 end
 y1 += 0.001 -- offset to avoid divide per 0
 local miny = min(y2,y3)
 local maxy = max(y2,y3)
 local fx = x2
 if(y2<y3) then
  fx = x3
 end
 local d12 = (y2-y1)
 if(d12 != 0) then
  d12 = 1.0/d12
 end
 local d13 = (y3-y1)
 if(d13 != 0) then
  d13 = 1.0/d13
 end
 local cl_y1 = clip(y1)
 local cl_miny = clip(miny)
 local cl_maxy = clip(maxy)
 local steps = (x3-x1) * d13
 local stepe = (x2-x1) * d12
 local sx = steps*(cl_y1-y1)+x1
 local ex = stepe*(cl_y1-y1)+x1
 for y=cl_y1,cl_miny do
  rectfill(sx,y,ex,y,c)
  sx += steps
  ex += stepe
 end
 sx = steps*(miny-y1)+x1
 ex = stepe*(miny-y1)+x1
 local df = (maxy-miny)
 if(df != 0) df = 1.0/df
 local step2s = (fx-sx) * df
 local step2e = (fx-ex) * df
 local sx2 = sx + step2s*(cl_miny-miny)
 local ex2 = ex + step2e*(cl_miny-miny)
 for y=cl_miny,cl_maxy do
  rectfill(sx2,y,ex2,y,c)
  sx2 += step2s
  ex2 += step2e
 end
end

--@creamdog
function sort2dvectors(list)
 for i=1,#list do
 for j=1,#list do
  if i != j then
   local x1 = list[i][1]
   local y1 = list[i][2]
   local x2 = list[j][1]
   local y2 = list[j][2]
   if y2 > y1 then
    local tmp = list[i]
    list[i] = list[j]
    list[j] = tmp
   elseif y2 == y1 then
    if x2 > x1 then
    local tmp = list[i]
    list[i] = list[j]
    list[j] = tmp
    end
   end
  end
 end
 end
 return list
end

function creamdog_tri(x1,y1,x2,y2,x3,y3,col)
 local list = {{flr(x1),flr(y1)},{flr(x2),flr(y2)},{flr(x3),flr(y3)}}
 list = sort2dvectors(list)

 local xs = list[1][1]
 local xe = list[1][1]

 local vx1 = (list[2][1]-list[1][1])/(list[2][2]-list[1][2])
 local vx2 = (list[3][1]-list[2][1])/(list[3][2]-list[2][2])
 local vx3 = (list[3][1]-list[1][1])/(list[3][2]-list[1][2])

 if flr((list[2][2]-list[1][2])) == 0 then
  vx2 = vx3
  xe = list[2][1]
  vx3 = (list[3][1]-list[2][1])/(list[3][2]-list[2][2])
 end
 for y=list[1][2],list[3][2],1 do
  if (y >= 0 and y <=127) then
   local x1 = xs
   local x2 = xe
   if (x1 < 0) x1 = 0
   if (x1 > 128) x1 = 128
   if (x2 < 0) x2 = 0
   if (x2 > 128) x2 = 128
   local l = sqrt((x1-x2)*(x1-x2))
   local mx = flr(min(x1,x2))
   local addr = 0x6000+y*64+flr(mx/2)
   memset(addr, col+col*16, -flr(-(l/2)))
  end
  if y < list[2][2] then
   xs += vx1
  elseif y >= list[2][2] then
   xs += vx2
  end
  xe += vx3
 end
 return list
end

--by @electricgryphon
function solid_trifill_v3( x1,y1,x2,y2,x3,y3, color1)
local min_x=min(x1,min(x2,x3))
if(min_x>127)return
local max_x=max(x1,max(x2,x3))
if(max_x<0)return
local min_y=min(y1,min(y2,y3))
if(min_y>127)return
local max_y=max(y1,max(y2,y3))
if(max_y<0)return
local x1=band(x1,0xffff)
local x2=band(x2,0xffff)
local y1=band(y1,0xffff)
local y2=band(y2,0xffff)
local x3=band(x3,0xffff)
local y3=band(y3,0xffff)
local width=min(127,max_x)-max(0,min_x)
local height=min(127,max_y)-max(0,min_y)
if(width>height)then --wide triangle
local nsx,nex
--sort y1,y2,y3
if(y1>y2)then
y1,y2=y2,y1
x1,x2=x2,x1
end
if(y1>y3)then
y1,y3=y3,y1
x1,x3=x3,x1
end
if(y2>y3)then
y2,y3=y3,y2
x2,x3=x3,x2
end
if(y1!=y2)then
local delta_sx=(x3-x1)/(y3-y1)
local delta_ex=(x2-x1)/(y2-y1)
if(y1>0)then
nsx=x1
nex=x1
min_y=y1
else --top edge clip
nsx=x1-delta_sx*y1
nex=x1-delta_ex*y1
min_y=0
end
max_y=min(y2,128)
for y=min_y,max_y-1 do
rectfill(nsx,y,nex,y,color1)
nsx+=delta_sx
nex+=delta_ex
end
else --where top edge is horizontal
nsx=x1
nex=x2
end
if(y3!=y2)then
local delta_sx=(x3-x1)/(y3-y1)
local delta_ex=(x3-x2)/(y3-y2)
min_y=y2
max_y=min(y3,128)
if(y2<0)then
nex=x2-delta_ex*y2
nsx=x1-delta_sx*y1
min_y=0
end
for y=min_y,max_y do
rectfill(nsx,y,nex,y,color1)
nex+=delta_ex
nsx+=delta_sx
end
else --where bottom edge is horizontal
rectfill(nsx,y3,nex,y3,color1)
end
else --tall triangle -----------------------------------<><>----------------
local nsy,ney
--sort x1,x2,x3
if(x1>x2)then
x1,x2=x2,x1
y1,y2=y2,y1
end
if(x1>x3)then
x1,x3=x3,x1
y1,y3=y3,y1
end
if(x2>x3)then
x2,x3=x3,x2
y2,y3=y3,y2
end
if(x1!=x2)then
local delta_sy=(y3-y1)/(x3-x1)
local delta_ey=(y2-y1)/(x2-x1)
if(x1>0)then
nsy=y1
ney=y1
min_x=x1
else --top edge clip
nsy=y1-delta_sy*x1
ney=y1-delta_ey*x1
min_x=0
end
max_x=min(x2,128)
for x=min_x,max_x-1 do
rectfill(x,nsy,x,ney,color1)
nsy+=delta_sy
ney+=delta_ey
end
else --where top edge is horizontal
nsy=y1
ney=y2
end
if(x3!=x2)then
local delta_sy=(y3-y1)/(x3-x1)
local delta_ey=(y3-y2)/(x3-x2)
min_x=x2
max_x=min(x3,128)
if(x2<0)then
ney=y2-delta_ey*x2
nsy=y1-delta_sy*x1
min_x=0
end
for x=min_x,max_x do
rectfill(x,nsy,x,ney,color1)
ney+=delta_ey
nsy+=delta_sy
end
else --where bottom edge is horizontal
rectfill(x3,nsy,x3,ney,color1)
end
end
end

-- eg latest trifill
function shade_trifill(x1,y1,x2,y2,x3,y3, col)
  color(col)
  local x1=band(x1,0xffff)
  local x2=band(x2,0xffff)
  local y1=band(y1,0xffff)
  local y2=band(y2,0xffff)
  local x3=band(x3,0xffff)
  local y3=band(y3,0xffff)

  local nsx,nex
  --sort y1,y2,y3
  if(y1>y2)then
  y1,y2=y2,y1
  x1,x2=x2,x1
  end

  if(y1>y3)then
  y1,y3=y3,y1
  x1,x3=x3,x1
  end

  if(y2>y3)then
  y2,y3=y3,y2
  x2,x3=x3,x2
  end

  if(y1!=y2)then
  local delta_sx=(x3-x1)/(y3-y1)
  local delta_ex=(x2-x1)/(y2-y1)

  if(y1>0)then
  nsx=x1
  nex=x1
  min_y=y1
  else --top edge clip
  nsx=x1-delta_sx*y1
  nex=x1-delta_ex*y1
  min_y=0
  end

  max_y=min(y2,128)

  for y=min_y,max_y-1 do

  rectfill(nsx,y,nex,y)
  nsx+=delta_sx
  nex+=delta_ex
  end
  else --where top edge is horizontal
  nsx=x1
  nex=x2
  end
  if(y3!=y2)then
  local delta_sx=(x3-x1)/(y3-y1)
  local delta_ex=(x3-x2)/(y3-y2)
  min_y=y2
  max_y=min(y3,128)
  if(y2<0)then
  nex=x2-delta_ex*y2
  nsx=x1-delta_sx*y1
  min_y=0
  end
  for y=min_y,max_y do
  rectfill(nsx,y,nex,y)
  nex+=delta_ex
  nsx+=delta_sx
  end
  else --where bottom edge is horizontal
  rectfill(nsx,y3,nex,y3)
  end
end


--by @musurca
function musurca_triangle(p0,p1,p2,c)
  color(c)
 --determine orientation of pts
 local p_left,p_mid,p_right

 if p0[1]<p1[1] and p0[1]<p2[1] then
  p_left=p0
  if p1[1]<p2[1] then
   p_mid,p_right=p1,p2
  else
   p_mid,p_right=p2,p1
  end
 elseif p1[1]<p0[1] and p1[1]<p2[1] then
  p_left=p1
  if p0[1]<p2[1] then
   p_mid,p_right=p0,p2
  else
   p_mid,p_right=p2,p0
  end
 elseif p2[1]<p0[1] and p2[1]<p1[1] then
  p_left=p2
  if p0[1]<p1[1] then
   p_mid,p_right=p0,p1
  else
   p_mid,p_right=p1,p0
  end
 else -- one pt.x==another pt.x
  if p0[1]<p1[1] or p0[1]<p2[1] then
   p_left=p0
   if p1[1]<p2[1] then
    p_mid,p_right=p1,p2
   else
    p_mid,p_right=p2,p1
   end
  elseif p1[1]<p0[1] or p1[1]<p2[1] then
   p_left=p1
   if p0[1]<p2[1] then
    p_mid,p_right=p0,p2
   else
    p_mid,p_right=p2,p0
   end
  else
   p_left=p2
   if p0[1]<p2[1] then
    p_mid,p_right=p0,p2
   else
    p_mid,p_right=p2,p0
   end
  end
 end

 --p_left[1]+=0.5
 --p_left[2]+=0.5
 --p_mid[1]+=0.5
 --p_mid[2]+=0.5
 --p_right[1]+=0.5
 --p_right[2]+=0.5

 --calculate right triangles
 local base_dist=p_right[1]-p_left[1]
 local seg1_dist=p_mid[1]-p_left[1]
 local seg2_dist=base_dist-seg1_dist

 local base_yinc,seg1_yinc,seg2_yinc

 if base_dist==0 then
  base_yinc=0
 else
  base_yinc=(p_right[2]-p_left[2])/base_dist
 end
 if seg1_dist<=0 then
  seg1_yinc=0
 else
  seg1_yinc=(p_mid[2]-p_left[2])/seg1_dist
 end
 if seg2_dist<=0 then
  seg2_yinc=0
 else
  seg2_yinc=(p_right[2]-p_mid[2])/seg2_dist
 end

 --start rasterizing
 local x=p_left[1]
 local y0=p_left[2]
 local y1=y0
 local off

 --make sure we don't waste time
 --rastering outside the canvas
 if x<0 then
  seg1_dist=seg1_dist+x
  if seg1_dist>0 then
   off=-x
  else
   off=seg1_dist-x
  end
  y0+=(off*seg1_yinc)
  y1+=(off*base_yinc)
  x+=off
 end

 if x+seg1_dist>=128 then
  seg1_dist=128-x
  seg2_dist=0
 end

 --raster first triangle
 for i=1,seg1_dist do
  rectfill(x,y0,x,y1)
  y0+=seg1_yinc
  y1+=base_yinc
  x+=1
 end

 y0=p_mid[2]

 if x<0 then
  seg2_dist=seg2_dist+x
  if seg2_dist>0 then
   off=-x
  else
   off=seg2_dist-x
  end
  y0+=off*seg2_yinc
  y1+=off*base_yinc
  x+=off
 end

 if x+seg2_dist>=128 then
  seg2_dist=128-x
 end

 --raster second triangle
 for i=1,seg2_dist do
  rectfill(x,y0,x,y1)
  y0=y0+seg2_yinc
  y1=y1+base_yinc
  x=x+1
 end

 --ensure thin triangles
 --don't disappear
 --line(p_left[1],p_left[2],p_mid[1],p_mid[2])
 --line(p_mid[1],p_mid[2],p_right[1],p_right[2])
end

tests={}

-->8
--proc branch goto local func
--add(tests, {len=229, author="shiftalow(hv)", fn=function(i) local v=flattable[i] pelogen_tri_hv(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end},1)
--add(tests, {len=261, author="shiftalow(hvdfif)", fn=function(i) local v=flattable[i] pelogen_tri_hvdfif(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end},1)
add(tests, {len=272, author="shiftalow(hvb)", fn=function(i) local v=flattable[i] pelogen_tri_hvb(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end},1)

--lowest token
add(tests, {len=113, author="shiftalow(low)", fn=function(i) local v=flattable[i] pelogen_tri_low(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end},1)
--
----top clipping
add(tests, {len=140, author="shiftalow(tclip)", fn=function(i) local v=flattable[i] pelogen_tri_tclip(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end},1)
--add(tests, {len=148, author="shiftalow(tclipdfif)", fn=function(i) local v=flattable[i] pelogen_tri_tclipdfif(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end},1)
--
----old
--add(tests, {len=308, author="shiftalow(308)", fn=function(i) local v=ntable[i] pelogen_tri_308(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end},1)
--add(tests, {len=176, author="shiftalow(176)", fn=function(i) local v=ntable[i] pelogen_tri_176(v[1],v[2],v[3],v[4]) end},1)
--add(tests, {len=129, author="shiftalow(129)", fn=function(i) local v=flattable[i] pelogen_tri_129(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end},1)
--common release
--add(tests, {len=128, author="shiftalow", fn=function(i) local v=flattable[i] pelogen_tri_o(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end},1)


yscale=1
xscale=1

--by @shiftalow
-- 272 proc branch goto beginning
function pelogen_tri_hvb(l,t,c,m,r,b,col)
	color(col)
	local a=rectfill
	::_w_::
 if(t>m)l,t,c,m=c,m,l,t
 if(m>b)c,m,r,b=r,b,c,m
 if(t>m)l,t,c,m=c,m,l,t

	local q,p=l,c
	if (q<c) q=c
	if (q<r) q=r
	if (p>l) p=l
	if (p>r) p=r
	if b-t>q-p then
		l,t,c,m,r,b,col=t,l,m,c,b,r
		goto _w_
	end

	local e,j,i=l,(r-l)/(b-t)
	while m do
		i=(c-l)/(m-t)
		local f=m\1-1
		f=f>127 and 127 or f
		if(t<0)t,l,e=0,l-i*t,b and e-j*t or e
		if col then
			for t=t\1,f do
				a(l,t,e,t)
				l=i+l
				e=j+e
			end
		else
			for t=t\1,f do
				a(t,l,t,e)
				l=i+l
				e=j+e
			end
		end
		l,t,m,c,b=c,m,b,r
	end
	if i<8 and i>-8 then
		if col then
			pset(r,t)
		else
			pset(t,r)
		end
	end
end

-- 261 proc branch goto
function pelogen_tri_hvdfif(l,t,c,m,r,b,col)
	color(col)
	local a=rectfill
	::_w_::
	while t>m or m>b do
		l,t,c,m=c,m,l,t
		while m>b do
			c,m,r,b=r,b,c,m
		end
		local q,p=l,c
		if (q<c) q=c
		if (q<r) q=r
		if (p>l) p=l
		if (p>r) p=r
		if b-t>q-p then
			l,t,c,m,r,b,col=t,l,m,c,b,r
			goto _w_
		end
	end

	local e,j,i=l,(r-l)/(b-t)
	while m do
		i=(c-l)/(m-t)
		local f=m\1-1
		if f>127 then
			f=127
		end
		if(t<0)t,l,e=0,l-i*t,b and e-j*t or e
		if col then
			for t=t\1,f do
				a(l,t,e,t)
				l=i+l
				e=j+e
			end
		else
			for t=t\1,f do
				a(t,l,t,e)
				l=i+l
				e=j+e
			end
		end
		l,t,m,c,b=c,m,b,r
	end
	if i<8 and i>-8 then
		if col then
			pset(r,t)
		else
			pset(t,r)
		end
	end
end

-- 229 proc branch goto
function pelogen_tri_hv(l,t,c,m,r,b,col)
	color(col)
	local a=rectfill
	::_w_::
	while t>m or m>b do
		l,t,c,m=c,m,l,t
		while m>b do
			c,m,r,b=r,b,c,m
		end
		if b-t>max(max(l,c),r)-min(min(l,c),r) then
			l,t,c,m,r,b,col=t,l,m,c,b,r
			goto _w_
		end
	end
	local e,j,i=l,(r-l)/(b-t)
	while m do
		i=(c-l)/(m-t)
		local f=min(flr(m)-1,127)
		if(t<0)t,l,e=0,l-i*t,b and e-j*t or e
		if col then
			for t=flr(t),f do
				a(l,t,e,t)
				l=i+l
				e=j+e
			end
		else
			for t=flr(t),f do
				a(t,l,t,e)
				l=i+l
				e=j+e
			end
		end
		l,t,m,c,b=c,m,b,r
	end
	if abs(i)<8 then
		if col then
			pset(r,t)
		else
			pset(t,r)
		end
	end
end

--148(top clipping)
function pelogen_tri_tclipdfif(l,t,c,m,r,b,col)
	color(col)
	local a=rectfill
	while t>m or m>b do
		l,t,c,m=c,m,l,t
		while m>b do
			c,m,r,b=r,b,c,m
		end
	end
	local e,j=l,(r-l)/(b-t)
	while m do
		local i=(c-l)/(m-t)
		if(t<0)t,l,e=0,l-i*t,b and e-j*t or e
		local p=m\1-1
		if (p>127) p=127
		for t=t\1,p do
			a(l,t,e,t)
			l+=i
			e+=j
		end
		l,t,m,c,b=c,m,b,r
	end
	pset(r,t)
end

--140(top clipping)
function pelogen_tri_tclip(l,t,c,m,r,b,col)
	color(col)
	local a=rectfill
	while t>m or m>b do
		l,t,c,m=c,m,l,t
		while m>b do
			c,m,r,b=r,b,c,m
		end
	end
	local e,j=l,(r-l)/(b-t)
	while m do
		local i=(c-l)/(m-t)
		if(t<0)t,l,e=0,l-i*t,b and e-j*t or e
		for t=flr(t),min(flr(m)-1,127) do
			a(l,t,e,t)
			l+=i
			e+=j
		end
		l,t,m,c,b=c,m,b,r
	end
	pset(r,t)
end

--113
function pelogen_tri_low(l,t,c,m,r,b,col)
	color(col)
	while t>m or m>b do
		l,t,c,m=c,m,l,t
		while m>b do
			c,m,r,b=r,b,c,m
		end
	end
	local e,j=l,(r-l)/(b-t)
	while m do
		local i=(c-l)/(m-t)
		for t=flr(t),min(flr(m)-1,127) do
			rectfill(l,t,e,t)
			l+=i
			e+=j
		end
		l,t,m,c,b=c,m,b,r
	end
	pset(r,t)
end

--127 select args
function pelogen_tri_ws(l,t,c,m,r,b,col)
color(col)
local q=1
while t>m or t>b or m>b do
l,t,c,m,r,b=select(q
,c,m,l,t,r,b
,c,m,l,t,r,b
,c,m
)
q+=2
end
local i,j,k,r=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m),l
while m do
for t=ceil(t),min(flr(m),127) do
rectfill(l,t,r,t)
l+=i
r+=j
end
l,t,m,i,b=c,m,b,k
end
end



-->8
--308 [old] token(top clipping & v-h processing branch)
function pelogen_tri_308(v1,v2,v3,col)
color(col)
local l,c,r,t,m,b=pelogen_sort(v1,v2,v3,2)
if abs(r-l)>abs(b-t) then
v1,v2,v3=l,t,0
local j=(r-l)/(b-t)
while t~=b do
local i=(c-l)/(m-t)
if(t<0) t,l,v1,v3=0,l-i*t,v1-j*(t-v3),m
for t=t,min(m-1,127) do
rectfill(l,t,v1,t)
l+=i
v1+=j
end
c,l,t,m=r,c,m,b
end
else
l,c,r,t,m,b=pelogen_sort(v1,v2,v3,1)
v1,v2,v3=l,t,0
local j=(b-t)/(r-l)
while l~=r do
local i=(m-t)/(c-l)
if(l<0) l,t,v2,v3=0,t-i*l,v2-j*(l-v3),c
for l=l,min(c-1,127) do
rectfill(l,t,l,v2)
t+=i
v2+=j
end
m,t,l,c=b,m,c,r
end
end
end
function pelogen_sort(v1,v2,v3,v)
if(v1[v]>v2[v]) v1,v2=v2,v1
if(v1[v]>v3[v]) v1,v3=v3,v1
if(v2[v]>v3[v]) v3,v2=v2,v3
return flr(v1[1]),flr(v2[1]),v3[1],flr(v1[2]),flr(v2[2]),v3[2]
end


--176 [old] top clipping
function pelogen_tri_176(v1,v2,v3,col)
color(col)
if(v1[2]>v2[2]) v1,v2=v2,v1
if(v1[2]>v3[2]) v1,v3=v3,v1
if(v2[2]>v3[2]) v3,v2=v2,v3
local l,c,r,t,m,b=v1[1],v2[1],v3[1],flr(v1[2]),flr(v2[2]),v3[2]
local i,j,k,r=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m),l
while t~=b do
if(t<0)t,l,r=0,l-i*t,v1 and r-j*t or r
for t=t,min(m-1,127) do
rectfill(l,t,r,t)
r+=j
l+=i
end
l,t,m,i,v1=c,m,b,k
end
end

--129 [old] lowest token
function pelogen_tri_129(l,t,c,m,r,b,col)
color(col)
if(t>m) l,t,c,m=c,m,l,t
if(t>b) l,t,r,b=r,b,l,t
if(m>b) c,m,r,b=r,b,c,m
local i,j,k,r=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m),l
while t~=b do
for t=flr(t),min(flr(m)-1,127) do
rectfill(l,t,r,t)
l+=i
r+=j
end
l,t,m,i=c,m,b,k
end
end


--128 common release
function pelogen_tri_o(l,t,c,m,r,b,col)
color(col)
if(t>m) l,t,c,m=c,m,l,t
if(t>b) l,t,r,b=r,b,l,t
if(m>b) c,m,r,b=r,b,c,m
local i,j,k,r=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m),l
while m do
for t=flr(t),min(flr(m)-1,127) do
rectfill(l,t,r,t)
l+=i
r+=j
end
l,t,m,i,b=c,m,b,k
end
end
-->8
-- azure48 triangle fill, slightly faster
function azulocallow(x1,y1,x2,y2,x3,y3,c)
 	local r = rectfill
  for i = 0, 1 do
      if(y1>y2)x1,y1,x2,y2 = x2,y2,x1,y1
      if(y2>y3)x2,y2,x3,y3 = x3,y3,x2,y2
  end
  local b,da,db = x1,(x2-x1)/(y2-y1),(x3-x1)/(y3-y1)
  color(c)
  for o = 0,1 do
      for i = y1, y2 do
          r(x1, i, b, i)
          x1 = da+x1
          b = db+b
      end
      x1 = x2
      da=(x2-x3)/(y2-y3)
      y1=y2 y2=y3
  end
 pset(x3,y3)
end

-- azure48 triangle fill, slightly faster
function azulocalfast(x1,y1,x2,y2,x3,y3,c)
 local r = rectfill
 --sort the triangle so y2 is the middle
    for i = 0, 1 do
        if(y1>y2)x1,y1,x2,y2 = x2,y2,x1,y1
        -- \/ this line is only needed once, it'll always fail on i==2
        if(y2>y3)x2,y2,x3,y3 = x3,y3,x2,y2
    end
    -- amounts to add by each iteration
    local da = (x2-x1)/(y2-y1)
    local db = (x3-x1)/(y3-y1)
    local b = x1
    color(c)
    -- main drawing part reduced to only addition and line drawing
    for i = y1, y2 do
        r(x1, i, b, i)
        x1 = da+x1
        b = db+b
    end
    -- calc angle to move towards 3
    da=(x2-x3)/(y2-y3)
    for i = y2, y3 do
        r(x2, i, b, i)
        x2 = da+x2
        b = db+b
    end
    -- the bottom often ends up 1 pixel short, this puts that in
    pset(x3,y3)
end


-- azure48 triangle fill, lowest tokens
function azulowtri(x1, y1, x2, y2, x3, y3, c)
    for i = 0, 1 do
        if(y1>y2)x1,y1,x2,y2 = x2,y2,x1,y1
        if(y2>y3)x2,y2,x3,y3 = x3,y3,x2,y2
    end
    local b,da,db = x1,(x2-x1)/(y2-y1),(x3-x1)/(y3-y1)
    color(c)
    for o = 0,1 do
        for i = y1, y2 do
            rectfill(x1, i, b, i)
            x1 = da+x1
            b = db+b
        end
        x1 = x2
        da=(x2-x3)/(y2-y3)
        y1=y2 y2=y3
    end
 pset(x3,y3)
end

-- azure48 triangle fill, slightly faster
function azufasttri(x1,y1,x2,y2,x3,y3,c)
 --sort the triangle so y2 is the middle
    for i = 0, 1 do
        if(y1>y2)x1,y1,x2,y2 = x2,y2,x1,y1
        -- \/ this line is only needed once, it'll always fail on i==2
        if(y2>y3)x2,y2,x3,y3 = x3,y3,x2,y2
    end
    -- amounts to add by each iteration
    local da = (x2-x1)/(y2-y1)
    local db = (x3-x1)/(y3-y1)
    local b = x1
    color(c)
    -- main drawing part reduced to only addition and line drawing
    for i = y1, y2 do
        rectfill(x1, i, b, i)
        x1 = da+x1
        b = db+b
    end
    x1 = x2
    -- calc angle to move towards 3
    da=(x2-x3)/(y2-y3)
    for i = y2, y3 do
        rectfill(x1, i, b, i)
        x1 = da+x1
        b = db+b
    end
    -- the bottom often ends up 1 pixel short, this puts that in
    pset(x3,y3)
end

-->8
add(tests, {len=599, author="electricgryphon(v3)", fn=function(i) local v=flattable[i] solid_trifill_v3(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end})
add(tests, {len=278, author="electricgryphon", fn=function(i) local v=flattable[i] shade_trifill(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end})
add(tests, {len=455, author="musurca", fn=function(i) local v=ntable[i] musurca_triangle(v[1],v[2],v[3],v[4]) end})
add(tests, {len=431, author="creamdog", fn=function(i) local v=flattable[i] creamdog_tri(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end})
add(tests, {len=335, author="p01(335)", fn=function(i) local v=flattable[i] p01_triangle_335(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end})
add(tests, {len=315, author="catafish", fn=function(i) gfx_draw(flattable[i]) end})
add(tests, {len=295, author="nusan", fn=function(i) local v=flattable[i] steptri(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end})
add(tests, {len=163, author="p01(163)", fn=function(i) local v=flattable[i] p01_triangle_163(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end})
add(tests, {len=134, author="azure48(local fast)", fn=function(i) local v=flattable[i] azulocalfast(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end})
add(tests, {len=125, author="azure48(local low)", fn=function(i) local v=flattable[i] azulocallow(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end})
add(tests, {len=134, author="azure48(fast)", fn=function(i) local v=flattable[i] azufasttri(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end})
add(tests, {len=122, author="azure48(low)", fn=function(i) local v=flattable[i] azulowtri(v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end})

average_tris_per_sec = 3500
cls()
color(7)
--print("\ntriangle fill thunderdome\nround 3!\n\n\npress \151 or \142 to begin")
print("\ntriangle fill thunderdome\nround 3-4!\n\n\npress \151 or \142 to begin")
color(13)
print("this should take ~"..ceil(#tests*count_repeat/average_tris_per_sec*count_triangles).." seconds")
while(band(btnp(),48)<1) do end

function profile_test(test)
  local func = test.fn
  local t=time()
  for q=1,count_repeat do
   for i=1,count_triangles do func(i) end
  end
  test.tris_per_sec = t

  t = flr(count_triangles * count_repeat / (time()-t) + .5)
  test.speed = t
  t = tostr(t)
  while(#t<4) do t=' '..t end
  test.tris_per_sec = t
end

for i=1,#tests do profile_test(tests[i]) end

function sort(what,by,tiebreaker)
  for i=1,#what do
    local h = i;
    for j=i+1,#what do
      if (what[j][by] > what[h][by]) h = j
      if (tiebreaker!=nil and what[j][by] == what[h][by] and what[j][tiebreaker] < what[h][tiebreaker]) h = j
    end
    if h > i then
      local t = what[i]
      what[i] = what[h]
      what[h] = t
    end
  end
end

-- sort the tests by speed
sort(tests,"speed","len")


function print_result(i)
  if (i==1) zebra = 0
  if (not draw_results and i!=method_index) then
    print("")
  else
    local test = tests[i]
    if (i>1 and test.tris_per_sec != tests[i-1].tris_per_sec) zebra += 1
    color(i==method_index and 7+rnd(8) or 15-zebra)
    print("  "..test.tris_per_sec.."  "..test.len.."  "..test.author);
  end
end

angle = rnd()
angle_inc = 1/256
draw_results = true
draw_wireframe = false
::loop_showing_results::
  cls(2)
  local _b=not(btn(4) or btn(5))
  if (btnp(5)) draw_results = not draw_results
  if (btnp(4)) draw_wireframe = not draw_wireframe
  if (_b and btnp(2) and method_index > 1) method_index-=1
  if (_b and btnp(3) and method_index < #tests) method_index+=1
  if (_b and btn(1)) angle += angle_inc
  if (_b and btn(0)) angle -= angle_inc
  if (btn(0)and btn(4)) xscale -= angle_inc
  if (btn(1)and btn(4)) xscale += angle_inc
  if (btn(2)and btn(4)) yscale -= angle_inc
  if (btn(3)and btn(4)) yscale += angle_inc

  -- draw triangle
  local r = 80+32*cos(angle*1.7)
  local f = {
  64+r*cos(angle)*cos(xscale)
  ,64+r*sin(angle)*cos(yscale)
  ,64+r*cos(angle+.33)*cos(xscale)
  ,64+r*sin(angle+.33)*cos(yscale)
  ,64+r*cos(angle+.67)*cos(xscale)
  ,64+r*sin(angle+.67)*cos(yscale)
  ,1}
  flattable[1] = f
  ntable[1] = flat2n(f)
  if (draw_wireframe) then
    color(14)
    line(f[1],f[2],f[3],f[4])
    line(f[5],f[6],f[3],f[4])
    line(f[1],f[2],f[5],f[6])
  end
  fillp(0b0101111110101111)
  tests[method_index].fn(1)
  fillp(0)

  color(7)
--  ?"   "..count_repeat.."X"..count_triangles.." triangles benchmark\n\n        TOKENS\n  TRIS/SEC   AUTHOR cpu:"..stat()
  ?"        TOKENS\n  TRIS/SEC   AUTHOR cpu:"..stat()
  for i=1,#tests do print_result(i) end
  color(7)
  ?"   \142 WIREFRAME \151 RESULTS\n   \139 \145 TURN THE TRIANGLE\n   \148 \131 SWITCH RASTERIZER",0,110
  flip()
goto loop_showing_results
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222777227727272777277222772222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222272272727722772272727222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222272272727272722272722272222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222272277227272277272727722222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222722222222222222222222222222222222222222222222222222222277277727272222277722222777277227772777222222222
22222222777277227772277227222772777227722222222222222772727277727272277277222222722272727272272272722222727227222272727222222222
22222222272272722722722227227222772272222222222222227272727227227272727272722222722277727272222272722222727227222772777222222222
22222222272277222722227227222272722272222222222222227772727227227772727277222222722272227272272272722222727227222272727222222222
22222222272272727772772272227722277227722222222222227272277227227272772272722222277272222772222277722722777277727772777222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222ccc2ccc2ccc2ccc222222222ccc2ccc2ccc2222222222cc2c2c2ccc2ccc2ccc2ccc2c2222cc2c2c22c22c2c2c2c2ccc22c2222222222222222222222
2222222222c222c2c2c2c2c22222222222c222c222c222222222c222c2c22c22c2222c22c2c2c222c2c2c2c2c222c2c2c2c2c2c222c222222222222222222222
2222222222c2ccc2c2c2c2c222222222ccc222c2ccc222222222ccc2ccc22c22cc222c22ccc2c222c2c2c2c2c222ccc2c2c2cc2222c222222222222222222222
2222222222c2c222c2c2c2c222222222c22222c2c2222222222222c2c2c22c22c2220c22c2c2c222c2c2ccc2c222c2c2ccc2c2c222c222222222222222222222
2222222222c2ccc2ccc2ccc222222222ccc222c2ccc222222222cc22c2c2ccc2c2221c22c2c2ccc2cc22ccc22c22c2c22c22ccc22c2222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222220002222222222222222222222222222222222222222222222222222222222
22222222e222ee22e2e2e2e222222222eee2eee2eee222222222eee2eee2ee222e01eee2eee2eee22e2222222222222222222222222222222222222222222222
22222222e2222e22e2e2e2e22222222222e222e2e22222222222e2e2e2e22e22e20000e222e2e22222e222222222222222222222222222222222222222222222
22222222eee22e22eee2eee2222222222ee22ee2eee222222222eee2e2e22e22e0101ee02ee2eee222e222222222222222222222222222222222222222222222
22222222e2e22e2222e222e22222222222e222e222e222222222e222e2e22e22e00000e022e222e222e222222222222222222222222222222222222222222222
22222222eee2eee222e222e222222222eee2eee2eee222222222e222eee2eee20e01eee1eee2eee22e2222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222200000000002222222222222222222222222222222222222222222222222222222
22222222ddd2ddd2ddd2ddd222222222ddd2ddd2ddd222222222ddd2d222ddd01dd0ddd0ddd2ddd22dd22dd2ddd2d2d2ddd2d2d22dd2dd222d22d2d2ddd22d22
22222222d222d2d222d222d222222222d222d2d2d2d222222222d222d222d000d0000d00d0d22d22d222d222d2d2d2d2d2d2d2d2d2d2d2d2d222d2d222d222d2
22222222ddd2ddd22dd22dd222222222ddd2ddd2ddd222222222dd22d222dd01d1010d01dd222d22d222d222dd22ddd2ddd2ddd2d2d2d2d2d222d2d22dd222d2
2222222222d2d2d222d222d22222222222d222d222d222222222d222d222d000d0000d00d0d22d22d222d2d2d2d222d2d222d2d2d2d2d2d2d222ddd222d222d2
22222222ddd2ddd2ddd2ddd222222222ddd222d222d222222222ddd2ddd0ddd01dd01d10d0d2ddd22dd2ddd2d2d2ddd2d222d2d2dd22d2d22d222d22ddd22d22
22222222222222222222222222222222222222222222222222222222222000000000000000002222222222222222222222222222222222222222222222222222
22222222ccc2c2c2ccc2c22222222222cc22c2c2ccc2222222222cc2c2c1ccc1ccc1ccc1ccc1c2222cc2c2c22c22ccc22cc2c222ccc2ccc22c22222222222222
22222222c222c2c2c2c2c222222222222c22c2c2c2c222222222c222c0c00c00c0000c00c0c0c222c2c2c2c2c2222c22c222c2222c22c2c222c2222222222222
22222222ccc2ccc2ccc2ccc2222222222c22ccc2c2c222222222ccc2ccc01c10cc101c10ccc0c222c2c2c2c2c2222c22c222c2222c22ccc222c2222222222222
2222222222c222c2c2c2c2c2222222222c2222c2c2c22222222222c2c0c00c00c0000c00c0c0c022c2c2ccc2c2222c22c222c2222c22c22222c2222222222222
22222222ccc222c2ccc2ccc222222222ccc222c2ccc222222222cc21c1c1ccc1c1010c01c1c1ccc2cc22ccc22c222c222cc2ccc2ccc2c2222c22222222222222
22222222222222222222222222222222222222222222222222222220000000000000000000000002222222222222222222222222222222222222222222222222
22222222bbb2bb22bbb2bbb222222222bb22bbb2b2b222222222bbb0bbb0b0b0bbb0bbb0b0b0bbb22b22b2222bb22bb2bbb2b2222222bbb2bbb22bb2bbb22b22
22222222b2222b2222b2b2b2222222222b2222b2b2b222222222b0b000b0b0b0b0b0b000b0b0b0b0b222b222b2b2b222b2b2b2222222b222b2b2b2222b2222b2
22222222bbb22b2222b2bbb2222222222b222bb2bbb222222222bbb10b01b1b1bb01bb01bbb1bbb1b222b222b2b2b222bbb2b2222222bb22bbb2bbb22b2222b2
2222222222b22b2222b2b2b2222222222b2222b222b222222222b0b0b000b0b0b0b0b00000b0b0b0b222b222b2b2b222b2b2b2222222b222b2b222b22b2222b2
22222222bbb2bbb222b2bbb222222222bbb2bbb222b222222220b0b0bbb01bb0b0b0bbb010b0bbb01b22bbb2bb222bb2b2b2bbb22222b222b2b2bb222b222b22
22222222222222222222222222222222222222222222222222000000000000000000000000000000022222222222222222222222222222222222222222222222
22222222bbb2bb22bbb2bbb222222222bbb2bbb2bbb222222201bbb1b101bbb10bb1bbb1bbb1bbb10bb22bb2bbb2b2b2bbb2b2b22bb2bb222222222222222222
22222222b2222b2222b2b2b22222222222b222b2b2b222222000b000b000b000b0000b00b0b00b00b022b222b2b2b2b2b2b2b2b2b2b2b2b22222222222222222
22222222bbb22b2222b2bbb222222222bbb222b2bbb222221010bb10b010bb10b0101b10bb101b10b012b222bb22bbb2bbb2bbb2b2b2b2b22222222222222222
2222222222b22b2222b2b2b222222222b22222b2b2b222220000b000b000b000b0000b00b0b00b00b002b2b2b2b222b2b222b2b2b2b2b2b22222222222222222
22222222bbb2bbb222b2bbb222222222bbb222b2bbb222210101bbb1bbb1bbb10bb10b01b1b1bbb10bb1bbb2b2b2bbb2b222b2b2bb22b2b22222222222222222
22222222222222222222222222222222222222222222220000000000000000000000000000000000000022222222222222222222222222222222222222222222
22222222bbb2bb22bbb2bbb222222222bbb2bb22bbb2221010101bb0bbb0bbb0bbb0bbb0bbb01bb0b0b012222222222222222222222222222222222222222222
22222222b2222b2222b2b2b22222222222b22b22b22220000000b000b0b00b00b0b0b0000b00b000b0b002222222222222222222222222222222222222222222
22222222bbb22b2222b2bbb2222222222bb22b22bbb201010101b101bbb10b01bbb1bb010b01bbb1bbb101222222222222222222222222222222222222222222
2222222222b22b2222b2b2b22222222222b22b2222b200000000b000b0b00b00b0b0b0000b0000b0b0b000222222222222222222222222222222222222222222
22222222bbb2bbb222b2bbb222222222bbb2bbb2bbb0101010101bb0b0b01b10b0b0b010bbb0bb10b0b010122222222222222222222222222222222222222222
22222222222222222222222222222222222222222200000000000000000000000000000000000000000000022222222222222222222222222222222222222222
22222222aaa2aa22aaa2aaa222222222aa22a222aaa101010101aaa1aaa1aa010a01aa01a101aaa10a0101022222222222222222222222222222222222222222
22222222a2222a2222a2a2a2222222222a22a22220a000000000a0a0a0a00a00a0000a00a00000a000a000002222222222222222222222222222222222222222
22222222aaa22a22aaa2a2a2222222222a22aaa21aa010101010aaa0a0a01a10a0101a10aaa01aa010a010102222222222222222222222222222222222222222
2222222222a22a22a222a2a2222222222a22a2a200a000000000a000a0a00a00a0000a00a0a000a000a000000222222222222222222222222222222222222222
22222222aaa2aaa2aaa2aaa222222222aaa2aaa1aaa101010101a101aaa1aaa10a01aaa1aaa1aaa10a0101010222222222222222222222222222222222222222
22222222222222222222222222222222222222000000000000000000000000000000000000000000000000000022222222222222222222222222222222222222
22222222999299929222929222222222992299909990101010109990999090909990999090909990191090101992299299929222222292222992929229222222
22222222922292929222929222222222292220909000000000009090009090909090900090909090900090009092922292929222222292229292929222922222
22222222999292929992999222222222292299919991010101019991090191919901990199919991910191019192922299929222222292229292929222922222
22222222229292929292229222222222292090000090000000009090900090909090900000909090900090009090922292929222222292229292999222922222
22222222999299929992229222222222999099909990101010109090999019909090999010909990191099909910299292929992222299929922999229222222
22222222222222222222222222222222220000000000000000000000000000000000000000000000000000000000022222222222222222222222222222222222
22222222828288828882882222222222880188818181010101018881888181818881888181818881080188818881088288822822222222222222222222222222
22222222828282828222282222222222280000808080000000008080008080808080800080808080800080008080802228222282222222222222222222222222
22222222888288828882282222222222181018808880101010108880181080808810881088808880801088108880888228222282222222222222222222222222
22222222228282822282282222222220080000800080000000008080800080808080800000808080800080008080008228222282222222222222222222222222
22222222228288828882888222222221888188810181010101018181888108818181888101818881080181018181880228222822222222222222222222222222
22222222222222222222222222222200000000000000000000000000000000000000000000000000000000000000000222222222222222222222222222222222
22222222828288828882882222222010808088808880101010108880808018808080888018808880101010101010101022222222222222222222222222222222
22222222828282828222282222222000808080008000000000008880808080008080808080008080000000000000000022222222222222222222222222222222
22222222888288828882282222220101888188818881010101018181818188818181880181018881010101010101010102222222222222222222222222222222
22222222228282822282282222200000008000800080000000008080808000808080808080008080000000000000000002222222222222222222222222222222
22222222228288828882888222101010108088808880101010108080188088101880808018808080101010101010101010222222222222222222222222222222
22222222222222222222222222000000000000000000000000000000000000000000000000000000000000000000000000222222222222222222222222222222
22222222727277727772777221010101777177717771010101017701717107717771770101010101010101010101010101022222222222222222222222222222
22222222727272727272727200000000007070707000000000007070707070007070707000000000000000000000000000022222222222222222222222222222
22222222777277727272727210101010777077707770101010107070707077707770707010101010101010101010101010102222222222222222222222222222
22222222227272727272727000000000700000700070000000007070707000707070707000000000000000000000000000002222222222222222222222222222
22222222227277727772777101010101777101717771010101017171077177017171717101010101010101010101010101012222222222222222222222222222
22222222222222222222220000000000000000000000000000000000000000000000000000000000000000000000000000000222222222222222222222222222
22222222626266626662661010101010661066606660101010106660666060606660666060606660161060101660606016101222222222222222222222222222
22222222626222626222060000000000060000600060000000006060006060606060600060606060600060006060606000600022222222222222222222222222
22222222666222626662262222222222262166616661010101016661060161616601660166616661610161016161616101610122222222222222222222222222
22222222226222622262262222222222262262226222222222006060600060606060600000606060600060006060666000600002222222222222222222222222
22222222226222626662666222222222666266626662222222226262666226626060666010606660161066606610666016101012222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222220000000000000000000000000222222222222222222222222
22222222525255525222555222222222552255225552222222222552525255525552555255525222255252522522520105515151252222222222222222222222
22222222525252225222225222222222252225222252222222225222525225225222252252525222525252525222522252525252225222222222222222222222
22222222555255525552555222222222252225222552222222225552555225225522252255525222525252525222522252525252225222222222222222222222
22222222225222525252522222222222252225222252222222222252525225225222252252525222525255525222522252525552225222222222222222222222
22222222225255525552555222222222555255525552222222225522525255525222252252525552552255522522555255225552252222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222244424442444222222222424244424422222222222442444244424442444244222442244222222222222222222222222222222222222222222222
22222222222242424222422222222222424222422422222222224222424242224242444242424242422222222222222222222222222222222222222222222222
22222222222244424442444222222222444224422422222222224222442244224442424242424242422222222222222222222222222222222222222222222222
22222222222242422242224222222222224222422422222222224222424242224242424242424242424222222222222222222222222222222222222222222222
22222222222244424442444222222222224244424442222222222442424244424242424244424422444222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222227777722222222222222222222222222222222222222222222222777772222222222222222222222222222222222222222222222222222222222
22222222222277222772222272727772772277727772772227727772777222227727277222227722777227727272722277722772222222222222222222222222
22222222222277272772222272722722727277227722727272727772772222227772777222227272772272227272722227227222222222222222222222222222
22222222222277222772222277722722772272227222772277727272722222227727277222227722722222727272722227222272222222222222222222222222
22222222222227777722222277727772727227727222727272727272277222222777772222227272277277222772277227227722222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222227777722222227777722222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222277722772222277227772222277727272772277222222777272727772222277727722777227727722277272227772222222222222222222222222
22222222222277222772222277222772222227227272727272722222272272727722222227227272272272727272722272227722222222222222222222222222
22222222222277722772222277227772222227227272772272722222272277727222222227227722272277727272727272227222222222222222222222222222
22222222222227777722222227777722222227222772727272722222272272722772222227227272777272727272777227722772222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222227777722222227777722222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222277727772222277222772222227727272777277722772727222227722277227727772777277227772777277727722222222222222222222222222
22222222222277222772222277222772222272227272272227227222727222227272727272222722772272722722227277227272222222222222222222222222
22222222222277222772222277727772222222727772272227227222777222227722777222722722722277222722722272227722222222222222222222222222
22222222222227777722222227777722222277227772777227222772727222227272727277222722277272727772777227727272222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222

