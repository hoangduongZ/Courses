param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path
)

$path = $Path.Trim().Trim('"').Trim("'")

if ($path -match '^([A-Za-z]):\\(.*)') {
    $drive = $Matches[1].ToLower()
    $rest = $Matches[2] -replace '\\', '/'
    Write-Output "/$drive/$rest"
} else {
    Write-Output ($path -replace '\\', '/')
}

# .\win_to_linux_path.ps1 "D:\hoangdv\Courses\kinh-nghiem-qua-du-an-thuc-te\thuc-hanh-lenh-bash"
# Output: /d/hoangdv/Courses/kinh-nghiem-qua-du-an-thuc-te/thuc-hanh-lenh-bash
