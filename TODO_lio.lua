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
-- local function typecheck(var,pos,name,typ)
--    if type(typ)=="string" then
--       if type(var)~=typ then
--          error("bad argument #"..pos.." to '"..name.."' ("..typ.." expected, got "..(var==nil and "no value" or type(var))..")")
--       end
--    elseif type(typ)=="table" then
--       local mat = false
--       for _,v in next,typ do
--          if type(var)==v then mat=true;break end
--       end
--       if not mat then
--          error("bad argument #"..pos.." to '"..name.."' ("..typ[1].." expected, got "..(var==nil and "no value" or type(var))..")")
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
            if required and success==nil then
               error('bad argument #'..i.." to '"..name.."'"..(reason~=nil and " ("..reason..")" or ""),3)
            end
            if success~=nil then
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

local function unimpl(s)
   return (function()
      error("'"..s.."' is unimplemented")
   end)
end

local stream = require('stream')
local input,output
local io = {}
-- io.write = defl(stream.meta.write,function() return output end)
-- io.read = defl(stream.meta.read,function() return input end)
-- io.close = defl(stream.meta.close,function() return output end)
-- io.flush = defl(stream.meta.flush,function() return output end)
-- io.lines = defl(stream.meta.lines,function() return output end)
-- repetitive...
function io.write(...)
   if stream.is((...)) or select("#",...)==0 then
      return stream.meta.write(...)
   end
   return stream.meta.write(output,...)
end
function io.read(...)
   if stream.is((...)) or select("#",...)>1 then
      return stream.meta.read(...)
   end
   return stream.meta.read(input,...)
end
function io.close(...)
   if stream.is((...)) or select("#",...)>0 then
      return stream.meta.close(...)
   end
   return stream.meta.close(output,...)
end
function io.flush(...)
   if stream.is((...)) or select("#",...)>0 then
      return stream.meta.flush(...)
   end
   return stream.meta.flush(output,...)
end
function io.lines(...)
   if stream.is((...)) or select("#",...)>0 then
      return stream.meta.lines(...)
   end
   return stream.meta.lines(input,...)
end

function io.input(...)
   local a = typecheckv("input",{
      {stream.is_tc,custom=true,optional=true,default=io.stdin}
   },...)
   input=a
   return input
end
function io.output(...)
   local a = typecheckv("output",{
      {stream.is_tc,custom=true,optional=true,default=io.stdout}
   },...)
   output=a
   return output
end
function io.open(path,flags)
   error("todo: open")
end
io.popen = unimpl("popen")
function io.type(a)
   if stream.is(a) then
      return "file"
   else
      return nil
   end
end
io.stdout = stream.factory.new()
io.stdin = stream.factory.new()
io.stderr = stream.factory.new()
input,output = io.stdin,io.stdout
return io