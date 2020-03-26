pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--utils

function tonorm(s)
if tonum(s) then return tonum(s)
elseif s=='true' then return true
elseif s=='false' then return false
elseif s=='nil' then return nil
end
return s
end

function todeg(p)
return tonum('0x'..p)
end
function tohex(p,n)
local x,y=''
p=tonum(p)
repeat
y=band(p,0xf)
x=sub('0123456789abcdef',y+1,y+1)..x
p=lshr(p-y,4)
until p==0
return join(tablefill(0,(n or 0)-#x),'')..x
end
function pack(h,l,b)
return bor(shl(tonum(h),b),tonum(l))
end
function unpack(v)
return {lshr(band(v,0xff00),8),band(v,0xff)}
end

function replace(s,f,r)
local a=''
while #s>0 do
local t=sub(s,1,#f)
a=a..(t~=f and sub(s,1,1) or r or '')
s=sub(s,t==f and 1+#f or 2)
end
return a
end

function htbl(ht,ri)
local t,c,k,rt,p={},0,''

ri=ri or 0
ht=replace(ht,"\n")
while #ht>0 do
p,ht=sub(ht,1,1),sub(ht,2)
 if p=='{' or p=='=' then
  rt,ht=htbl(ht,ri+1)
  if rt then
	  if p=='=' then
	   t[k]=rt[1]
	  else
	   if #k>0 then
	    t[k]=rt
	   else
	    add(t,rt)
	   end
	  end
  end
  k=''
 elseif p=='}' or p==';' or p==')' then
  if #k>0 then
   add(t,tonorm(k))
  end
  k=''
  return t,ht
 elseif p==' ' then
  if #k>0 then add(t,tonorm(k)) end
  k=''
 else
  k=k..p
 end
end
if #k>0 then
add(t,tonorm(k))
end
return t
end


function mkrect(p)
return rectf.new(istable(p) and p or split(p))
end
rectf={}
mkrs=htbl'x y w h ex ey r p'
hovk=htbl'{x y}{x ey}{ex y}{ex ey}'
function rfmt(p)
for i,v in pairs(p) do
p[i]=tonum(v)
end
local x,y,w,h=spread(p)
return comb(mkrs,cat(p,{x+w-1,y+h-1,w/2,p}))
end
rectf.new=function(p)

local o=rfmt(p)
cat(o,{
cont=function(x,y)
if y then
return inrng(x,o.x,o.ex) and inrng(y,o.y,o.ey)
else
return o.cont(x.x,x.y) and o.cont(x.ex,x.ey)
end
end
,hover=function(r,p)
local h
for i,v in pairs(hovk) do
h=h or o.cont(r[v[1]],r[v[2]])
end
return h or p==nil and r.hover(o,true)
end

,ud=function(p,y,w,h)
if type(p)=='string' then
p,y,w,h=spread(split(p))
end
p={p or o.x,y or o.y,w or o.w,h or o.h}
cat(o,rfmt(p))
return o
end

,rs=function(col,f)
local c=o.cam
f=(f or rect)(o.x-c.x,o.y-c.y,o.ex-c.x,o.ey-c.y,col)
return o
end
,rf=function(col)
return o.rs(col,rectfill)
end
,cs=function(col,f)
(f or circ)(o.x+o.r-o.cam.x,o.y+o.r-o.cam.y,o.w/2,col)
return o
end
,cf=function(col)
return o.cs(col,circfill)
end
,cam=htbl'x=0;y=0;'
})

return o
end

function toc(v,p)
return flr(v/(p or 8))
end

function join(s,d,dd)
local a=''
for i,v in pairs(s) do
a=a..v..d
end
return sub(a,1,#a-#d)
end

function split(str,d,dd)
local a,c,s,tk={},0,'',''
if dd then str=split(str,dd) end
while #str>0 do
 if dd then
  add(a,split(str[1],d))
  del(str,str[1])
 else
  s=sub(str,1,1)
  str=sub(str,2)
  if s==(d or ' ') then
   add(a,tk)
   tk=''
  else
   tk=tk..s
  end
 end
end
add(a,tk~='' and tk or nil)
return a
end

function btd(b,n)
local d={}
n=n or 2
for i=1,#b,n do
add(d,todeg(sub(b,i,i+n-1)))
end
return d
end

function slice(r,f,t)
local v={}
for i=f,t or #r do
add(v,r[i])
end
return v
end


function cat(f,s)
for k,v in pairs(s) do
if tonum(k) then
add(f,v)
else
f[k]=v
end
end
return f
end

function comb(k,v)
local a={}
for i=1,#k do
 a[k[i]]=v[i]
end
return a
end

function tablefill(v,n,...)
local t,r={},...
if r and r>0 then
n,r=r,n
end

local p=istable(v) and #v==0
for i=0,n-1 do
t[i]=p and {} or (r and tablefill(v,...) or v)
end
return t
end

function ecxy(p,f)
p=mkrect(p)
for y=p.y,p.ey do
for x=p.x,p.ex do
f(x,y,p)
end
end
end

function outline(t,a)
local i,j,k,l=spread(split(a))
ecxy('-1 -1 3 3',function(x,y)
?t,x+i,y+j,l
end)
?t,i,j,k
end

function tmap(t,f)
for i,v in pairs(t) do
local c=f(v,i)
t[i]=c or t[i]
end
return t
end

function eachpal(f,t)
for i=1,#f-1 do
local s=istable(t) and t[i] or todeg(sub(t,i,i))
local d=s>0 and pal or palt
d(todeg(sub(f,i,i)),s)
end
end

function istable(p)
return type(p)=='table'
end

function inrng(c,l,h)
return mid(c,l,h)==c
end
function amid(c,a)
return mid(c,a,-a)
end

function bmch(b,m,l)
b=band(b,m)
return l and b~=0 or b==m
end

function spread(t,n)
n=n or 1
if t[n]~=nil then
return t[n],spread(t,n+1)
end
end

-->8
--scenes
caller,scorder={},{}
scorder.new=function(fn,d,p)
local o={}
cat(o,comb(split'nm dur prm rate',{
fn
,tonum(d)
,p
,function(d,r)
local f,t=spread(d)
r=r or o.dur
return (t-f)/r*(o.cnt%r)+f
end
}))
cat(o,htbl'cnt=0;rm=false;')
return o
end

scenes={}
scenes.new=function(key)
local o={}
cat(o,{
ps=function(fn,d,p)
return add(o.ords,scorder.new(fn,d,p))
end
,st=function(fn,d,p)
o.cl()
return o.ps(fn,d,p)
end
,rm=function(s)
s=s and o.fi(s) or not s and o.cu()
if s then
del(o.ords,s).rm=true
end
return s
end
,cl=function()
 local s={}
 while o.ords[1] do
 add(s,o.rm())
 end
 return s
end
,fi=function(key)
 for v in all(o.ords) do
  if v.nm==key or key==v then 
return v end
 end
end
,cu=function()
return o.ords[1]
end
,sh=function()
local v=o.cu()
return del(o.ords,v)
end
,us=function(s,d,p)
p=scorder.new(s,d,p)
o.ords=cat({p},o.ords)
return p
end
,tra=function()
local c=o.cu()
if c then
local n=c.cnt
c.fst,c.lst=n==0,n>=(c.dur-1)
local r=c.rm or c.nm and caller[c.nm] and caller[c.nm](c)
c.cnt=n<=32000 and n+1 or 1
if r or inrng(c.dur,1,c.cnt) then
o.rm(c)
end
end
end
})
cat(o,htbl('ords{}nm='..key..';'))

return o
end

scal={}
function mkscenes(keys)
local o=add(scal,{})
return o,tmap(istable(keys) and keys or {keys},function(v)
o[v]=scenes.new(v)
end)
end

function scenesbat(b,p)
local res={}
tmap(split(b,' ',"\n"),function(v,i)
tmap(scal,function(o,k)
 local s,m,f,d=spread(v)
 if o[s] then
 	add(res,o[s][m](f,d,p or {}))
 end
end)
end)
return res
end
-->8
dbg_str={}
isdebug=false
function dbg(str)
add(dbg_str,str)
end

function dbg_print()
if isdebug then
dbg_each(dbg_str,0)
dbg_str={}
end
end

function dbg_each(tbl)
local c=0
tmap(tbl,function(str,i)
	if istable(str) then	dbg_each(str)
	else
 	?str,0,(i-1)*6,15-(c%16)
//		p=p+#(tostr(str)..'')+1
		c+=1
	end
end)
//return p
end

vdmpl={}
function vdmp(v,x)
local tstr=htbl([[
number=#;string=$;boolean=%;function=*;nil=!;
]])
tstr.table='{'
local p,s=true,''
if x==nil then x=0 color(6) cls()
else
s=join(tablefill(' ',x),'')
end
v=istable(v) and v or {v}
for i,str in pairs(v) do
	if istable(str) then
	 add(vdmpl,s..i..tstr[type(str)])
		vdmp(str,x+1)
	 add(vdmpl,s..'}')
 p=true
	else
		if p then
		add(vdmpl,s)
		end
 vdmpl[#vdmpl]=vdmpl[#vdmpl]..tstr[type(str)]..':'..tostr(str)..' '
	p=false
	end
end
if x==0 then
?join(vdmpl,"\n")
stop()
end
end


-->8
function _init()
menuitem(1,'save',function()
scenesbat([[
d st spr_d 0
k st save_k 0
]],{})
end)
menuitem(2,'load',function(v,i)
scenesbat([[
d st spr_d 0
k st load_k 0
]],{})
end)

btnc,btns,btrg,butrg=tablefill(0,8),{},{},{}
upsc,upscs=mkscenes(split'm k')
drsc,drscs=mkscenes(split'e d')

zoom=1
scale=1/zoom
aperture=0.9
focusd=8
arad=atan2(1/3,1)

vdist=4
sizc=htbl[[15=3; 6=1; 1=0; 0=-1; 10=1;]]
kmap=htbl[[{-1 0} {1 0} {0 -1} {0 1}]]
wasd=htbl[[a d w s]]
view=mkrect[[64 64 128 128]]
viewb=mkrect[[64 64 128 128]]
--cam=mkrect[[64 64 128 128]]
rview=mkrect[[0 0 128 128]]
opos=mkrect[[0 0 0 0]]
oposb=mkrect[[0 0 0 0]]
orot=mkrect[[0 0 0 0]]
orotb=mkrect[[0 0 0 0]]
view.z=64
viewb.z=64

genab=htbl[[x=true;y=true;z=true;]]
gedef=htbl[[x=false;y=false;z=false;]]
rfp=htbl[[0x0000 0x1040 0x050c 0x5a5a 0xfcf5 0xdfef 0xeff7 0xffff]]
--rfp=htbl[[0xffff 0xeff7 0xdfef 0xfcf5 0x5a5a 0x050c 0x1040 0x0000]]
--vdmp(rfp)

spid=0
vtxs={}
vtxsb={}
vcol=10
--cam.z=64
opos.z=0
oposb.z=0
orot.z=0
rview.z=0
--cat(view,htbl[[r{x=0;y=0;z=0;}]])
ldps=3
vtxsel={1}
vtxsl=1
vtxsll=0
vtxslf=1
dblwait=0

getmouse()
dragstart(opos,1)
dragstart(view,1)
dragstart(rview,1)
--cls()
--clickp=tablefill({0,0,0,false},16*16*16)
clickp={}
ecxy('-8 0 16 1',function(z)
ecxy('-8 -8 16 16',function(x,y)
add(clickp,{x,y,z})
end)
end)

pspal=tablefill(0,16)
ecxy('0 0 2 1',function(c,r)
ecxy('0 0 4 8',function(x,y)
--pspal[y+c*8][x]=sget(x+c*4,y+32)
pspal[y+c*8]+=shl(sget(x+c*4,y+32),12-x*4)
--pset(x,y+c*8+32,pspal[y+c*8][x])
--pspal[y][x]=sget(x,y+32)
end)
end)
--stop()

--lzbf=tablefill(1,16,16,16)
--pspal=split[[2 8 14 15]]

scenesbat[[
d st def_d 0
k st def_k 0
]]

cubr=tablefill(6,3,3,3)

tmap(htbl[[
{{0 0 0}{0 0 0}{0 0 0}}
{{0 0 0}{0 15 0}{0 0 0}}
{{0 0 0}{0 0 0}{0 0 0}}
]],function(v,z)
tmap(v,function(v,y)
tmap(v,function(v,x)
cubr[z-1][y-1][x-1]=v
end)
end)
end)

--0:1
--1:
caller={
def_d=function(o)
cls(5)
local p=0

rectfill(64,64,64,64,7)

local msk=0xffff
local qx,qy,qz=vradq(rview,1/128)
local zr=64/view.z

--**draw glid**
fillp(0xcc33.8)
clickp={x={},y={},z={}}
local c=genab.z and 13 or 6
if genab.x then
for i=max(opos.y-2,-7),min(opos.y+2,7) do
local x=0
local y=genab.z and opos.y*8*zr or i*8*zr
local z=genab.z and (i-opos.y+opos.z)*8*zr or opos.z*8*zr
local q,x1,y1,z1=rots(56*zr+x,y,z,qx,qy,qz)
local q,x2,y2,z2=rots(-64*zr+x,y,z,qx,qy,qz)
line(x1+view.x,y1+view.y,x2+view.x,y2+view.y,c)
end
end
if genab.y then
for i=max(opos.x-2,-7),min(opos.x+2,7) do
local x=genab.z and opos.x*8*zr or i*8*zr
local y=0
local z=genab.z and (i-opos.x+opos.z)*8*zr or opos.z*8*zr
local q,x1,y1,z1=rots(x,56*zr+y,z,qx,qy,qz)
local q,x2,y2,z2=rots(x,-64*zr+y,z,qx,qy,qz)
line(x1+view.x,y1+view.y,x2+view.x,y2+view.y,c)
end
end
if genab.z then
local st=genab.x and opos.x or opos.y
for i=max(st-2,-7),min(st+2,7) do
local x=genab.x and i*8*zr or opos.x*8*zr
local y=genab.y and i*8*zr or opos.y*8*zr
local z=genab.x and 0 or 0
local q,x1,y1,z1=rots(x,y,56*zr+z,qx,qy,qz)
local q,x2,y2,z2=rots(x,y,-64*zr+z,qx,qy,qz)
line(x1+view.x,y1+view.y,x2+view.x,y2+view.y,c)
end
end

--local x1,y1,z=rots(56*zr,opos.y*8*zr,opos.z*8*zr,qx,qy,qz)
--local x2,y2,z=rots(-64*zr,opos.y*8*zr,opos.z*8*zr,qx,qy,qz)

--local q,x1,y1,z=rots(56*zr,0,0,qx,qy,qz)
--local q,x2,y2,z=rots(-64*zr,0,0,qx,qy,qz)
--line(x1+view.x+opos.x*8*zr,y1+view.y+opos.y*8*zr,x2+view.x+opos.x*8*zr,y2+view.y+opos.y*8*zr,0x28)
fillp(not genab.x and msk)
local q,x1,y1,z=rots(56*zr,opos.y*8*zr,opos.z*8*zr,qx,qy,qz)
local q,x2,y2,z=rots(-64*zr,opos.y*8*zr,opos.z*8*zr,qx,qy,qz)
line(x1+view.x,y1+view.y,x2+view.x,y2+view.y,0x28)
--local x1,y1,z=rots(opos.x*8*zr,56*zr,opos.z*8*zr,qx,qy,qz)
--local x2,y2,z=rots(opos.x*8*zr,-64*zr,opos.z*8*zr,qx,qy,qz)
local q,x1,y1,z=rots(opos.x*8*zr,56*zr,opos.z*8*zr,qx,qy,qz)
local q,x2,y2,z=rots(opos.x*8*zr,-64*zr,opos.z*8*zr,qx,qy,qz)
--local q,x1,y1,z=rots(0,56*zr,0,qx,qy,qz)
--local q,x2,y2,z=rots(0,-64*zr,0,qx,qy,qz)
fillp(not genab.y and msk)
--line(x1+view.x+opos.x*8*zr,y1+view.y+opos.z*8*zr,x2+view.x+opos.x*8*zr,y2+view.y+opos.z*8*zr,0x3b)
line(x1+view.x,y1+view.y,x2+view.x,y2+view.y,0x3b)
--local x1,y1,z=rots(opos.x*8*zr,opos.y*8*zr,56*zr,qx,qy,qz)
--local x2,y2,z=rots(opos.x*8*zr,opos.y*8*zr,-64*zr,qx,qy,qz)
local q,x1,y1,z=rots(opos.x*8*zr,opos.y*8*zr,56*zr,qx,qy,qz)
local q,x2,y2,z=rots(opos.x*8*zr,opos.y*8*zr,-64*zr,qx,qy,qz)
--local q,x1,y1,z=rots(0,0,56*zr,qx,qy,qz)
--local q,x2,y2,z=rots(0,0,-64*zr,qx,qy,qz)
fillp(not genab.z and msk)
line(x1+view.x,y1+view.y,x2+view.x,y2+view.y,0x1c)
--line(x1+view.x+opos.x*8*zr,y1+view.y+opos.y*8*zr,x2+view.x+opos.x*8*zr,y2+view.y+opos.y*8*zr,0x1c)
fillp()

--tmap(clickp,function(p)
 
--ecxy({-2,-2,5,5},function(x,y)
--local q,x,y,z=rots
--(genab.x and ((opos.x+x)*8*zr) or ((opos.y+y)*8*zr)
--,not genab.z and ((opos.y+y)*8*zr) or 0
--,genab.z and ((opos.z+(genab.x and y or x))*8*zr) or 0
--,qx,qy,qz)
--circfill(x+view.x,y+view.y,1,8)
--end)
--dbg('nm'..join(normalize({0,0,-64}),' '))

local vt={}
local tr={}
local vs={}
local qx,qy,qz=vradq(rview,1/128)
--tmap(vtxs,function(v,i)
--vs=tmap(rolzsort(cat({},vtxs),qx,qy,qz),function(v,i)
vs=tmap(cat({},vtxs),function(v,i)
local q,vx,vy,vz=spread(rolq(rolq(rolq({0,v[1],v[2],v[3]},qx),qy),qz))
--local q,vx,vy,vz=spread(rolq(rolq(rolq({0,v[1]-opos.x,v[2]-opos.y,v[3]},qx),qy),qz))
v=cat({},{vx,vy,vz,v[4],i=i})
--v[1]=v[1]*8*zr+view.x+opos.x*8*zr
--v[2]=v[2]*8*zr+view.y+opos.y*8*zr
v[1]=v[1]*8*zr+view.x
v[2]=v[2]*8*zr+view.y

vt[v.i]=v
return v
end)

--tmap(rolzsort(vt,vradq(rview,1/128)),function(v,i)
--tmap(rolzsort(vt,qx,qy,qz),function(v,i)
tmap(vs,function(v,i)
local pfnc=inrng(v.i,vtxsl,vtxslf) and circfill or circ

--v[1]=v[1]*8*zr+view.x
--v[2]=v[2]*8*zr+view.y
--if inrng(v.i,vtxsl,vtxslf)  then
if inrng(v.i,vtxsl,vtxsl+vtxsll) then
circfill(v[1],v[2],2,i==vtxsl and v[4] or 11)
end
circ(v[1],v[2],2,v[4])
--drawp(v[1],v[2],v[3],v[4],2)
--if #tr>2 then
if v.i>2 then
tr={vt[v.i-2],vt[v.i-1],v}
--tr={v,vt[v.i-1],vt[v.i-2]}
--fp=rtfp(facerad(tr[1]))
--dbg('vt '..join(v,' '))
--dbg('nm '..join(normalize(v,1),' '))
--dbg('nm '..join(normalize({view.x,view.y,view.z},1),' '))
--dbg(dot(normalize({view.x,view.y,view.z}),normalize(v,1)))
local c,fp=light(pspal[tr[1][4]],dot({0,0,-32},normalize(v,1)))
--dbg('li '..join({c,fp},' '))

--if cull(tr[1][1],tr[1][2],tr[2][1],tr[2][2],tr[3][1],tr[3][2])==band(v.i,1) then
if cull(tr[1][1],tr[1][2],tr[2][1],tr[2][2],tr[3][1],tr[3][2])<1 then
return
end
--add(tr,v)
--vdmp(tr[1])
--trifill(tr[1],tr[2],{10 ,10},14)
--raster_triangle(tr[1],tr[2],tr[3])
--dbg(facerad(tr[1]))

if fp then
p01_triangle_163(tr[1][1],tr[1][2],tr[2][1],tr[2][2],tr[3][1],tr[3][2],c,fp)
end
--dbg(join({tr[1][1],tr[2][1],tr[3][1]}, "--"))
del(tr,tr[1])
end
end)
fillp()
v=cubr
pfnc=circ
local q,vx,vy,vz=spread(rolq(rolq(rolq({0,opos.x,opos.y,opos.z},qx),qy),qz))
--drawo(v,opos.x-1,opos.y-1,opos.z-1)
drawp(vx*8*zr+view.x,vy*8*zr+view.y,vz*8*zr+view.z,15,3)
orot.x=vx*8*zr+view.x
orot.y=vy*8*zr+view.y

rectfill(0,120,127,127,0)
for x=0,15 do
fillp()
rectfill(1+x*8,121,4+x*8,126,lshr(pspal[x],4))
fillp(0x0f0f)
rectfill(5+x*8,121,6+x*8,126,lshr(pspal[x],4))
end
fillp()
pset(1,121,5)
pal(7,vcol)
rect(vcol*8,120,vcol*8+8,127,pspal[vcol])
spr(spid,mo.x-3,mo.y-3)
pal()

end
,def_k=function(o)
local b
if not keystate.█ then
tmap(kmap,function(v,i)
if btn(i-1) or btn(i-1,1) then
view.x-=kmap[i][1]
view.y-=kmap[i][2]
end
end)
end
cat(genab,gedef)
local x,y
=cos(rview.x%64/64)>0
,cos(rview.y%64/64)>0
--=inrng(sgn(rview.x)*rview.x%64,-16,16)
--,inrng(sgn(rview.y)*rview.y%64,-16,16)
genab.x=x and 1 or not y and -1
genab.y=y or not x and y
genab.z=not(genab.y and genab.x)
if keystate['x'] or keystate['c'] or keystate['z'] then
genab.x=keystate['x']
genab.y=keystate['c']
genab.z=keystate['z']
end
spid=0

if mo.lt then
dragstart(opos)
dragstart(view)
chold=true
elseif mo.lut then
chold=false
end

if keystate[' '] and mo.l then
--**drag view**
spid=1
local x,y=dragrot(view,{x=0,y=0,z=0})
--local x,y,z=dragrot(rview,{x=opos.x,y=opos.y,z=opos.z})

view.ud(x,y)
else
if not mo.r and mo.l and chold then
if mo.y>120 then
vcol=flr(min(mo.x/8,15))
return
end

--**drag cursor**
scale=8
local p={dragdist(opos,rview)}
tmap((genab.x and cos((rview.x%64)/64)>0 or genab.y and cos((rview.y%64)/64)<0) and split'x y z' or split'z y x',function(v)
local s=sgn(cos(rview[v]/128))
s=1
opos[v]=mid(-8,7,flr(genab[v] and del(p,p[1])*s+0.5 or opos[v]))
p=cat({},p)
end)
opos.ud()
scale=1

if opos.x+opos.y+opos.z~=oposb.x+oposb.y+oposb.z then
dblwait=12
end
--**[cancel] drag cursor**
cat(oposb,opos)
end
end
dblwait=max(0,dblwait-1)

if mo.l and mo.rt then
--**cancel cursor drag**
cat(opos,oposb)
chold=false
end

if mo.rt then
chold=true
ytzr=not inrng(mo.y,24,104)
xtzr=not inrng(mo.x,24,104)
cat(viewb,view)
cat(orotb,orot)

elseif mo.rut then
ytzr=false
xtzr=false
end

if mo.r and chold then

--**rotate view**
spid=2
dragstart(rview)
dragstart(orot)
local x,y,zx,zy=dragrot(rview,{x=0,y=0,z=0})
--local x,y,z=dragrot(rview,{x=opos.x,y=opos.y,z=opos.z})
--z=rview.z
local z=rview.z
if ytzr then
spid=3
z=zx
x=rview.x
end
if xtzr then
spid=3
z=zy
y=rview.y
end

if keystate[' '] then
--**rot z and fix rot x-y **
z=x
x,y=rview.x,rview.y
end
--**rot view with one axis 
if keystate.x then
x,y,z=rview.x,x,rview.z
end
if keystate.c then
x,y,z=x,rview.y,rview.z
end
if keystate.z then
x,y,z=rview.y,rview.y,x+y
end

if mo.l then
--orot.z=z
--orot.ud(x,y)
else
rview.z=z
rview.ud(x,y)
end


--view.x+=(flr(orot.x)==64 and  or sgn(orot.x))
--view.x=64-64*sin(64/orot.x)
--view.x=viewb.x-orot.x+orotb.x


--rview.ud(inrng(x,128,-128) and x or -sgn(x)*128
--,inrng(y,128,-128) and y or -sgn(y)*128)

--end
end

if keystate[' '] then
mo.ldb=false
mo.rdb=false
view.z-=mo.w*2
else
--vcol=(vcol+16+mo.w)%16
opos.z=mid(opos.z+mo.w,-8,7)
--rview.z-=mo.w*2
end

if keytrg.█ then
vtxsl=#vtxs
vtxsll=-#vtxs+1
end
if mo.r and keytrg[','] or keytrg['<'] then
		vtxsll=min(vtxsll-1,vtxsl-1)
 	vtxsl=mid(vtxsl,1,#vtxs)
elseif keytrg[','] then
		vtxsl=max(vtxsl-1,1)
		vtxsll=0
end
if mo.r and keytrg['.'] or keytrg['>'] then
	vtxsll=min(vtxsll+1,#vtxs-vtxsl)
	vtxsl=mid(vtxsl,1,#vtxs)
elseif keytrg['.'] then
		vtxsl=min(vtxsl+1,#vtxs+1)
	 vtxsll=0
end
if mo.ldb then
--	local v={flr(opos.x),flr(opos.y),flr(opos.z),vcol}
 vtxsb={}
	tmap(vtxs,function(v)
	add(vtxsb,cat({},v))
	end)
	local v={flr(opos.x),flr(opos.y),flr(opos.z),vcol}
	if vtxsll~=0 or vtxsl<=#vtxs then
	 local st=max(1,min(vtxsl+vtxsll,vtxsl))
	 local en=min(#vtxs,max(vtxsl+vtxsll,vtxsl))
		for i=st,en do
		ecxy('1 0 3 1',function(a)
		vtxs[i][a]+=v[a]-vtxs[en][a]

		end)
		end
--		stop()
 
	else
	add(vtxs,v)

	v.i=#vtxs
	vtxsl=#vtxs+1
	vtxslf=vtxsl
	end
end
if mo.rdb then
vtxsb={}
tmap(vtxs,function(v)
add(vtxsb,cat({},v))
end)
del(vtxs,vtxs[vtxsl<#vtxs+1 and vtxsl or #vtxs])
vtxs=cat({},vtxs)
vtxsl=#vtxs+1
vtxsll=0
end

dbg(vtxsl)
dbg(vtxslf)
if keystate['0'] then
chold=false
if mo.r then
rview.z=0
rview.ud(0,0)
elseif mo.l then
opos.z=0
opos.ud(0,0)
oposb.z=0
oposb.ud(0,0)
elseif keystate[' '] then
view.ud(64,64)
view.z=64
else
end
end

if keytrg.▥ then
vtxs,vtxsb=vtxsb,vtxs
end
end

,spr_d=function(o)
cls()
spr(0,0,0,16,16)
outline('exit:q','32 0 7 0')
if(o.prm.cr)o.prm.cr.rs(7)
fillp(0xcc33)
if(o.prm.r)o.prm.r.rs(0x16)
fillp()

end
,save_k=function(o)
if o.fst then
keytrg["\r"]=false
end
--local r=o.prm.cr

local c,s=selcell(#vtxs)
o.prm.r=s or o.prm.r
o.prm.cr=c or o.prm.cr

if o.prm.r then
if keytrg["\r"] or keytrg.z then
poke(0x5f30,1)
local st=0x40*32
local ids={}
--local r=o.prm.r
local r=o.prm.r
ecxy({toc(r.x),toc(r.y),toc(r.w),toc(r.h)},function(x,y)
add(ids,x+y*16)
end)

local sec,seci=0,1
tmap(vtxs,function(v,i)
if ids[1] then
poke2
(ids[1]%16*4+toc(ids[1],16)*8*0x40
+(i-1)%2*2+toc((i-1)%16,2)*0x40
,bor((v[1]+8)+(v[2]+8)*16+(v[3]+8)*256,shl(v[4],12))
)
sec+=1
if sec==16 then
ids=slice(ids,2)
sec=0
end
end
end)
cstore(0,0,0x2000)

end
end
if keystate.q then
scenesbat[[
d st def_d 0
k st def_k 0
]]
return 1
end
end
,load_k=function(o)
if o.fst then
--keytrg["\r"]=false
end
local c,s=selcell()
o.prm.r=s or o.prm.r
o.prm.cr=c or o.prm.cr
if o.prm.r then
if keytrg["\r"] or keytrg.z then
poke(0x5f30,1)
local st=0x40*32
local ids={}
local r=o.prm.r
local ts={}
ecxy({toc(r.x),toc(r.y),toc(r.w),toc(r.h)},function(x,y)
add(ids,x+y*16)
end)

cls()
tmap(ids,function(v,i)
local l,t=v%16*8,toc(v,16)*8
ecxy('0 0 2 8',function(x,y)
if peek2(l/2+(t+y)*0x40+x*2)~=0 then
x*=4
--vdmp(peek2(l+t*0x40+x*2))
--local v={
--sget(x+l,y+t)
--,sget(x+l+1,y+t)
--,sget(x+l+2,y+t)
--,sget(x+l+3,y+t)
--}
--vdmp({l,t})
add(ts,{
sget(x+l,y+t)-8
,sget(x+l+1,y+t)-8
,sget(x+l+2,y+t)-8
,sget(x+l+3,y+t)
,i=#ts+1
})
else
end
end)
end)
vtxs=#ts>0 and ts or vtxs
scenesbat[[
d st def_d 0
k st def_k 0
]]
return 1
end
end
if keystate.q then
scenesbat[[
d st def_d 0
k st def_k 0
]]
return 1
end
end
}


end
function _update60()
tmap(btnc,function(v,i)
btns[i]=btn(i)
v=btn(i) and v+1 or 0
butrg[i]=v<btnc[i]
btnc[i]=v
btrg[i]=v==1
end)
tl,tr,tu,td,tz,tx,te=spread(btrg,0)
mo=getmouse()
updatekey()
--presskey=getkey()
--panholdck()
--dbg(panhold[' '])

tmap(upscs,function(v)
upsc[v].tra()
end)
end
function _draw()
tmap(drscs,function(v)
drsc[v].tra()
end)

isdebug=true
dbg(join({opos.x,opos.y,opos.z},' '))
dbg(join({view.x,view.y,view.z},' '))
dbg(join({rview.x,rview.y,rview.z},' '))
dbg('o:'..join({orot.x,orot.y,orot.z},' '))
dbg(stat(1))
dbg_print()
end

-->8
--control
mousestate,mousebtns,moky=spread(htbl([[
{l=0;r=0;m=0;stx=0;sty=0;x=0;y=0;lh=0;rh=0;}
{m r l}
{x y l r m w sx sy lh rh}
]]))

poke(0x5f2d,1)
function getmouse()
local mb=stat(34)
local mst=mousestate
local mo=comb(moky,
{stat(32)
,stat(33)
,band(mb,1)>0
,band(mb,2)>0
,band(mb,4)>0
,stat(36)
,mst.stx
,mst.sty
,mst.hl
,mst.hr
})

function ambtn()
return mo.lt or mo.rt or mo.mt
end

tmap(mousebtns,function(k)
if mo[k] then 
mst[k]+=1
mo[k..'ut']=false
else
mo[k..'ut']=mst[k]>0
mst[k]=0
end
mo[k..'t']=mst[k]==1
end)

if ambtn() then
mst.stx,mst.sty=mo.x,mo.y

end
mo.sx,mo.sy=mst.stx,mst.sty

mo.mv=(mo.x~=mst.x) or (mo.y~=mst.y)
mst.x,mst.y=mo.x,mo.y

mo.ldb=mo.lt and mst.lh>0
mo.rdb=mo.rt and mst.rh>0

mst.lh=max(0,mst.lh-1)
if mo.lt then
mst.lh=mo.ldb and 0 or 12
end

mst.rh=max(0,mst.rh-1)
if mo.rt then
mst.rh=mo.rdb and 0 or 12
end

return mo
end

function dragstart(vw,f)
if ambtn() or f then
--vw.stx,vw.sty,vw.stz=vw.x*rvrsa('x'),vw.y*rvrsa('y'),vw.z*rvrsa('z')
vw.stx,vw.sty,vw.stz=vw.x,vw.y,vw.z
end
end

function dragrot(vw,rv)
local qx,qy,qz=vradq({x=rv.x,y=rv.y,z=rv.z},1/128)
--local x,y,z=mo.x-mo.sx*sgn(rv.x),mo.y-mo.sy*sgn(rv.y),64
local x,y,zx,zy=mo.x-mo.sx,mo.y-mo.sy,mo.x-mo.sx,mo.y-mo.sy
return
 x/scale+vw.stx
,y/scale+vw.sty
,zx/scale+vw.stz
,zy/scale+vw.stz
end

function dragdist(vw,rv)

local qx,qy,qz=vradq({x=rv.x,y=rv.y,z=rv.z},1/128)
local x,y,z=mo.x-mo.sx,mo.y-mo.sy,64
return
 x/scale*rvrsa('x')+(genab.x and vw.stx or vw.stz)
,y/scale*rvrsa('y')+(genab.y and vw.sty or vw.stz)
-- (x/scale+(genab.x and vw.stx or -vw.stz))*rvrsa('x')
--,(y/scale+(genab.y and vw.sty or -vw.stz))*rvrsa('y')
--,z/scale+vw.stz
end
function rvrsa(a)
return sgn((a=='y' and cos or sin)((rview[a]-16)/128))
end

--btnstat={}
function statkeys()
local k={}
local i=0
while stat(30) do
k[stat(31)..'']=true
i+=1
end
return k
end


function updatekey()
--btnstat=statkeys()
local s=tmap(statkeys(),function(v,i)
presskey[i]=v
end)
--tmap(cat(presskey,btnstat),function(v,i)
tmap(presskey,function(v,i)
--local s=statkeys()
--tmap(s,function(v,i)
--presskey[i]=v
keytrg[i]=s[i]
panholdck(s,i)
end)
end
function getkey()
return presskey
end

presskey=''
presskey={}
panhold=0
panhold={}
keystate={}
keytrg={}


function panholdck(s,k)
k=k or ''
panhold[k]=panhold[k] or 0
panhold[k]+=min(1,panhold[k])

if s[k] then
--if s[k] then
 keystate[k]=true
 panhold[k]=panhold[k]>1 and 28 or 1
elseif panhold[k]>31 then
 keystate[k]=false
 panhold[k]=0
end
--dbg(panhold[k])
end

function selcell(mx)
local cr,sr=mkrect'0 0 8 8'
if mo.l or mo.r then
local reqn=toc(mx or 32767,16)+1
local w,h
=toc(mo.x)*8-r.x
,toc(mo.y)*8-r.y
--o.prm.r.ud(r.x,r.y
sr=mkrect'0 0 0 0'.ud(r.x,r.y
,mid(8,w,toc(reqn,toc(h+8))*8)
,mid(8,h,toc(reqn,toc(w+8))*8))
else
r=cr.ud(toc(mo.x)*8,toc(mo.y)*8)
--r=o.prm.cr.ud(toc(mo.x)*8,toc(mo.y)*8)
end
return cr,sr
end
-->8
--quaternion
function radq(r,v)
--r (rad) rotation
--with vector v as the rotation axis
local s=sin(r/2)
return {cos(r/2),v[1]*s,v[2]*s,v[3]*s}
end

function qprd(q,r)
return {q[1]*r[1]-q[2]*r[2]-q[3]*r[3]-q[4]*r[4]
,q[1]*r[2]+q[2]*r[1]+q[3]*r[4]-q[4]*r[3]
,q[1]*r[3]+q[3]*r[1]+q[4]*r[2]-q[2]*r[4]
,q[1]*r[4]+q[4]*r[1]+q[2]*r[3]-q[3]*r[2]}
end

function rolq(q,r)
return qprd(qprd(r,q),{r[1],-r[2],-r[3],-r[4]})
end

function drawo(o,x,y,z)
local v={}
tmap(o,function(o,oz)
tmap(o,function(o,oy)
tmap(o,function(o,ox)
--add(v,{0,ox+x,oy+y,oz+z,o})
add(v,{ox+x,oy+y,oz+z,o})
end)
end)
end)

--local qx,qy,qz=vradq(rview,1/128)

local v,s=rolzsort(v,vradq(rview,1/128))
local zr=64/view.z
tmap(v,function(p,i)
local s=sizc[p[4]..''] or 0

--drawp(p[1]*rview.z/view.z*8+view.x,p[2]*rview.z/view.z*8+view.y,p[3],p[4],s)
drawp(p[1]*8*zr+view.x,p[2]*zr*8+view.y,p[3]*8*zr+view.z,p[4],s)
end)
end

pfnc=circfill
function drawp(x,y,z,p,s)

pfnc(x,y,s,p)
end

function rolzsort(v,qx,qy,qz)
local s={}
tmap(v,function(v)
local x,y,z,p=spread(v)
--local q,vx,vy,vz=spread(rolq(rolq({0,x,y,z},qx),qy))
local q,vx,vy,vz=spread(rolq(rolq(rolq({0,x,y,z},qx),qy),qz))
add(s,vz)
return {vx,vy,vz,p,q,i=v.i}
end)
quicksort(v,1,#v)

return v,s
end

function vradq(vw,r)
return
radq((vw.x)*r,{0,1,0})
,radq((vw.y)*r,{1,0,0})
,radq((vw.z)*r,{0,0,1})
end
--function vradq(vw,r)
--return
--radq((vw.x)*r,{0,1,0})
--,radq((vw.y)*r,{1,0,0})
--,radq((vw.z)*r,{0,0,1})
--end

--function rots(x,y,z,qx,qy,qz)
----return x,y,z,q
--return spread(rolq(rolq(rolq({x,y,z,0},qx),qy),qz))
--end
function rots(x,y,z,qx,qy,qz)
--return q,x,y,z
return spread(rolq(rolq(rolq({0,x,y,z},qx),qy),qz))
end


--function trad(v0,v1,v2)
--local ba,bc={},{}
--ba[1]=v0[1]-v1[1]
--ba[2]=v0[2]-v1[2]
--bc[1]=v2[1]-v1[1]
--bc[2]=v2[2]-v1[2]
--
--local babc=ba[1]*bc[1]+ba[2]*bc[2]
--local ban=(ba[1]*ba[1])+(ba[2]*ba[2])
--local bcn=(bc[1]*bc[1])+(bc[2]*bc[2])
--local x=babc/(sqrt(ban*bcn))
--return atan2(x,-sqrt(1-x*x))
--end
function facerad(v)
return acos(1/sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3]))
end

function acos(x)
 return atan2(x,-sqrt(1-x*x))
end
function rtfp(r)
return rfp[mid(1,8,flr(r*100)-8)]
end
function light(c,r)
local s=1-mid(r*2,0,1)
--local s=mid(r*4,0,3)
--dbg('q '..c..' '..s..' '..band(s,0x.ffff)*7+1)
--return band(lshr(c,flr(s)*4),0xff),rfp[mid(1,8,flr(band(s,0x.ffff)*7)+1)]
return band(lshr(c,flr(s+1)*4),0xff),rfp[mid(1,8,flr(band(s,0x.ffff)*7)+1)]
end

function dot(v1,v2)--,x3,y3,z3
	return v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3]
end

function normalize(v,s)
--s=sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])
local l=sqrt(v[1]^2 + v[2]^2 + v[3]^2)
return {v[1]/l,v[2]/l,v[3]/l}
end

function cull(x1,y1,x2,y2,x3,y3)
return (x2-x1)*(y3-y1)>(x3-x1)*(y2-y1) and 1 or 0
end


-->8
--sort	
--function pivot(a,i,j)
--local k=i+1
--while k<=j and a[i][4]==a[k][4] do k+=1 end
--if(k>j)return -1
--if(a[i][4]>=a[k][4])return i
--return k
--end
--
--function partition(a,i,j,x)
--local l,r=i,j
--while l<=r do
--while l<=j and a[l][4]<x do l+=1 end
--while r>=i and a[r][4]>=x do r-=1 end
--if(l>r)break
--a[l],a[r]=a[r],a[l]
--l+=1
--r-=1
--end
--return l
--end
--
--function quicksort(a,i,j)
--if(i==j)return
--local p=pivot(a,i,j)
--if p!=-1 then
----print(join({i,j,#a,p,a[p]},' '))
--local k=partition(a,i,j,a[p][4])
--quicksort(a,i,k-1)
--quicksort(a,k,j)
--end
--end

function quicksort(a,l,r)
local i,j
if(l>=r)return
j=l

for i=l+1,r do
if a[i][3]<a[l][3] then
j+=1
a[j],a[i]=a[i],a[j]
end
end
a[l],a[j]=a[j],a[l]

quicksort(a,l,j-1)
quicksort(a,j+1,r)
end
--
--function swap(a,b)
--int w;
--
--w = a;
--a = b;
--b= w;
--end
-->8
--trifill
--@p01
function p01_triangle_163(x0,y0,x1,y1,x2,y2,col,fp)
 color(col)
 fillp(fp)
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
function raster_triangle(p0,p1,p2)
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777000007077000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007007000070070000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007007000070070000700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777000770700000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000128e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0015249a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012d49a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013b23bf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
124f1dc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
015615d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
156728ef000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d6778ef7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
248f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
249a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14a70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23bf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1dc60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15d60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
28ef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4ef70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
548a5c8a00000000000000000000000000000000000000008f847f843fda9f7a0000000000000000000000000000000000000000000000000000000000000000
dc8ad48a00000000000000000000000000000000000000007f748f741f9a9f7a0000000000000000000000000000000000000000000000000000000000000000
d48a000000000000000000000000000000000000000000008f8480841f4a9f7a0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000007f847084000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000007f747074000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000008f748074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000080847074000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000080847084000000000000000000000000000000000000000000000000000000000000000000000000
548a598a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c98ac48a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
668a96aa0000000000000000000000000000000000000000000000008f847f840000000000000000000000000000000000000000000000000000000000000000
964a94890000000000000000000000000000000000000000000000007f748f740000000000000000000000000000000000000000000000000000000000000000
668896ac0000000000000000000000000000000000000000000000008f8480840000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007f8470840000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000007f7470740000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000008f7480740000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000808470740000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000808470840000000000000000000000000000000000000000000000000000000000000000
