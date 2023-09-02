local string = require('./lstring')
local table = require('./ltable')
local aa = "su per se c re te"
local passed = (...) or error("no passed string")
local function safe(s)
   return (s:gsub('[^\32-\127]',function(a)
      return "\\"..a:byte()
   end))
end
local function bxor(a,b)
   -- print(a,b)
   if a==0 and b==0 then
      return 0
   elseif a==1 and b==1 then
      return 0
   else
      return 1
   end
end
local function xor(a,b)
   local b1,b2 = {},{}
   for i=0,31 do
      local t=a%2
      table.insert(b1,t)
      a=(a-t)/2
   end
   for i=0,31 do
      local t=math.fmod(b,2)
      table.insert(b2,t)
      b=(b-t)/2
   end
   local n = {}
   for i=32,1,-1 do
      table.insert(n,bxor(b1[i],b2[i]))
   end
   -- print(table.concat(b1))
   -- print(table.concat(b2).." ".."XOR")
   -- print(("_"):rep(32+4))
   -- print(table.concat(n))
   -- print(("-"):rep(32))
   return tonumber(table.concat(n),2)
end
local function xors(a,b)
   local n = {}
   for i=1,#a do
      -- local v=xor(string.byte(a,i),string.byte(b,i))
      -- print(string.byte(a,i),string.byte(b,i),' == ',v)
      table.insert(n,xor(string.byte(a,i),string.byte(b,((i-1)%#b)+1)))
   end
   -- print(a.."^"..b..' -> '..table.concat(n,", "))
   for i=1,#n do n[i]=string.char(n[i]) end
   print(safe(a),'X',safe(b),'->',safe(table.concat(n)))
   return table.concat(n)
end
local v1 = xors("abcdefg","AbCdEfG")
xors(v1,"AbCdEfG")