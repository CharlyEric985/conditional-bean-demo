@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem ================================================================
rem DEMONSTRATION QUARKUS - 4 INTERVENANTS
rem 1. Contexte et annotation
rem 2. Construction de deux JAR
rem 3. Comparaison du contenu reel des JAR
rem 4. Lancement et tests HTTP
rem ================================================================

set "TEST_CLASS=com/course/TestService"
set "TEST_SOURCE=src\main\java\com\course\TestService.java"
set "TEST_URL=/hello"
set "DEST=comparaison"

if not exist "pom.xml" (
    echo ERREUR : placer ce BAT a la racine du projet, avec pom.xml.
    goto :error
)
if not exist "%TEST_SOURCE%" (
    echo ERREUR : fichier introuvable : %TEST_SOURCE%
    goto :error
)
if not exist "%DEST%" mkdir "%DEST%"
if errorlevel 1 goto :error

cls
echo ============================================================
echo     DEMONSTRATION QUARKUS - 4 INTERVENANTS
echo ============================================================
echo Projet : conditional-bean-demo
echo Objectif : Mettre en place un mecanisme de compilation conditionnelle dans un microservice Quarkus, permettant d'activer ou de desactiver une fonctionnalite à l'aide d'une simple option lors du build.
echo Chaque intervenant explique sa partie avant de poursuivre.
call :next

rem --------- INTERVENANT 1 : CONTEXTE ---------
cls
echo ============================================================
echo INTERVENANT 1 / ETAPE 1 : OBJECTIF DE LA DEMONSTRATION
echo ============================================================
echo A presenter :
echo - Un microservice peut contenir des composants optionnels.
echo - @IfBuildProperty active ou desactive un bean CDI au build.
echo - Nous allons comparer deux archives JAR pour le prouver.
echo - L'exclusion physique du JAR demande une option distincte.
call :next

cls
echo ============================================================
echo INTERVENANT 1 / ETAPE 2 : LA CLASSE JAVA
echo ============================================================
echo Code reel du fichier %TEST_SOURCE% :
echo.
type "%TEST_SOURCE%"
if errorlevel 1 goto :error
echo.

echo - La propriete feature.test.enabled pilote l'activation CDI.
echo - False n'empeche PAS javac de compiler TestService.java.
call :next

rem --------- INTERVENANT 2 : BUILDS ---------
cls
echo ============================================================
echo INTERVENANT 2 / ETAPE 3 : CONSTRUIRE LE JAR DESACTIVE
echo ============================================================

echo - feature.test.enabled=false desactive le bean CDI.
echo - ignored-entries retire TestService.class du JAR final.
echo - Le code source reste compile dans target/classes.
echo.
echo Commande executee :
echo mvn clean package -DskipTests "-Dfeature.test.enabled=false" "-Dquarkus.package.jar.type=uber-jar" "-Dquarkus.package.jar.user-configured-ignored-entries=%TEST_CLASS%.class"
echo.
call mvn clean package -DskipTests "-Dfeature.test.enabled=false" "-Dquarkus.package.jar.type=uber-jar" "-Dquarkus.package.jar.user-configured-ignored-entries=%TEST_CLASS%.class"
if errorlevel 1 goto :error
call :copyRunner "%DEST%\bean-desactive.jar"
if errorlevel 1 goto :error
call :next

cls
echo ============================================================
echo INTERVENANT 2 / ETAPE 4 : CONSTRUIRE LE JAR ACTIVE
echo ============================================================

echo - feature.test.enabled=true active le bean CDI.
echo - Aucune exclusion physique de la classe n'est demandee.
echo.
echo Commande executee :
echo mvn clean package -DskipTests "-Dfeature.test.enabled=true" "-Dquarkus.package.jar.type=uber-jar"
echo.
call mvn clean package -DskipTests "-Dfeature.test.enabled=true" "-Dquarkus.package.jar.type=uber-jar"
if errorlevel 1 goto :error
call :copyRunner "%DEST%\bean-active.jar"
if errorlevel 1 goto :error
call :next

