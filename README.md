# Screenshot

## Synopsis

A PowerShell module to create Screenshots programmatically.

## Description

Take screenshot via PowerShell of:

- All screens
- Specific Window (by title)
- Specific Coordinates

The Screenshot will be saved in the current directory, but you can specify an own location with `-Path` and `-FileName`.

## Why

It's just a simple wrapper of a few .NET/C# things so you don't have to copy boiler-plate code.

## Getting Started

### Prerequisites

- A Windows Operating System
- Windows PowerShell 5.1 or higher

### Installation

The module is available via the [PowerShell Gallery](https://www.powershellgallery.com/packages/Screenshot).

```powershell
# Install from PowerShell Gallery
Install-Module Screenshot -Repository PSGallery

# Alternatively using Microsoft.PowerShell.PSResourceGet
Install-PSResource Screenshot -Repository PSGallery
```

### Quick start

#### Example1

```powershell
# Take a screenshot of all screens
New-Screenshot
```

#### Example 2

```powershell
# Take a screenshot of all screens and save it in C:\temp
New-Screenshot -Path C:\temp
```

#### Example 3

```powershell
# Take a screenshot of a specific Window named "Calculator"
New-Screenshot -WindowTitle "Calculator"
```

#### Example 4

```powershell
# Take a screenshot of all screens and specify the filename
New-Screenshot -FileName "MyCoolScreenshot.jpg"
```

## Author

Andreas Dieckmann / diecknet
