local MANUALLY_CHECK_LENGTH = false

local function list_iter(tab,i,...)
   if i==nil then i=0 end
   local v=tab[i+1]
   if v==nil then return v end
   return i+1,v
end
local pairs_iter = next -- no way (as far as I know) to do this in lua

local function typecheck(var,pos,name,typ)
   if type(typ)=="string" then
      if type(var)~=typ then
         error("bad argument #"..pos.." to '"..name.."' ("..typ.." expected, got "..(var==nil and "no value" or type(var))..")")
      end
   elseif type(typ)=="table" then
      local mat = false
      for _,v in list_iter,typ do
         if type(var)==v then mat=true;break end
      end
      if not mat then
         error("bad argument #"..pos.." to '"..name.."' ("..typ[1].." expected, got "..(var==nil and "no value" or type(var))..")")
      end
   end
end
local function shift(tab,from,size,offset)
   local ntab = {}
   for i=from,size do
      ntab[i+offset] = tab[i]
   end
   for i=from+offset,size+offset do
      tab[i]=ntab[i]
   end
   ntab=nil
end

local table = {}
function table.setn(tab)
   typecheck(tab,1,'setn','table')
   error("'setn' is obsolete")
end
function table.getn(tab)
   typecheck(tab,1,'getn','table')
   if MANUALLY_CHECK_LENGTH then
      local i=0
      while true do
         if tab[i+1]==nil then return i end
         i=i+1
      end
      return i
   end
   return #tab
end
function table.maxn(tab)
   typecheck(tab,1,'maxn','table')
   local max = 0
   for i in pairs_iter,tab do
      if type(i)=="number" and i > max then max=i end
   end
   return max
end
function table.insert(...)
   local args = {...}
   if #args==2 then
      local tab,value = args[1],args[2]
      typecheck(tab,1,'insert','table')
      tab[table.getn(tab)+1]=value
   elseif #args==3 then
      local tab,index,value = args[1],args[2],args[3]
      typecheck(tab,1,'insert','table')
      typecheck(index,2,'insert','number')
      if table.getn(tab)>=index then
         shift(tab,index,table.maxn(tab),1)
      end
      tab[index]=value
   else
      error("wrong number of arguments to 'insert'")
   end
end
function table.remove(tab,index)
   typecheck(tab,1,'remove','table')
   if index~=nil then
      typecheck(index,2,'remove','number')
   else
      index=table.getn(tab)
   end
   local maxn = table.maxn(tab)
   if index>maxn then return nil end
   local val = tab[index]
   shift(tab,index+1,maxn,-1)
   tab[maxn]=nil
   return val
end
function table.concat(tab,delim,start,end_)
   typecheck(tab,1,'concat','table')
   typecheck(delim,2,'concat',{'string','number','nil'})
   if delim==nil then
      delim=""
   end
   typecheck(start,3,'concat',{'number','string','nil'})
   if start==nil then
      start=1
   elseif type(start)=="string" then
      local n=tonumber(start)
      if n==nil then typecheck(n,3,'concat','number') end
      start=n
   end
   typecheck(end_,4,'concat',{'number','string','nil'})
   if end_==nil then
      end_=table.getn(tab)
   elseif type(end_)=="string" then
      local n=tonumber(end_)
      if n==nil then typecheck(n,4,'concat','number') end
      end_=n
   end
   local s=""
   for i=start,end_ do
      local v = tab[i]
      if i~=start then s=s..delim end
      if type(v)~="string" and type(v)~="number" then
         error("invalid value ("..type(v)..") at index "..i.." in table for 'concat'")
      end
      s=s..v
   end
   return s
end
local function floor(val)
   return val-(val%1)
end
-- https://en.wikipedia.org/wiki/Quicksort
-- #Hoare partition scheme
local function partition(array,lo,hi,cmp)
   local pivot = array[floor((hi-lo)/2)+lo]
   local i = lo-1
   local j = hi+1
   -- print("pivot,i,j:",pivot,i,j)
   while true do
      -- print("choosing i")
      repeat
         i=i+1
         if array[i]==nil then error("invalid order function for sorting") end
      until not cmp(array[i],pivot)
      -- print("i is chosen, choosing j")
      repeat
         j=j-1
      until not cmp(pivot,array[j])
      -- print("j is chosen")
      if i>=j then
         -- print("partition over, found new pivot",j)
         return j
      end
      -- print('swap ',i,' with ',j)
      array[i],array[j]=array[j],array[i]
   end
end
local function quicksort(array,lo,hi,cmp)
   if lo>=1 and hi>=1 and lo<hi then
      local p = partition(array,lo,hi,cmp)
      quicksort(array,lo,p,cmp)
      quicksort(array,p+1,hi,cmp)
   end
end
function table.sort(tab,func)
   typecheck(tab,1,'sort','table')
   if func~=nil then
      typecheck(func,2,'sort','function')
   else
      func=function(a,b) return a<b end
   end
   quicksort(tab,1,table.getn(tab),func)
end
function table.foreachi(tab,func)
   typecheck(tab,1,'foreachi','table')
   typecheck(func,2,'foreachi','function')
   for i,v in list_iter,tab do
      func(i,v)
   end
end
function table.foreach(tab,func)
   typecheck(tab,1,'foreach','table')
   typecheck(func,2,'foreach','function')
   for i,v in pairs_iter,tab do
      func(i,v)
   end
end
return table