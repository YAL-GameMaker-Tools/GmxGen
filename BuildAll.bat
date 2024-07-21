del /Q bin\GmxGen.n
haxe build-neko.hxml

nekotools boot bin\GmxGen.n

cd bin
del /Q GmxGen.zip
cmd /C 7z a GmxGen.zip GmxGen.n GmxGen.exe

pause