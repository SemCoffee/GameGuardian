-- Criado por !SemCafe
-- Update 8/Julho/2022

BASE_ADDRESS = {}
BASE_CLASS_POINTER={}
function WriteInt32(Address,Value)
return gg.setValues({{flags=4, address = Address, value = Value}});
end

function WriteByte(Address, Value)
 gg.setValues({{address= Address,flags= gg.TYPE_BYTE, value= Value}})
end

function WriteFloat(Address, Value)
  gg.setValues({{address= Address,flags=gg.TYPE_FLOAT, value=Value}})
end

function GotoPointer(addr,offsets)
  local r = {{address=addr,flags=4}}
  for i =1, #offsets do
    r= gg.getValues({{address=r[#r].address+offsets[i],flags=4}})
    r= gg.getValues({{address=r[#r].value,flags=4}})  
  end
  return r
end

function ReadByte(Address)
 return gg.getValues({{address=Address,flags=gg.TYPE_BYTE}})[1].value
end

function ReadInt32(Address)
return gg.getValues({{address = Address, flags = 4 }})[1].value
end

function CheckTypeDef(addr,Value)
 local IndexTypeDef = ReadInt32(addr + 0x8)
 if IndexTypeDef == Value then
    return gg.getValues({{address=addr - 8, flags=4}})
 end
 return nil
end

function get_region()
   local ranges = gg.getRangesList('[anon:libc_malloc]');
   if ranges[1] ~= nil then
    return gg.REGION_C_ALLOC
   else 
    return gg.REGION_ANONYMOUS
   end
end 

function GetBasePointer(rangeName,offset,value)
 gg.clearResults()
 local pointer =gg.getRangesList(rangeName)[1]['start'] + offset
 gg.setRanges(get_region())
 gg.loadResults({{address=pointer,flags=gg.TYPE_BYTE}})
 gg.searchPointer(0)
 local pointers = gg.getResults(gg.getResultsCount())
 for key, pointer in pairs(pointers) do
   local result = CheckTypeDef(pointer.address, value)
   if result ~= nil then
      gg.clearResults()
      return result;
   end
 end
 gg.clearResults()
 return nil
end

function GetClassPointer(tableAddr, funcLogic)
 gg.clearResults()
 gg.setRanges(gg.REGION_ANONYMOUS)
 gg.loadResults(tableAddr)
 gg.searchPointer(0)
 local pointers = gg.getResults(gg.getResultsCount())
 for key, pointer in pairs(pointers) do
   local result = funcLogic(pointer);
   if result ~= nil then
      gg.clearResults()
      return result;
   end
 end
 gg.clearResults()
 return nil
end

function LogicFilter(x)
   local start_address = x.address

   if ReadInt32(start_address + 0x4) == 0 and
      ReadInt32(start_address + 0x8 )~=0 then
      return gg.getValues({{address = start_address, flags= 4}})
   end
   return nil
end 


local base = GetBasePointer("global-metadata.dat",0xC80A2,4372)
local class = GetClassPointer(base,LogicFilter)
local Weapons = GotoPointer(class[1].address,{0x3C, 0x20})
gg.loadResults(Weapons)