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
dbg_each(dbg_str,0)
dbg_str={}
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

--?join(vdmpl,"\n")
tmap(vdmpl,function(v)
?v 
end)
stop()
end
end


-->8
function _init()
menuitem(1,'save',function()
scenesbat([[
d st spr_d 0
k st save_k 0
m us nil 0
]],{t='exit form save: x',p='32 1 13 7'})
end)
menuitem(2,'load',function(v,i)
scenesbat([[
d st spr_d 0
k st load_k 0
m us nil 0
]],{t='exit form load: x',p='32 1 3 7'})
end)menuitem(3,'play',function(v,i)
scenesbat([[
d st spr_d 0
k st load_k 0
]],{})
scenesbat[[
d st sc_d 0
k st sc_k 0
]]
end)

btnc,btns,btrg,butrg=tablefill(0,8),{},{},{}
upsc,upscs=mkscenes(split'm k')
drsc,drscs=mkscenes(split'e d')

zoom=1
scale=1/zoom
--aperture=0.9
--focusd=8
arad=atan2(1/3,1)



vdist=4
prsp=4
xyz=htbl[[x y z]]
--rada=htbl[[{0 1 0}{1 0 0}{0 0 1}]]
rada=htbl[[{1 0 0}{0 1 0}{0 0 1}]]
eface=true

sizc=htbl[[15=3; 6=1; 1=0; 0=-1; 10=1;]]
kmap=htbl[[{-1 0} {1 0} {0 -1} {0 1}]]
wasd=htbl[[a d w s]]
view=mkrect[[64 64 128 128]]
viewb=mkrect[[64 64 128 128]]
--cam=mkrect[[64 64 128 128]]
rview=mkrect[[0 0 128 128]]
opos=mkrect[[0 0 0 0]]
--oposb=mkrect[[0 0 0 0]]
orot=mkrect[[0 0 0 0]]
--orotb=mkrect[[0 0 0 0]]
oang=mkrect[[0 0 0 0]]
oscl=mkrect[[64 64 1 1]]
lpos=mkrect[[1 -5 0 0]]
lpos.z=-1
view.z=64
viewb.z=64

genab=htbl[[x=true;y=true;z=true;]]
gedef=htbl[[x=false;y=false;z=false;]]
rfp=htbl[[0x0003 0x0303 0x030f 0x0f0f 0x0f3f 0x3f3f 0x3fff 0xffff]]--rfp=htbl[[0x0000 0x1040 0x050c 0x5a5a 0xfcf5 0xdfef 0xeff7 0xffff]]
--rfp=htbl[[0xffff 0xeff7 0xdfef 0xfcf5 0x5a5a 0x050c 0x1040 0x0000]]
--vdmp(rfp)

spid=0
vtxs={}
vtxsb={}
vcol=10
bgcol=5
--cam.z=64
opos.z=0
oposb=cat({},opos)
--oposb.z=0
orot.z=0
orotb=cat({},orot)
--orotb.z=0
oang.z=0
rview.z=0
--cat(view,htbl[[r{x=0;y=0;z=0;}]])
ldps=3
--vtxsel={1}
vtxsl=1
vtxslb=1
vtxsll=0
vtxslf=1
dblwait=0

getmouse()
dragstart(opos,1)
dragstart(view,1)
dragstart(orot,1)
dragstart(lpos,1)

rothlf=32
rotful=64
scsize=128

local obj={}
obj.rt=orot
obj.vt=vtxs
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
k st edt_k 0
m st def_k 0
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
if not inrng(mo.x,8,120) or not inrng(mo.y,8,104) or xtzr or ytzr then
cls((bgcol+15)%16)
clip(8,8,112,104)
rectfill(0,0,127,127,bgcol)
clip()
else
cls(bgcol)
end
local p=0

rectfill(64,64,64,64,7)

local msk=0xffff
--local qx,qy,qz=vradq({orot.x,orot.y,orot.z},1/128)
--local rx,ry,rz=vradq({rview.x,rview.y,rview.z},1/128)
--local qx,qy,qz=vradq({orot.x,orot.y,orot.z,rview.x,rview.y,rview.z},1/128)
local qv=vradq({rview.x,rview.y,rview.z,orot.x,orot.y,orot.z},1/128)
--local qx,qy,qz=vradq(orot,1/128)
--local rx,ry,rz=vradq(orotb,1/128)
local zr=8*64+prsp
local wz=view.z+prsp
--local zr=64/wz
//(8*64+prsp)/(view.z-z+prsp)*y+view.y
--**draw glid**
fillp(0xcc33.8)
clickp={x={},y={},z={}}
local c=genab.z and 13 or 6
if genab.x then
for i=max(opos.y-2,-8),min(opos.y+2,7) do
--local zr=(8*64+prsp)/(view.z-0+prsp)
local x=0
--local y=genab.z and zr/(view.z-opos.y+prsp) or zr/(view.z-i)
--local z=genab.z and zr/(view.z-i-opos.y+opos.z) or opos.z*8*zr
--local y=genab.z and opos.y*8*zr or i*8*zr
local y=genab.z and opos.y or i
local z=genab.z and i-opos.y+opos.z or opos.z
line3(7+x,y,z,-8+x,y,z,qv,c)
rectfill()
--local q,x1,y1,z1=rots(7+x,y,z,qx,qy,qz)
--local q,x2,y2,z2=rots(-8+x,y,z,qx,qy,qz)
--local z1=zr/(wz-z1)
--local z2=zr/(wz-z2)
--line(x1*z1+view.x,y1*z1+view.y,x2*z2+view.x,y2*z2+view.y,c)
end
end
if genab.y then
for i=max(opos.x-2,-8),min(opos.x+2,7) do
--local x=genab.z and opos.x*8*zr or i*8*zr
--local y=0
--local z=genab.z and (i-opos.x+opos.z)*8*zr or opos.z*8*zr
local x=genab.z and opos.x or i
local y=0
local z=genab.z and i-opos.x+opos.z or opos.z
line3(x,7+y,z,x,-8+y,z,qv,c)

