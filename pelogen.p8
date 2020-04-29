pico-8 cartridge // http://www.pico-8.com
version 22
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
--pelogen lowpoly editor
--@shiftalow/bitchunk
--ver 0.2.2
function _init()
menuitem(1,'play',function(v,i)

scenesbat[[
d st sc_d 0
k st sc_k 0
]]
end)
menuitem(2,'load',function(v,i)
scenesbat([[
d st spr_d 0
k st load_k 0
m cl
]],{t='exit form load: x',p='32 1 3 7'})
end)
menuitem(3,'save',function()
scenesbat([[
d st spr_d 0
k st save_k 0
m cl
]],{t='exit form save: x',p='32 1 13 7'})
end)
menuitem(4,'export',function(v,i)
scenesbat([[
d st spr_d 0
k st exp_k 0
m cl
]],{t='exit form export: x',p='32 1 8 7'})
end)

menuitem(5,'copy-code',function(v,i)
exportcode()
end)

btnc,btns,btrg,butrg=tablefill(0,8),{},{},{}
upsc,upscs=mkscenes(split'm k')
drsc,drscs=mkscenes(split'e d')

zoom=1
scale=1/zoom
arad=atan2(1/3,1)

vdist=4
prsp=4
xyz=htbl[[x y z]]
rada=htbl[[{1 0 0}{0 1 0}{0 0 1}]]
vfilti=1
vfiltp=htbl[[0x7 0x1 0x2 0x4]]
vfilt=vfiltp[1]
--eface=true

sizc=htbl[[15=3; 6=1; 1=0; 0=-1; 10=1;]]
kmap=htbl[[{-1 0} {1 0} {0 -1} {0 1}]]
wasd=htbl[[a d w s]]
view=mkrect[[64 64 128 128]]
viewb=mkrect[[64 64 128 128]]
rview=mkrect[[0 0 128 128]]
opos=mkrect[[0 0 0 0]]
orot=mkrect[[0 0 0 0]]
oang=mkrect[[0 0 0 0]]
oscl=mkrect[[64 64 1 1]]
lpos=mkrect[[1 -5 0 0]]
lpos.z=-1
view.z=64
viewb.z=64

plgn_load({23})
btmr=vtxs
vtxs={}

genab=htbl[[x=true;y=true;z=true;]]
gedef=htbl[[x=false;y=false;z=false;]]

rfpt={}
rfp=tmap(split('8 9 10 11 12 13 14 15'),function(i)
local f=0
ecxy('0 0 4 4',function(x,y)
f+=shl(sget(x+i%16*8,y+toc(i%16,16)*8)~=0 and 1 or 0,12-y*4+3-x)
end)
add(rfpt,f+0.8)
return f
end)

spid=0
cvtxs={}
cvtx=0
vtxs={}
vtxsb={}
vcol=10
bgcol=5
opos.z=0
oposb=cat({},opos)
orot.z=0
orotb=cat({},orot)
oang.z=0
rview.z=0
ldps=3
vtxsl=1
vtxslb=1
vtxsll=0
vtxslf=1
dblwait=0

rothlf=32
rotful=64
scsize=128

tliw=0

--ffnc=rectfill
textured=nil
txrx=16
txry=0

floor=1

mo=getmouse()
dragstart(opos,1)
dragstart(view,1)
dragstart(orot,1)
dragstart(lpos,1)


local obj={}
obj.rt=orot
obj.vt=vtxs

--clickp={}
--ecxy('-8 0 16 1',function(z)
--ecxy('-8 -8 16 16',function(x,y)
--add(clickp,{x,y,z})
--end)
--end)

cpals=0
cpalid=16
--cpalid=17
function lpal_i(i)
palx=i%16*8
paly=flr(i/16)*8
lpal=tablefill(0,16)
ecxy('0 0 2 1',function(c,r)
ecxy('0 0 4 8',function(x,y)
lpal[y+c*8]+=shl(sget(x+c*4+palx,y+paly),12-x*4)
end)
end)
end
lpal_i(cpalid)

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
cls(lshr(lpal[bgcol],12))
clip(8,8,112,104)
rectfill(0,0,127,127,bgcol)
clip()
else
cls(bgcol)
end
local p=0

rectfill(64,64,64,64,7)
rfp,rfpt=rfpt,rfp
pal(0,lshr(lpal[bgcol],12))
textured=floor==2
objdraw({vt=btmr})
textured=false
rfpt,rfp=rfp,rfpt
pal()

local msk=0xffff
local qv=vradq({orot.x,orot.y,orot.z},1/128)
--local qv=vradq({rview.x,rview.y,rview.z,orot.x,orot.y,orot.z},1/128)
local zr=8*64+prsp
local wz=view.z+prsp
--local zr=64/wz
//(8*64+prsp)/(view.z-z+prsp)*y+view.y
--**draw glid**
fillp(0xcc33.8)
--clickp={x={},y={},z={}}

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
--local q,x1,y1,z1=vrolq({0,-lpos.x/8,-lpos.y/8,-lpos.z/8},qv)
local x1,y1,z1=lpos.x+64,lpos.y+64,lpos.z

