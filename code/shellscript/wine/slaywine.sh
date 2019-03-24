mykill -x '.*\.exe' '.*\.EXE' wineserver # 'C:\\.*\.exe'

# winedbg sometimes has a useful error message
mykill -x winedbg
