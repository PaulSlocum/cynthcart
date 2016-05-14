@echo ------------------------------------------------------------------------------------------------------------------------------
dasm cynthcart2.0.asm -f3 -v1 -ocynthcart2.0.prg -DMODE=1 -DDEVICE_CONFIG=0
@echo ------------------------------------------------------------------------------------------------------------------------------
dasm cynthcart2.0.asm -f3 -v1 -ocynthcart2.0_kerberos.prg -DMODE=1 -DDEVICE_CONFIG=1
@echo ------------------------------------------------------------------------------------------------------------------------------
dasm cynthcart2.0.asm -f3 -v1 -ocynthcart2.0_emu.prg -DMODE=1 -DDEVICE_CONFIG=2
@echo ------------------------------------------------------------------------------------------------------------------------------
dasm cynthcart2.0.asm -f3 -v1 -ocynthcart2.0_symphony.prg -DMODE=1 -DDEVICE_CONFIG=3
@echo ------------------------------------------------------------------------------------------------------------------------------

@rem "C:\My Documents\Dropbox\_VINTAGE PROGRAMMING\_dasm\dasm.exe"
dasm cynthcart2.0.asm -f3 -v1 -ocynthcart2.0.bin -DMODE=2 -DDEVICE_CONFIG=0
@echo .   
@echo ______________________________________________________________________________________________________________________________
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
@echo ------------------------------------------------------------------------------------------------------------------------------
@rem pucrunch cynthcart160.bin cynthcart160stand.cmp -c0 -l0x4000 -d
@rem pucrunch cynthcart160.bin cynthcart160.cmp -c0 -l0x5000 -d -m6 -fdelta -fshort
@rem pucrunch cynthcart160.bin cynthcart160.cmp -c0 -l0x5000 -d -m6 -fshort
@rem pucrunch cynthcart160.bin cynthcart160.cmp -c64 -l0x5000 -x0x1000 -d -m6 -fshort -fdelta
@rem ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
pucrunch cynthcart2.0.bin cynthcart2.0_comp.bin -c64 -l0x3000 -x0x3000 -d -m6 -ffast -fdelta
@echo ______________________________________________________________________________________________________________________________
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
@echo ------------------------------------------------------------------------------------------------------------------------------
dasm loader.asm -f3 -v1 -oloader2.0.bin -DMODE=0
@rem "D:\My Documents\_Vintage Programming\Atari 2600 Programming\_Emulators and tools\dasm\bin\dos\dasm.exe" ppt.asm -f3 -v3 -oppt.bin -llist.txt
@echo ------------------------------------------------------------------------------------------------------------------------------
@dir loader2.0.bin /W