# Download the Runtime for a service/ application
# Run in powershell with the following command:
# powershell -executionpolicy bypass -File .\Resources-GetRuntime.ps1

$TEMP_FOLDER = $env:USERPROFILE +"\Documents\Production\temp"
$INSTALL_FOLDER = $env:USERPROFILE +"\Documents\Production\runtime"
$AUDIT_PATH = $env:USERPROFILE + "\Documents\Resources\audit"

Function CreateDirectory {
    param($Directory)
    if (Test-Path -Path $Directory) {
        Write-Output ($Directory + " exists")
    } else {
        New-Item -ItemType Directory -Path $Directory
    }

}





Function CheckIfRuntimeExists {
    Param ($AuditPath, $AuditEntry)
    if (Test-Path -Path $AuditPath\audit.json) {
        $FileContentObject = Get-Content -Path $AuditPath\audit.json | ConvertFrom-Json
        if ($FileContentObject -Is [array]) {
            foreach ($Obj in $FileContentObject) {
                if ($Obj.objectName -Eq $AuditEntry.objectName) {
                    if (Test-Path -Path $Obj.location) {
                        return $true
                    }
                }
            }
        } 
        else {
            if ($FileContentObject.objectName -Eq $AuditEntry.objectName) {
                if (Test-Path -Path $FileContentObject.location) {
                    return $true
                }
            }      
          }
    }
    return $false
}



Function UpdateRuntimeAudit{
    Param ($AuditPath, $AuditEntry)
    $ArgsArray = [Collections.Generic.List[Object]]::new()
    if (Test-Path -Path $AuditPath\audit.json) {
        Write-Output ("File: audit.json Exists")
        $FileContentObject = Get-Content -Path $AuditPath\audit.json | ConvertFrom-Json
        if ($FileContentObject -Is [array]) {
            # the object being read from the file is an array of objects
            foreach ($Obj in $FileContentObject) {
                if ($Obj.objectName -Eq $AuditEntry.objectName) {
                    $ArgsArray.Add([Object] $AuditEntry)
                } else {
                    $ArgsArray.Add([Object] $Obj)
                }
            }
            Set-Content -Path $AuditPath\audit.json -Value ($ArgsArray | ConvertTo-Json)
        } else{
            # te object being read from the file is not an array of objects, just a single object
            if ($FileContentObject.objectName -Eq $AuditEntry.objectName) {
                $ArgsArray.add($AuditEntry)
            } else {
                $ArgsArray.add($FileContentObject)
                $ArgsArray.add($AuditEntry)
            }
            Set-Content -Path $AuditPath\audit.json -Value ($ArgsArray | ConvertTo-Json)
        }
    } else {
        New-Item -ItemType Directory -Path $AuditPath
        $ArgsArray.Add([Object] $AuditEntry)
        Set-Content -Path $AuditPath\audit.json -Value ($ArgsArray | ConvertTo-Json)
    }
}

Function DownloadRuntime {

    $entry = [pscustomobject]@{
        objectName = 'JAVA_HOME'
        location =  $INSTALL_FOLDER + '\graalvm-ce-java11-22.2.0'
    }



    $Result =  CheckIfRuntimeExists $AUDIT_PATH $entry
    Write-Output "Runtime exists [$Result]"
    if ($result -Eq $false) {
        # then do the download and the update
        CreateDirectory($TEMP_FOLDER)
        CreateDirectory($INSTALL_FOLDER)

        Invoke-WebRequest -Uri "https://github.com/EngineX-GB/resources/releases/download/1.0.0/graalvm-ce-java11-windows-amd64-22.2.0.zip" -OutFile $TEMP_FOLDER\graalvm-ce-java11-windows-amd64-22.2.0.zip
        Expand-Archive -Path $TEMP_FOLDER\graalvm-ce-java11-windows-amd64-22.2.0.zip -DestinationPath $INSTALL_FOLDER -Force

        UpdateRuntimeAudit $AUDIT_PATH $entry
    }

}

# Run the script to download the required runtime
DownloadRuntime
