@echo off
setlocal enabledelayedexpansion

set "searchPathsFile=search_paths.txt"

:loop
set "keyword="
set /p keyword="Enter the search keyword (or type 'exit' to quit): "
if /i "%keyword%"=="exit" goto :eof
if not defined keyword goto loop

setlocal enabledelayedexpansion
set "fileCount=0"
set "folderCount=0"
set "found=0"

rem --- Search for folders that match the keyword ---
for /f "usebackq tokens=*" %%P in ("%searchPathsFile%") do (
    for /f "tokens=*" %%D in ('dir "%%~P\*%keyword%*" /s /b /ad 2^>nul') do (
        set /a folderCount+=1
        set "folderList[!folderCount!]=%%D" 
        set found=1
    )
)

rem --- Search for files within the found folders and the initial search paths ---
for /f "usebackq tokens=*" %%P in ("%searchPathsFile%") do (
    for /f "tokens=*" %%F in ('dir "%%~P\*%keyword%*" /s /b /a-d 2^>nul') do (
        set /a fileCount+=1
        set "fileList[!fileCount!]=%%F" 
        set found=1
    )
)

rem --- Combine folder and file lists ---
if !found! equ 0 (
    echo Not found.
    goto loop
) else (
    for /l %%I in (1,1,!folderCount!) do (
        set /a fileCount+=1
        set "fileList[!fileCount!]=!folderList[%%I]!"
    )
)

for /l %%I in (1,1,!fileCount!) do (
    echo %%I - !fileList[%%I]!
)

goto chooseFile

:chooseFile
echo ====================================
echo.
echo Enter the number of the file to open,
echo +'exp' to go to file's folder, 
echo +'c' to copy the file path to clipboard, 
echo +'del' to delete a file,
echo +'code' to open file with VsCode
echo +'cdir' to open file's directory with VsCode
echo +'vim' to open file with vim
echo +'cd' to close this script and navigate to file's directory
echo DOUBLE SPACE+ENTER to add keywords, 
echo SPACE+ENTER to restart the search.
echo.
echo ====================================
echo.
set /p fileChoice="Choose an option:"

if "!fileChoice!"==" " goto loop
if "!fileChoice!"=="b" goto loop
if "!fileChoice!"=="  " goto searchInResults
if "!fileChoice!"=="ref" goto searchInResults
if "!fileChoice:~-3!"=="exp" (
    set /a fileIndex=!fileChoice:~0,-3!
    call :goToFolder !fileIndex!
    goto chooseFile
) else if "!fileChoice:~-1!"=="c" ( 
    set /a fileIndex=!fileChoice:~0,-1!
    call :copyToClipboard !fileIndex!
    goto chooseFile
) else if "!fileChoice:~-3!"=="del" (
    set /a fileIndex=!fileChoice:~0,-3!
    call :confirmDelete !fileIndex!
    goto chooseFile
) else if "!fileChoice:~-4!"=="code" (
    set /a fileIndex=!fileChoice:~0,-4!
    call :openWithVSCode !fileIndex!
    goto chooseFile
) else if "!fileChoice:~-4!"=="cdir" (
    set /a fileIndex=!fileChoice:~0,-4!
    call :openDirWithVSCode !fileIndex!
    goto chooseFile
) else if "!fileChoice:~-3!"=="vim" (
    set /a fileIndex=!fileChoice:~0,-3!
    call :openWithVim !fileIndex!
    goto chooseFile
) else if "!fileChoice:~-2!"=="cd" (
    set /a fileIndex=!fileChoice:~0,-2!
    call :openNewWindowInDirectory !fileIndex!
    goto chooseFile
) else (
    set /a fileIndex=!fileChoice!
    call :openFile !fileIndex!
    goto chooseFile
)

:openFile
set fileIndex=%1
if defined fileList[%fileIndex%] (
    set filePath=!fileList[%fileIndex%]!
    start "" "!filePath!"
) else (
    echo Invalid number, please try again.
)
exit /b

:goToFolder
set fileIndex=%1
if defined fileList[%fileIndex%] (
    set "filePath=!fileList[%fileIndex%]!"
    explorer /select,"!filePath!"  
) else (
    echo Invalid number, please try again.
)
exit /b


:confirmDelete
set fileIndex=%1
if defined fileList[%fileIndex%] (
    echo Are you sure you want to delete this file? Press SPACE and then ENTER for Yes, 'N' for No.
    set /p confirm="Confirm (SPACE+ENTER or Y for Yes, 'N' for No): "
    if "!confirm!"==" " (
        del /f "!fileList[%fileIndex%]!"
        echo File deleted.
    ) else if "!confirm!"=="Y" (
        del /f "!fileList[%fileIndex%]!"
        echo File deleted.
    ) else (
        echo Deletion cancelled.
    )
) else (
    echo Invalid number, please try again.
)
exit /b

@echo off
setlocal enabledelayedexpansion

:searchInResults
echo.
echo ====================================
set /p keyword="Enter the new search keyword (or type 'exit' to quit): "
if /i "%keyword%"=="exit" goto :eof

set found=0
set newFileCount=0
set "newFileList="

echo.

for /l %%I in (1,1,!fileCount!) do (
    set "filePath=!fileList[%%I]!"
    if not "!filePath!"=="!filePath:%keyword%=!" (
        set /a newFileCount+=1
        set "newFileList[!newFileCount!]=!filePath!"
        set found=1
        echo !newFileCount! - !filePath!
    )
)

if !found! equ 0 (
    echo Not found.
    goto searchInResults
)

:: Clear the old list
for /l %%I in (1,1,!fileCount!) do (
    set "fileList[%%I]="
)

:: Fill the old list with the new values
for /l %%I in (1,1,!newFileCount!) do (
    set "fileList[%%I]=!newFileList[%%I]!"
)

set /a fileCount=!newFileCount!

goto chooseFile

:copyToClipboard
set fileIndex=%1
if defined fileList[%fileIndex%] (
    set filePath=!fileList[%fileIndex%]!
    echo !filePath! | clip
    echo File path copied to clipboard.
) else (
    echo Invalid number, please try again.
)
exit /b

:openWithVSCode
set fileIndex=%1
if defined fileList[%fileIndex%] (
    set filePath=!fileList[%fileIndex%]!
    code "!filePath!" 
) else (
    echo Invalid number, please try again.
)
exit /b

:openDirWithVSCode
set fileIndex=%1
if defined fileList[%fileIndex%] (
    set "filePath=!fileList[%fileIndex%]!"
    for %%P in ("!filePath!") do code "%%~dpP"
) else (
    echo Invalid number, please try again.
)
exit /b

:openWithVim
set fileIndex=%1
if defined fileList[%fileIndex%] (
    set filePath=!fileList[%fileIndex%]!
    vim "!filePath!" 
) else (
    echo Invalid number, please try again.
)
exit /b

:openNewWindowInDirectory
set fileIndex=%1
if defined fileList[%fileIndex%] (
    set "filePath=!fileList[%fileIndex%]!"
    for %%P in ("!filePath!") do start cmd /k "cd /d "%%~dpP""
) else (
    echo Invalid number, please try again.
)
exit /b