# setup
# Run in powershell with the following command:
# powershell -executionpolicy bypass -File .\resources-setup.ps1

$TEMP_FOLDER = $env:USERPROFILE +"\Documents\Development\temp"
$INSTALL_FOLDER = $env:USERPROFILE +"\Documents\Development\Tools"
$ENV_FILE_FOLDER = $env:USERPROFILE +"\Documents"

Function CopyAndExtract {
    param($InstallDirectory)
    Invoke-WebRequest -Uri "https://github.com/EngineX-GB/resources/releases/download/1.0.0/apache-maven-3.8.6-bin.zip" -OutFile $TEMP_FOLDER\apache-maven-3.8.6-bin.zip
    Expand-Archive -Path $TEMP_FOLDER\apache-maven-3.8.6-bin.zip -DestinationPath $InstallDirectory -Force
    Invoke-WebRequest -Uri "https://github.com/EngineX-GB/resources/releases/download/1.0.0/graalvm-ce-java11-windows-amd64-22.2.0.zip" -OutFile $TEMP_FOLDER\graalvm-ce-java11-windows-amd64-22.2.0.zip
    Expand-Archive -Path $TEMP_FOLDER\graalvm-ce-java11-windows-amd64-22.2.0.zip -DestinationPath $InstallDirectory -Force
}

Function CreateDirectory {
    param($Directory)
    if (Test-Path -Path $Directory) {
        Write-Output ($Directory + " exists")
    } else {
        New-Item -ItemType Directory -Path $Directory
    }

}

Function GenerateEnvironmentFile {
    Param([string]$InstallDirectory, [string]$EnvFileFolder)
    $CONTENT = "SET M2_HOME=" + $InstallDirectory + "\apache-maven-3.8.6" +
    "`n" +
    "SET JAVA_HOME=" + $InstallDirectory + "\graalvm-ce-java11-22.2.0" +
    "`n" +
    "SET PATH=%PATH%;%JAVA_HOME%\bin;%M2_HOME%\bin"

    Set-Content -Path $EnvFileFolder\setenv.bat -Value $CONTENT
}

CreateDirectory($TEMP_FOLDER)
CreateDirectory($INSTALL_FOLDER)
CopyAndExtract($INSTALL_FOLDER)
GenerateEnvironmentFile $INSTALL_FOLDER $ENV_FILE_FOLDER