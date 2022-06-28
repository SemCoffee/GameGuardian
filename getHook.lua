-- Get Hook Adress ARMv7
-- Pass the name of lib...
local lib_name = ''
local lib_address = gg.getRangesList(lib_name)[1]['start']
gg.setRanges(gg.REGION_C_DATA)
gg.searchNumber('E51FF004h',gg.TYPE_DWORD)
local values = gg.getResults(gg.getResultsCount())
for _,v in pairs(values)do
    print(string.format('HOOK: %X \n',v.address - lib_address))
end