::Copyright (c) 2017 Pierre Laot
::
::Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, 
::including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
::subject to the following conditions:
::
::The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
::
::THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
::IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
::OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

mode 1000
@echo off
@title Atlas 
color C     
type Atlas.txt | more       
echo .
echo Atlas is a reverse DNS mapping tool. It can scan a range up to X.0.0.0 to X.255.255.255 ~= 16,6 Million IPs
echo Please make sure that you have proper authorization of network's owner before using this tool. The Author of Atlas cannot be held responsible for what you will do with this program
echo It is your own responsibilty as user to comply with the law.
echo By continuing, you accept these terms
pause 


:://///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
::////////////////////////////////////////////////////////////////////////////////////////////////////////////// INIT ////////////////////////////////////////////////////////////////////////////////////////////////////////
:://///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

:: Create a log directory for Atlas if it does not exists already
if not exist "Atlas_Logs" mkdir Atlas_Logs


:://///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
::////////////////////////////////////////////////////////////////////////////////////////////////////////////// MAIN MENU ////////////////////////////////////////////////////////////////////////////////////////////////////////
:://///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

setlocal ENABLEDELAYEDEXPANSION
:mainMenu 
echo .
echo .
echo                                                                                                                Available Modes
echo .
echo                                                                                                    (1) Ip analysis       (2) Search in previous record
echo .                                                                                                         
echo                                                                                                                   (q)uit
set  /p mode= Select the mode that you want to use: 

if /I '%mode%'=='1' GOTO:IpFromValidationLoop
if /I '%mode%'=='2' GOTO:SearchMode
if /I '%mode%'=='q' exit
goto :mainMenu

:://///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
::////////////////////////////////////////////////////////////////////////////////////////////////////////////// Modes/////////////////////////////////////////////////////////////////////////////////////////////////////////////
:://///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

:: VALIDATING THE IPs Inputs
:IpFromValidationLoop
set /p start= Enter ip from or (q)uit :
if "!start!"=="q" goto :eof
call :validateIP %start% bool
if not "!bool!"=="1" (
	echo Error: Please enter a valid IP Address 
	goto :IpFromValidationLoop
)
:IpToValidationLoop
set /p end= Enter ip to or (q)uit :
if "!end!"=="q" goto :eof
call :validateIP %end% bool
if not "!bool!"=="1" (
	echo  !bool! Error: Please enter a valid IP Address 
	goto :IpToValidationLoop
)


set count=0
set perc=0
set timestamp=%DATE:/=-%_%TIME::=-%
set timestamp=%timestamp: =%

:: Store the start IP in the  h.i.j.k form
for /f "tokens=1-4 delims=." %%a in ("%start%") do (
		 set h=%%a
		 set i=%%b
		 set j=%%c
		 set k=%%d
	)
:: Store the start IP in the xxx.l.m.n WHERE xxx is the h value (same for start and end IPs)
for /f "tokens=1-4 delims=." %%a in ("%end%") do (
		 set l=%%b
		 set m=%%c
		 set n=%%d
	)
	:: l - i because always positive, after that. 256 Ips from .0 to .255
	set /A tot1 = (!l!-!i!)*256*256
	set /A tot2 = (!j!-!m!)*256
	set /A tot3 = (!k!-!n!)
	::if values are negative transform them into positive numbers
	if %tot2% lss 0 set /A tot2=!tot2!*-1
	if %tot3% lss 0 set /A tot3=!tot3!*-1
	::total number of ip scanned
	set /A total = %tot1%-%tot2%-%tot3%
	:: set total as a positive valu in case l.m and i.j are the same
	if %total% lss 0 set /A total=!total!*-1
	:: ofset for .0 IPs
	set /A total=!total!+1
:: For each ip from the starting ip to the end ip 
for /l %%x in (%i%, 1, 255) do (
	for /l %%y in (%j%, 1, 255) do (
		for /l %%z in (%k%, 1, 255) do (
		 nslookup %h%.%%x.%%y.%%z >> Atlas_Logs\AtlasRawResults_%timestamp%.txt 2>nul
		 :: counter + Display to see progression
		 echo analyzing %h%.%%x.%%y.%%z
		 set /A count=!count!+1 
		 set /A perc= !count!*100/!total!	 
		 echo  !count! / !total! Ip adress analyzed !perc!%% progress
		 :: If end IP matched => exit the for loop
		 if "%%x.%%y.%%z" == "%l%.%m%.%n%" ( goto :endAnalysis )
		 )
		
	)
)
:endAnalysis
echo Ip analysis done !

goto:search

:: starting a keyword search and storing the search results in the logs
:search

set /p keystring=Enter a keystring for the search:

set numbers=
for /F "delims=:" %%a in ('findstr /I /N /C:%keystring% Atlas_Logs\AtlasRawResults_%timestamp%.txt') do (
   set /A current=%%a, after=%%a+1
   set "numbers=!numbers!!current!: !after!: "
)

