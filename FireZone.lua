
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

function GController()
 gg.clearResults()
 local pointer =gg.getRangesList('global-metadata.dat')[1]['start'] + 0xC819F
 local result = gg.getValues({{address=pointer,flags=gg.TYPE_BYTE}})
 gg.setRanges(gg.REGION_C_ALLOC)
 gg.loadResults({result[#result]})
 gg.searchPointer(0)
 result = gg.getResults(2)
 for key, value in pairs(result) do
    -- Endereço de checagem 
    if ReadInt32(value.address - 4).value == 0 then
      result= gg.getValues({{address=value.address - 8, flags=4}})
      break
    end
 end 
 -- Fim de filtragem
gg.clearResults()
return result;
end

-- Procura GameController na região anônima.
function GControllerA()
 gg.clearResults()
 gg.setRanges(gg.REGION_ANONYMOUS)
 gg.loadResults(BaseGController)
 gg.searchPointer(0)
 local r = nil
 local pointers = gg.getResults(gg.getResultsCount())
 for key, pointer in pairs(pointers) do
   if ReadInt32(pointer.address + 8).value ~= 0 then
      r = gg.getValues({{address=pointer.address, flags=4}})
      break
   end
 end
 gg.clearResults()
 return r
end

BaseGController = GController()

function MenuPlayer()
  gg.clearResults()
  local base = GControllerA();
  local index = gg.choice({'INVULNERABLE','SPEEDHACK'})
  if index == 1 then
    --GodMod 
    local fpsplayer = GotoPointer(base[1].address,{0x3C})
    local godmod = ReadByte(fpsplayer[1].address + 0xA5)
    if godmod.value == 0 then
      WriteByte(godmod.address,1)
      gg.toast('✅ GODMOD ATIVADO ✅')
    elseif godmod.value == 1 then
      WriteByte(godmod.address,0)
      gg.toast('❎ GODMOD DESATIVADO ❎')
    end
  elseif index == 2 then
       local movespeed = GotoPointer(base[1].address,{0x3C,0x14})
       WriteFloat(movespeed[1].address + 0x94,3)
  end
  gg.clearResults()
end

function MenuEnemy()
  local base=GControllerA()
  local BotMenu={}
  local ArrayEnemy = GotoPointer(base[1].address,{0x50})
  local length= ReadInt32(ArrayEnemy[1].address+0xC).value

  for i=1,length do
    table.insert(BotMenu,string.format('ENEMY %d',i))
  end

  local index = gg.choice(BotMenu)
  local Enemy = GotoPointer(ArrayEnemy[1].address + 0xC,{index * 4})
  
  gg.loadResults(Enemy)
  
end

function MenuWeapons()
  gg.clearResults()
  local base = GControllerA();
  local index = gg.choice({'BULLETSLEFT','FIRERATE','NORECOIL'})
  if index == 1 then
    local addr_weapon = GotoPointer(base[1].address,{0x3C,0x20})
    WriteInt32(addr_weapon[1].address+0x9C,999)
  elseif index == 2 then
    local addr_weapon = GotoPointer(base[1].address,{0x3C,0x20})
    WriteInt32(addr_weapon[1].address+0xC0,0)
  elseif index == 3 then
    MenuEnemy()
  end
  --gg.clearResults()
end

function Home()
 
    local HomeIndex = gg.choice({'PLAYER', 'WEAPONS', 'SAIR'})
    if HomeIndex==1 then
        MenuPlayer()
    elseif HomeIndex== 2 then
        MenuWeapons()
    elseif HomeIndex==3 then
       os.exit(gg.setVisible(true))
    end

end


while true do
    if gg.isVisible() then
        gg.setVisible(false)
        Home()
    end
end