--**line draw mode*
local vs,vt=objdraw({vt=vtxs})
local vs=bmch(vfilt,1) and cat({{x1,y1,z1,7},l1,l2,l3},vs) or {}
--local vt=cat({{lpos.x,lpos.y,lpos.z,7},l1,l2,l3},objdraw(obj))
--quicksort(vt,1,#vt)
cvtxs={}
cvtx=0

tmap(vs,function(v,i)
--local pfnc=inrng(v.i,vtxsl,vtxslf) and circfill or circ

--v[1]=v[1]*8*zr+view.x
--v[2]=v[2]*8*zr+view.y
--if inrng(v.i,vtxsl,vtxslf)  then

local z1=zr/(view.z-v[3]+prsp)
local x1,y1=v[1]*z1+view.x,v[2]*z1+view.y
if v.i then
--**vertex draw**
--if inrng(mo.x,v[1]-2,v[1]+2) and inrng(mo.y,v[2]-2,v[2]+2) then
if inrng(mo.x,x1-2,x1+2) and inrng(mo.y,y1-2,y1+2) then
cvtx=v.i
spid=5
end

fillp()
add(cvtxs,v)
if inrng(v.i,vtxsl,vtxsl+vtxsll) then
circfill(x1,y1,2,v.i==vtxsl and v[4] or 11)
end
if v.i==#vtxs and #vtxs>1 then
local p=vt[v.i-1]
local z2=zr/(view.z-p[3]+prsp)
line(x1,y1,p[1]*z2+view.x,p[2]*z2+view.y,
(v.i<3 or v.i%2==0) and 11 or 12)
end
circ(x1,y1,2,v.t and 12 or v[4])

elseif v[4]==7 then
fillp(0xebeb.8)
line(v[1],v[2],64,64,0x7)
--line(x1,y1,64,64,0x7)
--spr(4,x1-3,y1-3)
--sspr(32,0,8,8,x1-3,y1-3,z1,z1)
sspr(32,0,8,8,v[1]-3,v[2]-3,z1,z1)
fillp()
else
rectfill(v[1]-1,v[2]-1,v[1]+1,v[2]+1,v[4])

end
--pre=v
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
rectfill(1+x*8,121,4+x*8,126,lshr(lpal[x],8))
fillp(0x0f0f)
rectfill(5+x*8,121,6+x*8,126,lshr(lpal[x],8))
end
fillp()
pset(1,121,5)
pal(7,vcol)
rect(vcol*8,120,vcol*8+8,127,lpal[vcol])
pal()
local c=band(lpal[vcol],0xf)
eachpal('56dbc8$',(#vtxs<3 or vtxsl%2==1) and 'b0bb0'..c or '0cc0c'..c)
spr(spid,mo.x-3,mo.y-3)
local v=vtxs[vtxsl] or vtxs[vtxsl-1]
if v then
outline(v.i,join({mo.x,mo.y+5,5,7},' '))
end
pal()

--dbgs
dbg('★ '..join({opos.x,opos.y,opos.z},' '))
dbg('🅾️ '..join({flr(orot.x),flr(orot.y),flr(orot.z)},' '))
--dbg(join({orotb.x,orotb.y,orotb.z},' '))
--dbg(join({view.x,view.y,view.z},' '))
--dbg(join({dragst.x,dragst.y,dragst.z},' '))
--dbg(join({rview.x,rview.y,rview.z},' '))
dbg('✽ '..join({lpos.x,lpos.y,lpos.z},' '))
--dbg('o:'..join({orot.x,orot.y,orot.z},' '))
--dbg(stat(1))


end
,edt_k=function(o)
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

--if mo.lut then
----**pick vertex**
--tmap(cvtxs,function(v)
--if inrng(mo.x,v[1]-1,v[1]+1) and inrng(mo.y,v[2]-1,v[2]+1) then
--vtxsl,vtxslb=v.i,vtxsl
--end
--end)
--end

if mo.lt then
dragstart(opos)
chold=true
elseif mo.lut then
chold=false
if vtxs[cvtx] and mo.x==mo.sx and mo.y==mo.sy then
cat(opos,comb(xyz,vtxs[cvtx]))
--vtxsl,vtxslb=cvtx,vtxsl
end
end

if keytrg.… then
--**undo pointer**
vtxsl,vtxslb=vtxslb,vtxsl
end
if mo.r and mo.lt and #vtxs>0 then
if keystate[' '] then

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
--vtxslb=vtxsl
vtxsl,vtxslb=#vtxs+1,vtxsl
vtxsll=0
end
end
--dbg(opos.sty)
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
local p=tmap({dragdist(opos,orot)},function(v)
return mid(-8,7,flr(v))
end)

--local p={dragdist(opos,orot)}
--tmap(xyz,function(v,i)
----local s=sgn(cos(orot[v]/128))
--s=genab[v] and del(p,p[1])+0.5 or opos[v]
----s=genab[v] and del(p,p[1])+0.5 or opos[v]
--opos[v]=mid(-8,7,flr(s))
--p=cat({},p)
--end)

opos.ud(genab.x and p[1] or opos.x,genab.y and p[2] or opos.y).z
=genab.z and (genab.y and p[3] or p[4]) or opos.z
scale=1

if opos.x+opos.y+opos.z~=oposb.x+oposb.y+oposb.z then
dblwait=12
end

end
end

if keytrg.█ then
--**select all vtx**
if vtxsl==#vtxs then
vtxsl,vtxslb=#vtxs+1,vtxsl
vtxsll=0
else
vtxsl,vtxslb=max(1,#vtxs),vtxsl
vtxsll=-max(#vtxs,1)+1
local v=vtxs[vtxsl]
if v then
opos.ud(v[1],v[2]).z=v[3]
end
end
end
--dbg(vtxsll)
if mo.r and keytrg['2'] or keytrg['"'] then
--** prev vtx **
		vtxsll=mid(vtxsll-1,#vtxs-vtxsl,-vtxsl)
 	vtxsl=mid(vtxsl,1,#vtxs)
elseif keytrg['2'] then
		vtxsl=max(vtxsl-1,1)
		vtxsll=0
end
if mo.r and keytrg['1'] or keytrg['!'] then
--** next vtx **
	vtxsll=mid(vtxsll+1,-vtxsl,#vtxs-vtxsl)
	vtxsl=mid(vtxsl,1,#vtxs)
--	vdmp({vtxsll,vtxsl})
elseif keytrg['1'] then
		vtxsl=min(vtxsl+1,#vtxs+1)
	 vtxsll=0
end

if mo.ldb then
--	local v={flr(opos.x),flr(opos.y),flr(opos.z),vcol}
 vtxsb={}
	tmap(vtxs,function(v)
	add(vtxsb,cat({},v))
	end)
	
	if keystate.x then
		tmap(vtxs,function(v)
		v[2],v[3]=-v[3],v[2]
		end)
		return
	elseif keystate.c then
		tmap(vtxs,function(v)
		v[1],v[3]=-v[3],v[1]
		end)
		return
	elseif keystate.z then
		tmap(vtxs,function(v)
		v[1],v[2]=-v[2],v[1]
		end)
		return
	end
	
	local v={flr(opos.x),flr(opos.y),flr(opos.z),vcol}
	if keystate[' '] then
	vtxs=tmap(cat(cat(slice(vtxs,1,vtxsl),{v}),slice(vtxs,vtxsl+1)),function(v,i)
	v.i=i
--	v.p=vtxs[v.i-1]
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
--	v.p=vtxs[v.i-1]
	if v.i>1 then
end
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
--	v.p=vtxs[v.i-1]
	end)
end
if mo.mdb then
cpals=(cpals+1)%3
--cpalid=cpalid==16 and 17 or 16
lpal_i(cpalid+cpals)
end

end
,def_k=function(o)
--input key as view control
oscl.w=1
oscl.h=1
--if o.fst then
--end

if keystate['9'] then
tliw+=0.01
elseif keystate['0'] then
tliw-=0.01
end

if not keystate.█ then
tmap(kmap,function(v,i)
if btnp(i-1) then
opos.x+=kmap[i][1]
opos.y+=kmap[i][2]
end
end)
opos.z-=(keytrg['['] and 1 or keytrg[']'] and -1 or 0)

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
--spid=1
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
spid=1

--mo.ldb=false
--mo.rdb=false
--dbg(mo.ldb)
view.z-=mo.w*4
else
--vcol=(vcol+16+mo.w)%16
opos.z=mid(opos.z+amid(mo.w,1),-8,7)
--orot.z-=mo.w*2
end
end

if keystate['0'] then
chold=false
if mo.r then

orot.ud(0,0).z=0
rview.ud(0,0).z=0
elseif mo.l then
opos.ud(0,0).z=0
oposb.ud(0,0).z=0
elseif keystate[' '] then
view.ud(64,64).z=64
elseif mo.m then
lpos.ud(1,-5).z=-1
else
end
end

if keytrg.▥ then
vtxs,vtxsb=vtxsb,vtxs
end

if keytrg["\t"] then
vfilt=vfiltp[vfilti]
vfilti=vfilti%#vfiltp+1
--eface=not eface
end

--obj.rt=orot
--obj.vt=vtxs

end
,sc_d=function(o)
cls(bgcol)
orot.y+=0.5
objdraw({vt=vtxs})
end
,sc_k=function(o)
if o.fst then
oscl.w=1
oscl.h=1
end

oscl.w=1+(mo.x-mo.sx)/128*8
oscl.h=1+(mo.y-mo.sy)/128*8

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
if keystate.z then
rectfill(0,0,127,7,1)
end
outline(o.prm.t,o.prm.p)
fillp(0xcc33)
local r=o.prm.ra or o.prm.r or {}
tmap(r.x and {r} or r,function(r,i)
r.rs(0x16)
outline(i,r.x..' '..r.y..' 0 7')
end)
fillp()
if(o.prm.cr)o.prm.cr.rs(7)

end
,exp_k=function(o)
if o.fst then
keytrg["\r"]=false
o.prm.ra={}
end
local i=mo.lt and #o.prm.ra+1 or #o.prm.ra
local c,s=selcell(o.prm)
o.prm.ra[i]=s or o.prm.ra[i]
del(o.prm.ra,mo.rt and o.prm.ra[#o.prm.ra])
--o.prm.r=mo.rt and {} or o.prm.r
--o.prm.cr=c or o.prm.cr

if keytrg.z then
local objs={}
tmap(o.prm.ra or {},function(r)
local ids={}
ecxy({toc(r.x),toc(r.y),toc(r.w),toc(r.h)},function(x,y)
add(ids,x+y*16)
end)
local g='--'..getgfx(r)
add(objs,g.."\n{"..join(ids,',')..'}')
end)
local u=[[
function _update()
cls()
plgn_render(1,{64,64,64},{time()*4,time()*4,time()*4},{1,1,1})
end
]]
printh("plgn_load({\n"..join(objs,",\n").."\n})\n"..u,'@clip')
--o.prm.r={}
end

if keystate.x then
scenesbat[[
d st def_d 0
k st edt_k 0
m st def_k 0
]]
return 1
end
end
,save_k=function(o)
if o.fst then
keytrg["\r"]=false
end
--local r=o.prm.cr

local c,s=selcell(o.prm)
--o.prm.r=s or o.prm.r
--o.prm.cr=c or o.prm.cr

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
m st def_k 0
]]
return 1
end
end
,load_k=function(o)
if o.fst then
--keytrg["\r"]=false
end
local c,s=selcell(o.prm)
--o.prm.r=s or o.prm.r
--o.prm.cr=c or o.prm.cr
if o.prm.r then
if keytrg["\r"] or keytrg.z then
poke(0x5f30,1)
local ids={}
local r=o.prm.r
r.ud(toc(r.x),toc(r.y),toc(r.w),toc(r.h))

ecxy({r.x,r.y,r.w,r.h},function(x,y)
add(ids,x+y*16)
end)


plgn_load(ids)
scenesbat[[
d st def_d 0
k st edt_k 0
m st def_k 0
]]
return 1
end
end
if keystate.x then
scenesbat[[
d st def_d 0
k st edt_k 0
m st def_k 0
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
dbg(stat(1))
isdebug=true

dbg_print()
end

-->8
--control
mousestate,mousebtns,moky=spread(htbl([[
{l=0;r=0;m=0;stx=0;sty=0;x=0;y=0;lh=0;rh=0;mh=0;}
{m r l}
{x y l r m w sx sy lh rh mh}
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
,mst.hm
})

function ambtn()
return mo.lt or mo.rt or mo.mt
end

tmap(mousebtns,function(k)
local ut,t,h=k..'ut',k..'t',k..'h'
if mo[k] then 
mst[k]+=1
mo[ut]=false
else
mo[ut]=mst[k]>0
mst[k]=0
end
mo[t]=mst[k]==1

mo[k..'db']=mo[t] and mst[h]>0
mst[h]=max(0,mst[h]-1)
if mo[t] then
mst[h]=mo[k..'db'] and 0 or 12
end

end)

if ambtn() then
mst.stx,mst.sty=mo.x,mo.y
end

mo.sx,mo.sy=mst.stx,mst.sty

mo.mv=(mo.x~=mst.x) or (mo.y~=mst.y)
mst.x,mst.y=mo.x,mo.y

return mo
end
dragst=htbl[[x=0;y=0;z=0;]]
function dragstart(vw,f)
if ambtn() or f then
vw.stx,vw.sty,vw.stz=vw.x,vw.y,vw.z
--local qv=vradq({orot.x,orot.y,orot.z},1/rotful)
--vw.stq,vw.stx,vw.sty,vw.stz=vrolq({0,vw.x,vw.y,vw.z},qv)
end
end

function dragrot(vw,rv)
--local qx,qy,qz=vradq({x=rv.x,y=rv.y,z=rv.z},1/rotful,rx,ry,rz)
local qv=vradq({rv.x,rv.y,rv.z},1/rotful)
local x,y,zx,zy=mo.x-mo.sx,mo.y-mo.sy,mo.x-mo.sx,mo.y-mo.sy
local q,x,y,zx=vrolq({0,x,y,zx},qv)
return
-- x/scsize*rotful+dragst.y
--,y/scsize*rotful+dragst.x
--,zx/scsize*rotful+dragst.z
--,zy/scsize*rotful+dragst.z
 x/scsize*rotful+vw.sty
,y/scsize*rotful+vw.stx
,zx/scsize*rotful+vw.stz
,zy/scsize*rotful+vw.stz
end

function dragdist(vw,rv)

local qv=vradq({rv.x,rv.y,rv.z},1/scsize)
local x,y,zx,zy=mo.x-mo.sx,mo.y-mo.sy
,mo.x-mo.sx
,mo.y-mo.sy
--,genab.y and mo.x-mo.sx or 0
--,genab.x and mo.y-mo.sy or 0
--local q,x,y,zx=vrolq({0,x,y,zx},qv)
--local q,x,y,zx=vrolq({0,genab.x and x or zx,genab.y and y or zy,zx},qv)

return
 x/scale+vw.stx
,y/scale+vw.sty

-- x/scale+(genab.x and vw.stx or vw.stz)
--,y/scale+(genab.y and vw.sty or vw.stz)
,zx/scale+vw.stz
,zy/scale+vw.stz

-- x/scale*rvrsa('x')+(genab.x and vw.stx or vw.stz)
--,y/scale*rvrsa('y')+(genab.y and vw.sty or vw.stz)
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

function selcell(prm)
--mx=17
local cr,sr=mkrect'0 0 8 8'
cr.ud(toc(mo.x)*8,toc(mo.y)*8)
if mo.l then
local x,y=toc(mo.sx)*8,toc(mo.sy)*8
local reqn=toc(mx or 32767,16)+1
local w,h
=max(8,toc(mo.x+8)*8-x)
,max(8,toc(mo.y+8)*8-y)
--dbg(toc(reqn*8,h+8)*8)
--dbg(reqn)
--o.prm.r.ud(r.x,r.y
sr=mkrect'0 0 0 0'.ud(x,y
--w h*w
,mid(8,w,toc(reqn*8,h)*8)
,mid(8,h,toc(reqn*8,w)*8))
--,mid(8,w,toc(reqn,toc(h+8))*8)
--,mid(8,h,toc(reqn,toc(w+8))*8))
end

prm.r=sr or prm.r
prm.cr=cr or prm.cr

return cr,sr
end
-->8
--draw code

function line3(x1,y1,z1,x2,y2,z2,qv,c,f)
local q,x1,y1,z1=vrolq({0,x1,y1,z1},qv)
local q,x2,y2,z2=vrolq({0,x2,y2,z2},qv)
local zr=64*8+prsp
local z1=zr/(view.z-z1+prsp)
local z2=zr/(view.z-z2+prsp)
local x1,y1,x2,y2=x1*z1+view.x,y1*z1+view.y,x2*z2+view.x,y2*z2+view.y
if bmch(vfilt,2) then
f=f or line
f(x1,y1,x2,y2,c)
--return x1,y1,z1,x2,y2,z2
end
return x2,y2,z2,c
end

--todo apply to globalview localview
function vradq(v,s)
--return {radq(1*s,{rview.x*s,rview.y*s,rview.z*s})}
--return tmap(cat(v,{rview.x,rview.y,rview.z}),function(a,i)
return tmap(v,function(a,i)
i=(i-1)%3+1
return radq(a*s,normalize(rada[i],1))
end)

end

function vrolq(v,q)
--local rx,ry,rz=vradq(orotb,1/128)
local v1,v2,v3,v4=v[1],v[2],v[3],v[4]
for i,r in pairs(q) do
v1,v2,v3,v4=rolq(r[1],r[2],r[3],r[4],v1,v2,v3,v4)
end
return v1,v2,v3,v4
end

function getgfx(r)
local p=''
ecxy({r.x,r.y,r.w,r.h},function(x,y)
p=p..tohex(sget(x,y))
end)
return "[gfx]"..join({tohex(r.w,2),tohex(r.h,2),p},'').."[/gfx]"
end

function plgn_load(ids)
local ts={}
tmap(ids,function(v,i)
local l,t=v%16*8,toc(v,16)*8
ecxy('0 0 2 8',function(x,y)
if peek2(l/2+(t+y)*0x40+x*2)~=0 then
x=x*4+l
y+=t
add(ts,{
sget(x,y)-8
,sget(x+1,y)-8
,sget(x+2,y)-8
,sget(x+3,y)
,i=#ts+1
--,p=ts[#ts]
})
else
end
end)
end)
vtxs=#ts>0 and ts or vtxs
end

function exportcode()
printh([[
--generated by pelogen
--@shiftalow/bitchunk

--**color palette for light**--
]]..getgfx(mkrect({palx,paly,8,8}))..
[[

--**cut & paste to sprite sheet**--
cpalid=--sprite id as a color palette

]]
..[[rfp={]]..join(tmap(rfp,function(v)return '0x'..tohex(v)end),',')..[[}
function plgn_load(r)
lpos=normalize(1,-5,-1,1)
vtxs={}
prspx=4
prspy=4
prspz=4
culr=1
rothlf=32
rotful=64
palx=cpalid%16*8
paly=flr(cpalid/16)*8
--xyz=split('x y z')
rada={{0,1,0},{1,0,0},{0,0,1}}
lpal={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
lpal[0]=0
for c=0,1 do
for y=0,7 do
for x=0,3 do
lpal[y+c*8]+=shl(sget(x+c*4+palx,y+paly),12-x*4)
end
end
end
cls()
objl={}
for i,ids in pairs(r) do
local ts={}
for i,v in pairs(ids) do
local l,t=v%16*8,flr(v/16)*8
for y=0,7 do
y+=t
for x=0,1 do
if peek2(l/2+(y)*0x40+x*2)~=0 then
x=x*4+l
add(ts,{
sget(x,y)-8
,sget(x+1,y)-8
,sget(x+2,y)-8
,sget(x+3,y)
,i=#ts+1
})
end
end
end
end
objl[i]=ts
end
return objl
end

--quaternion
function radq(r,v)
local s=sin(r/2)
return {cos(r/2),v[1]*s,v[2]*s,v[3]*s}
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
end

function dot(v1,v2)
	return v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3]
end

function normalize(x,y,z)
local l=1/sqrt(x*x+y*y+z*z)
return {x*l,y*l,z*l}
end

gvtx={}
//**
//* m:int model_id
//* v:vecter pos
//* r:vectrr rot
//**/
function plgn_render(m,v,r,s)
local zr=8*64+prspx
local vt={}
local tr={}
local vs={}
local wx,wy,wz=v[1],v[2],v[3]
local r={r[1],r[2],r[3]}
local ra=1/rotful

local q={}
for i,v in pairs(r) do
add(q,radq(v*ra,rada[i]))
end
--local vs=gvtx[o.t] or {}
local vs={}

if #vs==0 then
for i,v in pairs(objl[m]) do
local v1,v2,v3,v4=0,v[1],v[2],v[3]
for i,r in pairs(q) do
v1,v2,v3,v4=rolq(r[1],r[2],r[3],r[4],v1,v2,v3,v4)
end
v={
v2*s[1]
,v3*s[2]
,v4*s[3],v[4]
,i=i
}
vt[v.i]=v
add(vs,v)
end
for i,v in pairs(vs) do
v.s=i>2 and v[3]+vs[i-1][3]+vs[i-2][3] or 0
end
quicksort(vs,1,#vs)
for i,v in pairs(vs) do
	if v.i>2 then
	local c=v[4]
	local v1,v2,v3
		if band(v.i,1)==1 then
		v1,v2,v3=vt[v.i-2],vt[v.i-1],v
		else
		v1,v2,v3=v,vt[v.i-1],vt[v.i-2]
		end
	
	local x1,y1,z1=v1[1],v1[2],v1[3]
	local x2,y2,z2=v2[1],v2[2],v2[3]
	local x3,y3,z3=v3[1],v3[2],v3[3]
	
	lpos=lpos or normalize(0,0,-64,1)
	local c,fp=light
	(lpal[c]
	,dot(
	normalize(vtopsort(v1,v2,v3))
	,lpos
	))
	
	local cull=((x2-x1)*(y3-y1)-(x3-x1)*(y2-y1)<0 and culr or bnot(culr))>0
	vs[i]={x1,y1,z1,x2,y2,z2,x3,y3,z3,c,fp,cull}
	end
end
	gvtx[m]=vs
end--not same obj

for i,v in pairs(vs) do

if v[11] and v[12] then
local z1,z2,z3
=zr/(wz-v[3]+prspx)
,zr/(wz-v[6]+prspy)
,zr/(wz-v[9]+prspz)
pelogen_tri
({v[1]*z1+wx,v[2]*z1+wy}
,{v[4]*z2+wx,v[5]*z2+wy}
,{v[7]*z3+wx,v[8]*z3+wy}
,v[10],v[11])
end
end
return vs
end

--sort
function vtopsort(v1,v2,v3)
if(v1[2]<v2[2]) v1,v2=v2,v1
if(v2[2]<v3[2]) v2,v3=v3,v2
if(v3[2]<v1[2]) v3,v1=v1,v3
return v1[1],v1[2],v1[3]
end

function quicksort(v,s,e)
local i,p
if(s>=e)return
p=s

for i=s+1,e do
if v[i].s<v[s].s then
p+=1
v[p],v[i]=v[i],v[p]
end
end
v[s],v[p]=v[p],v[s]

quicksort(v,s,p-1)
quicksort(v,p+1,e)
end

--trifill
--@shiftalow/bitchunk
function pelogen_tri(v1,v2,v3,col,fp)
color(col)
fillp(fp)
if(v1[2]>v2[2]) v1,v2=v2,v1
if(v1[2]>v3[2]) v1,v3=v3,v1
if(v2[2]>v3[2]) v3,v2=v2,v3
local l,c,r,t,m,b=v1[1],v2[1],v3[1],flr(v1[2]),flr(v2[2]),v3[2]
local i,j,k=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m)
r=l
for t=t,m-1 do
rectfill(l,t,r,t)
r+=j
l+=i
end
for m=m,b-1 do
rectfill(c,m,r,m)
r+=j
c+=k
end
end
]],"@clip")
end
-->8
--for 3d render

--sort	
function quicksort(v,s,e)
local i,p
if(s>=e)return
p=s
for i=s+1,e do
--if v[i][3]<v[s][3] then
if v[i].s<v[s].s then
p+=1
v[p],v[i]=v[i],v[p]
end
end
v[s],v[p]=v[p],v[s]

quicksort(v,s,p-1)
quicksort(v,p+1,e)
end

function vtopsort(v1,v2,v3)

--if(v1[2]<v2[2]) v1,v2={v2[1],v2[2],v2[3]},{v1[1],v1[2],v1[3]}return v1,v2,v3
--if(v2[2]<v3[2]) v2,v3={v3[1],v3[2],v3[3]},{v2[1],v2[2],v2[3]}return v1,v2,v3
--if(v3[2]<v1[2]) v3,v1={v1[1],v1[2],v1[3]},{v3[1],v3[2],v3[3]}return v1,v2,v3
--if(v1.s<v2.s) v1,v2=v2,v1
--if(v2.s<v3.s) v2,v3=v3,v2
--if(v3.s<v1.s) v3,v1=v3,v1
if(v1[2]<v2[2]) v1,v2=v2,v1
if(v2[2]<v3[2]) v2,v3=v3,v2
if(v3[2]<v1[2]) v3,v1=v3,v1
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

function cross(v1,v2)
--local ax=v1[1]
--local ay=v1[2]
--local az=v1[3]
--local bx=v2[1]
--local by=v2[2]
--local bz=v2[3]
--return ay*bz-az*by,az*bx-*bz,ax*by-ay*bx
return v1[2]*v2[3]-v1[3]*v2[2],v1[3]*v2[1]-v1[1]*v2[3],v1[1]*v2[2]-v1[2]*v2[1]
end

function normalize(v,s)
local l=s/sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3])
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
--local qv=vradq({orot.x,orot.y,orot.z,rview.x,rview.y,rview.z},1/128)
local qv=vradq({orot.x,orot.y,orot.z},1/128)
local vtx=o.vt
local orot=o.rt
vs=tmap(cat({},vtx),function(v,i)
local q,vx,vy,vz=vrolq({0,v[1],v[2],v[3]},qv)

v=cat({},{
vx*zr*oscl.w
,vy*zr*oscl.h
,vz*zr,v[4]
,i=i
})
vt[v.i]=v
return v
end)
tmap(vs,function(v,i)
--if #tr>2 then
--v.s=v[3]+vtx[v.i-1][3]+vtx[v.i-2][3]
v.s=i>2 and v[3]+vs[i-1][3]+vs[i-2][3] or 0
end)

quicksort(vs,1,#vs)
tmap(vs,function(v,i)
--if #tr>2 then
if v.i>2 then
local c=v[4]
tr=band(v.i,1)==1 and {vt[v.i-2],vt[v.i-1],v} or {v,vt[v.i-1],vt[v.i-2]}
--dbg(v.i..' '..v.s)

local l={lpos.x,lpos.y,lpos.z}
local c,fp=light
(lpal[c]
,cross(
normalize(tr[1],1)
--normalize(vtopsort(tr[1],tr[2],tr[3]),1)
--,cross(
--normalize(vtopsort(tr[1],tr[2],tr[3]),1)
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
if bmch(vfilt,4) then
pelogen_tri
({tr[1][1]*z1+view.x
,tr[1][2]*z1+view.y}
,{tr[2][1]*z2+view.x
,tr[2][2]*z2+view.y}
,{tr[3][1]*z3+view.x
,tr[3][2]*z3+view.y}
,c,fp)
--p01_triangle_163
--(tr[1][1]*z1+view.x
--,tr[1][2]*z1+view.y
--,tr[2][1]*z2+view.x
--,tr[2][2]*z2+view.y
--,tr[3][1]*z3+view.x
--,tr[3][2]*z3+view.y,c,fp)
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
--flip()
--flip()
--flip()
--flip()
--flip()
--flip()
--flip()
--flip()
--dbg(tr[1][2]*z1+view.x)
end
--dbg(join({tr[1][1],tr[2][1],tr[3][1]}, "--"))
--del(tr,tr[1])
end
end)

return vs,vt
end
-->8
--trifill

--function pelogen_sort(v1,v2,v3,v)
--if(v1[v]>v2[v]) v1,v2=v2,v1
--if(v1[v]>v3[v]) v1,v3=v3,v1
--if(v2[v]>v3[v]) v3,v2=v2,v3
--return flr(v1[1]),flr(v2[1]),v3[1],flr(v1[2]),flr(v2[2]),v3[2]
--end
----function pelogen_tri(v1,v2,v3,col,fp)
--function pelogen_tri(v1,v2,v3,col)
--color(col)
----fillp(fp)
--
----local f=textured and tline or rect
--local l,c,r,t,m,b=pelogen_sort(v1,v2,v3,2)
--if abs(r-l)>abs(b-t) then
--v1,v2,v3=l,t,0
--
--local j=(r-l)/(b-t)
--while t~=b do
--local i=(c-l)/(m-t)
--if(t<0) t,l,v1,v3=0,l-i*t,v1-j*(t-v3),m
--for t=t,min(m-1,127) do
--rectfill(l,t,v1,t)
--l+=i
--v1+=j
--end
--c,l,t,m=r,c,m,b
--end
--else
--l,c,r,t,m,b=pelogen_sort(v1,v2,v3,1)
--v1,v2,v3=l,t,0
--local j=(b-t)/(r-l)
--while l~=r do
--local i=(m-t)/(c-l)
--if(l<0) l,t,v2,v3=0,t-i*l,v2-j*(l-v3),c
--for l=l,min(c-1,127) do
--rectfill(l,t,l,v2)
--t+=i
--v2+=j
--end
--m,t,l,c=b,m,c,r
--end
--end
--end

--function pelogen_tri_178(v1,v2,v3,col)
function pelogen_tri(v1,v2,v3,col,fp)
color(col)
fillp(fp)
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

--function pelogen_tri_152(v1,v2,v3,col)
--color(col)
--if(v1[2]>v2[2]) v1,v2=v2,v1
--if(v1[2]>v3[2]) v1,v3=v3,v1
--if(v2[2]>v3[2]) v3,v2=v2,v3
--local l,c,r,t,m,b=v1[1],v2[1],v3[1],flr(v1[2]),flr(v2[2]),v3[2]
--
--local i,j,k=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m)
--r=l
--while t~=b do
--for t=t,min(m-1,127) do
--rectfill(l,t,r,t)
--r+=j
--l+=i
--end
--l,t,m,i=c,m,b,k
--end
--end

--function pelogen_tri_172(v1,v2,v3,col)
--function pelogen_tri(v1,v2,v3,col)
--color(col)
--if(v1[2]>v2[2]) v1,v2=v2,v1
--if(v1[2]>v3[2]) v1,v3=v3,v1
--if(v2[2]>v3[2]) v3,v2=v2,v3
--local l,c,r,t,m,b=v1[1],v2[1],v3[1],flr(v1[2]),flr(v2[2]),v3[2]
--
--local j,v2,v3=(r-l)/(b-t),l,0
--
--while t~=b do
--local i=(c-l)/(m-t)
--if(t<0) t,l,v2,v3=0,l-i*t,v2-j*(t-v3),m
--for t=t,min(m-1,127) do
--rectfill(l,t,v2,t)
--l+=i
--v2+=j
--end
--c,l,t,m,i=r,c,m,b,k
--end
--end

poke(0x5f38,0)
poke(0x5f39,0)



__gfx__
00000000000000000000000000000000007000000888880000000000000000000070000000700000007000007070000007070000077700007777000077770000
00070000077777000077077000077700070777000877780000000000000000000000000007000000070000000707000070770000707700007077000077770000
00b0c0000700070007000700000700000700007088b7c88000000000000000007000000070000000707000007070000077070000770700007777000077770000
0b000c00070007000700070007070700070007008b000c8000000000000000000000000000070000070700000707000070700000777000007770000077770000
0d605d00070007000700070007000700700007008d605d8000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddddd00077777007707700000777000077707008ddddd8000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000070008888888000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000288e0000288800008888000000000000000000000000000000000f010ff10070007000700070007000707070707007070707077707777777777777777777
0112499a011149991111999900000000000000000000000000000000ff00fff00000000007000700070007000707070770777077707770777077707777777777
122d9aa712229aaa2222aaaa00000000000000000000000000000000000000007000700070007000707070707070707077077707770777077777777777777777
133b3bb713333bbb3333bbbb00000000000000000000000000000000000000000000000000070007070707070707070770707070777077707770777077777777
244fdcc72444dccc4444cccc00000000000000000000000000000000000000000070007000700070007000707070707007070707077707777777777777777777
15565dd615555ddd5555dddd00000000000000000000000000000000000000000000000007000700070007000707070770777077707770777077707777777777
56678eef56668eee6666eeee00000000000000000000000000000000000000007000700070007000707070707070707077077707770777077777777777777777
6777eff76777efff7777ffff00000000000000000000000000000000000000000000000000070007070707070707070770707070777077707770777077777777
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
11111111111111888811111111111111848c829c874c862c00000000c4ca44ca0000000000000000000000000000000000000000000000000000000000000000
11111111111111888811111111111111727c927d874c874c00000000ccca4cca0000000000000000000000000000000000000000000000000000000000000000
11111111111111888811111111111111848c927c896c8c6c000000004c4a44ca0000000000000000000000000000000000000000000000000000000000000000
11111111111111888811111111111111829c848c8c6c8d4c00000000444ac4ca0000000000000000000000000000000000000000000000000000000000000000
111111111199997777ffff1111111111848c848c7e6c9e6d00000000c44acc4a0000000000000000000000000000000000000000000000000000000000000000
111111111199997777ffff1111111111867c874c8c6c8d4c00000000444a4c4a0000000000000000000000000000000000000000000000000000000000000000
111111111199997777ffff1111111111874c862c8c6c8c6c000000004c4acc4a0000000000000000000000000000000000000000000000000000000000000000
111111111199997777ffff1111111111782c982d8b8c8cac00000000cccac4ca0000000000000000000000000000000000000000000000000000000000000000
111111aaaa777777777777eeee1111118cac8eac87cc87cc00000000000000000000000000000000000000000000000000000000000000000000000000000000
111111aaaa777777777777eeee1111117dcc9dcd869c848c00000000000000000000000000000000000000000000000000000000000000000000000000000000
111111aaaa777777777777eeee1111118cac8eac0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111aaaa777777777777eeee1111118cac8cac0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111bbbb7777dddd111111111189ac87cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111bbbb7777dddd111111111187cc88ec0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111bbbb7777dddd111111111176ec96ed0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111bbbb7777dddd111111111187cc88ec0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111cccc11111111111111000000000000000000000000d8deb86e586d586d000000008f834d8300000000886b457b000000000000000000000000
11111111111111cccc111111111111110000000000000000000000008a8ec49e8a8d28de000000005e838f83000000008d8b88ab000000000000000000000000
11111111111111cccc11111111111111000000000000000000000000c49da67d00000000000000008f83cc8300000000c59b8d8b000000000000000000000000
11111111111111cccc111111111111110000000000000000000000008a8da05e0000000000000000be838f8300000000887b838b000000000000000000000000
11111111111111111111111111111111000000000000000000000000a05d845d00000000000000008f837b83000000004bbb889b000000000000000000000000
111111111111111111111111111111110000000000000000000000008a8d605e00000000000000006b83888300000000838bcb5b000000000000000000000000
11777717777117771177771111177771000000000000000000000000667d667d00000000000000006b837b8300000000888b888b000000000000000000000000
177177117711771117717711111711710000000000000000000000008a8d449e00000000000000008f83000000000000dacb384b000000000000000000000000
17777711771177111771771771777771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17711111771177111771771111771171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17711117777177771777711111777771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11116616616666111166661111666611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111616616166111111661111616611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111616616166111166111111616611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111666116666166166661661666611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000729c848c478c287c00000000727c848c874c982c00000000eadeba6e5a6d5a6d000000008f834d8300000000886b457b000000000000000000000000
00000000929c927c267c289c00000000729c929c962c782d000000008d8ed59e8d8d1ade000000005e838f83000000008d8b88ab000000000000000000000000
00000000729c727c478c478c00000000727d927d874c874c00000000d59da87d00000000000000008f83cc8300000000c59b8d8b000000000000000000000000
00000000848c927c698c6c8c00000000848c929c896c8c6c000000008d8da15e0000000000000000be838f8300000000887b838b000000000000000000000000
00000000848c848c6c8c4d9c00000000848c848c8c6c7d4c00000000a15d865d00000000000000008f837b83000000004bbb889b000000000000000000000000
00000000768c478c6e9c6e7c00000000867c874c7e6c9e6d000000008d8d615e00000000000000006b83888300000000838bcb5b000000000000000000000000
00000000478c267c6c8c4d7c00000000874c962c8c6c9d4c00000000687d687d00000000000000006b837b8300000000888b888b000000000000000000000000
00000000269c289c4d9c6e7c00000000762c782d7d4c9e6d000000008d8d359e00000000000000008f83000000000000dacb384b000000000000000000000000
000000006c8c6c8cc78ce89c000000008c6c8c6c87cc78ec00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008b8cac8ce69ce67c000000008b8c8cac76ec96ed00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ac8cae7cc78ce87c000000008cac9eac87cc98ec00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ae9ccd9ce89ce67c000000007eac7dcd78ec96ed00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ac8ccd7cc78cc78c000000008cac9dcc87cc87cc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ae7ccd9c968c848c000000009eac7dcd869c848c00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ac8cac8c00000000000000008cac8cac0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a98cc78c000000000000000089ac87cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001889f8894a19fa19000000001889f8891884f884000000000889f8890369088900000000000000000000000000000000000000000000000000000000
000000001283e2831b49eb49000000001289f2891829f829000000000289f289f369f88900000000000000000000000000000000000000000000000000000000
000000004169f1691c43ec43000000004179c1794919c91900000000f289d1890000000000000000000000000000000000000000000000000000000000000000
000000001459e4594e59fe59000000001364f3641a34fa3400000000d289a1890000000000000000000000000000000000000000000000000000000000000000
000000001443e4431d89ed89000000001884f8841884f88400000000a28982890000000000000000000000000000000000000000000000000000000000000000
000000004529f5291e83ee83000000001449f4491c49fc4900000000628961890000000000000000000000000000000000000000000000000000000000000000
000000001839e8394fa9ffa9000000004429c4294e49ce4900000000228921890000000000000000000000000000000000000000000000000000000000000000
000000001823e8231cb9ecb9000000001634f6341d64fd6400000000028902890000000000000000000000000000000000000000000000000000000000000000
000000001cc3ecc31489f489000000001884f8841884f88400000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004be9fbe900000000000000001e89fe8918e9f8e900000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000018d9e8d900000000000000004f99cf9947f9c7f900000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000018e3e8e300000000000000001da4fda416d4f6d400000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000046f9f6f900000000000000001884f8841884f88400000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000015c9e5c900000000000000001cc9fcc914c9f4c900000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000014c3e4c300000000000000004ce9cce942b9c2b900000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000042b9f2b900000000000000001ad4fad414a4f4a400000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000018830000000000006b37ab37653576050000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008887c835483658060000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a53765367a0588860000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088854837888686d60000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006b357a0586d6a3d60000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ab369a0663d886d80000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c835b80586d84cd90000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a53696064cd929d90000000000000000
00000000247328832479288300000000188318831883188300000000f883e493f883f74300000000000000000000000069d94cd9000000000000000000000000
000000002493e8831743e883000000002493f8832743f88300000000188324931883174300000000000000000000000069d969d9000000000000000000000000
00000000e493e473e743e94300000000e493e473e743e943000000002471116419411a14000000000000000000000000a9daa9da000000000000000000000000
00000000e1692479ea19294900000000f1692479fa19294900000000e479f169f949fa19000000000000000000000000ccdae9da000000000000000000000000
00000000116924992a19261900000000116911a91a19161900000000f1a91169f6191a19000000000000000000000000a9daccda000000000000000000000000
0000000011a9e499ea19e61900000000f169f1a9fa19f6190000000011a9249416191744000000000000000000000000e9daa9da000000000000000000000000
00000000f1a9e169e749261900000000e49911a9e749161900000000f1a9e499f619f74900000000000000000000000000000000000000000000000000000000
0000000011a911691749294900000000249924792749294900000000e479f883f949f88300000000000000000000000000000000000000000000000000000000
00000000288300000000000000000000188318831883188300000000f883fc73f883f9c300000000728874887669746996879887986d9a6d838a678a278a678a
000000000000000000000000000000002c73f88329c3f8830000000018831c73188319c3000000009288948876897489b687b887988d9a8da78aa78a678a838a
00000000000000000000000000000000ec73ec93e9c3e7c3000000001c911fa417c116f4000000009268946874877687d68ed88eb88dba8de78aba8aa78aa78a
00000000000000000000000000000000ffa92c99f6f927c900000000fc99ffa9f7c9f6f9000000007268746894879687d66ed86e988d988dba8aba8aa78ae78a
000000000000000000000000000000001fa91f6916f91af900000000ff691fa9faf916f90000000072887488b48fb68fb66eb86e78879687ce8a8c8aba8aba8a
00000000000000000000000000000000ffa9ff69f6f9faf9000000001f691c741af919c40000000076897489b46fb66fb68eb88e768756878c8a8c8aba8ace8a
00000000000000000000000000000000ec791f69e9c91af900000000ff69fc79faf9f9c90000000056895489946f966fb88dba8d788758874e8a5a8a8c8a8c8a
000000000000000000000000000000002c792c9929c927c900000000fc99f883f7c900000000000056695469948f968fb86dba6d588a568a5a8a5a8a8c8a4e8a
00000000000000000000000000000000188300000000000000000000000000000000000000000000388a368a7a8b588b9a8c9c8c000000005a8a5a8a00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000386a366a5a8b788b9a6c9a6c00000000678a278a00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000586a566a788b7a8794677a6700000000678a000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000588a568a98879a8774677667000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000588b588b9a8c9c8c76675667000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000005a8b586b9a6c9c6c5867b667000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000005a6b786b7a6c7c6cb8670000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000007a6b788b7a8c7c8c00000000000000000000000000000000
__label__
111f11111111fff11111fff11111fff11111111111111111111111111111111111111111111bbb11111111111111111111111111111111111111111111111111
11fff1111111f1f11111f1f11111f1f11111111111111111111111111111111111111111111bb311116111111111111111111111111111111111111111111111
fffffff11111f1f11111f1f11111f1f11111111111111111111111111111111116111111111b3b11111111116111111111111111111111111111111111111111
1fffff111111f1f11111f1f11111f1f111111111111111111111111111111111161111111111b111111111111111111111111111111111111111111111111111
1f111f111111fff11111fff11111fff11111111111111111111111111111111111111161111b1111111111161111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111b1111111111161111111111111111111111111111111111111111
1eeeee1111111111e1e11111eee11111eee1111111111111111111111111111161111611111b1111161111111111111111111111111111111111111111111111
ee111ee111111111e1e1111111e11111e1e1111111111111111111111111111161111611111b1111161111111111111111111111111111111111111111111111
ee1e1ee15555eee5eee5555555e55555e5e555555555555555555555555555555555555555b55555555555655555555555555555555555555555555511111111
ee111ee15555555555e5555555e55555e5e555555555555555555555555555565555555555b55555555555655555555555555555555555555555555511111111
1eeeee115555555555e5555555e55555eee555555555555555555555555555555555655555b55555655555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555555555555555655555b55555655555555555555555555555555555555555555511111111
11d111115555dd5555555555ddd555555555dd555555555555555555555555565555555555b55555555555555555555555555555555555555555555511111111
11dddd1155555d5555555555d555555555555d55555555555555555555555565555655555b555556555555555555555555555555555555555555555511111111
11ddd11155555d555555ddd5ddd55555ddd55d55555555555555555555555555555555555b555555555556555555555555555555555555555555555511111111
1dddd11155555d555555555555d5555555555d55555555555555555555555555555555555b555555555556555555555555555555555555555555555511111111
1111d1115555ddd555555555ddd555555555ddd5555555555555555555555565555655555b555556555555555555555555555555555555555555555511111111
111111115555555555555555555555555555555555555555555555555555555555565555b5555565555555555555555555555555555555555555555511111111
111111115555555555555555555555555555555555555555555555555555565555555555b5555555555565555555555555555555555555555555555511111111
1111111155555555555555555555555555555555555555555555555555555655555555aaa5555555555565555555555555555555555555555555555511111111
111111115555555555555555555555555555555555555555555555555555555555655aaaaa555565555555555555555555555555555555555555555511111111
111111115555555555555555555555555555555555555555555555555555555555655aaaaa555565555655555555555555555555555555555555555511111111
111111115555555555555555555555555555555555555555555555555555655556555aaaaa555655555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555555555555555555555555556555565555aaa5555655555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555555555555555559995555555555655555555555555555555555555555555555511111111
111111115555555555555555555555555555555555555555555555555555555555555a9995555555556555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555555555555655999995556555555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555555555556555999a99556555555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555555655555559999999555555556555555555555555555555555555555555555511111111
111111115555555555555555555555555555555555555555555555555556555555999a999a555555556555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555555555556599999999555555565555555555555555555555555555555555555511111111
1111111155555555555555555555555555555555555555555555555555555555599a999a99555555565555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555556555569999999999965555555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555556555569a999a999a965555555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555565555599999999999955555565555555555555555555555555555555555555511111111
111111115555555555555555555555555555555555555555555555555655555a999a999a99955555655555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555555555999999999999955555555555555555555555555555555555555555555511111111
1111111155555555555555555555515555555555555555555555555555555a999a999a999a995555555555555555555555555555555555555555555511111111
11111111555555555555555555555511555555555555555555555555655559999999999999995555655555555555555555555555555555555555555511111111
111111115555555555555555555555551155555555555555555555556555999a999a999a999a5555555555555555555555555555555555555555555511111111
11111111555555555555555555555555551155555555555555555555555999999999999999995556555555555555555555555555555555555555555511111111
1111111155555555555555555555555555551155555555555555555555599a999a999a999a995556555555555566556655665566556655665555555511111111
11111111555555555555555555555555555555155555565566556655669999999999999999999655665566556555555555555555555555555555555511111111
11111111555555555555555566556655665566511655655555555555599a999a999a999a999a9555555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555115555555555556599999999999999999999565555555555555555555555555555555555555555511111111
111111115555555555555555555555555555555555511555555555569a999a999a999a999a999565555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555511555555555999999999999999999999555555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555555555555515555555a999a999a999a999a999aaaa5555555555555555555555aaa555555555555555511111111
1111111155555555555555555555555aaa5555555555555511555aaa9999999999999999999a995a55555555555555555555a555a55555555555555511111111
111111115555555555555555555555a555a55555555555555511a599aa999a999a999a999a9a9aaaaaaaaaaaaaaaaaaaaaaaaaa6a56655555555555511111111
111111115555555555555655665566a5ccccccccccccccccccccacc5a65566556b555555555a5aaaaaaaaaaaaaaaaaaaaaaaaa55a55555555555555511111111
111111115555555555555555555555a5aaaaaaaaaaaaaaaaaaaaaa15a55555555b5555555555aaaaaaaaaaaaaaaaaaaaaaaaaaaa555555555555555511111111
1111111155555555555555555555555aaaaaaaaaaaaaaaaaaaaaaaaa155655555b55555655555aaaaaaaaaaaaaaaaaaaaaaa5555555555555555555511111111
111111115555555555555555555555555aaaaaaaaaaaaaaaaaaaa55551155555b555556555555aaaaaaaaaaaaaaaaaaaaaa55555555555555555555511111111
1111111155555555555555555555555555aaaaaaaaaaaaaaaaaa56555551155fff55555555556aaaaaaaaaaaaaaaaaaaaa555555555555555555555511111111
11111111555555555555555555555555555aaaaaaaaaaaaaaaaa6555555551f5b5f5555555556aaaaaaaaaaaaaaaaaaaa5555555555555555555555511111111
11111111555555555558885555555555555aaaaaaaaaaaaaaaa5555555655f51b55f556555555aaaaaaaaaaaaaaaaaaa55555555555555555555555511111111
111111115555555555588288888888888888aaaaaaaaaaaaaaa8888888888f8b118f8888888888aaaaaaaaaaaaaaaa8888888888888855555555555511111111
111111115555555555582855555555555555aaaaaaaaaaaaaa55655556557f5b551f5655555555aaaaaaaaaaaaaaa55555555555555555555555555511111111
1111111155555555555555555555555555555aaaaaaaaaaaaa555555565757f755f51155555555aaaaaaaaaaaaaa555555555555555555555555555511111111
1111111155555555555555555555555555555aaaaaaaaaaaa55655555557555fff555511555655aaaaaaaaaaaaa5555555555555555555555555555511111111
11111111555555555555555555555555555555aaaaaaaaaaa55655555557555755555555155655aaaaaaaaaaaa55555555555555555555555555555511111111
11111111555555555555555555555555555555aaaaaaaaaa55555555657555b755556555511555aaaaaaaaaaa555555555555555555555555555555511111111
111111115555555555556655665566556655665aaaaaaaaa66556655665777b755556555555115aaaaaaaaaa5555555555555555555555555555555511111111
111111115555555555555555555555555555555aaaaaaaa5556555555555557675665566556651aaaaaaaaa65566556655665566556555555555555511111111
1111111155555555555555555555555555555555aaaaaaa555655555555555b555555555556555aaaaaaaa555555555555555555555555555555555511111111
1111111155555555555555555555555555555555aaaaaa555555555555555b5555555555565555aaaaaaa5555555555555555555555555555555555511111111
11111111555555555555555555555555555555555aaaaa555555555555555b5555555555565555aaaaaa55555555555555555555555555555555555511111111
111111115555555555555555555555555555555555aaa5555555555655555b5555565555555555aaaaa511555555555555555555555555555555555511111111
111111115555555555555555555555555555555555aaa5555555555655555b555556555555555aaaaa5555115555555555555555555555555555555511111111
11111111555555556655665566556655665566555a5a5a555655555555555b55555555555655a5aaa55555551555555555555555555555555555555511111111
11111111555555555555555555555555555555556a576a55665566556655b655665566556655a675a65555555115555555555555555555555555555511111111
11111111555555555555555555555555555555555a577a55555555655555b555556555555555a7a5a55655665561156655665566555555555555555511111111
111111115555555555555555555555555555555555aaa755555555655555b5555565555555577aaa555555555555511555555555555555555555555511111111
11111111555555555555555555555555555555555577a775655555555555b555555555556577a77555555555555555511cc55555555555555555555511111111
11111111555555555555555555555555555555555777777765555655555b555556555555777777755555555555555555ccc55555555555555555555511111111
111111115555555555555555555555555555555557a777a775555555555b55555555555777a777a55555555555555555cc155555555555555555555511111111
11111111555555555555555555555555555555557777777777555555555b55555555577777777775555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555555a777a777a7755655555b55555655a777a777a775555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555557777777777756555555b55555677777777777775555555555555555555555555555555555555555511111111
111111115555555555555555555555555555555777a777a777a7555555b5555557a777a777a777a5555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555557777777777777755555b555577777777777777775555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555577a777a777a777a75555b55577a777a777a777a775555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555577777777777777777555b577777777777777777775555555555555555555555555555555555555555511111111
11111111555555555555555555555555555557a777a777a777a777a7aaa777a777a777a777a777a5555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555777777777777777777a777a77777777777777777775555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555777a777a777a777a77aa77aa777a777a777a777a775555555555555555555555555555555555555555511111111
1111111155555555555555555555555555557777777777777777777a5b7a77777777777777777775555555555555555555555555555555555555555511111111
11111111555555555555555555555555555577a777a777a777a77755aaa777a777a777a777a777a5555555555555555555555555555555555555555511111111
11111111555555555555555555555555555777777777777777775555b55557777777777777777775555555555555555555555555555555555555555511111111
111111115555555555555555555555555557a777a777a777a7555555b5555577a777a777a777a775555555555555555555555555555555555555555511711111
11111111555555555555555555555555557777777777777755555555b5555557777777777777777555555555555555555555555555555555555555551b111111
1111111155555555555555555555555555a777a777a7775555555555b555556557a777a777a777a55555555555555555555555555555555555555555b1111111
1111111155555555555555555555555557777777777755555555555b5555555555777777777777755555555555555555555555555555555555555555b11bb111
111111115555555555555555555555555777a777a75555555655555b555556555557a777a777a7755555555555555555555555555555555555555555bbbbb111
1111111155555555555555555555555557777777555555555655555b555556555555777777777775555555555555555555555555555555555555555511111111
1111111155555555555555555555555577a77755555655555555555b55555555555655a777a777a5555555555555555555555555555555555555555517777111
111111115555555555555555555555aaa777555555655555555555b5555555555556555777777775555555555555555555555555555555555555555517bb7111
11111111555555555555555555555a57aa55555555555555655555b55555655555555555a777a7755555555555555555555555555555555555555555177b7111
11111111555555555555555555555a575a55555555555555655555b55555655555555555557777755555555555555555555555555555555555555555117b7111
11111111555555555555555555555a555a55555555655555555555b5555555555565555555577aaa5555555555555555555555555555555555555555177b7711
111111115555555555555555555555aaa555555555555556555555b555555555556555555555a775a55555555555555555555555555555555555555517bbb711
11111111555555555555555555555555555555555655555555555b5555555555555555555555a775a55555555555555555555555555555555555555517777711
11111111555555555555555555555555555555555655555555555b5555555555565555555555a555a55555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555655555b55555655555555555555555aaa555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555556555555b55555655555555555555555555555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555555655555555555b555555555555655555555555555555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555555655555555555b555555555556555555555555555555555555555555555555555555555555555555511111111
1111111155555555555555555555555555555555555555555555b555556555555555555555555555555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555511111111
11111111555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555511111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa000000000000000000000000000000000000000
05000000011110000222211003333110044442200555511006666550077776600888822009999440aaaaa990abbbb3300ccccdd00dddd5500eeee8800ffffee0
00000000011111100222222003333330044444400555555006666660077777700888888009999990aaaaaaa0abbbbbb00cccccc00dddddd00eeeeee00ffffff0
00000000011110000222211003333110044442200555511006666550077776600888822009999440aaaaa990abbbb3300ccccdd00dddd5500eeee8800ffffee0
00000000011111100222222003333330044444400555555006666660077777700888888009999990aaaaaaa0abbbbbb00cccccc00dddddd00eeeeee00ffffff0
00000000011110000222211003333110044442200555511006666550077776600888822009999440aaaaa990abbbb3300ccccdd00dddd5500eeee8800ffffee0
00000000011111100222222003333330044444400555555006666660077777700888888009999990aaaaaaa0abbbbbb00cccccc00dddddd00eeeeee00ffffff0
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa000000000000000000000000000000000000000

__map__
4040404040404040404040404040404040414243404142434041424340414243000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404050515253505152535051525350515253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404060616263606162636061626360616263000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404070717273707172737071727370717273000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040414243404142434041424340414243000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404050515253505152535051525350515253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404041424340404040404060616263606162636061626360616263000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040405051525340404040404070717273707172737071727370717273000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040406061626340404040404040414243404142434041424340414243000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040407071727340404040404050515253505152535051525350515253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404060616263606162636061626360616263000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404070717273707172737071727370717273000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040414243404142434041424340414243000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404050515253505152535051525350515253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404060616263606162636061626360616263000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404070717273707172737071727370717273000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
