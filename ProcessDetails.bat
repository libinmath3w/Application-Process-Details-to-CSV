@ECHO OFF 

pushd %~dp0

mkdir %USERNAME%

FOR /L %%X IN (100,-1,0) DO (
echo %%X
Powershell.exe -File .\powershellScriptToCSV.ps1 2>&1
timeout 30 > NUL
)