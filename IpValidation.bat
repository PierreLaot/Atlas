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
@echo off
setlocal EnableExtensions EnableDelayedExpansion

:startLoop
set /p start= Enter ip from or (q)uit :
if "!start!"=="q" goto :eof
call :validateIP %start% bool
if not "!bool!"=="0" (
	echo Error: Please enter a valid IP Address 
	goto :startLoop
)

:endLoop
set /p end= Enter ip to or (q)uit :
if not "!end!"=="q" got :eof
call :validateIP %end% bool
if not "!bool!"=="0" (
	echo Error: Please enter a valid IP Address 
	goto :endLoop
)


::////////////////////////////////////
:://///////// FUNCTIONS //////////////


:: Check the IpAdress  and return 0 if succes,  1 if failed in the second parameter.
:: call ex: call :validateIP 192.1.1.1 bool
:validateIP IpAdress [BoolReturn]

	setlocal	
	set "_return=1"
	echo %~1| findstr /b /e /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" >nul 
	if not errorlevel 1 for /f "tokens=1-4 delims=." %%a in ("%~1") do (
		if %%a gtr 0 if %%a lss 255 if %%b leq 255 if %%c leq 255 if %%d leq 254 set "_return=0"
	)
	endlocal & ( if not "%~2"=="" set "%~2=%_return%" ) & exit /b %_return%

 



