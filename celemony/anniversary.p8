pico-8 cartridge // http://www.pico-8.com
version 37
__lua__
function tonorm(s)
if tonum(s) then return tonum(s)
elseif s=='true' then return true
elseif s=='false' then return false
elseif s=='nil' then return nil
end
return s
end

function tohex(p,n)
p=sub(tostr(tonum(p),1),3,6)
while sub(p,1,1)=='0' do
p=sub(p,2)
end
p=join(tbfill(0,(n or 0)-#p),'')..p
return p
end

function ttoh(h,l,b)
return bor(shl(tonum(h),b),tonum(l))
end
function htot(v)
return {lshr(band(v,0xff00),8),band(v,0xff)}
end

function replace(s,f,r)
local a,i='',1
while i<=#s do
if sub(s,i,i+#f-1)~=f then
a..=sub(s,i,i)
i+=1
else
a..=r or ''
i+=#f
end
end
return a
end

function toc(v,p)
return flr(v/(p or 8))
end

function join(s,d)
local a=''
for i,v in pairs(s) do
a=a..v..d
end
return sub(a,1,-1-#d)
end

_split,split=split,function(str,d,dd)
if dd then
local a,str={},split(str,dd)
while str[1] do
add(a,split(deli(str,1),d))
end
return a
end
return _split(str,d or ' ',false)
end

_bc={}
function htd(b,n)
local d={}
n=n or 2
for i=1,#b,n do
add(d,tonum('0x'..(sub(b,i,i+n-1))))
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

function comb(k,p)
local a={}
for i=1,#k do
a[k[i]]=p[i]
end
return a
end

function tbfill(v,n,r)
local t={}
if r and r>0 then
n,r=r,n
end
for i=0,n-1 do
t[i]=r and tbfill(v,r) or v
end
return t
end

function ecxy(p,f)
p=rfmt(p)
for y=p.y,p.ey do
for x=p.x,p.ex do
f(x,y,p)
end
end
end

function outline(t,a)
local i,j,k,l=unpack(split(a))
ecxy('-1 -1 3 3',function(x,y)
?t,x+i,y+j,l
end)
?t,i,j,k
end

function tmap(t,f)
for i,v in pairs(t) do
t[i]=f(v,i) or t[i]
end
return t
end

function mkpal(f,t)
return comb(htd(f,1),htd(t,1))
end
function ecmkpal(v)
return tmap(v,function(v,i)
i,v=unpack(v)
return tmap(v,function(v)
return mkpal(_ENV[i],v)
end)
end)
end
function ecpalt(p)
for i,v in pairs(p) do
if v==0 then
palt(i,true)
end
end
end

function ttable(p)
return type(p)=='table' and p
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


function htbl(ht,c)
local t,k,rt={}
ht,c=split(ht,'') or ht,c or 1
while ht[c] do
local p=ht[c]
c+=1
if p=='{' or p=='=' then
rt,c=htbl(ht,c)
if rt then
if p=='=' then
t[k]=rt[1]
elseif k then
t[k]=rt
else
add(t,rt)
end
end
k=nil
elseif p=='}' or p==';' then
add(t,tonorm(k))
k=nil
return t,c
elseif p==' ' then
add(t,tonorm(k))
k=nil
elseif p~="\n" then
k=(k or '')..p
end
end
add(t,tonorm(k))

return t
end

mkrs,hovk,_mnb=htbl'x y w h ex ey r p'
,htbl'{x y}{x ey}{ex y}{ex ey}'
,htbl'cont hover ud rs rf cs cf os of cam'
function rfmt(p)
local x,y,w,h=unpack(ttable(p) or _split(p,' ',true))
return comb(mkrs,{x,y,w,h,x+w-1,y+h-1,w/2,p})
end

function exrect(p)
local o=rfmt(p)
return cat(o,comb(_mnb,{
function(x,y)
if y then
return inrng(x,o.x,o.ex) and inrng(y,o.y,o.ey)
else
return o.cont(x.x,x.y) and o.cont(x.ex,x.ey)
end
end
,function(r,p)
local h
for i,v in pairs(hovk) do
h=h or o.cont(r[v[1]],r[v[2]])
end
return h or p==nil and r.hover(o,true)
end
,function(p,y,w,h)
return cat(
o,rfmt((tonum(p) or not p) and {p or o.x,y or o.y,w or o.w,h or o.h} or p
))
end
,function(col,f)
local c=o.cam
f=(f or rect)(o.x-c.x,o.y-c.y,o.ex-c.x,o.ey-c.y,col)
return o
end
,function(col)
return o.rs(col,rectfill)
end
,function(col,f)
(f or circ)(o.x+o.r-o.cam.x,o.y+o.r-o.cam.y,o.w/2,col)
return o
end
,function(col)
return o.cs(col,circfill)
end
,function(col)
return o.rs(col,oval)
end
,function(col)
return o.rs(col,ovalfill)
end
,{x=0,y=0}
}))
end

-->8

-->8

-->8
function _init()
b,c={peek(0,8)},0::_::cls(1)
golc=0
golp=mkpal(stf,golp)
rrr=exrect('0 0 0 0')
end

function _update60()
if golc%8==0 then
add(golp,deli(golp,2))
end
golc+=1

end

function _draw()
cls(15)
e,f,g,h=unpack(b)
b[4]+=2
c+=1for i=1,5 do
--b[i]+=btn(i-1) and 1 or 0
srand(i)i=c-rnd(1024)
srand(i/20&0xffff)
x,y,r=(rnd(127)+f-e)%128,(rnd(127)+h-g)%128,sin(i/40)*8
circ(x,y,r,4)
oval(x-r,y,x+r,y,10)
oval(x,y-r,x,y+r)
circfill(x,y,r/2,7)
end
--flip()
--goto _

local mul=1
plgn_render(1
,{64,64,96}
,{time()*8,sin(time()/1.6)*1.3,sin(time()/1.6)*0.1}
,{mul,mul,mul}
)
?'pelogen @) shiftalow/bitchunk',0,120,14
fillp()

local t1,t2='● konsairi ●'
,'    ♥ 2ND anniversary ♥'
local x,y,h=
128-(golc*0.5)%(((#t1+#t2+4)*8+128)*1)
,sin(time()/2)*2+96
,8
--local x,y,h
--=flr(o.rate('16 4',20))
--,min(o.rate('256 -16',50,o.cnt-200),72)
--,flr(mid(o.rate('0 8',16,o.cnt-80),0,8))
rrr.ud(-1,y-5,130,19).rf(7).
ud(nil,y-4,nil,18).rs(2)
pal(golp)

--outline("\^p\^t\^w\^x"..tohex(x).."\^y"..5-h..'perfect!',join({65-8*x,y+h*2,2,10},' '))
local c,d=1,2
outline(
"\^t\^w\^x4\^y"..max(h-2,0)..t1
.." \|h\^p\^t\^w\^x4".."\^y9"..t2
,join({x,y,2,10},' '))
c,d=d
--outline("\|h\^p\^t\^w\^x4".."\^y9"..'perfect!',join({65-8*x,y,2,10},' '))
pal()
spr(golc%240>236 and 12 or golc%240>232 and 8 or 4,8,y-36,4,4,false,false)
spr(32,8+10,y-36+6,4,4,false,false)
end

-->8

--generated by pelogen
--@shiftalow/bitchunk
--v_ex0.2.3
--**color palette for light**--
--[gfx]080800000248000102490012249a0123013b012401dc0015015d15d6248e156724ef[/gfx]
--**cut & paste to sprite sheet**--
cpalid=1--sprite id as a color palette

rfp={0x0000,0x2080,0x2481,0x24a5,0xa5a5,0x5bda,0x7bde,0xfbfe}
function plgn_load(r)
lpos=normalize(40,-40,00)
gvtx={}
vtxs={}
prspx=4
prspy=4
prspz=4
culr=1
lfrom,lto,llen=0,3,4
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
x=x*4+l
if sget(x,y)~=0 then
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

function light(c,r)
local s=mid(r*llen,lfrom,lto)
return c>>>flr(s)*4&0xff,rfp[mid(1,8,flr((s&0x.ffff)*7)+1)]
end

function dot(v1,v2)
	return v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3]
end

function cross(v1,v2)
return v1[2]*v2[3]-v1[3]*v2[2],v1[3]*v2[1]-v1[1]*v2[3],v1[1]*v2[2]-v1[2]*v2[1]
end

function normalize(x,y,z)
local l=1/sqrt(x*x+y*y+z*z)
return {x*l,y*l,z*l}
end

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
	local v1,v2,v3
		if band(v.i,1)==1 then
		v1,v2,v3=vt[v.i-2],vt[v.i-1],v
		else
		v1,v2,v3=v,vt[v.i-1],vt[v.i-2]
		end
	
	local x1,y1,z1=v1[1],v1[2],v1[3]
	local x2,y2,z2=v2[1],v2[2],v2[3]
	local x3,y3,z3=v3[1],v3[2],v3[3]
	local c,fp=light(
	lpal[ v[4] ]
	,dot(lpos
	,normalize(cross(
		normalize(x1-x3,y1-y3,z1-z3)
	,normalize(x2-x3,y2-y3,z2-z3)
	))
	))
	local cull=((x2-x1)*(y3-y1)-(x3-x1)*(y2-y1)<=0 and culr or bnot(culr))>0
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
function quicksort(v,s,e)
if(s>=e)return
local p=s
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

plgn_load({
--paste the gfx code into the sprite sheet.
--[gfx]1808aca88e888948498889484988ac686c686c686ca8777877986c688e88498889c8977897986ca8aca877989798979b777b89c8c98889c8c988858b418baca8ac6897989778777b777bc9888948c9888948858b979bac686c6897787778c18b858b[/gfx]
{16,17,18}
--put the pasted sprite id in an array.
})
-->8
cat(_ENV,htbl[[
stf=0123456789abcdef$;
golp=02242497a97aa49a$;
]])
__gfx__
000000000000288e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000102490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000012249a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000123233b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000012401dc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000015015d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000015d6248e0000000000000000000000000000995000000995000000000000000000009950000009950000000000000000000099500000099500000000
00000000156724ef0000000000000000000000000009999500009999500000000000000000099995000099995000000000000000000999950000999950000000
aca88e88894849888948498800000000000000000009499500009949500000000000000000094995000099495000000000000000000949950000994950000000
ac686c686c686ca87778779800000000000000000094799950099974950000000000000000947999500999749500000000000000009479995009997495000000
6c688e88498889c89778979800000000000000000097749950099477950000000000000000977499500994779500000000000000009774995009947795000000
6ca8aca877989798979b777b00000000000000000077779995999777750000000000000000777799959997777500000000000000007777999599977775000000
89c8c98889c8c988858b418b00000000000000000097779999999777950000000000000000977799999997779500000000000000009777999999977795000000
aca8ac6897989778777b777b00000000000000000094799999999974950000000000000000947999999999749500000000000000009479999999997495000000
c9888948c9888948858b979b00000000000000000059999999999999500000000000000000599999999999995000000000000000005999999999999950000000
ac686c6897787778c18b858b00000000000000000009999999999999500000000000000000099999999999995000000000000000000999999999999950000000
022ee220000000000000000000000000000000000009611999996119500000000000000000099999999999995000000000000000000999999999999950000000
2aaeeaa2000000000000000000000000000000000009616999996169500000000000000000099999999999995000000000000000000919999999991950000000
2a6226a2000000000000000000000000000000000009611999996119500000000000000000099999999999995000000000000000000991999999919950000000
eed7edee000000000000000000000000000000000099745999567459950000000000000000991119995611199500000000000000009911199956111995000000
88288288000000000000000000000000000000000097777777777777950000000000000000977777777777779500000000000000009777777777777795000000
2a6226a2000000000000000000000000000000000055577747777755500000000000000000555777477777555000000000000000005557774777775550000000
2aa88aa2000000000000000000000000000000000000099447450000000000000000000000000994474500000000000000000000000009944745000000000000
02288220000000000000000000000000000000000000099777745000000000000000000000000997777450000000000000000000000009977774500000000000
00000000000000000000000000000000000000000000009499595000000000000000000000000094995950000000000000000000000000949959500000000000
00000000000000000000000000000000000000044444495999959500000000000000000444444959999595000000000000000004444449599995950000000000
00000000000000000000000000000000000000499999995555995955000000000000004999999955559959550000000000000049999999555599595500000000
00000000000000000000000000000000000004777799955999595959500000000000047777999559995959595000000000000477779995599959595950000000
00000000000000000000000000000000000057777799959999955459950000000000577777999599999554599500000000005777779995999995545995000000
00000000000000000000000000000000000057777499954499955459950000000000577774999544999554599500000000005777749995449995545995000000
00000000000000000000000000000000000057777444995444455544450000000000577774449954444555444500000000005777744499544445554445000000
00000000000000000000000000000000000005544455555555500555500000000000055444555555555005555000000000000554445555555550055550000000
