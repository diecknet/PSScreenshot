function New-Screenshot {
    <#
.SYNOPSIS
Captures a screenshot and saves it as a JPEG file.

.DESCRIPTION
New-Screenshot captures either a screen region by coordinates or a window by title,
then saves the image to the specified path and file name.

.PARAMETER X
The X coordinate of the upper-left corner of the capture area (optional).

.PARAMETER Y
The Y coordinate of the upper-left corner of the capture area (optional).

.PARAMETER Width
The width of the capture area (optional).

.PARAMETER Height
The height of the capture area (optional).

.PARAMETER WindowTitle
The title of the window to capture when using the WindowTitle parameter set (optional).

.PARAMETER Path
The directory where the screenshot will be saved. Defaults to the current location.

.PARAMETER FileName
The output file name. Defaults to Screenshot_yyyyMMdd_HHmmss.jpg.

.EXAMPLE
New-Screenshot

Captures the full virtual screen and saves it to the current directory.

.EXAMPLE
New-Screenshot -X 100 -Y 100 -Width 800 -Height 600 -Path C:\Temp -FileName region.jpg

Captures a region starting at (100,100) with size 800x600 and saves it to C:\Temp\region.jpg.

.EXAMPLE
New-Screenshot -WindowTitle "Notepad" -Path C:\Temp

Captures the Notepad window and saves it to C:\Temp using the default file name.

.OUTPUTS
System.IO.FileInfo

Returns the saved screenshot file when successful.

.NOTES
Supports -WhatIf and -Confirm via ShouldProcess.
#>
    [CmdletBinding(DefaultParameterSetName = 'Coordinates', SupportsShouldProcess = $true)]
    param(
        [Parameter(ParameterSetName = 'Coordinates', Position = 0)]
        [Parameter(ParameterSetName = 'CoordinatesWithSize', Position = 0)]
        [int]$X = 0,
        [Parameter(ParameterSetName = 'Coordinates', Position = 1)]
        [Parameter(ParameterSetName = 'CoordinatesWithSize', Position = 1)]
        [int]$Y = 0,
        [Parameter(ParameterSetName = 'Coordinates', Position = 2)]
        [int]$Width,
        [Parameter(ParameterSetName = 'Coordinates', Position = 3)]
        [int]$Height,

        [Parameter(ParameterSetName = 'WindowTitle', Position = 0)]
        [string]$WindowTitle,

        [Parameter(ParameterSetName = 'WindowTitle', Position = 1)]
        [Parameter(ParameterSetName = 'Coordinates', Position = 4)]
        [Parameter(ParameterSetName = 'CoordinatesWithSize', Position = 2)]
        [string]$Path,

        [Parameter(ParameterSetName = 'WindowTitle', Position = 2)]
        [Parameter(ParameterSetName = 'Coordinates', Position = 5)]
        [Parameter(ParameterSetName = 'CoordinatesWithSize', Position = 3)]
        [string]$FileName = "Screenshot_{0}.jpg" -f (Get-Date -Format "yyyyMMdd_HHmmss")
    )

    Add-Type -AssemblyName System.Windows.Forms, System.Drawing

    switch ($PSCmdlet.ParameterSetName) {
        "Coordinates" {
            if ($Width -eq 0) {
                $Width = [System.Windows.Forms.SystemInformation]::VirtualScreen.Width
                if ($X -gt 0) {
                    $Width = $Width - $X
                }
            }
            if ($Height -eq 0) {
                $Height = [System.Windows.Forms.SystemInformation]::VirtualScreen.Height
                if ($Y -gt 0) {
                    $Height = $Height - $Y
                }
            }
            break
        }
        "WindowTitle" {
            $Coordinates = Get-WindowLocation -WindowTitle $WindowTitle
            $X = $Coordinates.Left
            $Y = $Coordinates.Top
            $Width = $Coordinates.Right - $Coordinates.Left
            $Height = $Coordinates.Bottom - $Coordinates.Top
            break
        }
    }

    $Bitmap = [System.Drawing.Bitmap]::new($Width, $Height)
    $Graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $Graphic.CopyFromScreen($X, $Y, 0, 0, [System.Drawing.Size]::new($Width, $Height))

    #region Screenshot Destination Path
    if ([string]::IsNullOrEmpty($Path)) {
        $Path = Get-Location
        # Fallback to TEMP if current location is root of C:\ and user is not admin to avoid "Access Denied" error
        # not really necessary, but the previous behavior annoyed me lol
        if ( $Path.ToString() -eq "C:\" -and
            ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -notcontains 'S-1-5-32-544')) {
            $Path = $env:TEMP
        }
    }
    $DestinationPath = Join-Path -Path $Path -ChildPath $FileName
    #endregion Screenshot Destination Path

    #region Save Screenshot
    if ($PSCmdlet.ShouldProcess($DestinationPath, ("Saving Screenshot to path: '{0}'" -f $DestinationPath))) {
        try {
            $Bitmap.Save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            Get-Item -Path $DestinationPath
        } catch {
            throw "Failed to save screenshot to path: '{0}'. Error: {1}" -f $DestinationPath, $_.Exception.Message
        }
    }
    #endregion Save Screenshot
}