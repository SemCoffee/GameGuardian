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
 return gg.getValues({{address=Address,flags=gg.TYPE_BYTE}})[1]
end

function ReadInt32(Address)
return gg.getValues({{address = Address, flags = 4 }})[1]
end

local function hexdecode(hex)
   return (hex:gsub("%x%x", function(digits) return string.char(tonumber(digits, 16)) end))
end

function ReadMonoString(monoString)
 local length = ReadInt32(monoString[1].address + 8).value
 local encode={}
 for count=1,length do
   encode[count] = string.format('%2x',ReadByte(monoString[1].address + 0xA + count * 2).value)
 end 
 return hexdecode(table.concat(encode))
end

function GController()
 gg.clearResults()
 local pointer=gg.getRangesList('global-metadata.dat')[1]['start'] + 0x108A00
 local result=gg.getValues({{address=pointer,flags=gg.TYPE_BYTE}})
 gg.setRanges(gg.REGION_C_ALLOC)
 gg.loadResults({result[#result]})
 gg.searchPointer(0)
 result = gg.getResults(2)
 for key, value in pairs(result) do
    -- Endereço de checagem 
    if ReadInt32(value.address - 4).value == 0x1C400001 then
      result= gg.getValues({{address=value.address - 8, flags=4}})
      break
    end
 end 
 gg.clearResults()
 return result
end

function GControllerA(baseAddress)
 gg.clearResults()
 gg.setRanges(gg.REGION_ANONYMOUS)
 gg.loadResults(baseAddress)
 gg.searchPointer(0)
 local tabled ={}
 result = gg.getResults(gg.getResultsCount())
 for key, value in pairs(result) do
    -- Endereço de checagem 
    if ReadInt32(value.address + 0x74).value == 60 then
      if ReadInt32(value.address + 8).value ~=0 then
        result= gg.getValues({{address=value.address, flags=4}})
        break
      end
    end
 end 
 gg.clearResults()
 return result
end

local CBASE = GController()
local r= GControllerA(CBASE)

function ReadList(ListUnity)
  local length = ReadInt32(ListUnity[1].address + 0xC).value
  local pointer = GotoPointer(ListUnity[1].address,{0x8})
  local array={}
  for count=1, length do
     table.insert(array,GotoPointer(pointer[1].address + 0xC,{count * 4})[1])
  end
  return array
end



function MenuPlayer()
 local pointer = GotoPointer(r[1].address,{0x10})
 local playersOnly=ReadList(pointer)
 local choicePlayer = {}
 for key, player in pairs(playersOnly)do 
   local pString = GotoPointer(player.address,{0x54,0xC})
   table.insert(choicePlayer,ReadMonoString(pString))
 end
 gg.choice(choicePlayer)
end

MenuPlayer()