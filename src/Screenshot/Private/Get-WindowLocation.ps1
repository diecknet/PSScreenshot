function Get-WindowLocation {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$WindowTitle
    )

    Add-Type @"
        using System;
        using System.Runtime.InteropServices;

        namespace Screenshot {

            public class Window {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

                // From an unknown user on Reddit: https://www.reddit.com/r/PowerShell/comments/2llb4u/comment/cm0e8fi/
                private class unmanaged {
                    // FindWindowByCaption
                    [DllImport("user32.dll", EntryPoint="FindWindow", SetLastError = true)]
                    internal static extern IntPtr FindWindowByCaption(IntPtr ZeroOnly, string lpWindowName);

                }

                // FindWindowByCaption
                public static IntPtr FindWindowByCaption(string Title) {
                    return unmanaged.FindWindowByCaption(IntPtr.Zero, Title);
                }
            }

            public struct RECT {
                public int Left;        // x position of upper-left corner
                public int Top;         // y position of upper-left corner
                public int Right;       // x position of lower-right corner
                public int Bottom;      // y position of lower-right corner
            }
        }
"@

    $ProcessHandle = [Screenshot.Window]::FindWindowByCaption($WindowTitle)
    $Rectangle = [Screenshot.RECT]::New()
    if ([Screenshot.Window]::GetWindowRect($ProcessHandle, [ref]$Rectangle)) {
        return $Rectangle
    } else {
        throw "Failed to get window coordinates for '$WindowTitle'."
    }

}