--local q,x1,y1,z1=rots(x,7+y,z,qx,qy,qz)
--local q,x2,y2,z2=rots(x,-8+y,z,qx,qy,qz)
--local z1=zr/(wz-z1)
--local z2=zr/(wz-z2)
--line(x1*z1+view.x,y1*z1+view.y,x2*z2+view.x,y2*z2+view.y,c)
--line(x1+view.x,y1+view.y,x2+view.x,y2+view.y,c)
end
end
if genab.z then
local st=genab.x and opos.x or opos.y
for i=max(st-2,-8),min(st+2,7) do
--local x=genab.x and i*8*zr or opos.x*8*zr
--local y=genab.y and i*8*zr or opos.y*8*zr
--local z=genab.x and 0 or 0
local x=genab.x and i or opos.x
local y=genab.y and i or opos.y
local z=genab.x and 0 or 0
--local q,x1,y1,z1=rots(x,y,7+z,qx,qy,qz)
--local q,x2,y2,z2=rots(x,y,-8+z,qx,qy,qz)
--local z1=zr/(wz-z1)
--local z2=zr/(wz-z2)
--line(x1*z1+view.x,y1*z1+view.y,x2*z2+view.x,y2*z2+view.y,c)
line3(x,y,7+z,x,y,-8+z,qv,c)
end
end

fillp(not genab.x and msk)
--local q,x1,y1,z1=rots(56*zr,opos.y*8*zr,opos.z*8*zr,qx,qy,qz)
--local q,x2,y2,z2=rots(-64*zr,opos.y*8*zr,opos.z*8*zr,qx,qy,qz)
--line(x1+view.x,y1+view.y,x2+view.x,y2+view.y,0x28)
local l1={line3(7,opos.y,opos.z,-8,opos.y,opos.z,qv,0x28)}
--rectfill(x2-1,y2-1,x2+1,y2+1,0x28)

--local q,x1,y1,z=rots(opos.x*8*zr,56*zr,opos.z*8*zr,qx,qy,qz)
--local q,x2,y2,z=rots(opos.x*8*zr,-64*zr,opos.z*8*zr,qx,qy,qz)
fillp(not genab.y and msk)
--line(x1+view.x,y1+view.y,x2+view.x,y2+view.y,0x3b)
local l2={line3(opos.x,7,opos.z,opos.x,-8,opos.z,qv,0x3b)}
--rectfill(x2-1,y2-1,x2+1,y2+1,0x3b)

fillp(not genab.z and msk)
--local q,x1,y1,z=rots(opos.x*8*zr,opos.y*8*zr,56*zr,qx,qy,qz)
--local q,x2,y2,z=rots(opos.x*8*zr,opos.y*8*zr,-64*zr,qx,qy,qz)
--line(x1+view.x,y1+view.y,x2+view.x,y2+view.y,0x1c)
local l3={line3(opos.x,opos.y,7,opos.x,opos.y,-8,qv,0x1c)}
--rectfill(x2-1,y2-1,x2+1,y2+1,0x1c)
fillp()


fillp()
--local q,x1,y1,z1=rots(lpos.x*zr,lpos.y*zr,lpos.z*zr,qx,qy,qz)
local q,x1,y1,z1=vrolq({0,-lpos.x/8,-lpos.y/8,-lpos.z/8},qv)
--zr=8*64/view.z
--zr=8*64+prsp
--local z1=zr/(view.z-z1+prsp)
--local z2=zr/(view.z-z2+prsp)
--**line draw mode*

