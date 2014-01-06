assert(not pcall(function() get_environment() end))
local env = environment()
env:import("Int")
env:add_uvar("Z", level(level("M"), 1))
assert(env:is_ge(level("Z"), level("M")))
local child = env:mk_child()
assert(env:has_children())
assert(child:has_parent())
child:add_var("x", Const("Int"))
for o in child:local_objects() do
   assert(o:get_name() == name("x"))
   print(o)
end
local eenv = empty_environment()
print(not eenv:find_object("Int"))
assert(not pcall(function() env:parent() end))
local p = child:parent()
assert(p:has_children())
assert(not pcall(function() env:add_uvar("Z") end))
child:add_definition("val1", Const("true"), true)
child:add_definition("val2", Const("Bool"), Const("true"), true)
local ok, msg = pcall(function() child:add_definition("val3", Const("Int"), Const("true"), true) end)
assert(not ok)
print(msg)
assert(child:normalize(Const("val2")) == Const("val2"))
child:add_theorem("Th1", Eq(iVal(0), iVal(0)), Const("trivial"))
child:add_axiom("H1", Eq(Const("x"), iVal(0)))
assert(child:has_object("H1"))
local ctx = context(context(), "x", Const("Int"), iVal(10))
assert(child:normalize(Var(0), ctx) == iVal(10))
assert(child:type_check(Var(0), ctx) == Const("Int"))
