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
setlocal EnableDelayedExpansion
set /p keystring=Enter a keystring for the search: 
set timestamp=%DATE:/=-%_%TIME::=-%
set timestamp=%timestamp: =%

set numbers=
for /F "delims=:" %%a in ('findstr /I /N /C:%keystring% AtlasRawResult_%timestamp%.txt') do (
   set /A current=%%a, after=%%a+1
   set "numbers=!numbers!!current!: !after!: "
)

(for /F "tokens=1* delims=:" %%a in ('findstr /N "^" AtlasRawResult_%timestamp%.txt ^| findstr /B "%numbers%"') do echo %%b ) > AtlasSearchResults_%keystring%.txt


echo.
echo Search Finished! Press (q)uit or any other key to display the results
echo .
type AtlasSearchResults_%keystring%.txt

pause