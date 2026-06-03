function Get-WindowLocation {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$WindowTitle
    )

    Add-Type @"
        using System;
        using System.Collections.Generic;
        using System.Runtime.InteropServices;
        using System.Text;

        namespace Screenshot {

            public class Window {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

                private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

                // From an unknown user on Reddit: https://www.reddit.com/r/PowerShell/comments/2llb4u/comment/cm0e8fi/
                private class unmanaged {
                    // FindWindowByCaption
                    [DllImport("user32.dll", EntryPoint="FindWindow", SetLastError = true)]
                    internal static extern IntPtr FindWindowByCaption(IntPtr ZeroOnly, string lpWindowName);

                    [DllImport("user32.dll")]
                    internal static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

                    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
                    internal static extern int GetWindowTextLength(IntPtr hWnd);

                    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
                    internal static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

                    [DllImport("user32.dll")]
                    internal static extern bool IsWindowVisible(IntPtr hWnd);
                }

                // FindWindowByCaption
                public static IntPtr FindWindowByCaption(string Title) {
                    return unmanaged.FindWindowByCaption(IntPtr.Zero, Title);
                }

                private static string GetWindowText(IntPtr hWnd) {
                    int length = unmanaged.GetWindowTextLength(hWnd);
                    if (length == 0) {
                        return string.Empty;
                    }
                    StringBuilder builder = new StringBuilder(length + 1);
                    unmanaged.GetWindowText(hWnd, builder, builder.Capacity);
                    return builder.ToString();
                }

                // Enumerate visible top-level windows and return the handle of the first one
                // whose title matches exactly, falling back to a partial (contains) match.
                // This is more robust than FindWindow for modern (UWP-hosted) windows such
                // as the Windows 11 Notepad.
                public static IntPtr FindWindowByPartialCaption(string Title) {
                    IntPtr exactMatch = IntPtr.Zero;
                    IntPtr partialMatch = IntPtr.Zero;

                    unmanaged.EnumWindows(delegate(IntPtr hWnd, IntPtr lParam) {
                        if (!unmanaged.IsWindowVisible(hWnd)) {
                            return true;
                        }
                        string text = GetWindowText(hWnd);
                        if (string.IsNullOrEmpty(text)) {
                            return true;
                        }
                        if (string.Equals(text, Title, StringComparison.OrdinalIgnoreCase)) {
                            exactMatch = hWnd;
                            return false; // stop enumeration on exact match
                        }
                        if (partialMatch == IntPtr.Zero &&
                            text.IndexOf(Title, StringComparison.OrdinalIgnoreCase) >= 0) {
                            partialMatch = hWnd;
                        }
                        return true;
                    }, IntPtr.Zero);

                    return exactMatch != IntPtr.Zero ? exactMatch : partialMatch;
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

    # Fast path: exact match via FindWindow.
    $ProcessHandle = [Screenshot.Window]::FindWindowByCaption($WindowTitle)

    # Fallback: enumerate visible windows for an exact or partial title match.
    # Handles modern (UWP-hosted) windows such as the Windows 11 Notepad.
    if ($ProcessHandle -eq [IntPtr]::Zero) {
        $ProcessHandle = [Screenshot.Window]::FindWindowByPartialCaption($WindowTitle)
    }

    if ($ProcessHandle -eq [IntPtr]::Zero) {
        throw "Failed to find a window with the title '$WindowTitle'."
    }

    $Rectangle = [Screenshot.RECT]::New()
    if ([Screenshot.Window]::GetWindowRect($ProcessHandle, [ref]$Rectangle)) {
        return $Rectangle
    } else {
        throw "Failed to get window coordinates for '$WindowTitle'."
    }

}