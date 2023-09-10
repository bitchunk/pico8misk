pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--knutil_0.14.0
--@shiftalow / bitchunk
version='v0.14.0'
--function tonorm(v)
--if v=='false' then return false
--elseif v=='nil' then return nil
--end
--return v=='true' or tonum(v) or v
--end

function tohex(v,d)
v=sub(tostr(tonum(v),1),3,6)
while v[1]=='0' and #v>(d or 0) do
v=sub(v,2)
end
return v
end

function bpack(w,s,b,...)
return b and flr(0x.ffff<<add(w,deli(w,1))&b)<<s|bpack(w,s-w[1],...) or 0
end

function bunpack(b,s,w,...)
if w then
return flr(0x.ffff<<w&b>>>s),bunpack(b,s-(... or 0),...)
end
end

function replace(s,f,r,...)
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
return ... and replace(a,...) or a
end

function toc(v,p)
return flr(v/(p or 8))
end

function join(d,s,...)
return not s and '' or not ... and s or s..d..join(d,...)
end

function msplit(s,d,...)
local t=split(s,d or ' ',false)
if ... then
for i,v in pairs(t) do
t[i]=msplit(v,...)
end
end
return t
end

function htd(b,n)
local a={}
tmap(split(b,n or 2),function(v)
add(a,tonum('0x'..v))
end)
return a
end

function cat(f,...)
foreach({...},function(s)
for k,v in pairs(s) do
if tonum(k) then
add(f,v)
else
f[k]=v
end
end
end)
return f
end

function comb(k,p)
local a={}
for i=1,#k do
a[k[i]]=p[i]
end
return a
end

function tbfill(v,s,e,...)
local t={}
for i=s,e do
t[i]=... and tbfill(v,...) or v
end
return t
end

function rceach(p,f)
p=_rfmt(p)
for y=p.y,p.ey do
for x=p.x,p.ex do
f(x,y,p)
end
end
end

function oprint(s,x,y,f,o,p)
 for v in all(split(p or '\+ff,\+gf,\+hf,\+fg,\+hg,\+fh,\+gh,\+hh,')) do
  ?v..s,x,y,v~='' and o or f
 end
end

function tmap(t,f)
for i,v in pairs(t) do
v=f(v,i)
if v~=nil then
t[i]=v
end
--t[i]=f(v,i) or v
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

function inrng(...)
return mid(...)==...
end

function amid(c,a)
return mid(c,a,-a)
end

function htbl(ht,c)
local t,k,rt={}
ht,c=split(ht,'') or ht,c or 1
while 1 do
local p=ht[c]
c+=1
if p=='{' or p=='=' then
rt,c=htbl(ht,c)
if not k then
add(t,rt)
else
t[k],k=p=='{' and rt or rt[1]
end
elseif not p or p=='}' or p==';' or p==' ' then
if k=='false' then k=false
elseif k=='nil' then k=nil
else k=k=='true' or tonum(k) or k
end
add(t,k)
rt,k=p and c or nil
if p~=' ' then
break
end
elseif p~="\n" then
k=(k or '')..p
end
end
return t,rt
end

_mkrs,_hovk,_mnb=htbl'x y w h ex ey r p'
,htbl'{x y}{x ey}{ex y}{ex ey}'
,htbl'con hov ud rs rf cs cf os of cam'
function _rfmt(p)
local x,y,w,h=unpack(ttable(p) or split(p,' ',true))
return comb(_mkrs,{x,y,w,h,x+w-1,y+h-1,w/2,p})
end

