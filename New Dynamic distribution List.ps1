New-DynamicDistributionGroup -Name "DUB All Users" -RecipientFilter {((((RecipientType -eq 'UserMailbox') -and (City -eq 'Dublin'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))} -RecipientContainer "Dublin-IE"


((((RecipientType -eq 'UserMailbox') -and (City -eq 'Dublin'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))
