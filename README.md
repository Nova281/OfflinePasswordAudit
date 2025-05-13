# OfflinePasswordAudit

## Step 1: Use ntdsutil to get the ntds.dit and SYSTEM hive
On the domain controller, open command prompt and run the following:
```
C:\>ntdsutil

ntdsutil: activate instance ntds
ntdsutil: ifm
ifm: create full c:\temp\audit
ifm: quit
ntdsutil: quit
```

## Step 2: Download the HIBP hash list using PwnedPasswordsDownloader
Follow instructions to download recent HIBP Offline NTLM password list:
[PwnedPasswordsDownloader](https://github.com/HaveIBeenPwned/PwnedPasswordsDownloader)\
This password audit requires NTLM hashes and may take time to download (requires no interruptions).
> Download all NTLM hashes to a single txt file called pwnedpasswords_ntlm.txt
`haveibeenpwned-downloader.exe -n pwnedpasswords_ntlm`



## Step 3: Convert hashes in ntds.dit file to Hashcat formatting
> [!TIP]
> Change current directory into workspace directory like `cd C:\temp\audit`

Make sure you have DSInternals installed from [here](https://github.com/MichaelGrafnetter/DSInternals?tab=readme-ov-file#downloads) or if you a running Powershell 5 `Install-Module -Name DSInternals -Force`.\
Open PowerShell as administrator and run the following:
```
$key = Get-BootKey -SystemHivePath .\registry\SYSTEM
Get-ADDBAccount -All -DBPath '.\Active Directory\ntds.dit' -BootKey $key | Format-Custom -View HashcatNT | Out-File hashes.txt -Encoding ASCII
```

## Step 4: Compare AD Hashes to HIBP password list
Download CompareADHashes.ps1 from [here](https://github.com/Nova281/OfflinePasswordAudit/blob/main/CompareADHashes.ps1). 
Open PowerShell as administrator and run the following:
```
Import-Module c:\temp\audit\CompareADHashes.ps1
Compare-ADHashes -ADHashes "C:\temp\audit\hashes.txt" -HashDictionary "C:\temp\audit\pwnedpasswords_ntlm.txt" | Export-Csv "C:\temp\audit\output.csv" -NoTypeInformation
```

## Step 5: Remove Critical Files
Regardless of the results, it's critical to securely delete both the `ADHashes.txt`, `NTDS.dit`, and `SYSTEM` files immediately after you're done. These files contain sensitive information, and if they fall into the wrong hands, they could lead to serious security or legal consequences.\
Using Sysinternals' [SDelete](https://docs.microsoft.com/en-us/sysinternals/downloads/sdelete) and run the following:
```
.\sdelete.exe -p 7 -r -s <DIRECTORY OR FILE>
```

