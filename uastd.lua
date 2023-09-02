-- TODO: globals...
-- local old_G = _G
-- _G = {}
-- _G._G = _G -- so true
-- for i,v in pairs(require('globals').impl) do
--    _G[i]=v
-- end
-- local pcall,require,getmetatable,setfenv,getfenv = pcall,require,getmetatable,setfenv,getfenv
-- for i=0,256 do
--    local s,r = pcall(getfenv,i)
--    if not s then break end
--    if rawequal(r,old_G) then
--       pcall(setfenv,i,_G)
--    end
-- end
string = require('lstring')
pcall(function()
   getmetatable("").__index = string
end)
table = require('ltable')
io = require('TODO_lio')