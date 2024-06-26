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
echo +'exp' to open selection's folder in Explorer;
echo +'c' to copy the selection's path to clipboard;
echo +'del' to delete a file;
echo +'code' to open selection with VsCode;
echo +'cdir' to open selection's directory with VsCode;
echo +'vim' to open selection with vim;
echo +'cd' to open new console window in selection's directory;
echo +'move' to move the selection;
echo DOUBLE SPACE+ENTER or 'ref' to add keywords, 
echo SPACE+ENTER or 'b' to restart the search.
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
) else if "!fileChoice:~-4!"=="move" (
    set /a fileIndex=!fileChoice:~0,-4!
    call :moveFile !fileIndex!
    goto chooseFile
) else if "!fileChoice:~-3!"=="ren" (
    set /a fileIndex=!fileChoice:~0,-3!
    call :renameFile !fileIndex!
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

:moveFile
set "fileIndex=%1"
if defined fileList[%fileIndex%] (
    set "filePath=!fileList[%fileIndex%]!"

    call :selectPredefinedLocation

    :inputLocation
    set /p "newLocation=Enter new path or select a number from the list ('b' or 'space+enter' to go back): "
    echo.

    if "%newLocation%"=="b" (
        goto chooseFile 
    ) else if "%newLocation%"==" " (
        goto chooseFile 
    ) else if exist "!newLocation!\" (
        rem Valid directory path entered
    ) else (
        set "predefinedChoice="
        for /L %%i in (1,1,!count!) do (
            if "!newLocation!"=="%%i" set "predefinedChoice=!location[%%i]!"
        )
        if defined predefinedChoice (
            set "newLocation=!predefinedChoice!"
        ) else (
            echo Invalid location or choice. Please try again.
            goto inputLocation
        )
    )

    move "!filePath!" "!newLocation!\"
    echo File moved successfully.

) else (
    echo Invalid number, please try again.
)
exit /b

:selectPredefinedLocation
set "count=0"

rem *** Read predefined paths from file ***
for /f "tokens=*" %%L in (move_paths.txt) do (
    set /a count+=1
    set "location[!count!]=%%L"  
)

echo Predefined locations:
for /L %%i in (1,1,!count!) do (
    echo %%i. !location[%%i]!
)
echo.
exit /b

:renameFile
if defined fileList[%fileIndex%] (
    set "filePath=!fileList[%fileIndex%]!"
    if exist "!filePath!" (
        echo Current file: !filePath!
        for %%a in ("!filePath!") do (
            set "extension=%%~xa"
        )
        set /p newFileName="Enter new file name without extension: "
        if "!newFileName!"=="" (
            echo Filename cannot be empty.
            exit /b
        )
        set "newFilePath=!fileList[%fileIndex%]!"
        for %%a in ("!newFilePath!") do (
            set "newFilePath=%%~dpa!newFileName!!extension!"
        )
        ren "!filePath!" "!newFileName!!extension!"
        if !errorlevel! equ 0 (
            echo File renamed to !newFilePath!
        ) else (
            echo Failed to rename the file.
        )
    ) else (
        echo File does not exist.
    )
) else (
    echo Invalid number, please try again.
)
exit /b
