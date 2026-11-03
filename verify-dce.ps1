# verify-dce.ps1 - Verifie la presence de MyOptionalService dans les JAR
function Check-Jars($label) {
    $appJar = (Get-ChildItem target\quarkus-app\app\*.jar | Select-Object -First 1).FullName
    $genJar = "target\quarkus-app\quarkus\generated-bytecode.jar"
    Write-Host "`n===== $label =====" -ForegroundColor Cyan
    foreach ($jar in @($appJar, $genJar)) {
        $name = Split-Path $jar -Leaf
        $hits = tar -tf $jar | Select-String "MyOptionalService"
        if ($hits) {
            Write-Host "[PRESENT] $name" -ForegroundColor Green
            $hits | ForEach-Object { "    $_" }
        } else {
            Write-Host "[ABSENT]  $name" -ForegroundColor Red
        }
    }
}

mvn -q clean package
Check-Jars "Build 1 : sans propriete (feature desactivee)"

mvn -q clean package "-Dfeature.X.enabled=true"
Check-Jars "Build 2 : avec -Dfeature.X.enabled=true"