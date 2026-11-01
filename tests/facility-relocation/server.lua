local source = LoadResourceFile('bob74_ipl', 'dlc_doomsday/facility.lua')
local callbacks, calls, now, resolved = {}, {}, 0, 876543
local function record(name, ...)
 calls[#calls+1] = {name=name,args={...}}
end
local env = {
 exports=function(name,fn) callbacks[name]=fn end,
 vector3=vector3, error=error, ipairs=ipairs, pairs=pairs, type=type,
 GetInteriorAtCoords=function(x,y,z) assert(x==-2300 and y==300 and z==-59);return resolved end,
 RemoveIpl=function(name) record('RemoveIpl',name) end,
 RequestIpl=function(name) record('RequestIpl',name) end,
 GetGameTimer=function() return now end, Wait=function(ms) now=now+ms end,
 print=function(...) record('print',...) end,
 EnableIpl=function(...) record('EnableIpl',...) end,
 SetIplPropState=function(...) record('SetIplPropState',...) end,
 SetInteriorEntitySetColor=function(...) record('SetInteriorEntitySetColor',...) end,
 RefreshInterior=function(...) record('RefreshInterior',...) end,
 GetClosestObjectOfType=function(...) record('GetClosestObjectOfType',...);return 1 end,
}
local chunk,err=load(source,'@shelter-test-facility','t',env)
assert(chunk,err);chunk()
local facility=callbacks.GetDoomsdayFacilityObject()
assert(facility.interiorId==resolved and facility.Ipl.Interior.ipl=='bcl_shelter_bunker')
facility.LoadDefault()
local settings=0
for _,c in ipairs(calls) do
 if c.name=='SetIplPropState' or c.name=='SetInteriorEntitySetColor' or c.name=='RefreshInterior' then
  assert(c.args[1]==resolved,'Setting applied to stale interior ID');settings=settings+1
 elseif c.name=='RemoveIpl' then assert(c.args[1]=='xm_x17dlc_int_placement_interior_33_x17dlc_int_02_milo_')
 elseif c.name=='GetClosestObjectOfType' then assert(c.args[1]<-2200 and c.args[2]<400,'Privacy control was not relocated') end
end
assert(settings>20,'Default settings were not applied')
resolved=876544
assert(callbacks.GetDoomsdayFacilityObject().interiorId==resolved,'Export did not re-resolve ID')
facility.Walls.SetColor(facility.Colors.expertise,0)
resolved=0
assert(not pcall(callbacks.GetDoomsdayFacilityObject),'Missing MLO should fail explicitly')
calls={};facility.LoadDefault();assert(now==15000,'Missing MLO wait must be bounded')
for _,c in ipairs(calls) do assert(c.name~='SetIplPropState','Missing MLO received settings') end
print('[SHELTER-LUA-TEST] PASS: defaults, dynamic IDs, stale-ID rejection, privacy coordinates, bounded missing-MLO handling; native settings='..settings)
