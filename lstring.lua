local DBG = function()end
-- other locales are NOT supported
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
local function unimpl(s)
   return function()
      error("'"..s.."' is unimplemented")
   end
end
local function find(a,b)
   for i,v in pairs_iter,a do
      if v==b then return i end
   end
   return nil
end
local byte_lookup = {[0]="\0";[1]="\1";[2]="\2";[3]="\3";[4]="\4";[5]="\5";[6]="\6";[7]="\b";[8]="\8";[9]="\t";[10]="\10";[11]="\11";[12]="\n";[13]="\13";[14]="\14";[15]="\r";[16]="\16";[17]="\17";[18]="\18";[19]="\19";[20]="\20";[21]="\21";[22]="\22";[23]="\23";[24]="\24";[25]="\25";[26]="\26";[27]="\27";[28]="\28";[29]="\29";[30]="\30";[31]="\31";[32]=" ";[33]="!";[34]="\"";[35]="#";[36]="$";[37]="%";[38]="&";[39]="'";[40]="(";[41]=")";[42]="*";[43]="+";[44]=",";[45]="-";[46]=".";[47]="/";[48]="0";[49]="1";[50]="2";[51]="3";[52]="4";[53]="5";[54]="6";[55]="7";[56]="8";[57]="9";[58]=":";[59]=";";[60]="<";[61]="=";[62]=">";[63]="?";[64]="@";[65]="A";[66]="B";[67]="C";[68]="D";[69]="E";[70]="F";[71]="G";[72]="H";[73]="I";[74]="J";[75]="K";[76]="L";[77]="M";[78]="N";[79]="O";[80]="P";[81]="Q";[82]="R";[83]="S";[84]="T";[85]="U";[86]="V";[87]="W";[88]="X";[89]="Y";[90]="Z";[91]="[";[92]="\\";[93]="]";[94]="^";[95]="_";[96]="`";[97]="a";[98]="b";[99]="c";[100]="d";[101]="e";[102]="f";[103]="g";[104]="h";[105]="i";[106]="j";[107]="k";[108]="l";[109]="m";[110]="n";[111]="o";[112]="p";[113]="q";[114]="r";[115]="s";[116]="t";[117]="u";[118]="v";[119]="w";[120]="x";[121]="y";[122]="z";[123]="{";[124]="|";[125]="}";[126]="~";[127]="\127";[128]="\128";[129]="\129";[130]="\130";[131]="\131";[132]="\132";[133]="\133";[134]="\\";[135]="\135";[136]="\136";[137]="\137";[138]="\138";[139]="\139";[140]="\140";[141]="\141";[142]="\142";[143]="\143";[144]="\144";[145]="\145";[146]="\146";[147]="\147";[148]="\148";[149]="\149";[150]="\150";[151]="\151";[152]="\152";[153]="\153";[154]="\154";[155]="\155";[156]="\156";[157]="\157";[158]="\158";[159]="\159";[160]="\160";[161]="\161";[162]="\162";[163]="\163";[164]="\164";[165]="\165";[166]="\166";[167]="\167";[168]="\168";[169]="\169";[170]="\170";[171]="\171";[172]="\172";[173]="\173";[174]="\174";[175]="\175";[176]="\176";[177]="\177";[178]="\178";[179]="\179";[180]="\180";[181]="\181";[182]="\182";[183]="\183";[184]="\184";[185]="\185";[186]="\186";[187]="\187";[188]="\188";[189]="\189";[190]="\190";[191]="\191";[192]="\192";[193]="\193";[194]="\194";[195]="\195";[196]="\196";[197]="\197";[198]="\198";[199]="\199";[200]="\200";[201]="\201";[202]="\202";[203]="\203";[204]="\204";[205]="\205";[206]="\206";[207]="\207";[208]="\208";[209]="\209";[210]="\210";[211]="\211";[212]="\212";[213]="\213";[214]="\214";[215]="\215";[216]="\216";[217]="\217";[218]="\218";[219]="\219";[220]="\220";[221]="\221";[222]="\222";[223]="\223";[224]="\224";[225]="\225";[226]="\226";[227]="\227";[228]="\228";[229]="\229";[230]="\230";[231]="\231";[232]="\232";[233]="\233";[234]="\234";[235]="\235";[236]="\236";[237]="\237";[238]="\238";[239]="\239";[240]="\240";[241]="\241";[242]="\242";[243]="\243";[244]="\244";[245]="\245";[246]="\246";[247]="\247";[248]="\248";[249]="\249";[250]="\250";[251]="\251";[252]="\252";[253]="\253";[254]="\254";[255]="\255";}
local upper_lookup = {}
for i=97,122 do
   upper_lookup[byte_lookup[i]]=byte_lookup[i-32]
