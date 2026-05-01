function New-Screenshot {
    [CmdletBinding(DefaultParameterSetName = 'Coordinates',SupportsShouldProcess=$true)]
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
        [string]$Path = (Get-Location),

        [Parameter(ParameterSetName = 'WindowTitle', Position = 2)]
        [Parameter(ParameterSetName = 'Coordinates', Position = 5)]
        [Parameter(ParameterSetName = 'CoordinatesWithSize', Position = 3)]
        [string]$FileName = "Screenshot_{0}.jpg" -f (Get-Date -Format "yyyyMMdd_HHmmss")
    )

    Add-Type -AssemblyName System.Windows.Forms,System.Drawing

    switch ($PSCmdlet.ParameterSetName) {
        "Coordinates" {
            if($Width -eq 0) {
                $Width = [System.Windows.Forms.SystemInformation]::VirtualScreen.Width
                if($X -gt 0) {
                    $Width = $Width - $X
                }
            }
            if($Height -eq 0) {
                $Height = [System.Windows.Forms.SystemInformation]::VirtualScreen.Height
                if($Y -gt 0) {
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

    $DestinationPath = Join-Path -Path $Path -ChildPath $FileName
    if ($PSCmdlet.ShouldProcess($DestinationPath, ("Saving Screenshot to path: '{0}'" -f $DestinationPath))) {
        try {
            $Bitmap.Save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            Get-Item -Path $DestinationPath
        } catch {
            throw "Failed to save screenshot to path: '{0}'. Error: {1}" -f $DestinationPath, $_.Exception.Message
        }
    }
}