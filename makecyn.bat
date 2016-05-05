rem "C:\My Documents\Dropbox\_VINTAGE PROGRAMMING\_dasm\dasm.exe"
"C:\My Documents\Dropbox\_VINTAGE PROGRAMMING\_dasm\dasm.exe" cynthcart152.asm -f3 -v1 -ocynthcart152.bin -llist.txt
rem ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
rem ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
rem ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
pucrunch cynthcart152.bin cynthcart152stand.cmp -c0 -l0x5000 -d
rem ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
@rem pucrunch cynthcart152.bin cynthcart152.cmp -c0 -l0x5000 -d -m6 -fdelta -fshort
@rem pucrunch cynthcart152.bin cynthcart152.cmp -c0 -l0x5000 -d -m6 -fshort
@rem pucrunch cynthcart152.bin cynthcart152.cmp -c64 -l0x5000 -x0x1000 -d -m6 -fshort -fdelta
pucrunch cynthcart152.bin cynthcart152_comp.prg -c64 -l0x5000 -x0x5000 -d -m6 -ffast -fdelta
rem ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
rem ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
rem ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= ~-= 
@rem "D:\My Documents\_Vintage Programming\Atari 2600 Programming\_Emulators and tools\dasm\bin\dos\dasm.exe" ppt.asm -f3 -v3 -oppt.bin -llist.txt