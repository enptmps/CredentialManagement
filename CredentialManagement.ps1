Function New-PSCredential{
<#
.Synopsis
   Store a new credential as a variable
.DESCRIPTION
   New-PSCredential promots you for credentials and saves it to a variable by concatinating 
   the prefix (Name) and Suffix (Suffix) that you give it, by default the suffix is Cred
.EXAMPLE
   ./New-PSCredential
.EXAMPLE
   ./New-PSCredential -Name <variable prefix>
.EXAMPLE
   ./New-PSCredential -Name <variable prefix> -Suffix <variable suffix>
#>

    [CmdletBinding()]
    Param
    (
        # Credential variable name starts with, usually something shorthand to identify the credential
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Name,

        # Credential variable name ends with (such as Cred eg corpCred persCred clientCred)
        [Parameter(Mandatory=$false)]
        [string]$Suffix = "Cred"
    )

    Begin
    {
        $Name = $Name + $Suffix
    }
    Process
    {
        $Cred = Get-Credential
        New-Variable -Name $Name -Value $cred -Scope Global
    }
    End
    {
    }
}

Function Get-PSCredential{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false,
                    Position='0')]
        [string]$Name
        
    )
    If ($name -ne $null){
    Get-Variable $name | Where-Object {$_.Value -like "System.Management.Automation.PSCredential"}
    }
    Else{
    Get-Variable | Where-Object {$_.Value -like "System.Management.Automation.PSCredential"}
    }
    
}

Function Get-StoredPSCredential{
    [CmdletBinding()]
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

    Get-ChildItem -path $Path | Where-Object {($_.name -match "$SearchSuffix") -and ($_.extension -eq ".xml")}
}

Function Export-PSCredential{
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
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [System.Object]$PSCredential,
        
        # Path to save the clixml objects containing credentials to, trys to default to .
        [Parameter(Mandatory=$false)]
        [string]$Path
    )

    Begin
    {
        If (!($Path)){
        $outPath = "."
        }
        Else {$outPath = $Path}
        Write-Verbose "Output path is set to $outPath"
    }

    Process
    {
        Write-Verbose "Input Object is $PSCredential named $($PSCredential.name)"
        $PSVarPath = (Join-Path -Path variable:\ -ChildPath $PSCredential.name)
            Write-Verbose $PSVarPath
        
        Get-Content $PSVarPath | Out-Null
        $PSCredentialObj = Get-Content $PSVarPath
            Write-Verbose "Object Data for $PSCredential is $PSCredentialObj"
        
        $varname = $PSCredential.name
            Write-Verbose "varname is set to $varname"
        
        $fullpath = (Join-Path -Path $outpath -ChildPath $varname) + ".xml"
        Export-Clixml -InputObject $PSCredentialObj -Path $fullpath
            Write-Verbose "Exporting $varname to $fullpath"
    }
    End
    {
    }
}

Function Import-AllStoredPSCredential{
<#
.Synopsis
   Searches a directory for xml files ending with the SearchSuffix (default is Cred) and imports them all as variables 
   with matching names, exampleCred.xml would be imported as exampleCred and called with $exampleCred
.DESCRIPTION
   
.EXAMPLE
   Import-AllStoredPSCredential -Path .
.EXAMPLE
   Import-AllStoredPSCredential -Path . -SearchSuffix CustomCredEnds
#>
    [CmdletBinding()]
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
        # create array containing list of files that match our filter
        $credFiles = Get-ChildItem -path $Path | Where-Object {($_.name -match "$SearchSuffix") -and ($_.extension -eq ".xml")}
        Write-Verbose "Searching $path for CLIXML files ending in $SearchSuffix.[xml]"
        Write-Verbose "Found these stored credentials matching your search: "
        Write-Verbose "$credfiles"
    }
    Process
    {
        # Each entry in the array gets imported individually as a new global variable 
        ForEach ($file in $credFiles){
            Write-Verbose "`n"
            Write-Verbose "Found $file and beginning import"
            $hold = $file.basename
            $content = Import-Clixml -Path $file.fullname
            New-Variable -Name $hold -Value $content -Scope Global
            Write-Verbose "Credential for $($content.UserName) created and stored in the variable $ `b$hold"
            }
    }
    End
    {
        
    }
}