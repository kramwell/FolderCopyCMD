REM Written by KramWell.com - 20/JUN/15
REM This script copies files and folders from one place to another, compares and outputs the results into a text file.

@echo off
setlocal

echo FolderCopyCMD.bat v.0.6.4
echo This script copies files and folders from one place to another, compares and outputs the results into a text file. 
echo Written by kramwell.com - 20/JUN/15
echo.

:: strVal meanings-
:: 1 | strFrom path cannot be found
:: 2 | strTo path already exists [can be disabled]
:: 3 | strTo path doesn't exist after xcopy has run 
:: 4 | strTo files copied but folder sizes didn't match after check
:: 5 | strTo files copied and size check ok but cant delete strFrom files after
:: 6 | strTo files copied, size check ok and strFrom files deleted. all ok

:: TIP: keep backslash at end of strTo to prevent error

set strFrom="c:\users\%username%\desktop\example1"
set strTo="c:\users\%username%\desktop\example2\"
set textFile="c:\users\%username%\desktop\list.txt"

set xcopyOut=0
set size=0
set size1=0

::if both paths now exist
IF EXIST %strFrom% (set strFromTrue=1)ELSE set strFromTrue=0
IF EXIST %strTo% (set strToTrue=1)ELSE set strToTrue=0
::ECHO %strFromTrue% %strToTrue%

::if first folder exists then start to copy to destination
IF %strFromTrue%==1 GOTO :fromPath ELSE :fromPathNoExist

:fromPathNoExist
echo path doesnt exist, cant copy
set strVal=1
goto:eofFinish

:toPathNoExist
echo ERROR after xcopy, last path doesnt exists
set strVal=3
goto:eofFinish

:FromPathNoDelete
echo path still exists and cant delete
set strVal=5
goto:eofFinish

:toPath
echo ERROR Last path exists
set strVal=2
goto:eofFinish

:fromPath
::if last path exists go to error
IF %strToTrue%==1 GOTO :toPath

echo copying folders and files
::xcopy %strFrom% %strTo% /V /E /Q /G /H /Y /Z > temp.txt 2> temp1.txt

::placed in loop to get output to store in varible, xcopyOut
for /f %%i in ('xcopy %strFrom% %strTo% /V /E /Q /G /H /Y /Z') do set xcopyOut=%%i

echo %xcopyOut% file(s) copied

::V is to verify size of each new files
::E copies dir and sub dir incl. empty ones, use /S to not copy empty folders
::Q doesn't display file names while copying
::G gives ability to copy encrypted files to a non encrypted destination
::H copies hidden and system files
::Y hides confirm if destination file exists
::Z tells xcopy to retry on dropped network connections. 

::check if last path exists, refresh var
IF EXIST %strTo% (set strToTrue=1)ELSE set strToTrue=0
::if last path doesnt exist go to error
IF %strToTrue%==0 GOTO :toPathNoExist

:: check folders are the same size, if so delete first path
for /f "tokens=3" %%A in ('dir /a/s %strFrom%^|find "File(s)"') do set size=%%A
set "size=%size:,=%"
echo Folder contains %size% bytes
for /f "tokens=3" %%A in ('dir /a/s %strTo%^|find "File(s)"') do set size1=%%A
set "size1=%size1:,=%"
echo Folder contains %size1% bytes

::delete folder if file sizes are the same
IF %size%==%size1% GOTO :removeToDir ELSE :folderSizeDiff

::goto:eof

:folderSizeDiff
echo ERROR: Foler size not the same.
set strVal=4
goto:eofFinish

:removeToDir
rd %strFrom% /Q /S
::check if first dir is removed
IF EXIST %strFrom% (set strFromTrue=1)ELSE set strFromTrue=0
::if last path exists go to error
IF %strFromTrue%==1 GOTO :FromPathNoDelete

set strVal=6
echo Remove dir ok
goto:eofFinish

:eofFinish
::echo all results to text file
echo %username%-%strVal%-%xcopyOut%-%size%-%size1%-%date%-%time% >> %textFile%
:: if the txt output file is in use when trying to save data the bat file will wait until the txt file is released.
goto:eof