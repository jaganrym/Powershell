Start-Transcript

Get-DistributionGroup -ResultSize unlimited | select name,DisplayName,Alias,grouptype,GroupName,PrimarySmtpaddress,ISDirsynced,Managedby | export-csv C:\Output\Allo365Groupsmay25941PM.csv