rem --------- INTERVENANT 3 : INSPECTION ---------
cls
echo ============================================================
echo INTERVENANT 3 / ETAPE 5 : INSPECTER LES DEUX JAR
echo ============================================================
echo Le contenu ci-dessous est lu directement avec jar tf.
echo On affiche uniquement les .class dont le nom commence par TestService.
echo.
jar tf "%DEST%\bean-desactive.jar" > "%DEST%\contenu-desactive.txt"
if errorlevel 1 goto :error
jar tf "%DEST%\bean-active.jar" > "%DEST%\contenu-active.txt"
if errorlevel 1 goto :error
findstr /B /L /C:"%TEST_CLASS%" "%DEST%\contenu-desactive.txt" > "%DEST%\classes-desactive.txt"
findstr /B /L /C:"%TEST_CLASS%" "%DEST%\contenu-active.txt" > "%DEST%\classes-active.txt"
echo ----- JAR DESACTIVE : fichiers TestService -----
for %%F in ("%DEST%\classes-desactive.txt") do if %%~zF EQU 0 echo Aucun fichier TestService trouve.
type "%DEST%\classes-desactive.txt"
echo.
echo ----- JAR ACTIVE : fichiers TestService -----
for %%F in ("%DEST%\classes-active.txt") do if %%~zF EQU 0 echo Aucun fichier TestService trouve.
type "%DEST%\classes-active.txt"
call :next

cls
echo ============================================================
echo INTERVENANT 3 / ETAPE 6 : VERIFIER LE RESULTAT
echo ============================================================
findstr /L /X /C:"%TEST_CLASS%.class" "%DEST%\classes-desactive.txt" >nul
if not errorlevel 1 (
    echo VERIFICATION ECHEC : TestService.class est PRESENT dans le JAR desactive.
    goto :error
)
findstr /L /X /C:"%TEST_CLASS%.class" "%DEST%\classes-active.txt" >nul
if errorlevel 1 (
    echo VERIFICATION ECHEC : TestService.class est ABSENT du JAR active.
    goto :error
)
echo Verification reussie :
echo - TestService.class n'est pas dans bean-desactive.jar.
echo - TestService.class est dans bean-active.jar.
echo.

echo - L'annotation conditionne le bean CDI.
echo - L'option ignored-entries controle le contenu physique du JAR.
call :next

rem --------- INTERVENANT 4 : RUNTIME ---------
cls
echo ============================================================
echo INTERVENANT 4 / ETAPE 7 : DEMARRER LES DEUX APPLICATIONS
echo ============================================================
echo Le JAR desactive va demarrer sur le port 8081.
echo Le JAR active va demarrer sur le port 8082.
echo Deux nouvelles fenetres s'ouvrent pour montrer les logs reels.
echo.
echo A observer : si TestService utilise @Startup, son message de
echo demarrage ne doit apparaitre que dans la version active.
echo.
start "Quarkus DESACTIVE - Port 8081" cmd /k java -Dquarkus.http.port=8081 -jar "%DEST%\bean-desactive.jar"
start "Quarkus ACTIVE - Port 8082" cmd /k java -Dquarkus.http.port=8082 -jar "%DEST%\bean-active.jar"
echo.
echo Verifiez dans les deux fenetres que Quarkus a bien demarre.
call :next

cls
echo ============================================================
echo INTERVENANT 4 / ETAPE 8 : TESTER LES ENDPOINTS HTTP
echo ============================================================
echo Ce test demande a chaque application de repondre a %TEST_URL%.
echo Les deux services peuvent repondre meme si TestService est absent.
echo.
echo ----- Reponse HTTP du JAR DESACTIVE : http://localhost:8081%TEST_URL% -----
curl.exe --silent --show-error --include --max-time 8 "http://localhost:8081%TEST_URL%"
if errorlevel 1 echo Impossible de joindre le port 8081 ou l'endpoint %TEST_URL%.
echo.
echo ----- Reponse HTTP du JAR ACTIVE : http://localhost:8082%TEST_URL% -----
curl.exe --silent --show-error --include --max-time 8 "http://localhost:8082%TEST_URL%"
if errorlevel 1 echo Impossible de joindre le port 8082 ou l'endpoint %TEST_URL%.
echo.
echo Conclusion a presenter :
echo - Les deux JAR demarrent separement.
echo - Le bean CDI est conditionne par @IfBuildProperty.
echo - L'absence physique de la classe est obtenue au packaging.
echo - La classe Java a quand meme ete compilee pendant le build.
echo.
echo Les deux fenetres Quarkus restent ouvertes.
echo Arretez chaque application dans sa fenetre avec Ctrl+C.
call :next
exit /b 0

:next
echo.
echo [Appuyez sur une touche pour passer a l'etape suivante...]
pause >nul
exit /b 0

:copyRunner
set "RUNNER="
for %%F in (target\*-runner.jar) do if exist "%%~fF" set "RUNNER=%%~fF"
if not defined RUNNER (
    echo ERREUR : aucun uber-JAR target\*-runner.jar trouve.
    exit /b 1
)
copy /Y "%RUNNER%" "%~1" >nul
if errorlevel 1 exit /b 1
echo Copie reussie : "%~1"
exit /b 0

:error
echo.
echo ERREUR : demonstration interrompue. Verifiez le message ci-dessus.
pause
exit /b 1
