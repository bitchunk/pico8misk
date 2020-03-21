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
btnc,btns,btrg,butrg=tablefill(0,8),{},{},{}
upsc,upscs=mkscenes(split'm k')
drsc,drscs=mkscenes(split'e d')

zoom=1
scale=1/zoom
aperture=0.9
focusd=8
arad=atan2(1/3,1)

vdist=4
kmap=htbl[[{-1 0} {1 0} {0 -1} {0 1}]]
wasd=htbl[[a d w s]]
view=mkrect[[64 64 128 128]]
--cam=mkrect[[64 64 128 128]]
rview=mkrect[[0 0 128 128]]
opos=mkrect[[0 0 0 0]]
orot=mkrect[[0 0 0 0]]
view.z=64

genab=htbl[[x=true;y=true;z=true;]]
gedef=htbl[[x=true;y=true;z=true;]]

--cam.z=64
opos.z=0
orot.z=0
rview.z=64
--cat(view,htbl[[r{x=0;y=0;z=0;}]])
ldps=3

pspal=tablefill(0,4,16)
ecxy('0 0 4 16',function(x,y)
pspal[y][x]=sget(x,y+32)
end)
--pspal=split[[2 8 14 15]]

scenesbat[[
d st def_d 0
k st def_k 0
]]
--0:1
--1:
caller={
def_d=function(o)
cls(5)
local p=0

v=tablefill(15,3,3,3)

drawo(v,opos.x,opos.y,opos.z)

rectfill(64,64,64,64,7)
spr(keystate[' '] and 1 or 0,mo.x,mo.y)

local qx,qy,qz=vradq(rview,1/128)
local q,x,y,z=rots(128,0,0,qx,qy,qz)
fillp(not keystate['x'] and 0xcc33.8)
line(view.x,view.y,x+view.x,y+view.y,8)
local q,x,y,z=rots(0,128,0,qx,qy,qz)
fillp(not keystate['c'] and 0xcc33.8)
line(view.x,view.y,x+view.x,y+view.y,11)
local q,x,y,z=rots(0,0,128,qx,qy,qz)
fillp(not keystate['z'] and 0xcc33.8)
line(view.x,view.y,x+view.x,y+view.y,12)
fillp()
end
,def_k=function(o)
local b
tmap(kmap,function(v,i)
if btn(i-1) or btn(i-1,1) then
view.x-=kmap[i][1]
view.y-=kmap[i][2]
end
end)

cat(genab,gedef)
if keystate['x'] or keystate['c'] or keystate['z'] then
genab.x=keystate['x']
genab.y=keystate['c']
genab.z=keystate['z']
end

if mo.l then
dragstart(opos)
dragstart(view)
if keystate[' '] then
local x,y=dragdist(view,{x=0,y=0,z=0,})
view.ud(x,y)
else
scale=8
local x,y,z=dragdist(opos,rview)
opos.ud(genab.x and flr(x),genab.y and flr(y))
opos.z=genab.z and flr(z) or opos.z
scale=1
end
end

if mo.r then
dragstart(rview)
dragstart(orot)
if keystate[' '] then
local x,y=dragdist(rview,{x=0,y=0,z=0})
rview.ud(inrng(-x,256,-256) and x or toc(x,abs(x))*256
,inrng(-y,256,-256) and y or toc(y,abs(y))*256)
else
scale=8
--local x,y,z=dragdist(orot,rview)
--orot.ud(x,y)
--orot.z=z

scale=1
end
end

if keystate[' '] then
rview.z-=mo.w*2
else
view.z-=mo.w*2
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
presskey=getkey()
panholdck()

tmap(upscs,function(v)
upsc[v].tra()
end)
end
function _draw()
tmap(drscs,function(v)
drsc[v].tra()
end)

isdebug=true
dbg(join({view.x,view.y,view.z},' '))
dbg(join({rview.x,rview.y,rview.z},' '))
dbg(stat(1))
dbg_print()
end

-->8
--control
mousestate,mousebtns,moky=spread(htbl([[
{l=0;r=0;m=0;stx=0;sty=0;x=0;y=0;}
{m r l}
{x y l r m w sx sy}
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
})

function ambtn()
return mo.lt or mo.rt
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

return mo
end

function dragstart(vw)
if ambtn() then
vw.stx,vw.sty,vw.stz=vw.x,vw.y,vw.z
end
end

function dragdist(vw,rv)

local qx,qy,qz=vradq({x=rv.x,y=rv.y,z=rv.z},1/128)

--local x,y=mo.x-mo.sx,mo.y-mo.sy
--vdmp({x,y,z,vradq({x=x,y=y,z=0},1)})
local x,y=mo.x-mo.sx,mo.y-mo.sy
local q,x,y,z=rots(x,y,0,qx,qy,qz)
return
 x/scale+vw.stx
,y/scale+vw.sty
,-z/scale+vw.stz
--,(mo.z-mo.sz)/scale+vw.stz
-- (mo.x-mo.sx)/scale+(x or vw.x)+vw.stx
--,(mo.y-mo.sy)/scale+vw.sty+(y or vw.y)
--,(mo.z-mo.sz)/scale+vw.stz+(z or vw.z)
--,(mo.z-mo.sz)/scale+vw.stz+(z or vw.z)
--return (mo.x-mo.sx)/scale+(x or vw.x)+vw.stx,(mo.y-mo.sy)/scale+vw.sty+(y or vw.y)
--return (mo.x-mo.sx)/scale+(x or vw.x)-vw.stx,(mo.y-mo.sy)/scale+(y or vw.y)-vw.sty
end

btnstat={}
function statkeys()
local k={}
local i=0
while stat(30) do
k[stat(31)]=true
i+=1
end
--if i>1 then
--cls()
--tmap(k,function(v,i)
--?i
--end)
--stop()
--end
dbg(i)
return k
--tmap(wasd,function(v,i)
--btnstat[i-1]=false
--end)
--stop()
--while stat(30) do
--local d=stat(31)
--tmap(wasd,function(v,i)
--btnstat[i-1]=v==d
--end)
--end
end

function updatekey()
--presskey=stat(31)
btnstat=statkeys()
dbg(#btnstat)
tmap(cat(presskey,btnstat),function(v,i)
--dbg(i)
panholdck(i)
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

function panholdck(k)
k=k or ''
panhold[k]=panhold[k] or 0
panhold[k]+=min(1,panhold[k])
if btnstat[k] then
 keystate[k]=true
 panhold[k]=panhold[k]>1 and 28 or 1
elseif panhold[k]>31 then
 keystate[k]=false
 panhold[k]=0
end
--dbg(panhold[k])
end
--function panholdck(k)
--k=k or ''
--panhold+=min(1,panhold)
--if presskey==k then
-- keystate=presskey
-- panhold=panhold>1 and 28 or 1
--elseif panhold>31 then
-- keystate=''
-- panhold=0
--end
--end
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
add(v,{0,ox+x,oy+y,oz+z,o})
end)
end)
end)

local qx,qy,qz=vradq(rview,1/128)

local v,s=rolzsort({qx,qy,qz},v)
tmap(v,function(p,i)
p[5]=pspal[p[5]][min(ceil((3.2-#v/i)),3)]
drawp(spread(p))
end)
end

function drawp(q,x,y,z,p)

--x=x*view.z/rview.z
--y=y*view.z/rview.z

x=x*rview.z/view.z
y=y*rview.z/view.z
--circfill(x*8+view.x,y*8+view.y,4,p)
circfill(x*8+view.x,y*8+view.y,1,p)
end

function rolzsort(q,v)
local s={}
tmap(v,function(v)
local a,x,y,z,p=spread(v)
--local q,vx,vy,vz=spread(rolq(rolq(rolq({0,x,y,z},q[1]),q[2]),q[3]))
local q,vx,vy,vz=spread(rolq(rolq({0,x,y,z},q[1]),q[2]))
add(s,vz)
--vdmp(q)
return {q,vx,vy,vz,p}
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

function rots(x,y,z,qx,qy,qz)
--return q,x,y,z
return spread(rolq(rolq({0,x,y,z},qx),qy))
end
-->8
--sort	
function pivot(a,i,j)
local k=i+1
while k<=j and a[i][4]==a[k][4] do k+=1 end
if(k>j)return -1
if(a[i][4]>=a[k][4])return i
return k
end

function partition(a,i,j,x)
local l,r=i,j
while l<=r do
while l<=j and a[l][4]<x do l+=1 end
while r>=i and a[r][4]>=x do r-=1 end
if(l>r)break
a[l],a[r]=a[r],a[l]
l+=1
r-=1
end
return l
end

function quicksort(a,i,j)
if(i==j)return
local p=pivot(a,i,j)
if p!=-1 then
--print(join({i,j,#a,p,a[p]},' '))
local k=partition(a,i,j,a[p][4])
quicksort(a,i,k-1)
quicksort(a,k,j)
end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
023b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
124f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d6770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
248f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
249a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14a70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23bf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1dc60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15d60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
28ef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4ef70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