function exrect(p)
local o=_rfmt(p)
return cat(o,comb(_mnb,{
function(p,y)
if y then
return inrng(p,o.x,o.ex) and inrng(y,o.y,o.ey)
else
return o.con(p.x,p.y) and o.con(p.ex,p.ey)
end
end
,function(r,i)
local h
for i,v in pairs(_hovk) do
h=h or o.con(r[v[1]],r[v[2]])
end
return h or i==nil and r.hov(o,true)
end
,function(p,y,w,h)
return cat(
o,_rfmt((tonum(p) or not p) and {p or o.x,y or o.y,w or o.w,h or o.h} or p
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
--scenes
function scorder(...)
local o={}
return cat(o,comb(msplit'rate cnt rm nm dur prm',{
function(d,r,c)
local f,t=unpack(ttable(d) or msplit(d))
r=r or o.dur
return min(c or o.cnt,r)/max(r,1)*(t-f)+f
end
,0,false
,...
}))
end

_scal={}
function mkscenes(keys)
return tmap(ttable(keys) or {keys},function(v)
local o={}
_scal[v]=cat(o,comb(msplit'ps st rm cl fi cu sh us tra ords nm',{
function(...)
return add(o.ords,scorder(...))
end
,function(...)
o.cl()
return o.ps(...)
end
,function(s)
s=s and o.fi(s) or not s and o.cu()
if s then
del(o.ords,s).rm=true
end
return s
end
,function()
local s={}
while o.ords[1] do
add(s,o.rm())
end
return s
end
,function(key)
for v in all(o.ords) do
if v.nm==key or key==v then 
return v end
end
end
,function(n)
return o.ords[n or 1]
end
,function()
local v=o.cu()
return del(o.ords,v)
end
,function(...)
local p=scorder(...)
o.ords=cat({p},o.ords)
return p
end
,function(n)
local c=o.cu(n)
if c then
local n=c.cnt+1
c.cnt,c.fst,c.lst=n==0x7fff and 1 or n,n==1,inrng(c.dur,1,n)
if c.rm or c.nm and _ENV[c.nm] and _ENV[c.nm](c) or c.lst then
o.rm(c)
end
end
end
,{},v
}))
return o
end)
end

function cmdscenes(b,p,...)
return tmap(msplit(replace(b,"\t",""),"\n",' '),function(v)
local s,m,f,d=unpack(v)
return _scal[s] and _scal[s][m](f,tonum(d),p or {}) or false
end)
,... and cmdscenes(...)
end

function transition(v)
 v.tra()
end
-->8
--dmp
function dmp(v,q,s)
	if not s then
	 q,s,_dmpx,_dmpy="\f6","\n",0,-1
	end
	local p,t=s
	tmap(ttable(v) or {v},function(str,i)
		t=type(str)
		if ttable(str) then
			q,p=dmp(str,q..s..i.."{",s.." ")..s.."\f6}",s
		else
		 q..=join('',p,i
		 ,comb(msplit"number string boolean function nil"
		 ,msplit"\ff#\f6:\ff \fc$\f6:\fc \fe%\f6:\fe \fb*\f6:\fb \f2!\f6:\f2"
			)[t],tostr(str),"\f6 ")
			p=""
		end
	end)
	q..=t and "" or s.."\f2!\f6:\f2nil"
	::dmp::
	_update_buttons()
	if s=="\n" and not btnp'5' then
		flip()
		cls()
		?q,_dmpx*4,_dmpy*6
		_dmpx+=_kd'0'-_kd'1'
		_dmpy+=_kd'2'-_kd'3'
		goto dmp
	end
	return q
end

function _kd(d)
return tonum(btn(d))
end


--dbg
function dbg(...)
	local p,d={},{...}
	for i=1,#d do
		if add(p,tostr(d[i]))=='d?' then
			poke(0x5f58,0)
			tmap(_dbgv,function(v,i)
				oprint(join(' ',unpack(v)),0,128-i*8,5,7)
			end)
			_dbgv,p={}
		end
	end
	add(_dbgv,p,1)
end
dbg'd?'
-->8
function flat2n(t)
  return {{t[1], t[2]},{t[3], t[4]}, {t[5], t[6]}, t[7]}
end
flattable={}
ntable={}
col=0xcd
angle = rnd()
angle_inc = 1/256
draw_results = true
draw_wireframe = false
compress_y = 128
compress_x = 128
compress_vertical=true
testfunc = pelogen_tri_o
trifuncs = {
{'pelogen_tri_hvb',"shiftalow(hvb)",flattable}
,{'pelogen_tri_hv',"shiftalow(hv)",flattable}
--,{'pelogen_tri_tclip',"shiftalow(tclip)",flattable}
--,{'pelogen_tri_low',"shiftalow(low)",flattable}
--,{'pelogen_tri_308',"shiftalow(308)",ntable}
--,{'pelogen_tri_176',"shiftalow(176)",ntable}
--,{'pelogen_tri_129',"shiftalow(129)",flattable}
,{'azufasttri',"azure48(fast)",flattable}
,{'azulowtri',"azure48(low)",flattable}
,{'solid_trifill_v3',"electricgryphon(v3)",flattable}
,{'shade_trifill',"electricgryphon",flattable}
,{'musurca_triangle',"musurca",ntable}
,{'creamdog_tri',"creamdog",flattable}
,{'p01_triangle_335',"p01(335)",flattable}
,{'gfx_draw',"catafish",{flattable}}
,{'steptri',"nusan",flattable}
,{'p01_triangle_163',"p01(163)",flattable}
}

function _init()
menuitem(1,'v-h inverse',function()
 compress_vertical=not compress_vertical
end)
tests={{fn=function(i) local v=trifuncs[1][3][i] _ENV[trifuncs[1][1]](v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end}}
::loop_showing_results::
cls(1)
  if (btnp(5)) draw_results = not draw_results
  if (btnp(4)) draw_wireframe = not draw_wireframe
  if (btn(0)) angle -= angle_inc
  if (btn(1)) angle += angle_inc
--  compress = 
  compress_y =
   compress_vertical
    and mid(compress_y + tonum(btn(2)) - tonum(btn(3)),0,160)
     or compress_y
  compress_x =
   compress_vertical
    and compress_x
     or mid(compress_x + tonum(btn(2)) - tonum(btn(3)),0,160)
  local t = compress_y
  local u = compress_x
  if btnp(5) then
  	add(trifuncs,deli(trifuncs,1))
  end
  local r = 80+32*cos(angle*1.7)

--		?64+r*cos(angle),0,8
--		?mid(r*sin(angle+.33),-t,t),0,120

  local f = {
--  	64+r*cos(angle)
  	64+mid(r*cos(angle),-u-1,u+1)
  	,64+mid(r*sin(angle),-t-1,t+1)
--  	,64+r*cos(angle+.33)
  	,64+mid(r*cos(angle+.33),-u-1,u+1)
  	,64+mid(r*sin(angle+.33),-t-1,t+1)
--  	,64+r*cos(angle+.67)
  	,64+mid(r*cos(angle+.67),-u-1,u+1)
  	,64+mid(r*sin(angle+.67),-t-1,t+1)
  	,col
  }
-- compress_y test
  fillp(0xaaaa.8)
  line(min(min(f[1],f[3]),f[5]),63-compress_y,max(max(f[1],f[3]),f[5]),63-compress_y,0x2)
  line(max(max(f[1],f[3]),f[5]),65+compress_y,min(min(f[1],f[3]),f[5]),65+compress_y,0x2)
  fillp(0x0f0f.8)
  line(63-compress_x,min(min(f[2],f[4]),f[6]),63-compress_x,max(max(f[2],f[4]),f[6]),0x2)
  line(65+compress_x,max(max(f[2],f[4]),f[6]),65+compress_x,min(min(f[2],f[4]),f[6]),0x2)
  fillp(0)
-- end of compress_y test 

--  local f = {64+r*cos(angle),64+r*sin(angle),64+r*cos(angle+.33),64+r*sin(angle+.33),64+r*cos(angle+.67),94+r*sin(angle+.67),col}
--  local f = {64+r*cos(angle),64+r*sin(angle),64+r*cos(angle+.33),64+r*sin(angle+.33),64+r*cos(angle+.67),64+r*sin(angle+.67),col}
  flattable[1] = f
  ntable[1] = flat2n(f)
  if (draw_wireframe) then
    color(14)
    line(f[1],f[2],f[3],f[4])
    line(f[5],f[6],f[3],f[4])
    line(f[1],f[2],f[5],f[6])
  end
  fillp(0b0101111110101111)
  tests[1].fn(1)
  fillp(0)
		?join('\n',unpack(trifuncs[1],1,2)),0,0,7
		dbg'd?'
  flip()
goto loop_showing_results
end
-->8
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

function pelogen_tri_ww(l,t,c,m,r,b,col)
color(col)
--while col do
--l,t,c,m,col=c,m,l,t
--while t>m or m>b do
--c,m,r,b,col=r,b,c,m,1
--end
while t>m or m>b do
l,t,c,m=c,m,l,t
while m>b do
c,m,r,b=r,b,c,m
end
--dbg(1)
end

local i,j,k,r=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m),l
while m do
for t=flr(t),min(flr(m)-1,127) do
rectfill(l,t,r,t)
l+=i
r+=j
end
l,t,m,i,b=c,m,b,k
end
pset(r,t)
--dbg()
end

function pelogen_tri_ws(l,t,c,m,r,b,col)
color(col)
local q=1
while t>m or m>b do
l,t,r,b,c,m=select(q
,c,m,r,b,l,t,c,m,r,b,l,t,c,m
)
q+=2
--,l,t,c,m,r,b

--,c,m,l,t,r,b -- 213
--,l,t,r,b,c,m -- 231
--,r,b,c,m,l,t -- 132
--,c,m,l,t,r,b -- 312
--,l,t,r,b,c,m -- 321
--dbg(flr(l),flr(t),flr(r),flr(b),flr(c),flr(m))
end

local i,j,k,r=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m),l
while m do
for t=flr(t),min(flr(m)-1,127) do
rectfill(l,t,r,t)
l+=i
r+=j
end
l,t,m,i,b=c,m,b,k
end
--dbg()
end

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

function pelogen_tri_126(l,t,c,m,r,b,col)
color(col)
if(t>m) l,t,c,m=c,m,l,t
if(t>b) l,t,r,b=r,b,l,t
if(m>b) c,m,r,b=r,b,c,m
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

function pelogen_tri_123(l,t,c,m,r,b,col)
color(col)
if(t>m) l,t,c,m=c,m,l,t
if(t>b) l,t,r,b=r,b,l,t
if(m>b) c,m,r,b=r,b,c,m
local i,j,k,r=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m),l
while t~=b do
for t=flr(t),min(flr(m)-1,127) do
--for t=t,min(m-1,127) do
rectfill(l,t,r,t)
r+=j
l+=i
end
l,t,m,i=c,m,b,k
end
end
--t,m,b
--b,m,t
--b,t,m
--t,m,b

function pelogen_tri_d166(l,t,c,m,r,b,col,p)
if(t>m) l,t,c,m=c,m,l,t
if(t>b) l,t,r,b=r,b,l,t
if(m>b) c,m,r,b=r,b,c,m
if b-t<=max(max(l,c),r)-min(min(l,c),r)then
color(col)
local i,j,k,r=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m),l
while t~=b do
if p then
for t=t,min(m,128) do
rectfill(t,l,t,r)
r+=j
l+=i
end
else
for t=t,min(m,128) do
rectfill(l,t,r,t)
r+=j
l+=i
end
end
l,t,m,i=c,m,b,k
end
else
pelogen_tri_d166(t,l,m,c,b,r,col,1)
end
end


function pelogen_tri_hs(l,t,c,m,r,b,col,p)
color(col)
if(t>m) l,t,c,m=c,m,l,t
if(t>b) l,t,r,b=r,b,l,t
if(m>b) c,m,r,b=r,b,c,m
local i,j,k,e=(c-l)/(m-t),(r-l)/(b-t),(r-c)/(b-m),l
if b-t<max(max(l,c),r)-min(min(l,c),r) then
while t~=b do
for t=t,min(m,128) do
rectfill(l,t,e,t)
e+=j
l+=i
end
l,t,m,i=c,m,b,k
end
else
if(l>c) l,t,c,m=c,m,l,t
if(l>r) l,t,r,b=r,b,l,t
if(c>r) c,m,r,b=r,b,c,m
local i,j,k,e=(m-t)/(c-l),(b-t)/(r-l),(b-m)/(r-c),t
while l~=r do
for l=l,min(c,128) do
rectfill(l,t,l,e)
e+=j
t+=i
end
t,l,c,i=m,c,r,k
end
end
end

-->8
-- azure48 triangle fill, faster
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
-->8

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

function p01_trapeze_hr(l,r,lt,rt,y0,y1)
local f=rectfill
 lt,rt=(lt-l)/(y1-y0),(rt-r)/(y1-y0)
 if(y0<0)l,r,y0=l-y0*lt,r-y0*rt,0
 y1=min(y1,128)
 for y0=y0,y1 do
  f(l,y0,r,y0)
  l+=lt
  r+=rt
 end
end
function p01_trapeze_wr(t,b,tt,bt,x0,x1)
local f=rectfill
 tt,bt=(tt-t)/(x1-x0),(bt-b)/(x1-x0)
 if(x0<0)t,b,x0=t-x0*tt,b-x0*bt,0
 x1=min(x1,128)
 for x0=x0,x1 do
  f(x0,t,x0,b)
  t+=tt
  b+=bt
 end
end
function p01_triangle_335_r(x0,y0,x1,y1,x2,y2,col)
 color(col)
 if(y1<y0)x0,x1,y0,y1=x1,x0,y1,y0
 if(y2<y0)x0,x2,y0,y2=x2,x0,y2,y0
 if(y2<y1)x1,x2,y1,y2=x2,x1,y2,y1
 if max(x2,max(x1,x0))-min(x2,min(x1,x0)) > y2-y0 then
  col=x0+(x2-x0)/(y2-y0)*(y1-y0)
  p01_trapeze_hr(x0,x0,x1,col,y0,y1)
  p01_trapeze_hr(x1,col,x2,x2,y1,y2)
 else
  if(x1<x0)x0,x1,y0,y1=x1,x0,y1,y0
  if(x2<x0)x0,x2,y0,y2=x2,x0,y2,y0
  if(x2<x1)x1,x2,y1,y2=x2,x1,y2,y1
  col=y0+(y2-y0)/(x2-x0)*(x1-x0)
  p01_trapeze_wr(y0,y0,y1,col,x0,x1)
  p01_trapeze_wr(y1,col,y2,y2,x1,x2)
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

-- EG latest trifill
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

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
