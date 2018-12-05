@echo ___________________________________________________________________________________________
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-=
@echo -------------------------------------------------------------------------------------------
@echo ** CYNTHCART BUILDER BATCH SCRIPT **
@cd source
@echo ___________________________________________________________________________________________
@echo ASSEMBLING CYNTHCART FOR STANDARD HARDWARE
..\tools\dasm cynthcart.asm -f3 -v1 -o..\bin\cynthcart.prg -DMODE=1 -DDEVICE_CONFIG=0
@echo ___________________________________________________________________________________________
@echo ASSEMBLING CYNTHCART FOR KERBEROS CARTRIDGE
..\tools\dasm cynthcart.asm -f3 -v1 -o..\bin\cynthcart_kerberos.prg -DMODE=1 -DDEVICE_CONFIG=1
@echo ___________________________________________________________________________________________
@echo ASSEMBLING CYNTHCART FOR EMULATION
..\tools\dasm cynthcart.asm -f3 -v1 -o..\bin\cynthcart_emu.prg -DMODE=1 -DDEVICE_CONFIG=2
@echo ___________________________________________________________________________________________
@echo ASSEMBLING CYNTHCART FOR USE WITH SID SYMPHONY
..\tools\dasm cynthcart.asm -f3 -v1 -o..\bin\cynthcart_symphony.prg -DMODE=1 -DDEVICE_CONFIG=3
@echo ___________________________________________________________________________________________
@echo ASSEMBLING CYNTHCART BIN FOR 8K CARTRIDGE
..\tools\dasm cynthcart.asm -f3 -v1 -o..\bin\cynthcartUncompressed.bin -DMODE=2 -DDEVICE_CONFIG=0
@echo .   
@echo ___________________________________________________________________________________________
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-=
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-=
@echo -------------------------------------------------------------------------------------------
@echo COMPRESSING CYNTHCART CARTRIDGE BIN WITH PUNCRUNCH
..\tools\pucrunch ..\bin\cynthcartUncompressed.bin ..\bin\cynthcartRawCompressed.bin -c64 -l0x3000 -x0x3000 -d -m6 -ffast -fdelta
@echo ___________________________________________________________________________________________
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-=
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-=
@echo -------------------------------------------------------------------------------------------
@echo ASSEMBLING CARTRIDGE LOADER
..\tools\dasm cynth_cart_loader.asm -f3 -v1 -o..\bin\cynthcart_cartridge_ROM.bin -DMODE=0 -l..\bin\loaderSymbolList.txt
@echo -------------------------------------------------------------------------------------------
@dir ..\bin\cynthcart_cartridge_ROM.bin /W
@echo ___________________________________________________________________________________________
@echo ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-=
@echo -------------------------------------------------------------------------------------------
cd ..
@echo DONE!
