﻿Get-Service -ComputerName HYDPCM339513L | Select @{name='Date ';expression={date}},@{name='ServerName';expression={$_.MachineName}},@{name='ServiceName';expression={$_.Displayname}},status | ConvertTo-Html | Out-File -FilePath C:\temp\serversdate2.html
