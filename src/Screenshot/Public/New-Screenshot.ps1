function New-Screenshot {
    [CmdletBinding(DefaultParameterSetName = 'Coordinates')]
    param(
        [Parameter(ParameterSetName = 'Coordinates', Position = 0)]
        [int]$X = 0,
        [Parameter(ParameterSetName = 'Coordinates', Position = 1)]
        [int]$Y = 0,
        [Parameter(ParameterSetName = 'Coordinates', Position = 2)]
        [int]$Width,
        [Parameter(ParameterSetName = 'Coordinates', Position = 3)]
        [int]$Height
    )

    Add-Type -AssemblyName System.Windows.Forms,System.Drawing
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
    $Bitmap = [System.Drawing.Bitmap]::new($Width, $Height)
    $Graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $Graphic.CopyFromScreen($X, $Y, 0, 0, [System.Drawing.Size]::new($Width, $Height))
    $Bitmap.Save("C:\temp\Screenshots\Screenshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').jpg", [System.Drawing.Imaging.ImageFormat]::Jpeg)
}

New-Screenshot