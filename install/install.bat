
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

set ssl_final_lib_path="%parent%..\lib\msw"
if exist %ssl_final_lib_path% rmdir %ssl_final_lib_path% /q /s
mkdir %ssl_final_lib_path%
echo Final lib path: %ssl_final_lib_path%

set ssl_final_include_path="%parent%..\include\msw"
if exist %ssl_final_include_path% rmdir %ssl_final_include_path% /q /s
mkdir %ssl_final_include_path%
echo Final include path: %ssl_final_include_path%

set version_name=gtk2-gtk3-sdk-2.24.30-3.20.2-2016-04-09-ts-win64
echo "%me%: Downloading %version_name% ..."
set compressed=%tmp%\%version_name%.zip
mkdir %tmp%\%version_name%

start /wait bitsadmin /transfer GTKBundleDownload /download /priority normal http://lvserver.ugent.be/gtk-win64/sdk/%version_name%.zip %compressed%

echo "%me%: Decompressing ..."
set PATH=%PATH%;C:\Program Files\7-Zip\
7z x %compressed% -o%tmp%\%version_name%

echo "%me%: Copying ..."
cd %tmp%\%version_name%\lib\

for %%I in (libgio-2.0.a libglib-2.0.a libgmodule-2.0.a libgobject-2.0.a libgthread-2.0.a libpango-1.0.a libpangocairo-1.0.a libpangoft2-1.0.a libpng.a libpixman-1.a libcairo.a libharfbuzz.a libfontconfig.a libfreetype.a) do xcopy /F %%I "%ssl_final_lib_path%\"

xcopy /s /e "%tmp%\%version_name%\include\cairo" %ssl_final_include_path%\cairo\
xcopy /s /e "%tmp%\%version_name%\include\fontconfig" %ssl_final_include_path%\fontconfig\
xcopy /s /e "%tmp%\%version_name%\include\freetype2" %ssl_final_include_path%\freetype2\
xcopy /s /e "%tmp%\%version_name%\include\glib-2.0" %ssl_final_include_path%\glib-2.0\
xcopy /s /e "%tmp%\%version_name%\include\harfbuzz" %ssl_final_include_path%\harfbuzz\
xcopy /s /e "%tmp%\%version_name%\include\libpng16" %ssl_final_include_path%\libpng16\
xcopy /s /e "%tmp%\%version_name%\include\pango-1.0" %ssl_final_include_path%\pango-1.0\
xcopy /s /e "%tmp%\%version_name%\include\pixman-1" %ssl_final_include_path%\pixman-1\

echo "%me%: Cleanup..."
cd %parent%
rmdir "%tmp%" /q /s
echo "%me%: DONE."

PAUSE