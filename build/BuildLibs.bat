@echo off
setlocal enabledelayedexpansion

echo Checking pre-requisites... 

:: Check if CMake is installed
cmake --version > nul 2>&1
if %errorlevel% NEQ 0 (
    echo Cannot find path to cmake. Is CMake installed? Exiting...
    exit /b -1
) else (
    echo    CMake      - Ready.
) 

for %%B in (DX12 VK) do (
    echo.
    echo Building FSR2 API for %%B...

    REM Create build directory
    if not exist %%B mkdir %%B
    cd %%B

    REM Configure CMake for the backend only
    cmake -A x64 ..\..\src\ffx-fsr2-api -DFFX_FSR2_API_DX12=OFF -DFFX_FSR2_API_VK=OFF -DFFX_FSR2_API_%%B=ON

    REM Build Debug and Release
    cmake --build . --config Debug
    cmake --build . --config Release

    mkdir ..\..\bin\
    move ..\\..\\src\\ffx-fsr2-api\\bin\\ffx_fsr2_api\\*.* ..\\..\\bin\\

    REM Rename .lib files
    pushd ..\..\bin\
    for %%F in (ffx_fsr2_api_*.lib) do (
        set "oldname=%%~nxF"
        set "newname=!oldname:ffx_fsr2_api_=ffx_fsr2_212_api_!"
        if exist "!newname!" (
            del /f /q "!newname!"
        )
        ren "!oldname!" "!newname!"
    )
    popd

    echo FSR2 API for %%B built successfully.

    cd ..
)