dbg_str={}
isdebug=false
function dbg(str)
add(dbg_str,str)
if #dbg_str==2 then
--vdmp(dbg_str)
end
end

function dbg_print()
if isdebug then
--dbg({"隨ｳ�ｽ"..stat(1),"隨ｳ�ｽ"..stat(0)})
dbg_each(dbg_str,0)
dbg_str={}
end
end

function dbg_each(tbl,p)
local c=0
for i,str in pairs(tbl) do
	if type(str)=='table' then	p=dbg_each(str,p)
	else
 	print(str,p*4,0,(c%16)+1)
		p=p+#(tostr(str)..'')+1
		c+=1
	end
end
return p
end

function vdmp(v,_x,_y)
local tstr=htbl([[
number=#;string=$;boolean=%;function=*;nil=!;
]])
tstr.table='{'
local p=0
if _x==nil then _x=0 _y=0 color(6) end
if _y==0 then cls() end
if type(v)~='table' then v={v} end
for i,str in pairs(v) do
	if type(str)=='table' then
	 if p>0 then _y+=1 end
 	print(i..tstr[type(str)],_x*4,_y*6)
		_y=vdmp(str,_x+1,_y+1)
  _y+=1
  print('}',_x*4,_y*6)
  _y+=1
  p=0
	else
 	str=tstr[type(str)]..':'..tostr(str)
 	print(str,(_x+p)*4,_y*6)
		p=p+#(str..'')+1
	end
end
cursor(0,(_y+1)*6)
if _x==0 then
 stop()
end
return _y
end