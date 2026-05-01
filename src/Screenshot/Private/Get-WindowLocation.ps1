function Get-WindowLocation {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$WindowTitle
    )

    $ProcessHandle = [Window]::FindWindowByCaption($WindowTitle)
    $Rectangle = [Rect]::New()
    if ([Window]::GetWindowRect($ProcessHandle, [ref]$Rectangle)) {
        return $Rectangle
    } else {
        throw "Failed to get window coordinates for '$WindowTitle'."
    }

}