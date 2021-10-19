del /Q bin\GmxGen.n
haxe build-neko.hxml

del /Q bin\GmxGen.exe
haxe build-cs.hxml
copy /Y GmxGen.NET\bin\GenMain.exe bin\GmxGen.exe

cd bin
del /Q GmxGen.zip
cmd /C 7z a GmxGen.zip GmxGen.n GmxGen.exe

pause