$env:POWERSHELL_TELEMETRY_OPTOUT = $true
if (-Not (Get-Module -ListAvailable -Name PSFzf))
{
    Install-Module -Name PSFzf
}

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
