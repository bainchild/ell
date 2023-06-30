local function get_cptr(src,start)
   return setmetatable({
      s=src;
      p=start or 0;
   },{
      __div=function(self,other)
         return other==self.s:sub(self.p,self.p)
      end;
      __add=function(self,other)
         self.p=self.p+other
         return self
      end;
      __sub=function(self,other)
         self.p=self.p-other
         return self
      end;
      __unm=function(self)
         return get_cptr(self.s,self.p)   
      end;
      __mul=function(self,other)
         if other==0 then
            return self.p==#self.s
         end
      end;
      __tostring=function(self)
         return self.s:sub(self.p,self.p)
      end;
   })
end
return get_cptr