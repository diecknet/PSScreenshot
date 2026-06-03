function Set-DPIAware {
    <#
.SYNOPSIS
Makes the current process DPI aware so screen coordinates are reported in physical pixels.

.DESCRIPTION
When a screen scaling factor (e.g. 200%) is used, a process that is not DPI aware receives
virtualized (scaled down) coordinates and dimensions from the operating system. This causes
screenshots to be captured at the wrong size and position.

Set-DPIAware flags the current process as DPI aware via the Win32 API. It prefers the modern
per-monitor aware context and falls back to the legacy system DPI aware call on older systems.
DPI awareness can only be set once per process, so subsequent calls are effectively ignored.

.OUTPUTS
None

.NOTES
Only has an effect on Windows.
#>
    [CmdletBinding()]
    param()

    # DPI awareness is a Windows-only concept.
    if (-not ($IsWindows -or $env:OS -eq 'Windows_NT')) {
        return
    }

    Add-Type @"
        using System;
        using System.Runtime.InteropServices;

        namespace Screenshot {
            public static class DPI {
                [DllImport("user32.dll")]
                private static extern bool SetProcessDpiAwarenessContext(IntPtr value);

                [DllImport("user32.dll")]
                private static extern bool SetProcessDPIAware();

                // DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
                private static readonly IntPtr PerMonitorAwareV2 = new IntPtr(-4);

                public static void Enable() {
                    try {
                        if (SetProcessDpiAwarenessContext(PerMonitorAwareV2)) {
                            return;
                        }
                    } catch (EntryPointNotFoundException) {
                        // SetProcessDpiAwarenessContext is not available on older Windows versions.
                    }
                    SetProcessDPIAware();
                }
            }
        }
"@ -ErrorAction SilentlyContinue

    try {
        [Screenshot.DPI]::Enable()
    } catch {
        Write-Verbose -Message ("Unable to set process DPI awareness: {0}" -f $_.Exception.Message)
    }
}
