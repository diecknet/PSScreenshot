BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'Screenshot'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'Screenshot' {
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Set-DPIAware Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll
        Context 'Success' {

            It 'should not throw when invoked' {
                { Set-DPIAware } | Should -Not -Throw
            } #it

            It 'should be safe to call more than once' {
                Set-DPIAware
                { Set-DPIAware } | Should -Not -Throw
            } #it

        } #context_Success
    } #describe_Set-DPIAware
} #inModule