(for /F "tokens=1* delims=:" %%a in ('findstr /N "^" Atlas_Logs\AtlasRawResults_%timestamp%.txt ^| findstr /B "%numbers%"') do echo %%b ) > Atlas_Logs\AtlasSearchResults_%keystring%_%timestamp%.txt


echo.
echo Search Finished! Press (q)uit or any other key to display the results
echo .
type Atlas_Logs\AtlasSearchResults_%keystring%_%timestamp%.txt
echo .
set /p choice= Do a new search with a different keystring ? (y/n) or press an other key to close Atlas: 
if /I '%choice%'=='y' goto:search
if /I '%choice%'=='n' goto:mainMenu
goto:eof


pause
goto:eof

:: Search mode for previous logs
:SearchMode
	set /p filename=Please enter file name  or (r)eturn: 
	if /I '%filename%'=='r' goto:mainMenu
	call :validateFileName %filename% bool
	if not "!bool!" == "1" (
		echo Error: File not found, please enter a valid file name and make sure the file is in the Atlas_Logs directory: 
		goto :SearchMode
	)
	call :searchInPreviousRecord Atlas_Logs\%filename%


:://///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
::////////////////////////////////////////////////////////////////////////////////////////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////////////////////////
:://///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

:: Check the IpAdress  and return 0 or 1, 0 = failure, 1 = success
:: @param1 Ip Adress to validate  
:: @param2 variable to store the return value 
:: call ex: call :validateIP 192.1.1.1 bool
:validateIP IpAdress [BoolReturnValue]
	setlocal	
	set "_return=0"
	echo %~1| findstr /b /e /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" >nul 
	if not errorlevel 1 for /f "tokens=1-4 delims=." %%a in ("%~1") do (
		if %%a gtr 0 if %%a lss 255 if %%b leq 255 if %%c leq 255 if %%d leq 254 set "_return=1"
	)
	endlocal & ( if not "%~2"=="" set "%~2=%_return%" ) & exit /b %_return%
	
	
:CalculateIpRange start end [code] 	
	
	setlocal
	set "list1[0]=0"
	set "list2[0]=0"
	set "_result[0]=0"
	if not errorlevel 1 for /f "tokens=1-4 delims=." %%a in ("%~1") do (
		list1[0] = %%a
		list1[1] = %%b
		list1[2] = %%c
		list1[3] = %%d
	)
	if not errorlevel 1 for /f "tokens=1-4 delims=." %%a in ("%~2") do (
		list2[0] = %%a
		list2[1] = %%b
		list2[2] = %%c
		list2[3] = %%d
	)
	
	for /l %%i in (0, 1, 3) do (
		for /l %%j in (0, 1, 3) do (
			_result[0] = list1[0] - list2[0]
			_result[1] = list1[1] - list2[1]
			_result[2] = list1[2] - list2[2]
			_result[3] = list1[3] - list2[3]
		)
	 )
	 if not !_result!== "0"  goto :mainMenu
	endlocal & ( if not "%~2"=="" set "%~2=%_return%" ) & exit /b %_return%
	
	
:: Iniate a keystring search in a previous record
:: @param1 name of the file to search in 
:: call ex: call :searchInPreviousRecord myLog.txt
:searchInPreviousRecord filename
	setlocal 
	set /p keystring=Enter a keystring for the search:
	set numbers=
	for /F "delims=:" %%a in ('findstr /I /N /C:%keystring% Atlas_Logs\%filename%') do (
	   set /A current=%%a, after=%%a+1
	   set "numbers=!numbers!!current!: !after!: "
	)
	(for /F "tokens=1* delims=:" %%a in ('findstr /N "^" Atlas_Logs\%filename% ^| findstr /B "%numbers%"') do echo %%b ) > Atlas_Logs\AtlasSearchResults_%keystring%_%timestamp%.txt
	echo .
	echo Search Finished! Press (q)uit or any other key to display the results
	echo .
	type Atlas_Logs\AtlasSearchResults_%keystring%_%timestamp%.txt
	echo .
	set /p choice= Do a new search with a different keystring ? (y/n) or press an other key to return to the main menu : 
	if /I '%choice%'=='y' call :searchInPreviousRecord Atlas_Logs\%filename%
	if /I '%choice%'=='n' goto:mainMenu
	endlocal	
	goto :mainMenu

:: Check the file exists and return 0 or 1, 0 = failure, 1 = success
:: @param1 filename to validate 
:: @param2 variable to store the return value 
:: call ex: call :validateFileName myFile.txt bool
:validateFileName filename [BoolReturnValue]
	setlocal
	set "_return=0"
	if exist Atlas_Logs\%filename% set "_return=1"
	endlocal & ( if not "%~2"=="" set "%~2=%_return%" ) & exit /b %_return%
	
	