BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'Screenshot'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'Screenshot' {
    Describe 'New-Screenshot Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll
        Context 'Error' {

            # It 'should ...' {

            # } #it

        } #context_Error
        Context 'Success' {

            BeforeEach {
                #Mock -CommandName Get-Day -MockWith {
                #    'Friday'
                #} #endMock
            } #beforeEach

            It 'should return the expected results' {
                New-Screenshot | Should -BeLike '*Screenshot_*.jpg'
            } #it

        } #context_Success
    } #describe_New-Screenshot
} #inModule