end

local string = {}
string.sub = ("").sub
function string.upper(s)
   typecheck(s,1,"upper",{"string","number"})
   if type(s)=="number" then s=tostring(s) end
   local n = ""
   for i=1,#s do
      n=n..(upper_lookup[string.sub(s,i,i)] or string.sub(s,i,i))
   end
   return n
end
function string.lower(s)
   typecheck(s,1,"lower",{"string","number"})
   if type(s)=="number" then s=tostring(s) end
   local n = ""
   for i=1,#s do
      n=n..(find(upper_lookup,string.sub(s,i,i)) or string.sub(s,i,i))
   end
   return n
end
function string.reverse(s)
   typecheck(s,1,"lower",{"string","number"})
   if type(s)=="number" then s=tostring(s) end
   local n = ""
   for i=#s,1,-1 do
      n=n..string.sub(s,i,i)
   end
   return n
end
function string.len(s)
   typecheck(s,1,'len',{"string","number"})
   if type(s)=="number" then s=tostring(s) end
   return #s
end
function string.rep(s,a)
   typecheck(s,1,'rep',{"string","number"})
   typecheck(a,2,'rep','number')
   local n = ""
   for i=1,a do
      n=n..s
   end
   return n
end
function string.char(...)
   local args = {...}
   local n = ""
   for i,v in list_iter,args do
      typecheck(v,i,'char',{'number','string'})
      if type(v)=="string" then
         local n = tonumber(v)
         if n==nil then
            typecheck(v,1,'char','number')
         end
         v=n
      end
      if i>255 or i<0 then print("ERR",i); error("bad argument #"..i.." to 'char' (invalid value)") end
      n=n..byte_lookup[v]
   end
   return n
end
function string.byte(str,index,amount)
   typecheck(str,1,'byte',{'string','number'})
   if type(str)=="number" then
      str=tostring(str)
   end
   typecheck(index,2,'byte',{'number','string','nil'})
   if type(index)=="string" then
      local n=tonumber(index)
      if n==nil then typecheck(index,2,'byte','number') end
      index=n
   end
   typecheck(amount,3,'byte',{'number','string','nil'})
   if type(amount)=="string" then
      local n=tonumber(amount)
      if n==nil then typecheck(amount,3,'byte','number') end
      amount=n
   end
   if index==nil then index=1 end
   if amount==nil then amount=1 end
   str=string.sub(str,index,index+amount-1)
   local re = {}
   for i=1,#str do
      re[i]=find(byte_lookup,string.sub(str,i,i))
   end
   return unpack(re)
end
function string.dump(f,strip)
   typecheck(f,1,'dump','function')
   typecheck(strip,2,'dump',{'boolean','nil'})
   if strip==nil then strip=false end
   error('string.dump is unimplemented')
