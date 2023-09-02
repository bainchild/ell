local type=type
local tonumber=tonumber
local tostring=tostring
local error=error
local select=select
-- these can _technically_ be omitted but at what cost?
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
-- function typecheck(var,pos,name,typ)
--    if type(typ)=="string" then
--       if type(var)~=typ then
--          error("bad argument #"..pos.." to '"..name.."' ("..typ.." expected, got "..(var==nil and "no value" or type(var))..")",3)
--       end
--    elseif type(typ)=="table" then
--       local mat = false
--       for _,v in next,typ do
--          if type(var)==v then mat=true;break end
--       end
--       if not mat then
--          error("bad argument #"..pos.." to '"..name.."' ("..typ[1].." expected, got "..(var==nil and "no value" or type(var))..")",3)
--       end
--    end
-- end
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
            if required and not success then
               error('bad argument #'..i.." to '"..name.."'"..(reason~=nil and " ("..reason..")" or ""),3)
            end
            if success then
               val=reason
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
local g = {}
for i,v in next, _G do
   g[i]=v
end
if not rawequal(_G,getfenv()) then
   for i,v in next,getfenv() do
      g[i]=v
   end
end
-- ^ this covers all the environment-provided functions we cannot emulate
-- (or at least we need to emulate themselfs)
-- it's gonna be a bit odd from now on
-- because you have syntax-based constructors like
-- "" and {} and (literally any number) that can only
-- be changed by the sandbox, which isn't something
-- we have access to in the main chunk.
-- (you'd have to use FiOne or similar.)

-- speaking of...
if INTERPRETER and INTERPRETER.can_load('constructor_hooks') then
   INTERPRETER.load('constructor_hooks')
   INTERPRETER.loaded.constructor_hooks.add_table('post',function(tab)
      g.setmetatable(tab,table_mt)
   end)
end
--
local impl = {}
for i,v in next,{
   "loadstring" -- TODO: use FiOne + yueliang to emulate this.
   ""
} do impl[v]=g[v] end
function impl.setmetatable(...)
   local a,b = typecheckv('setmetatable',{
      {'table'};
      {optional=true};
   },...)
   g.setmetatable(a,{
      __real = b;
      -- todo: ALL the metamethods!
   })
   return a
end
function impl.getmetatable(...)
   local a = typecheckv('getmetatable',{
      {'userdata','table','string'};
   },...)
   local mt = g.rawget(g.getmetatable(a),'__real')
   if not g.rawequal(mt,nil) and rawgetexists(mt,'__metatable') then
      return g.rawget(mt,'__metatable')
   end
   return mt
end
g.impl = impl
return g