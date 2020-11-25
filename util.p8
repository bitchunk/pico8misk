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
p=sub(tostr(tonum(p),16),3,6)
while sub(p,1,1)=='0' do
p=sub(p,2)
end
p=join(tablefill(0,(n or 0)-#p),'')..p
return p
end


function ttoh(h,l,b)
return bor(shl(tonum(h),b),tonum(l))
end
function htot(v)
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
local t,c,k,rt,p={},0

ri,ht=ri or 0,ri and ht or replace(ht,"\n")
while ht~='' do
p,ht=sub(ht,1,1),sub(ht,2)
 if p=='{' or p=='=' then
  rt,ht=htbl(ht,ri+1)
  if rt then
	  if p=='=' then
	   t[k]=rt[1]
	  else
	   if k then
	    t[k]=rt
	   else
	    add(t,rt)
	   end
	  end
  end
  k=nil
 elseif p=='}' or p==';' or p==')' then
  add(t,tonorm(k))
  k=nil
  return t,ht
 elseif p==' ' then
  add(t,tonorm(k))
  k=nil
 else
  k=(k or '')..p
 end
end
add(t,tonorm(k))
return t
end


function exrect(p)
return _exrect.new(ttable(p) or split(p))
end
_exrect={}
mkrs=htbl'x y w h ex ey r p'
hovk=htbl'{x y}{x ey}{ex y}{ex ey}'
function rfmt(p)
for i,v in pairs(p) do
p[i]=tonum(v)
end
local x,y,w,h=unpack(p)
return comb(mkrs,{x,y,w,h,x+w-1,y+h-1,w/2,p})
end
_exrect.new=function(p)

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
p,y,w,h=unpack(split(p))
end
cat(o,rfmt({p or o.x,y or o.y,w or o.w,h or o.h}))
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

function join(s,d)
local a=''
for i,v in pairs(s) do
a=a..v..d
end
return sub(a,1-#d)
end


_tonum,tonum=tonum,function(v)
return v and _tonum(v) or nil
end

_split,split=split,function(str,d,dd)
local a,c,s,tk={},0,''
if dd then str=split(str,dd) end
if dd then
while #str>0 do
add(a,split(del(str,str[1]),d))
end
else
a=_split(str,d or ' ',false)
end
add(a,tk)
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

function tablefill(v,n,r)
local t={}
if r and r>0 then
n,r=r,n
end

local p=ttable(v) and #v==0
for i=0,n-1 do
t[i]=p and {} or r and tablefill(v,r) or v
end
return t
end

function ecxy(p,f)
p=exrect(p)
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

function eachpal(f,t,b)
for i=1,#f-1 do
local s=ttable(t) and t[i] or todeg(sub(t,i,i))
local d=s>(b or 0) and pal or palt
d(todeg(sub(f,i,i)),s)
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
