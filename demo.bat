@echo off
setlocal EnableExtensions
cd /d "%~dp0"

if not exist "pom.xml" exit /b 1
if not exist "comparaison" mkdir "comparaison"

echo ===== BUILD : feature.test.enabled=false =====
call mvn clean package -DskipTests "-Dfeature.test.enabled=false" "-Dquarkus.package.jar.type=uber-jar" "-Dquarkus.package.jar.user-configured-ignored-entries=com/course/TestService.class"
if errorlevel 1 exit /b 1

call :copyRunner "comparaison\bean-desactive.jar"
if errorlevel 1 exit /b 1

echo.
echo ===== BUILD : feature.test.enabled=true =====
call mvn clean package -DskipTests "-Dfeature.test.enabled=true" "-Dquarkus.package.jar.type=uber-jar"
if errorlevel 1 exit /b 1

call :copyRunner "comparaison\bean-active.jar"
if errorlevel 1 exit /b 1

echo.
echo ===== CLASSES TestService : JAR DESACTIVE =====
jar tf "comparaison\bean-desactive.jar" | findstr /L /C:"com/course/TestService"

echo.
echo ===== CLASSES TestService : JAR ACTIVE =====
jar tf "comparaison\bean-active.jar" | findstr /L /C:"com/course/TestService"

exit /b 0

:copyRunner
set "RUNNER="
for %%F in (target\*-runner.jar) do if exist "%%~fF" set "RUNNER=%%~fF"
if not defined RUNNER exit /b 1

copy /Y "%RUNNER%" "%~1" >nul
exit /b %errorlevel%