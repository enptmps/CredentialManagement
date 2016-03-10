Function New-StoredCredential{
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>

    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Name,

        # Credential filename ends with (such as Creds eg corpCreds persCreds clientCreds)
        [Parameter(Mandatory=$false)]
        [string]$FileSuffix = "Cred"
    )

    Begin
    {
        $Cred = Get-Credential
        $Name = $Name + $Suffix
    }
    Process
    {
        New-Variable -Name $Name -Value $cred
    }
    End
    {
    }
}

Function Export-StoredCredential{
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>

    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Path to save clixml objects containing credentials
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Path

    )

    Begin
    {
        $loaded =  Get-Variable | Where-Object {$_.Value -like "System.Management.Automation.PSCredential"}
    }
    Process
    {
        ForEach ($variable in $loaded){
        $varname = $variable.name
        $fullpath = (Join-Path -Path $path -ChildPath $varname) + ".xml"
        Export-Clixml -InputObject $variable -Path $fullpath
        }
    }
    End
    {
    }
}

Function Import-StoredCredential{
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Path to stored clixml objects containing saved credentials
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Path,

        # Credential filename ends with (defaults to Cred eg corpCred persCred clientCred)
        [Parameter(Mandatory=$false)]
        [string]$SearchSuffix = "Cred"
    )

    Begin
    {
        $credFiles = Get-ChildItem -path $Path | Where-Object {($_.name -match "$SearchSuffix") -and ($_.extension -eq ".xml")}
        Write-Verbose "Searching $path for CLIXML files ending in $SearchSuffix.[xml]"
        Write-Verbose "Found these stored credentials matching your search: "
        Write-Verbose "$credfiles"
    }
    Process
    {
        ForEach ($file in $credFiles){
            Write-Verbose "Found $file and beginning import"
            $hold = $file.basename
            $content = Import-Clixml -Path $file.fullname
            New-Variable -Name $hold -Value $content -Scope Global
            Write-Verbose "$content.UserName Variable created with the name $hold in Global scope"
            }
    }
    End
    {
        
    }
}