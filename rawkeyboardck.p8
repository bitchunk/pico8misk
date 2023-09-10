pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--spranimation-kit
--@shiftalow
--knutil_0.6
--@shiftalow
function tonorm(s)
if s=='true' then return true
elseif s=='false' then return false
elseif s=='nil' then return nil
end
return tonum(s) or s
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

function join(d,...)
local a,c,s={...},2,... or ''
while a[c] do
s..=d..tostr(a[c])
c+=1
end
return s
end

_split,split=split,function(str,d,...)
local t=_split(str,d or ' ',false)
for i,v in pairs(t) do
if ... then
t[i]=split(v,...)
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
p=rfmt(p)
for y=p.y,p.ey do
for x=p.x,p.ex do
f(x,y,p)
end
end
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

function ttable(p)
return type(p)=='table' and p
end

function inrng(...)
return mid(...)==...
end

function htbl(ht,c)
local t,k,rt={}
ht,c=split(ht,'') or ht,c or 1
while ht[c] do
local p=ht[c]
c+=1
if p=='{' or p=='=' then
rt,c=htbl(ht,c)
if p=='=' then
t[k],k=rt[1]
elseif k then
t[k],k=rt
else
add(t,rt)
end
elseif p=='}' or p==';' then
add(t,tonorm(k))
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
,htbl'con hov ud rs rf cs cf os of cam'
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
return o.con(x.x,x.y) and o.con(x.ex,x.ey)
end
end
,function(r,p)
local h
for i,v in pairs(hovk) do
h=h or o.con(r[v[1]],r[v[2]])
end
return h or p==nil and r.hov(o,true)
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
--dmp
function dmp(v,s)
if not s then
_dmpl,s={},'\f6'
end

tmap(ttable(v) or {v},function(str,i)
	if ttable(str) then
	 add(_dmpl,s..i..'{')
		dmp(str,s..' ')
	 v=add(_dmpl,s..'\f6}')
	else
		if v then
		add(_dmpl,s)
		end
	 _dmpl[#_dmpl],v=join('',_dmpl[#_dmpl],
	 tonum(i) and '' or i,
	 comb(split[[
number string boolean function nil
]],split"#:\ff $:\fc %:\fe *:\fb !:\f2"
)[type(str)],tostr(str),' \f6')
	end
end)
if s=='\f6' then
cls()
foreach(_dmpl,print)
stop()
end
end

--dbg
function dbg(...)
if ... then
add(_dbgv,{...})
else
tmap(_dbgv,function(t,y)
?join(' ',unpack(ttable(t) or {t})),0,122+(y-#_dbgv)*6,7
end)
_dbgv={}
end
end
dbg()

-->8
function _init()
 poke(0x5f2d,1)
 scans={}
 -- uk keymapping --
	tmap(split([[
a
b
c
d
e
f
g
h
i
j
k
l
m
n
o
p
q
r
s
t
u
v
w
x
y
z
1
2
3
4
5
6
7
8
9
0
[return]
[escape]
[backspace]
[tab]
[space]
-
=
[
]
\
#
;
'
`
,
.
/ 
[capslock]
f1
f2
f3
f4
f5
f6
f7
f8
f9
f10
f11
f12
[printscreen]
[scrolllock]
[pause]
[insert]
⌂
[pageup]
[delete]
[end]
[pagedown]
➡️
⬅️
⬇️
⬆️
[numlockclear]
[num /]
[num *]
[num -]
[num +]
[num enter]
[num 1]
[num 2]
[num 3]
[num 4]
[num 5]
[num 6]
[num 7]
[num 8]
[num 9]
[num 0]
[num .]
¥
▤
[power]
[num =]
f13
f14
f15
f16
f17
f18
f19
f20
f21
f22
f23
f24
[execute]
[help]
[menu]
[select]
[stop]
[again]
[undo]
[cut]
[copy]
[paste]
[find]
[mute]
[volumeup]
[volumedown]
[num ,]
[num キ]
[footnotes]
]],"\n"),function(v,i)
		scans[v]=i+3
 end)
 
scans['[lctrl]'] = 224
scans['[lshift]'] = 225
scans['[lalt]'] = 226
scans['[lgui]'] = 227
scans['[rctrl]'] = 228
scans['[rshift]'] = 229
scans['[ralt]'] = 230
scans['[rgui]'] = 231

end

function _draw()
	cls()
	poke(0x5f30,0xff)

	tmap(scans,function(v,i)
	 if stat(29,scans[i] or 0)~=0x.0001 then
	 	?tostr(v,1)..' '..type(v),0,0
--flip()
	 end
	 if stat(28,scans[i] or 0) then
	  ?sub('000'..v,-3)..' : '..i
	 end
	end)
	?stat(31)
	for i=0x5f80,0x5fff do
		if peek(i)~=0 then
			?peek(i)
		end
	end
end
-->8
--	tmap(_split("abcdefghijklmnopqrstuvwxyz1234567890\nˇ\b\t -=[]\\#;'`,./😐…∧░➡️⧗▤⬆️☉🅾️◆█★","",false),function(v,i)
--		scans[v]=i+3
-- end)

--s=''
--for i=1,255 do
--s..=replace(chr(i),"\n",[[\n]],"\r",[[\r]],"\t",[[\t]],"\\",[[\\]],[["]],[[\"]])
--end
--
--printh(s,'@clip')

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
