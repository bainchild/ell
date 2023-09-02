-- this is gonna be typecheck and un implemented functions, 4 sure
function typecast(var,type_)
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
function typecheck(var,pos,name,typ)
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
function typecheckv(name,types,...)
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
               if v.any then
                  matched=true
               else
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
local function tycui(name,types)
   return function(...)
      typecheckv(name,types,...)
      error("'"..name.."' is unimplemented.")
   end
end

local stacklvl = {'function','thread','number'};
local debug = {}
debug.getinfo = tycui('getinfo',{
   implicit_casting=true;
   stacklvl;
   {function(val,type_,is_none,typecast)
      if type_~="string" and not is_none then
         if typecast then
            local s,r = typecast(val,type_)
            if s then
               val=r
            else
               return false,'expected string, got '..(is_none and 'no value' or type_)
            end
         else
            return false,'expected string, got '..(is_none and 'no value' or type_)
         end
      end
      if (string.gsub(val,'nfSlu',''))~="" then
         return false, 'invalid option'
      end
      return (is_none and 'nfSlu') or val
   end,custom=true};
})
debug.getlocal = tycui('getlocal',{
   implicit_casting=true;
   stacklvl;
   {'number'};
})
debug.setlocal = tycui('setlocal',{
   implicit_casting=true;
   stacklvl;
   {'number'};
   {any=true,optional=true};
})
debug.getupvalue = tycui('getupvalue',{
   implicit_casting=true;
   stacklvl;
   {'number'};
})
debug.setupvalue = tycui('setupvalue',{
   implicit_casting=true;
   stacklvl;
   {'number'};
   {any=true,optional=true};
})
debug.sethook = tycui('sethook',{
   implicit_casting=true;
   {'function'};
   {function(val,type_,is_none,typecast)
      if type_~="string" then
         if typecast then
            local s,r = typecast(val,type_)
            if s then
               val=r
            else
               return nil,'expected string, got '..(is_none and 'no value' or type_)
            end
         else
            return nil,'expected string, got '..(is_none and 'no value' or type_)
         end
      end
      for i=1,#val do
         local c = val:sub(i,i)
         if c~="c" and c~="r" and c~="l" then return nil, 'invalid option' end
      end
      return val
   end,custom=true};
   {'number',optional=true};
})
debug.gethook = tycui('gethook',{stacklvl})
for _,v in next, {"setfenv", "getfenv", "getregistry", "getmetatable", "setmetatable", "debug"} do
   debug[v] = function()
      error("'"..v.."' is unimplemented.",2)
   end
end
return debug