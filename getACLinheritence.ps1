get-acl D:\TestInher

GET-ACL D:\TestInher\Level1 | where {$_.Access.IsInherited -eq $false}
