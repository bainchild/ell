local function desc()
   it("should pass Lua.org's 5.1 tests (sort.lua)",function()
      require('luaorg51_test_sort')
   end)
   local test_table = {1,2,['a']=true,[4]=false}
   local test_table_2 = {1,2,['a']=true,[4]=false,3}
   local test_table_3 = {}
   local test_table_4 = {[4]=false}
   local test_table_5 = {[-4]=false}
   it("table.setn",function()
      assert.has_error(function() table.setn() end,"bad argument #1 to 'setn' (table expected, got no value)")
      assert.has_error(function() table.setn({}) end,"'setn' is obsolete")
   end)
   it("table.getn",function()
      assert.are.equal(2,table.getn(test_table))
      assert.are.equal(#test_table,table.getn(test_table))
      assert.are.equal(4,table.getn(test_table_2))
      assert.are.equal(#test_table_2,table.getn(test_table_2))
      assert.are.equal(0,table.getn(test_table_3))
      assert.are.equal(#test_table_3,table.getn(test_table_3))
      assert.are.equal(0,table.getn(test_table_4))
      assert.are.equal(#test_table_4,table.getn(test_table_4))
      assert.are.equal(0,table.getn(test_table_5))
      assert.are.equal(#test_table_5,table.getn(test_table_5))
   end)
   it("table.maxn",function()
      assert.are.equal(4,table.maxn(test_table))
      assert.are.equal(4,table.maxn(test_table_2))
      assert.are.equal(0,table.maxn(test_table_3))
      assert.are.equal(4,table.maxn(test_table_4))
      assert.are.equal(0,table.maxn(test_table_5))
   end)
   it("table.insert",function()
      local n = {}
      table.insert(n,1)
      assert.are.same({1},n)
      table.insert(n,2)
      assert.are.same({1,2},n)
      table.insert(n,2,3)
      assert.are.same({1,3,2},n)
      table.insert(n,1,4)
      assert.are.same({4,1,3,2},n)
   end)
   it("table.remove",function()
      local n = {'a',1,'b',2,'c',3,'d',4}
      assert.are.equal(1,table.remove(n,2))
      assert.are.same({'a','b',2,'c',3,'d',4},n)
      assert.are.equal(2,table.remove(n,3))
      assert.are.same({'a','b','c',3,'d',4},n)
      assert.are.equal(3,table.remove(n,4))
      assert.are.same({'a','b','c','d',4},n)
      assert.are.equal(4,table.remove(n,5))
      assert.are.same({'a','b','c','d'},n)
      assert.are.equal('d',table.remove(n))
      assert.are.same({'a','b','c'},n)
   end)
   describe("table.sort",function()
      local n = {4,1,2,8}
      local function shuffle()
         for i=1,10 do
            local ni = ((i-1)%4)+1
            local oi = #n-(ni-1)
            n[ni],n[oi]=n[oi],n[ni]
         end
      end
      local function try()
         table.sort(n)
         assert.are.same({1,2,4,8},n)
         table.sort(n,function(a,b) return a>b end)
         assert.are.same({8,4,2,1},n)
      end
      for i=1,10 do
         shuffle()
         it("attempt #"..i,try)
      end
   end)
   it("table.foreachi",function()
      local n = {'a',1,'b',2,'c',3,'d',4,["naw"]=false}
      local new = {}
      table.foreachi(n,function(i,v)
         assert.are_not.equal(i,'naw')
         new[#new+1]=v
      end)
      assert.are.same({'a',1,'b',2,'c',3,'d',4},new)
      n = {[-1]='a',1,'b',2,'c',3,'d',4}
      new = {}
      table.foreachi(n,function(i,v)
         new[#new+1]=v
      end)
      assert.are.same({1,'b',2,'c',3,'d',4},new)
   end)
   it("table.foreach",function()
      local orig = test_table
      local n = {}
      local function copy(i,v) n[i]=v end
      table.foreach(orig,copy)
      assert.are.same(n,orig)
      orig = test_table_2
      n = {}
      table.foreach(orig,copy)
      assert.are.same(n,orig)
      orig = test_table_3
      n = {}
      table.foreach(orig,copy)
      assert.are.same(n,orig)
      orig = test_table_4
      n = {}
      table.foreach(orig,copy)
      assert.are.same(n,orig)
      orig = test_table_5
      n = {}
      table.foreach(orig,copy)
      assert.are.same(n,orig)
   end)
   it("table.concat",function()
      assert.are.equal("12",table.concat({1,2,[4]='naw'}))
      assert.are.equal("123naw",table.concat({1,2,[4]='naw',3}))
      assert.are.equal("",table.concat({}))
      assert.are.equal("",table.concat({[4]='naw'}))
      assert.are.equal("",table.concat({[-4]='naw'}))
      assert.are.equal("1,2",table.concat({1,2,[4]='naw'},","))
      assert.are.equal("1,2,3,naw",table.concat({1,2,[4]='naw',3},","))
      assert.are.equal("",table.concat({},","))
      assert.are.equal("",table.concat({[4]='naw'},","))
      assert.are.equal("",table.concat({[-4]='naw'},","))
      assert.are.equal("",table.concat({1,2,[4]='naw'},'',3))
      assert.are.equal("3naw",table.concat({1,2,[4]='naw',3},'',3))
      assert.are.equal("",table.concat({},'',3))
      assert.are.equal("",table.concat({[4]='naw'},'',4))
      assert.are.equal("",table.concat({[-4]='naw'},''))
      assert.are.equal("naw",table.concat({[4]='naw'},'',4,4))
      assert.are.equal("naw",table.concat({[-4]='naw'},'',-4,-4))
   end)
   describe("fuzzing #fuzz",function()
      local fuzz = require('luzer').Fuzz
      pending("table.setn",function()end)
      pending("table.getn",function()end)
      pending("table.maxn",function()end)
      pending("table.insert",function()end)
      pending("table.remove",function()end)
      pending("table.sort",function()end)
      pending("table.foreachi",function()end)
      pending("table.foreach",function()end)
      pending("table.concat",function()end)
   end)
end
describe("table",desc)
describe("ltable",function()
   table=require('ltable')
   package.loaded.table=package.loaded.ltable
   desc()
end)
