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
[PwnedPasswordsDownloader](https://github.com/HaveIBeenPwned/PwnedPasswordsDownloader)
This password audit requires NTLM hashes.
> Download all NTLM hashes to a single txt file called pwnedpasswords_ntlm.txt
`haveibeenpwned-downloader.exe -n pwnedpasswords_ntlm`



## Step 3: Convert hashes in ntds.dit file to Hashcat formatting
> [!TIP]
> Change current directory into workspace directory like `cd c:\temp\audit`

Make sure you have DSInternals installed from here or if you a running Powershell 5 `Install-Module -Name DSInternals -Force`.
Open PowerShell as administrator and run the following:
```
$key = Get-BootKey -SystemHivePath .\registry\SYSTEM
Get-ADDBAccount -All -DBPath '.\Active Directory\ntds.dit' -BootKey $key | Format-Custom -View HashcatNT | Out-File hashes.txt -Encoding ASCII
```

## Step 4: Compare AD Hashes to HIBP password list
Download CompareADHashes.ps1 from here. 
Open PowerShell as administrator and run the following:
```
Import .\CompareADHashes.ps1
CompareADHashes -ADHashes hashes.txt -HashDictionary pwnedpasswords.txt | Out-File PasswordAudit.csv
```
