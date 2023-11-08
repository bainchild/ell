---@diagnostic disable-next-line: undefined-global
local MANUALLY_CHECK_LENGTH = jit~=nil

local function list_iter(tab,i,...)
   if i==nil then i=0 end
   local v=tab[i+1]
   if v==nil then return v end
   return i+1,v,...
end
local pairs_iter = next -- no way (as far as I know) to do this in lua
local function _unpack_r(list,start,en,count)
   if count>=en or list[start+count]==nil then
      return
   end
   if count+1>=8000 then error("too many results to unpack",count+3) end
   return list[start+count],_unpack_r(list,start,en,count+1)
end
local function unpack(list,i,j)
   if i==nil then i=1 end
   if j==nil then j=2^16384 end -- (hopefully) saturates to inf
   return _unpack_r(list,i,j,0)
end

local function typecast(var,type_)
   local vartype = type(var)
   if vartype==type_ then return true,var end
   if vartype=="string" then
      if type_=="number" then
         local new = tonumber(var)
         if new then
            return true, new
         else
            return false, nil
         end
      end
   elseif vartype=="number" then
      if type_=="string" then
         return true, tostring(var)
      end
   end
   return false, nil
end
local function typecheck(var,pos,name,typ)
   if type(typ)=="string" then
      if type(var)~=typ then
         error("bad argument #"..pos.." to '"..name.."' ("..typ.." expected, got "..(var==nil and "no value" or type(var))..")",3)
      end
   elseif type(typ)=="table" then
      local mat = false
      for _,v in next,typ do
         if type(var)==v then mat=true;break end
      end
      if not mat then
         error("bad argument #"..pos.." to '"..name.."' ("..typ[1].." expected, got "..(var==nil and "no value" or type(var))..")",3)
      end
   end
end
local function typecheckv(name,types,...)
   local can_cast = types.implicit_casting
   local nargs,args = select('#',...),{...}
   local ret = {}
   for i,v in next,types do
      if type(i)=="number" then
         local val = args[i]
         local type_ = type(val)
         local is_none = i>nargs and val==nil
         local required = not v.optional
         if v.custom then
            local success,reason = v[1](val,type_,is_none,(can_cast and typecast) or nil)
            if required and success==nil then
               error('bad argument #'..i.." to '"..name.."'"..(reason~=nil and " ("..reason..")" or ""),3)
            end
            if success~=nil then
               val=success
            end
         else
            local matched,bad_typecast = false,false
            if not is_none then
               for ti,b in next,v do
                  --print('awlcast',typecast(val,b))
                  if type(ti)=="number" and (type_==b or can_cast) then
                  	  if can_cast then
                  	     local s,r = typecast(val,b)
                  	     --print('cast',s,r)
                  	     val=r
                  	     if not s then
                  	        bad_typecast=true;break
                  	     end
                  	  end
                  	  matched=true;break
                  end
               end
            end
            --print(matched,required,bad_typecast)
            if not matched then
               if required or bad_typecast then
                  error("bad argument #"..i.." to '"..name.."' ("..v[1].." expected, got "..(is_none and 'no value' or type_)..")",3)
               elseif v.default and is_none then
                  val=v.default
               end
            end
         end
         ret[i]=val
      end
   end
   return unpack(ret)
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
function table.setn(...)
   typecheckv('setn',{
      {'table'}
   },...)
   error("'setn' is obsolete",2)
end
function table.getn(...)
   local tab = typecheckv('getn',{
      {'table'}
   },...)
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
function table.maxn(...)
   local tab = typecheckv('maxn',{
      {'table'}
   },...)
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
      error("wrong number of arguments to 'insert'",2)
   end
end
function table.remove(tab,index)
   typecheck(tab,1,'remove','table')
   if not rawequal(index,nil) then
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
function table.concat(...)
   local tab,delim,start,end_ = typecheckv('concat',{
      implicit_casting=true;
      {'table'};
      {'string',default="",optional=true};
      {'number',default=1,optional=true};
      {'number',optional=true};
   },...)
   if end_==nil then end_=table.getn(tab) end
   local s=""
   for i=start,end_ do
      -- * nil is already checked by typecheckv
      ---@diagnostic disable-next-line: need-check-nil
      local v = tab[i]
      if i~=start then s=s..delim end
      if type(v)~="string" and type(v)~="number" then
         error("invalid value ("..type(v)..") at index "..i.." in table for 'concat'",2)
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
         if array[i]==nil then error("invalid order function for sorting",3) end
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
function table.sort(...)
   local tab,func = typecheckv('sort',{
      {'table'};
      {'function',default=function(a,b)return a<b end,optional=true};
   },...)
   quicksort(tab,1,table.getn(tab),func)
end
function table.foreachi(...)
   local tab,func = typecheckv('foreachi',{
      {'table'};
      {'function'};
   },...)
   for i,v in list_iter,tab do
      ---@diagnostic disable-next-line: need-check-nil
      func(i,v)
   end
end
function table.foreach(...)
   local tab,func = typecheckv('foreach',{
      {'table'};
      {'function'};
   },...)
   for i,v in pairs_iter,tab do
      ---@diagnostic disable-next-line: need-check-nil
      func(i,v)
   end
end
function table.unpack(...)
   local tab,i,j = typecheckv('unpack',{
      implicit_casting=true;
      {'table'};
      {'number',optional=true};
      {'number',optional=true};
   },...)
   return unpack(tab,i,j)
end
return table