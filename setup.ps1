
Function Set-ScriptConfiguration {
    param(
        [string]$namespace,
        [string]$domain,
        [string]$username,
        [string]$InvocationName
    )

    Function Get-Usage {
        param([string]$InvcationName)
        Write-Host "Usage:"
        Write-Host "-n -namespace: vSphere Kubernetes namespace"
        Write-Host ""
        Write-Host "-d -domain: Login Domain name"
        Write-Host ""
        Write-Host "-u -username: Login Username"
        Write-Host ""
        Write-Host "$($InvocationName) -n <namespace> -d <domain> -u <username>"
        Write-Host ""
    }

    Function New-Backup {
        param(
            [string]$folder,
            [System.IO.FileInfo]$file,
            [string]$content
        )
        if (-not $folder -or -not $file -or -not $content) {
            throw("ERROR: Incorrect parameters given")
        }
        if (-not (Test-Path -Path $folder)) {
            $folder = New-Item -Path (Get-Location) -Name $folder -ItemType Directory
            Write-Host "Folder: $($folder)"
        } else {
            $folder = "$(Get-Location)\$($folder)"
        }

        $bakFile = "$($folder)\$($file.Name).bak"
        Set-Content -Path $bakFile -Value $content
    }

    if (-not $namespace -or -not $domain -or -not $username) {
        Get-Usage -InvocationName $InvocationName
        return 1
    }

    $replacementTable = @{
        "<namespace>"   = $namespace
        "<domain>"      = $domain
        "<username>"    = $username
    }

    Write-Host "-- Runtime Settings --"
    foreach ($key in $replacementTable.Keys) {
        $setting = "$($key -replace "<","""" -replace ">",""""): $($replacementTable[$key])"
        $setting = "$($setting.Substring(0,1).ToUpper())$($setting.Substring((1)))"
        Write-Host $setting
    }
    Write-Host ""

    $files = Get-ChildItem -Filter "*.yaml"
    foreach ($file in $files) {
        Write-Host "Updating: $($file.Name)"
        $content = Get-Content -Path $file.FullName -Raw

        foreach ($key in $replacementTable.Keys) {
            if ($content -match $key) {
                New-Backup -folder "backup" -file $file -content $content
                $updatedContent = $content -replace $key,$replacementTable[$key]
                Set-Content -Path $file.FullName -Value $updatedContent
            }
        }
    }
}

# Only run if not Dot-Sourced
$InvocationName = (Get-Variable -Name:MyInvocation).Value.InvocationName
if ($InvocationName -NotLike ".") {
    $args = (Get-Variable -Name:args).Value
    $namespace = $null
    $domain = $null
    $username = $null

    for ($i = 0 ; $i -le $args.Count ; $i+=2) {
        $arg = $args[$i]
        switch($arg) {
            {$arg -eq "-n" -or $arg -eq "-namespace"} {
                $namespace = $args[$i+1]
            }

            {$arg -eq "-d" -or $arg -eq "-domain"} {
                $domain = $args[$i+1]
            }

            {$arg -eq "-u" -or $arg -eq "-username"} {
                $username = $args[$i+1]
            }

        }

    }

    $null = Set-ScriptConfiguration -Namespace $namespace -Domain $domain -Username $username -InvocationName $InvocationName
}
