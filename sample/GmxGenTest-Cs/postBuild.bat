@echo off
rem goto bye
set dllPath=%~1
set solutionDir=%~2
set projectDir=%~3
set arch=%~4
set config=%~5

echo Running post-build for %config%

set extName=GmxGenTest
set dllName=GmxGenTest-Cs

set gmlDir14=%solutionDir%GmxGenTest.gmx
set gmlDir22=%solutionDir%GmxGenTest_GMS22
set gmlDir23=%solutionDir%GmxGenTest_GMS23
set gmlDir2022=%solutionDir%GmxGenTest_GM2022
set gmlDir2023=%solutionDir%GmxGenTest_GM2023
set gmlDir2024=%solutionDir%GmxGenTest_GM2024

set ext14=%gmlDir14%\extensions\%extName%
set ext22=%gmlDir22%\extensions\%extName%
set ext23=%gmlDir23%\extensions\%extName%
set ext2022=%gmlDir2022%\extensions\%extName%
set ext2023=%gmlDir2023%\extensions\%extName%
set ext2024=%gmlDir2024%\extensions\%extName%
set extMain=%ext2024%

set dllRel=%dllName%.dll
set csRel=%dllName%.cs
set csPath=%extMain%\%csRel%
set gmlPath=%extMain%\*.gml
set jsPath=%extMain%\*.js

where /q gmxgen
if %ERRORLEVEL% EQU 0 (
	
	echo Combining the source files...
	type "%projectDir%*.cs" >"%csPath%" 2>nul
	
	echo Running GmxGen...
	
	gmxgen "%extMain%\%extName%.yy" ^
	--copy "%dllPath%" "%dllRel%:%arch%"

	set copyRest=--copy "%dllPath%" "%dllRel%:%arch%" ^
	--copy "%csPath%" "%csRel%" ^
	--copy "%jsPath%" "*.js" ^
	--copy "%gmlPath%" "*.gml"

	gmxgen "%ext2023%\%extName%.yy" %copyRest%
	gmxgen "%ext2022%\%extName%.yy" %copyRest%
	gmxgen "%ext23%\%extName%.yy" %copyRest%
	gmxgen "%ext22%\%extName%.yy" %copyRest%
	gmxgen "%ext14%.extension.gmx" %copyRest%

) else (
	echo postBuild.bat: Error N/A: Could not find GmxGen - extensions will not be updated automatically. See https://github.com/YAL-GameMaker-Tools/GmxGen for setup.
)
:bye