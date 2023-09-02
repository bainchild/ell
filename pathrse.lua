local function split(str,delim,add)
   local matches = {}
   for mat in (str..(add or delim)):gmatch("(.-)"..delim) do
      table.insert(matches,mat)
   end
   return matches
end
return function(str)
   if string.find(str,'\0')~=nil then
      return false, 'Path contains a NUL character.'
   end
   local s = split(str,'/')
   local new = {}
   for i,v in next,s do
      if not (i~=1 and v=="") then
         table.insert(new,v)
      end
   end
   s.root = new[1]==""
   if s.root then table.remove(new,1) end
   return s
end