local pre
local vt=cat({{x1,y1,z1,7},l1,l2,l3},objdraw(obj))
--local vt=cat({{lpos.x,lpos.y,lpos.z,7},l1,l2,l3},objdraw(obj))
--quicksort(vt,1,#vt)
tmap(vt,function(v,i)
--local pfnc=inrng(v.i,vtxsl,vtxslf) and circfill or circ

--v[1]=v[1]*8*zr+view.x
--v[2]=v[2]*8*zr+view.y
--if inrng(v.i,vtxsl,vtxslf)  then

local z1=zr/(view.z-v[3]+prsp)
if v.i then
--**vertex draw**
fillp()
if inrng(v.i,vtxsl,vtxsl+vtxsll) then
circfill(v[1]*z1+view.x,v[2]*z1+view.y,2,v.i==vtxsl and v[4] or 11)
end
if v.i==#vtxs and #vtxs>1 then
local z2=zr/(view.z-pre[3]+prsp)
line(v[1]*z1+view.x,v[2]*z1+view.y,pre[1]*z2+view.x,pre[2]*z2+view.y,
(v.i<3 or v.i%2==0) and 11 or 12)
end
circ(v[1]*z1+view.x,v[2]*z1+view.y,2,v.t and 12 or v[4])

elseif v[4]==7 then
spr(4,v[1]*z1+view.x-3,v[2]*z1+view.y-3)
else
rectfill(v[1]-1,v[2]-1,v[1]+1,v[2]+1,v[4])
--fillp(0x5a5a.8)
--circfill(v[1]*zr+view.x,v[2]*zr+view.y,2,v[4])
--fillp()
--circ(v[1]*zr+view.x,v[2]*zr+view.y,2,v[4])
end
pre=v
end)

v=cubr
pfnc=circ
--local q,x1,y1,z1=vrolq({lpos.x/8,lpos.y/8,lpos.z/8},qx,qy,qz)
--local z1=zr/(view.z-z1+prsp)
--spr(4,x1*z1+view.x-3,y1*z1+view.y-3)

local q,vx,vy,vz=vrolq({0,opos.x,opos.y,opos.z},qv)
local z1=zr/(view.z-vz+prsp)
circ(vx*z1+view.x,vy*z1+view.y,3,15)

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
pal()
eachpal('56dbc$',(#vtxs<3 or vtxsl%2==1) and 'b0bb0' or '0cc0c')
spr(spid,mo.x-3,mo.y-3)
local v=vtxs[vtxsl] or vtxs[vtxsl-1]
if v then
outline(v.i,join({mo.x,mo.y+5,5,7},' '))
end
pal()

end
,edt_k=function(o)
if mo.lt then
dragstart(opos)
chold=true
elseif mo.lut then
chold=false
end

if keytrg.… then
vtxsl,vtxslb=vtxslb,vtxsl
end
if mo.r and mo.lt and #vtxs>0 then
if keystate[' '] then
--select vtx on opos
--local m={}
for i,v in pairs(vtxs) do
if vtxsl~=v.i and opos.x==v[1] and opos.y==v[2] and opos.z==v[3] then
vtxsl,vtxslb=v.i,vtxsl
break
--add(m,v.i)
end
end
else
local v=vtxs[min(vtxsl,#vtxs)]
opos.z=v[3]
opos.ud(v[1],v[2])
vtxsb=vtxsl
vtxsl,vtxslb=#vtxs+1,vtxsl
vtxsll=0
end
end

if mo.r and mo.lt then
cat(orot,orotb)
end
if mo.l and mo.rt then
--**cancel cursor drag**
cat(opos,oposb)
chold=false
end

if not mo.r and mo.l and chold then
--**change edit color**
if mo.y>120 then
vcol=flr(min(mo.x/8,15))
chold=false
return
end

--**drag cursor**
if not keystate[' '] and mo.l then
scale=8
local p={dragdist(opos,orot)}
tmap((genab.x and cos((orot.x%rothlf)/rothlf)>0 or genab.y and cos((orot.y%rothlf)/rothlf)<0) and split'x y z' or split'z y x',function(v)
local s=sgn(cos(orot[v]/128))
s=1
opos[v]=mid(-8,7,flr(genab[v] and del(p,p[1])*s+0.5 or opos[v]))
p=cat({},p)
end)
opos.ud()
scale=1

if opos.x+opos.y+opos.z~=oposb.x+oposb.y+oposb.z then
dblwait=12
end

end
end

if keytrg.█ then
if vtxsl==#vtxs then
vtxsl,vtxslb=#vtxs+1,vtxsl
vtxsll=0
else
vtxsl,vtxslb=#vtxs,vtxsl
vtxsll=-#vtxs+1
local v=vtxs[vtxsl]
if v then
opos.ud(v[1],v[2]).z=v[3]
end
end
end
if mo.r and keytrg['1'] or keytrg['!'] then
		vtxsll=mid(vtxsll-1,vtxsl-1,-#vtxs)
 	vtxsl=mid(vtxsl,1,#vtxs)
elseif keytrg['1'] then
		vtxsl=max(vtxsl-1,1)
		vtxsll=0
end
if mo.r and keytrg['2'] or keytrg['"'] then
	vtxsll=mid(vtxsll+1,#vtxs-vtxsl,0)
	vtxsl=mid(vtxsl,1,#vtxs)
--	vdmp({vtxsll,vtxsl})
elseif keytrg['2'] then
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
	if keystate[' '] then
	vtxs=tmap(cat(cat(slice(vtxs,1,vtxsl),{v}),slice(vtxs,vtxsl+1)),function(v,i)
	v.i=i
	end)
	vtxsl+=1
	

	elseif vtxsll~=0 or vtxsl<=#vtxs then
	 local st=max(1,min(vtxsl+vtxsll,vtxsl))
	 local en=min(#vtxs,max(vtxsl+vtxsll,vtxsl))
		local ismv=v[1]~=vtxs[en][1] or v[2]~=vtxs[en][2] or v[3]~=vtxs[en][3]
		for i=st,en do
		ecxy('1 0 3 1',function(a)
		vtxs[i][a]+=v[a]-vtxs[en][a]
		end)
		vtxs[i][4]=ismv and vtxs[i][4] or vcol
		end
--		stop()
 
	else
	add(vtxs,v)

	v.i=#vtxs
	vtxsl,vtxslb=#vtxs+1,vtxsl
	vtxslf=vtxsl
	end
end
if mo.rdb then
vtxsb={}
tmap(vtxs,function(v)
add(vtxsb,cat({},v))
end)

	if keystate[' '] then
	vtxs[vtxsl]=nil
	vtxsl=max(1,vtxsl-1)
	else
	del(vtxs,vtxs[vtxsl<#vtxs+1 and vtxsl or #vtxs])
	vtxs=cat({},vtxs)
	vtxsl,vtxslb=#vtxs+1,vtxsl
	vtxsll=0
	end
	tmap(vtxs,function(v,i)
	v.i=i
	end)
end
end
,def_k=function(o)
--input key as view control
oscl.w=1
oscl.h=1
--if o.fst then
--end
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
=cos(orot.y%rothlf/rothlf)>0
,cos(orot.x%rothlf/rothlf)>0
--=inrng(sgn(orot.x)*orot.x%64,-16,16)
--,inrng(sgn(orot.y)*orot.y%64,-16,16)
genab.x=x and 1 or not y and -1
genab.y=y or not x and y
genab.z=not(genab.y and genab.x)
if keystate.x or keystate.c or keystate.z then
genab.x=keystate.x
genab.y=keystate.c
genab.z=keystate.z
end
spid=0

if mo.lt then
dragstart(view)
chold=true
elseif mo.lut then
chold=false
--**[cancel] drag cursor**
cat(oposb,opos)

end


--if mo.lt then
--dragstart(opos)
--dragstart(view)
--chold=true
--elseif mo.lut then
--chold=false
--end

if keystate[' '] and mo.l then
--**drag view**
--sss+=1.01
spid=1
--local x,y=dragrot(view,{x=0,y=0,z=0})
local x,y=dragdist(view,{x=0,y=0,z=0})
view.ud(x,y)
else
--opos cursor control
end
dblwait=max(0,dblwait-1)

--local xr,yr=not inrng(mo.x,8,120),not inrng(mo.y,8,104)
--xtzr=(xtzr and not yr) or xr
--ytzr=(ytzr and not yr) or yr

if mo.rt then
xtzr,ytzr=not inrng(mo.x,8,120),not inrng(mo.y,8,104)
chold=true
cat(viewb,view)
if mo.y>120 then
bgcol=flr(min(mo.x/8,15))
chold=false
return
end

elseif mo.rut then
cat(orotb,orot)
end

if mo.r and chold then

--**rotate view**
spid=2
dragstart(orot)
dragstart(rview)
local y,x,zy,zx=dragrot(orot,{x=0,y=0,z=0})
--local x,y,zx,zy=dragrot(orot,{x=0,y=0,z=0})
--z=orot.z
local z=orot.z
if ytzr then
spid=3
z=zy
y=orot.y
end
if xtzr then
spid=3
z=zx
x=orot.x
end

if keystate[' '] then
--**rot z and fix rot x-y **
local zr=64/view.z
--local qv=vradq({opos.x*8,opos.y*8,opos.z*8},1/rotful)
--local q,x1,y1,z1=vrolq({0,view.x-64,view.y-64,view.z-64},qv)
local x,y=dragrot(rview,{x=0,y=0,z=0})

--lpos.ud(x,y)
rview.ud(x,y)


end
--**rot view with one axis 
if keystate.x then
x,y,z=y,orot.y,orot.z
end
if keystate.c then
x,y,z=orot.x,y,orot.z
end
if keystate.z then
x,y,z=orot.x,orot.y,x+y
end

if mo.l then

elseif not keystate[' '] then
orot.z=z
orot.ud(x,y)
end



--orot.ud(inrng(x,128,-128) and x or -sgn(x)*128
--,inrng(y,128,-128) and y or -sgn(y)*128)

--end
else
ytzr=false
xtzr=false
end

if mo.mt then
vcol=vtxs[vtxsl] and vtxs[vtxsl][4] or vcol
dragstart(lpos)
end

if mo.m then
local x,y=dragdist(lpos,{x=0,y=0,z=0})
if keystate[' '] then
lpos.z-=mo.w*2
lpos.z=x+y
else
lpos.ud(x,y)
end
end

if not mo.m then
if keystate[' '] then
--mo.ldb=false
--mo.rdb=false
--dbg(mo.ldb)
view.z-=mo.w
else
--vcol=(vcol+16+mo.w)%16
opos.z=mid(opos.z+amid(mo.w,1),-8,7)
--orot.z-=mo.w*2
end
end

if keystate['0'] then
chold=false
if mo.r then
orot.z=0
orot.ud(0,0)
rview.ud(0,0).z=0
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

if keytrg["\t"] then
eface=not eface
end

--obj.rt=orot
--obj.vt=vtxs

end
,sc_d=function(o)
cls(bgcol)
orot.x+=0.5
objdraw(obj)
end
,sc_k=function(o)
if o.fst then
oscl.w=1
oscl.h=1
end
--dbg(mo.x-mo.sx)
if mo.l or mo.r then
--mo.sx=mo.x-oscl.w
--mo.sy=mo.y-oscl.h
end
--if not mo.l and not mo.r then
oscl.w=1+(mo.x-mo.sx)/128*8
oscl.h=1+(mo.y-mo.sy)/128*8
--end
if not keystate.█ then
tmap(kmap,function(v,i)
if btn(i-1) or btn(i-1,1) then
view.x-=kmap[i][1]
view.y-=kmap[i][2]
end
end)
end
if keystate.x then
scenesbat[[
d st def_d 0
k st edt_k 0
]]
return 1
end

end
,spr_d=function(o)
cls()
spr(0,0,0,16,16)
outline(o.prm.t,o.prm.p)
fillp(0xcc33)
if(o.prm.r)o.prm.r.rs(0x16)
fillp()
if(o.prm.cr)o.prm.cr.rs(7)

end
,save_k=function(o)
if o.fst then
keytrg["\r"]=false
end
--local r=o.prm.cr

local c,s=selcell()
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
if keystate.x then
scenesbat[[
d st def_d 0
k st edt_k 0
m rm
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
local ids={}
local r=o.prm.r
local ts={}
r.ud(toc(r.x),toc(r.y),toc(r.w),toc(r.h))

ecxy({r.x,r.y,r.w,r.h},function(x,y)
add(ids,x+y*16)
end)

cls()
tmap(ids,function(v,i)
local l,t=v%16*8,toc(v,16)*8
ecxy('0 0 2 8',function(x,y)
if peek2(l/2+(t+y)*0x40+x*2)~=0 then
x=x*4+l
y+=t
--vdmp(peek2(l+t*0x40+x*2))
--local v={
--sget(x+l,y+t)
--,sget(x+l+1,y+t)
--,sget(x+l+2,y+t)
--,sget(x+l+3,y+t)
--,sget(x+l+3,y+t)
--}
--vdmp({l,t})
add(ts,{
sget(x,y)-8
,sget(x+1,y)-8
,sget(x+2,y)-8
,sget(x+3,y)
,i=#ts+1
})
else
end
end)
end)
vtxs=#ts>0 and ts or vtxs
scenesbat[[
d st def_d 0
k st edt_k 0
m rm
]]
return 1
end
end
if keystate.x then
scenesbat[[
d st def_d 0
k st edt_k 0
m rm
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
dbg(join({orot.x,orot.y,orot.z},' '))
dbg(join({orotb.x,orotb.y,orotb.z},' '))
dbg(join({view.x,view.y,view.z},' '))
dbg(join({rview.x,rview.y,rview.z},' '))
dbg('l:'..join({lpos.x,lpos.y,lpos.z},' '))
--dbg('o:'..join({orot.x,orot.y,orot.z},' '))
dbg(stat(1))
dbg(vtxsll)

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
--local qx,qy,qz=vradq({x=rv.x,y=rv.y,z=rv.z},1/rotful,rx,ry,rz)
local qv=vradq({rv.x,rv.y,rv.z},1/rotful)
local x,y,zx,zy=mo.x-mo.sx,mo.y-mo.sy,mo.x-mo.sx,mo.y-mo.sy
local q,x,y,zx=vrolq({0,x,y,zx},qv)
return
 x/scsize*rotful+vw.sty
,y/scsize*rotful+vw.stx
,zx/scsize*rotful+vw.stz
,zy/scsize*rotful+vw.stz
end

function dragdist(vw,rv)

--local qx,qy,qz=vradq({x=rv.x,y=rv.y,z=rv.z},1/128)
local qv=vradq({rv.x,rv.y,rv.z},1/scsize)
local x,y,z=mo.x-mo.sx,mo.y-mo.sy,64
return
 x/scale+(genab.x and vw.stx or vw.stz)
,y/scale+(genab.y and vw.sty or vw.stz)
-- x/scale*rvrsa('x')+(genab.x and vw.stx or vw.stz)
--,y/scale*rvrsa('y')+(genab.y and vw.sty or vw.stz)

-- (x/scale+(genab.x and vw.stx or -vw.stz))*rvrsa('x')
--,(y/scale+(genab.y and vw.sty or -vw.stz))*rvrsa('y')
--,z/scale+vw.stz
end
function rvrsa(a)
return sgn((a=='y' and cos or sin)((orot[a]-16)/scsize))
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
--mx=17
local cr,sr=mkrect'0 0 8 8'
cr.ud(toc(mo.x)*8,toc(mo.y)*8)
if mo.l or mo.r then
local x,y=toc(mo.sx)*8,toc(mo.sy)*8
local reqn=toc(mx or 32767,16)+1
local w,h
=max(8,toc(mo.x+8)*8-x)
,max(8,toc(mo.y+8)*8-y)
dbg(toc(reqn*8,h+8)*8)
dbg(reqn)
--o.prm.r.ud(r.x,r.y
sr=mkrect'0 0 0 0'.ud(x,y
--w h*w
,mid(8,w,toc(reqn*8,h)*8)
,mid(8,h,toc(reqn*8,w)*8))
--,mid(8,w,toc(reqn,toc(h+8))*8)
--,mid(8,h,toc(reqn,toc(w+8))*8))
else
--r=o.prm.cr.ud(toc(mo.x)*8,toc(mo.y)*8)
end
return cr,sr
end
-->8
--draw

function line3(x1,y1,z1,x2,y2,z2,qv,c)
--function line3(x1,y1,z1,x2,y2,z2,qx,qy,qz,c)
--local q,x1,y1,z1=rots(x1,y1,z1,qx,qy,qz)
--local q,x2,y2,z2=rots(x2,y2,z2,qx,qy,qz)
--local q,x1,y1,z1=vrolq({0,x1,y1,z1},{qx,qy,qz})
--local q,x2,y2,z2=vrolq({0,x2,y2,z2},{qx,qy,qz})
local q,x1,y1,z1=vrolq({0,x1,y1,z1},qv)
local q,x2,y2,z2=vrolq({0,x2,y2,z2},qv)
local zr=64*8+prsp
local z1=zr/(view.z-z1+prsp)
local z2=zr/(view.z-z2+prsp)
local x1,y1,x2,y2=x1*z1+view.x,y1*z1+view.y,x2*z2+view.x,y2*z2+view.y
line(x1,y1,x2,y2,c)
--return x1,y1,z1,x2,y2,z2
return x2,y2,z2,c
end

function vradq(v,s)
return tmap(v,function(a,i)
i=(i-1)%3+1
return radq(a*s,normalize(rada[i],1))
end)
--return spread(tmap(cat({},xyz),function(a,i)
--i=normalize(rada[i],1)
--return radq(v[a]*s,i)
--end))

end

--sss=0
--function vrolq(x,y,z,qx,qy,qz)
--function vrolq(v,qx,qy,qz)
function vrolq(v,q)
--local rx,ry,rz=vradq(orotb,1/128)
local v1,v2,v3,v4=v[1],v[2],v[3],v[4]
for i,r in pairs(q) do
v1,v2,v3,v4=rolq(r[1],r[2],r[3],r[4],v1,v2,v3,v4)
end
return v1,v2,v3,v4
--return
--rolq(qx[1],qx[2],qx[3],qx[4],
--rolq(qz[1],qz[2],qz[3],qz[4],
--rolq(qy[1],qy[2],qy[3],qy[4],
--0,v[1],v[2],v[3])
--))
--)))
--return rolq(rolq(rolq({0,x,y,z},qx),qy),qz)
end

-->8
--for 3d render

--sort	
function quicksort(v,s,e)
local i,p
if(s>=e)return
p=s
for i=s+1,e do
if v[i][4]<v[s][4] then
--if v[i].s>v[s].s then
p+=1
v[p],v[i]=v[i],v[p]
end
end
v[s],v[p]=v[p],v[s]

quicksort(v,s,p-1)
quicksort(v,p+1,e)
end

function vtopsort(v1,v2,v3)

if(v1[2]<v2[2]) v1,v2={v2[1],v2[2],v2[3]},{v1[1],v1[2],v1[3]}
if(v2[2]<v3[2]) v2,v3={v3[1],v3[2],v3[3]},{v2[1],v2[2],v2[3]}
if(v3[2]<v1[2]) v3,v1={v1[1],v1[2],v1[3]},{v3[1],v3[2],v3[3]}
--dbg(v1[2])
return v1,v2,v3
end

--quaternion
function radq(r,v)
--r (rad) rotation
--with vector v as the rotation axis
local s=sin(r)
return {cos(r),v[1]*s,v[2]*s,v[3]*s}
end


function qprd(r1,r2,r3,r4,q1,q2,q3,q4)
return
 q1*r1-q2*r2-q3*r3-q4*r4
,q1*r2+q2*r1+q3*r4-q4*r3
,q1*r3+q3*r1+q4*r2-q2*r4
,q1*r4+q4*r1+q2*r3-q3*r2
end
function rolq(r1,r2,r3,r4,q1,q2,q3,q4)
return qprd(r1,-r2,-r3,-r4,qprd(q1,q2,q3,q4,r1,r2,r3,r4))
end
function rtfp(r)
return rfp[mid(1,8,flr(r*100)-8)]
end
function light(c,r)
local s=mid(r*3,0,3)
return band(lshr(c,flr(s)*4),0xff),rfp[mid(1,8,flr(band(s,0x.ffff)*7)+1)]
--local s=mid(r,0,1)
--return band(lshr(c,flr(s+1)*4),0xff),rfp[mid(1,8,flr(band(s,0x.ffff)*7)+1)]
end




function dot(v1,v2)
	return v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3]
end

function cross(p,v1,v2)
--local ax=v1[1]-p[1]
--local ay=v1[2]-p[2]
--local az=v1[3]-p[3]
--local bx=v2[1]-p[1]
--local by=v2[2]-p[2]
--local bz=v2[3]-p[3]
local ax=v1[1]
local ay=v1[2]
local az=v1[3]
local bx=v2[1]
local by=v2[2]
local bz=v2[3]
--dbg(ay*bz-az*by)
return
 {ay*bz-az*by
	,az*bx-ax*bz
	,ax*by-ay*bx
	}
end

function normalize(v,s)
--local l=sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])
--local l=s/sqrt(v[1],2)+shl(v[2],2)+shl(v[3],2))
--dbg(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])
local l=s/sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])
--return {v[1]/l,v[2]/l,v[3]/l}
return {v[1]*l,v[2]*l,v[3]*l}
end

function cull(x1,y1,x2,y2,x3,y3,i)
return (x2-x1)*(y3-y1)-(x3-x1)*(y2-y1)<0 and i or bnot(i)
end
function objdraw(o)
--local zr=64/view.z
local zr=1
local vt={}
local tr={}
local vs={}
local qv=vradq({orot.x,orot.y,orot.z,rview.x,rview.y,rview.z},1/128)
--local qx,qy,qz=vradq(orot,1/128)
--local rx,ry,rz=vradq(rview,1/128)
local vtx=o.vt
local orot=o.rt
--dbg(join(qx,' '))
vs=tmap(cat({},vtxs),function(v,i)
--local q,vx,vy,vz=vrolq({v[1],v[2],v[3]},qx,qy,qz)
local q,vx,vy,vz=vrolq({0,v[1],v[2],v[3]},qv)
--local q,vx,vy,vz=spread(rolq(rolq(rolq({sss,v[1],v[2],v[3]},qx),qy),qz))
--local cz=.01*(p1z+p2z+p3z)/3
--local cx=.01*(p1x+p2x+p3x)/3
--local cy=.01*(p1y+p2y+p3y)/3

v=cat({},{
vx*zr*oscl.w
,vy*zr*oscl.h
,vz*zr,v[4]
,i=i
--,s=i>2 and -vz-vt[i-1][3]-vt[i-2][3] or 32765
})
--dbg(v.s)
--v[1]=v[1]
--v[2]=v[2]
--v[1]=v[1]*8*zr*oscl.w+view.x
--v[2]=v[2]*8*zr*oscl.h+view.y
--dbg(v[1])

vt[v.i]=v
return v
end)

--tmap(rolzsort(vt,vradq(orot,1/128)),function(v,i)
--tmap(rolzsort(vt,qx,qy,qz),function(v,i)
quicksort(vs,1,#vs)
tmap(vs,function(v,i)
--if #tr>2 then
if v.i>2 then
local c=v[4]
tr=band(v.i,1)==1 and {vt[v.i-2],vt[v.i-1],v} or {v,vt[v.i-1],vt[v.i-2]}
--tr=band(v.i,1)==1 and {v,vt[v.i-2],vt[v.i-1]} or {vt[v.i-2],vt[v.i-1],v}
--tr=band(v.i,1)==1 and {vt[v.i-2],vt[v.i-1],v} or {vt[v.i-3],vt[v.i-1],v}
--tr=v.i==3 and {vt[v.i-2],vt[v.i-1],v} or {vt[v.i-3],vt[v.i-1],v}
--tr={v,vt[v.i-1],vt[v.i-2]}
--dbg('vt '..join(v,' '))
--dbg('nm '..join(normalize(v,1),' '))
--dbg('nm '..join(normalize({view.x,view.y,view.z},1),' '))
--dbg(dot(normalize({view.x,view.y,view.z}),normalize(v,1)))
local l={lpos.x,lpos.y,lpos.z}
if i==3 then
--dbg('dot '..
--dot(normalize(cross
--(tr[1],tr[2],tr[3])
--,1),normalize(l,1)))
end
--cross(tr[1],tr[2],tr[3])
--local c,fp=light(pspal[tr[1][4]],dot({0,0,-32},normalize(v,1)))
--dbg(dot(normalize(v,1)
--,normalize(l,1)))
--dbg('top' ..join(vtopsort(tr[1],tr[2],tr[3]),' '))
--dbg(join(normalize(vtopsort(tr[1],tr[2],tr[3]),1),' '))
--tr[vtopsort(tr[1],tr[2],tr[3]).i].t=true
local c,fp=light
(pspal[c]
,dot(
normalize(vtopsort(tr[1],tr[2],tr[3]),1)
--,normalize(tr[3],1)))
--,normalize(tr[1]
,normalize(l,1)
))

--return (x2-x1)*(y3-y1)-(x3-x1)*(y2-y1)<0 and i or bnot(i)
if cull(tr[1][1],tr[1][2],tr[2][1],tr[2][2],tr[3][1],tr[3][2],-1)>0 then
return
end
if fp then
--zr=8*64/view.z
zr=8*64+prsp
local z1,z2,z3
=zr/(view.z-tr[1][3]+prsp)
,zr/(view.z-tr[2][3]+prsp)
,zr/(view.z-tr[3][3]+prsp)
--local z1,z2,z3=zr/tr[1][3],zr/tr[2][3],zr/tr[3][3]
--local z1,z2,z3=tr[1][3]*zr,tr[2][3]*zr,tr[3][3]*zr
--local z1,z2,z3=zr,zr,zr
if eface then
p01_triangle_163
(tr[1][1]*z1+view.x
,tr[1][2]*z1+view.y
,tr[2][1]*z2+view.x
,tr[2][2]*z2+view.y
,tr[3][1]*z3+view.x
,tr[3][2]*z3+view.y,c,fp)
else
line(tr[1][1]*z1+view.x
,tr[1][2]*z1+view.y
,tr[2][1]*z2+view.x
,tr[2][2]*z2+view.y,c)
line(tr[3][1]*z3+view.x
,tr[3][2]*z3+view.y)
line(tr[1][1]*z1+view.x
,tr[1][2]*z1+view.y)
end
--dbg(tr[1][2]*z1+view.x)
end
--dbg(join({tr[1][1],tr[2][1],tr[3][1]}, "--"))
--del(tr,tr[1])
end
end)

return vs
end
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
00000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d0000077777000077077000077700070777000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b0c000070007000700070000070000070000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b000c00070007000700070007070700070007000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d605d00070007000700070007000700700007000700770000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddddd00077777007707700000777000077707000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000044440000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000044440000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000288e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0112499a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
122d9aa7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
133b3bb7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
244fdcc7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15565dd6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56678eef000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6777eff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
548a5c8a00000000858a747965679477000000007b838b93e593eb930000000083b16471874179514780598069a18aa100000000000000000000000000000000
dc8ad48a00000000947974799477f72700000000758b859be575eb7500000000a4718741995087417750696059818a5100000000000000000000000000000000
d48a0000000000008c797c99a56784970000000085938593a573ab7300000000c781a47187419950795f79507951995100000000000000000000000000000000
000000000000000074797c99849787f70000000095838b9595869b8600000000a471c7819750a96f775087400000000000000000000000000000000000000000
000000000000000084999c9985a79477000000009b859b8685758b750000000084a187c1c780b980995099500000000000000000000000000000000000000000
000000000000000094798c7900000000000000009b86ab96758b7b8b00000000478184a1a9a0a9a099518a510000000000000000000000000000000000000000
00000000000000007477747700000000000000009586a596000000000000000084a14781c780a9a0b9818aa10000000000000000000000000000000000000000
0000000000000000747707270000000000000000a593ab9300000000000000006471874187c069a0a9a169a10000000000000000000000000000000000000000
548a598a0000000000000000000000000000000000000000858a0000000000000000000000000000000000000000000000000000000000000000000000000000
c98ac48a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
668a96aa0000000000000000000000000000000043834b8343834b83000000008cd7cad746d646c685584c5a0000000000000000000000000000000000000000
964a94890000000000000000000000000000000063836b83000000000000000088d7c6d74ad64ac6295a69590000000000000000000000000000000000000000
668896ac0000000000000000000000000000000073757b75000000000000000084d746d78cd68cc6695a695a0000000000000000000000000000000000000000
0000000000000000000000000000000000000000d373db73000000000000000088d74ad78cd68cd6cc5ae95a0000000000000000000000000000000000000000
0000000000000000000000000000000000000000d353db5300000000000000008cd78cc688d688d6a95a00000000000000000000000000000000000000000000
000000000000000000000000000000000000000073537b530000000000000000cad6cac685568556000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000063456b450000000000000000c6d6c6c6a2566256000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000043434b43000000000000000084d684c685588558000000000000000000000000000000000000000000000000
729c868c688c287c7a8c7a8ca88ce89c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
929c927c267c289c888c9a8ce69ce67c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
729c727c688c688c9a8cae7ca88ce87c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
868c927c888c7a8cae9ccd9ce89ce67c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
868c868c7a8c4d9c9a8ccd7ca88ca88c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888c688c6e9c6e7cae7ccd9c888c868c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
688c267c7a8c4d7c9a8c9a8c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
269c289c4d9c6e7c888ca88c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
729c848c478c287c6c8c6c8cc78ce89c000000008b939ba3f5a3fba30000000000000000000000008f847f84808450e48f845fe4000000008f847f8400000000
929c927c267c289c8b8cac8ce69ce67c00000000859b95abf583fb830000000000000000000000007f748f74a0e4e0b41fb41f54000000007f748f7400000000
729c727c478c478cac8cae7cc78ce87c0000000095a395a3b583bb830000000000000000000000008f8480848084e0b48f841f54000000008f84808400000000
848c927c698c6c8cae9ccd9ce89ce67c00000000a5939ba5a596ab960000000000000000000000007f847084e054a0145f14af14000000007f84708400000000
848c848c6c8c4d9cac8ccd7cc78cc78c00000000ab95ab9695859b850000000000000000000000007f7470748084a0148f84ef54000000007f74707400000000
768c478c6e9c6e7cae7ccd9c968c848c00000000ab96bba6859b8b9b0000000000000000000000008f7480745014105400000000000000008f74807400000000
478c267c6c8c4d7cac8cac8c0000000000000000a596b5a600000000000000000000000000000000808470748084105400000000000000008084707400000000
269c289c4d9c6e7ca98cc78c0000000000000000b5a3bba3000000000000000000000000000000008084708410b450e400000000000000008084708400000000
729c868c6e7c888ccd9cae9c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
929c927c888ce69ccd7c888c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
729c727cd49cd47c888c347c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
868c927c888ce67c349c269c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888c888ce69cd47c888c267c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4d9c4d7c888c888c347c269c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6e7c888cae9cae7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6e9c4d9ccd7c888c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006ea4aea4ae64ba54
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ae646e64ae64aea4
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006ea45ab4bab4ba54
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bab4aea4a664ba54
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006ea46e64bab4a6a4
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a545ab4a664a6a4
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006ea46e6466a46664
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ae645a54a6646664
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a54ba54858fd62f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a6646664858f37df
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066a45ab400000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005a54666400000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bab45ab400000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066a4a6a400000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bab466af00000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066af37df00000000
