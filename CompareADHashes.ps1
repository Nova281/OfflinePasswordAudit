function Compare-ADHashes {
<#
.NAME
    CompareADHashes
.SYNOPSIS
    Compares AD Hashes against PwnedPasswords hash ranges
.DESCRIPTION
    Compares NTLM hashes from Active Directory dump against a list of known breached hashes (e.g., Troy Hunt's database).
.PARAMETER ADHashes
    Path to file containing AD hashes in username:hash format.
.PARAMETER HashDictionary
    Path to file containing breached hashes in HASH:count format.
.EXAMPLE
    Compare-ADHashes -ADHashes "C:\temp\hashes.txt" -HashDictionary "C:\temp\pwnedpasswords_ntlm.txt" -Verbose -OutputFile "C:\temp\PasswordAudit.csv"
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $ADHashes,

        [Parameter(Mandatory = $true)]
        [string] $HashDictionary,

        [Parameter(Mandatory = $false)]
        [string] $OutputFile = "PasswordAudit.csv"
    )

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $htADHashes = @{}
    Import-Csv -Delimiter ":" -Path $ADHashes -Header "User","Hash" | ForEach-Object {
        $upperHash = $_.Hash.ToUpper()
        if ($htADHashes.ContainsKey($upperHash)) {
            $htADHashes[$upperHash] += $_.User
        } else {
            $htADHashes[$upperHash] = @($_.User)
        }
    }

    $results = @()

    Get-Content $HashDictionary | ForEach-Object {
        $parts = $_ -split ":"
        $hash = $parts[0].ToUpper()
        $frequency = $parts[1]

        if ($htADHashes.ContainsKey($hash)) {
            foreach ($user in $htADHashes[$hash]) {
                $results += [PSCustomObject]@{
                    User      = $user
                    Frequency = $frequency
                    Hash      = $hash
                }
            }
        }
    }

    $stopwatch.Stop()
    Write-Verbose "Compare-ADHashes completed in $($stopwatch.Elapsed.TotalSeconds) seconds."

    return ($results | Export-Csv $OutputFile  -NoTypeInformation)
}
