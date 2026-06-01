if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
    exit
}

Set-Location $PSScriptRoot

$outputDir = "$PSScriptRoot\kinh-nghiem-qua-du-an-thuc-te"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "kinh-nghiem-qua-du-an-thuc-te.md" |
    Where-Object { $_.FullName -notlike "$outputDir\*" } |
    ForEach-Object {
        $topic  = $_.Directory.Name
        $target = ".\$topic\kinh-nghiem-qua-du-an-thuc-te.md"
        $link   = "$outputDir\$topic.md"

        if (Test-Path $link) { Remove-Item $link -Force }
        New-Item -ItemType SymbolicLink -Path $link -Target $target -Force | Out-Null
    }