end
do
   local get_cptr = require('cptr')
   local pattern_classes = {
      ["."]=(function()
         local n = {}
         for i=1,256 do
            n[i+1]=i-1
         end
         return string.char(unpack(n))
      end)();
      ["a"]="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
      ["l"]="abcdefghijklmnopqrstuvwxyz";
      ["u"]="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      ["d"]="0123456789";
      ["p"]="!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";
      ["w"]="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
      ["s"]=" \v\t\r\n";
      ["c"]="\0\1\2\3\4\5\6\7\8\9\10\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31\127";
      ["x"]="01233456789abcdefABCDEF";
      ["z"]="\0";
   }
   -- translation from lstrlib.c's "PATTERN MATCHING" section
   local CAP_UNFINISHED = -1
   local CAP_POSITION = -2
   local LUA_MAXCAPTURES = 5000
   -- typedef struct MatchState {
   --   const char *src_init;  /* init of source string */
   --   const char *src_end;  /* end (`\0') of source string */
   --   lua_State *L;
   --   int level;  /* total number of captures (finished or unfinished) */
   --   struct {
   --     const char *init;
   --     ptrdiff_t len;
   --   } capture[LUA_MAXCAPTURES];
   -- } MatchState;
   --end
   local L_ESC = "%"
   local SPECIALS="^$*+?.([%-"
   local match
   local function check_capture(ms,l)
      l=l-1
      if l<0 or l>=ms.level or ms.capture[l].len == CAP_UNFINISHED then
         error("invalid capture index")
      end
      return l
   end
   local function capture_to_close(ms)
      for i=1,ms.level do
         if ms.capture[i].len==CAP_UNFINISHED then
            error("invalid pattern capture")
         end
      end
   end
   local function classend(ms,p)
      local p = -p
      local nc = -p+1
      if nc/L_ESC then
         if p*0 then
            error("malformed pattern (ends with %)")
         end
         return -p+1
      elseif nc/"[" then
         if p/"^" then p=p+1 end
         while not p/"]" do
            if p*0 then
               error("malformed pattern (missing ])")
            end
            if (-p-1)/L_ESC and not p*0 then
               p=p+1
            end
         end
         return p+1
      else
         return p
      end
   end
   local function islower(c)
      return upper_lookup[c]~=nil
   end
   local function match_class(c,cl)
      local lcl,res = string.lower(cl)
      if     lcl=='a' then res = isalpha(c);
      elseif lcl=='c' then res = iscntrl(c); 
      elseif lcl=='d' then res = isdigit(c); 
      elseif lcl=='l' then res = islower(c); 
      elseif lcl=='p' then res = ispunct(c); 
      elseif lcl=='s' then res = isspace(c); 
      elseif lcl=='u' then res = isupper(c); 
      elseif lcl=='w' then res = isalnum(c); 
      elseif lcl=='x' then res = isxdigit(c); 
      elseif lcl=='z' then res = (c == 0);
      else
         return (cl/c);
      end
      if islower(cl) then
         return res
      else
         return not res
      end
   end
   local function matchbracketclass(c,p,ce)
      local sig = true
      if (-p+1)/"^" then
         sig = false
      end
      while ((-p+1).p < ec) do
         if (p/L_ESC) then
            p=p+1
            if match_class(c,tostring(p)) then
               return sig
            end
         elseif (((-p+1)/"-") and ((-p+2).p < ec)) then
            p=p+2
            if -p-2 <= c and c <= p then
               return sig
            end
         elseif p/c then
            return sig
         end
      end
      return not sig
   end
   local function singlematch(c,p,ep)
      print("singlematch",c,p,ep)
      if p/"." then
         return 1
      elseif p/L_ESC then
         return match_class(c,-p+1)
      elseif p/"[" then
         return matchbracketclass(c,p,-ep-1)
      else
         return p/tostring(c)
      end
   end
   local function matchbalance(ms,s,p)
      if p*0 or (-p+1)*0 then
         error("unbalanced pattern")
      end
      if not s/p then
         return nil
      else
         local b = -p;
         local e = -p+1;
         local cont = 1
         while ((-s+1).p < #ms.src_end) do
            if (s/e) then
               if (cont-1 == 0) then return s+1 end
            elseif s/b then
               cont=cont+1
            end
         end
      end
      return nil
   end
   local function max_expand(ms,s,p,ep)
      print("max_expand",ms,s,p,ep)
      DBG()
      local i = 1
      while ((-s+i).p < ms.src_end and singlematch(-s+i,p,ep)) do
         i=i+1
      end
      while (i>=0) do
         local res = match(ms,-s-i,-ep)
         if res then return res end
         i=i-1
      end
      return nil
   end
   local function min_expand(ms,s,p,ep)
      print("min_expand",ms,s,p,ep)
      while true do
         local res = match(ms,s,ep+1)
         if res~=nil then
            return res
         elseif (s.p<ms.src_end and singlematch(s,p,ep)) then
            s=s+1
         else
            return nil
         end
      end
   end
   local function start_capture(ms,s,p,what)
      local level = ms.level;
      if level >= LUA_MAXCAPTURES then
         error("too many captures")
      end
      ms.capture[level].init = s.p
      ms.capture[level].len = what
      ms.level=ms.level+1
      local res=match(ms,s,p)
      if (res==nil) then
         ms.level=ms.level-1
      end
      return res
   end
   local function end_capture(ms,s,p)
      local l = capture_to_close(ms)
      ms.capture[l].len = s-ms.capture[l].init;
      local res = match(ms,s,p)
      if res == nil then
         ms.capture[l].len = CAP_UNFINISHED
      end
      return res
   end
   local function match_capture(ms,s,l)
      l = check_capture(ms,l)
      local len = ms.capture[l].len
      if (ms.src_end-s.p >= len and string.sub(s.s,ms.capture[l].init) == string.sub(s.s,len)) then
         return s+len
      else
         return nil
      end
   end
   function match(ms,s,p)
      local p=-p
      print('match',tostring(p),tostring(s))
      if p/"(" then
         if (-p+1)/")" then
            return start_capture(ms,s,-p+2,CAP_POSITION)
         else
            return start_capture(ms,s,-p+1,CAP_UNFINISHED)
         end
      elseif p/")" then
         return end_capture(ms,s,-p+1)
      elseif p==L_ESC then
         local n = -p+1
         if n/"b" then
            s=matchbalance(ms,s,-p+2)
            if s==nil then return s end
            p=p+4
            print("submatch-b")
            return match(ms,s,p)
         elseif n/"f" then
            local ep,previous
            p=p+2
            if not p/"[" then
               error("missing [ after %f in pattern")
            end
            ep = classend(ms,p)
            if s.p==ms.src_init then
               previous=""
            else
               previous=tostring(-s-1)
            end
            if matchbracketclass(previous,p,ep-1) or not matchbracketclass(tostring(s),p,ep-1) then
               return nil
            end
            p=ep
            print("submatch-f")
            return match(ms,s,ep)
         else
            if isdigit(tostring(-p+1)) then
               s=match_capture(ms,s,tostring(-p+1))
               if s==nil then return nil end
               p=p+1
               print("submatch-%"..tostring(-p+1))
               return match(ms,s,p)
            end
            dflt=true
         end
      elseif p*0 then
         return s
      elseif p/"$" then
         if ((-p+1)*0) then
            if s*0 then
               return s
            else
               return nil
            end
         else
            dflt=true
         end
      else
         dflt=true
      end
      DBG()
      if dflt then
         print("dflt classend param",-p+1)
         local ep = classend(ms,-p+1)
         local m = (s.p<ms.src_end and singlematch(s,p,ep))
         print("dflt ep,m",ep,m)
         if ep/"?" then
            local res = match(ms,s+1,ep+1)
            if m and res~=nil then
               return res
            end
            p=ep+1
            print("dflt-submatch-optional")
            return match(ms,s,p)
         elseif ep/"*" then
            return max_expand(ms,s,p,ep)
         elseif ep/"+" then
            if m then
               return max_expand(ms,s+1,p,ep)
            else
               return nil
            end
         elseif ep/"-" then
            return min_expand(ms,s,p,ep)
         else
            if not m then
               return nil
            end
            s=s+1
            p=ep
            print("dflt-submatch-fallthrough")
            return match(ms,s,p)
         end
      end
   end
   local function plain_search(l1,l2,init)
      if #l1<#l2 then return false end
      for i=(init or 1),#l1 do
         if string.sub(l1,i,i+#l2-1)==l2 then
            return i
         end
      end
      return false
   end
   local function push_onecapture(ms,i,s,e)
      if s==nil then s=0 end
      if (i>=ms.level) then
         if i==0 then
            return true,s,e-s
         else
            error("invalid capture index ("..i..","..ms.level..")")
         end
      else
         local l = ms.capture[i].len
         if l==CAP_UNFINISHED then
            error("unfinished capture")
         end
         if l==CAP_POSITION then
            return false,ms.capture[i].init-ms.src_init+1
         else
            return true,ms.capture[i].init,l
         end
      end
   end
   local function push_captures(ms,s,e)
      local nlevels = (ms.level==0 and s) and 0 or ms.level
      local n = {}
      for i=0,nlevels do
         local vs={push_onecapture(ms,i,s,e)}
         print(i,unpack(vs))
         for si=2,#vs do
            n[#n+1]=vs[si]
         end
      end
      return unpack(n)
   end
   local function string_contains(a,b,init)
      for i=1,#a do
         local c1 = string.sub(a,i,i)
         for si=1,#b do
            if string.sub(b,si,si) == c1 then
               return true
            end
         end
      end
      return false
   end
   local function str_find_aux(l1,l2,init,raw,find)
      if init==nil or init < 0 then
         init=1
      elseif init>#l1 then
         init=#l1
      end
      local s = get_cptr(l1,1)
      local p = get_cptr(l2,1)
      if (find and (raw or not string_contains(l2,SPECIALS))) then
         local s2 = plain_search(l1,l2,init)
         if s2 then
            return s2-s.p,s2-s.p+#l2-1 -- this part works
         end
      else
         local ms = {}
         local anchor = p/"^" and p+1
         local s1 = -s+init
         ms.src_init = s.p
         ms.src_end = s.p+#l1
         ms.capture = {}
         while ((s1+1).p < ms.src_end and not anchor) do
            ms.level = 0
            local res = match(ms,s1,p)
            if res~=nil then
               print('foun',find)
               if (find) then
                  print('epc',push_captures(ms,nil,0))
                  return s1.p-s.p+1,res.p-s.p+1 --,push_captures(ms,nil,0)
               else
                  local va = {push_captures(ms,s1.p,res.p)}
                  print('va',unpack(va))
                  return string.sub(l1,unpack(va))
               end
            end
         end
      end
      return nil
   end
   string.gfind = unimpl('gfind')
   string.gmatch = unimpl('gmatch')
   string.gsub = unimpl('gsub')
   function string.find(s,pattern,init,raw)
      typecheck(s,1,'find',{"string","number"})
      if type(s)=="number" then s=tostring(s) end
      typecheck(pattern,2,'find',{"string","number"})
      if type(pattern)=="number" then pattern=tostring(pattern) end
      typecheck(init,3,'find',{"number","string","nil"})
      if type(init)=="string" then
         local n = tonumber(init)
         if n==nil then typecheck(init,3,'find',"number") end
         init=ni
      elseif init==nil then
         init=1
      end
      typecheck(raw,4,'find',{"boolean","nil"})
      return str_find_aux(s,pattern,init,raw,true)
   end
   function string.match(s,pattern,init)
      typecheck(s,1,'match',{"string","number"})
      if type(s)=="number" then s=tostring(s) end
      typecheck(pattern,2,'match',"string") -- you BETTER not be passing a number as a pattern
      typecheck(init,3,'match',{"number","string","nil"})
      if type(init)=="string" then
         local n = tonumber(init)
         if n==nil then typecheck(init,3,'match',"number") end
         init=ni
      elseif init==nil then
         init=1
      end
      return str_find_aux(s,pattern,init,nil,false)
   end
end
string.format = unimpl('format')
return string
