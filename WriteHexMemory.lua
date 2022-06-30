-- Created by !SemCafé
function ToArrayChars(shell)
	local bytes = {}
	shell:gsub('..', function(x)
		table.insert(bytes,x .. 'h')
	end)
   return bytes
end

function WriteMemory(libname, tableHex)
	local range = gg.getRangesList(libname)[1]
	if range == nil then
		print(string.format('The %s, not found', libname))
		return false
	end
	for _,hexInfo in pairs(tableHex) do
		local addr = range['start'] + hexInfo.offset;
		local count = 0;
		for i, v in pairs(ToArrayChars(hexInfo.hex)) do
			gg.setValues({{address=addr + count, flags= gg.TYPE_BYTE, value=v}})
			count = count + 1
		end
	end
end

-- Exemplo 
WriteMemory('libil2cpp.so', {{offset=0, hex='0100A0E31EFF2FE1'}})
