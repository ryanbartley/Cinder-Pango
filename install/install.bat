
@echo off
setlocal enableextensions

set me=%~n0
set parent=%~dp0
set tmp=%parent%tmp

:: set /p is_32=Enter "32" for 32 bit, "64" for 64 bit version:
set lib_version=64
::if %is_32%==32  (
::    set lib_version=32
::    echo %me%: Copying 32 bit version
::) else (
::    echo %me%: Copying 64 bit version
::)

echo %me%: Parent directory: "%parent%"
echo %me%: Temp directory: "%tmp%"

echo about to delete "%tmp%"
if exist "%tmp%" (
   rmdir "%tmp%" /q /s
   echo "tmp did exist and now it's deleted"
)
mkdir "%tmp%"

echo made tmp

set pango_final_lib_path="%parent%..\lib\msw"
if exist %pango_final_lib_path% rmdir %pango_final_lib_path% /q /s
mkdir %pango_final_lib_path%
echo Final lib path: %pango_final_lib_path%

set pango_final_include_path="%parent%..\include\msw"
if exist %pango_final_include_path% rmdir %pango_final_include_path% /q /s
mkdir %pango_final_include_path%
echo Final include path: %pango_final_include_path%

set version_name=gtk2-gtk3-sdk-2.24.30-3.20.2-2016-04-09-ts-win64
echo "%me%: Downloading %version_name% ..."
set compressed_file="%tmp%\%version_name%.zip"
set compressed_dir="%tmp%\%version_name%"
mkdir %compressed_dir%

start /wait bitsadmin /transfer GTKBundleDownload /download /priority normal http://lvserver.ugent.be/gtk-win64/sdk/%version_name%.zip %compressed_file%

echo "%me%: Decompressing ..."
set PATH=%PATH%;"C:\Program Files\7-Zip\"
7z x %compressed_file% -o%compressed_dir%

echo "%me%: Copying ..."
cd %compressed_dir%\lib

for %%I in (libcairo.dll.a libcairo-gobject.dll.a libcairo-script-interpreter.dll.a 
			libffi.dll.a libfontconfig.dll.a libgio-2.0.dll.a libglib-2.0.dll.a 
			libgmodule-2.0.dll.a libgobject-2.0.dll.a libgthread-2.0.dll.a
			libharfbuzz.dll.a libiconv.dll.a libintl.dll.a libpango.dll.a 
			libpangocairo.dll.a libpangoft2.dll.a libpangowin32.dll.a 
			libpixman-1.dll.a libpng.dll.a libxml2.dll.a
			) do xcopy /F %%I %pango_final_lib_path%

xcopy /s /e %compressed_dir%\lib\glib-2.0\include\glibconfig.h %pango_final_include_path%\glib-2.0
xcopy /s /e %compressed_dir%\include\cairo %pango_final_include_path%\cairo\
xcopy /s /e %compressed_dir%\include\fontconfig %pango_final_include_path%\fontconfig\
xcopy /s /e %compressed_dir%\include\freetype2 %pango_final_include_path%\freetype2\
xcopy /s /e %compressed_dir%\include\glib-2.0 %pango_final_include_path%\glib-2.0\
xcopy /s /e %compressed_dir%\include\harfbuzz %pango_final_include_path%\harfbuzz\
xcopy /s /e %compressed_dir%\include\libpng16 %pango_final_include_path%\libpng16\
xcopy /s /e %compressed_dir%\include\pango-1.0 %pango_final_include_path%\pango-1.0\
xcopy /s /e %compressed_dir%\include\pixman-1 %pango_final_include_path%\pixman-1\

echo "%me%: Cleanup..."
rem cd %parent%
rem rmdir "%tmp%" /q /s
echo "%me%: DONE."