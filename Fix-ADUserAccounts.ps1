$ScriptDirectory = 'C:\Tasks_and_Scripts\AD_Maintenance'

Import-Module -Name ActiveDirectory



#### TASK 1: Remove all disabled user accounts from all groups ####
$DisabledAccounts = Get-ADUser -SearchBase 'OU=Disabled User Accounts,DC=efrafa,DC=net' -Filter * -Properties MemberOf
$DisabledAccounts | ForEach-Object { $_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$false }



#### TASK 2: Make sure all accounts in the disabled OU are actually disabled ####
$AccountsToDisable = Get-ADUser -SearchBase 'OU=Disabled User Accounts,DC=efrafa,DC=net' -Filter "Enabled -eq 'True'"
$AccountsToDisable | ForEach-Object { Set-ADUser -Identity $_ -Enabled:$false }



#### TASK 3: Make sure staff accounts do NOT have the following properties checked: ####
####           - User cannot change password                                        ####
####           - Password never expires                                             ####
$StaffAccounts = Get-ADUser -SearchBase 'OU=Staff Accounts,DC=efrafa,DC=net' -Filter *
$StaffAccounts | ForEach-Object { Set-ADUser -Identity $_ -CannotChangePassword $false -PasswordNeverExpires $false }



#### TASK 4: Make sure student accounts have the following property checked: ####
####           - User cannot change password                                 ####
####           - Password never expires                                      ####
$StudentAccounts = Get-ADUser -SearchBase 'OU=Student Accounts,DC=efrafa,DC=net' -Filter *
$StudentAccounts | ForEach-Object { Set-ADUser -Identity $_ -CannotChangePassword $true -PasswordNeverExpires $true }



#### TASK 5: Set all UPNs to efrafa.net ####
$OldSuffix = 'efrafawarren.edu'
$NewSuffix = 'efrafa.net'

# Conform staff users.
$StaffWithUPNIssues = @()
$StaffParent = 'OU=Staff Accounts,DC=efrafa,DC=net'
$Staff = Get-ADUser -SearchBase $StaffParent -Filter *

foreach ($User in $Staff) {
    try {
        $NewUPN = $User.UserPrincipalName.Replace($OldSuffix,$NewSuffix)
        Set-ADUser -Identity $User -UserPrincipalName $NewUPN
    }
    catch {
        $StaffWithUPNIssues += (($User.Surname, $User.GivenName) -join ', ')
    }
}

if ($StaffWithUPNIssues) {
    $StaffWithUPNIssues | Out-File -FilePath "$ScriptDirectory\Staff_With_UPN_Issues.txt"
}

# Conform student users.
$StudentsWithUPNIssues = @()
$StudentParent = 'OU=Student Accounts,DC=efrafa,DC=net'
$Students = Get-ADUser -SearchBase $StudentParent -Filter *

foreach ($User in $Students) {
    try {
        $NewUPN = $User.UserPrincipalName.Replace($OldSuffix,$NewSuffix)
        Set-ADUser -Identity $User -UserPrincipalName $NewUPN
    }
    catch {
        $StudentsWithUPNIssues += (($User.Surname, $User.GivenName) -join ', ')
    }
}

if ($StudentsWithUPNIssues) {
    $StudentsWithUPNIssues | Out-File -FilePath "$ScriptDirectory\Students_With_UPN_Issues.txt"
}

# Conform service accounts:
$ServiceAcctsWithUPNIssues = @()
$ServiceParent = 'OU=Service Accounts,DC=efrafa,DC=net'
$ServiceAccounts = Get-ADUser -SearchBase $ServiceParent -Filter *

foreach ($User in $ServiceAccounts) {
    try {
        $NewUPN = $User.UserPrincipalName.Replace($OldSuffix,$NewSuffix)
        Set-ADUser -Identity $User -UserPrincipalName $NewUPN
    }
    catch {
        $ServiceAcctsWithUPNIssues += (($User.Surname, $User.GivenName) -join ', ')
    }
}

if ($ServiceAcctsWithUPNIssues) {
    $ServiceAcctsWithUPNIssues | Out-File -FilePath "$ScriptDirectory\Students_With_UPN_Issues.txt"
}



### TASK 6: Set all staff accounts' Department attributes. ###
# We're rebuilding this variable from task 2, but I think it makes the code easier to
# understand (even though it's inefficient).
$StaffAccounts = Get-ADUser -SearchBase 'OU=Staff Accounts,DC=efrafa,DC=net' -Filter *

foreach ($Account in $StaffAccounts) {
    # Parse the account object for the name of the containing OU one level under 'Staff Accounts.'
    # We'll set the department attribute to this value.
    $Account02 = $Account.DistinguishedName.Substring($Account.DistinguishedName.IndexOf("OU="))
    $Account03 = $Account02.Split(',')
    $Account04 = $Account03[-6]
    $Account05 = $Account04.Split('=')
    $Department = $Account05[1]

    Set-ADUser -Identity $Account -Department $Department
}



#### TASK 7: Email error reports to IT support staff ####
$Attachments = Get-ChildItem -Path "$ScriptDirectory\*.txt"

if ($Attachments) {
    $EmailSubject = 'Active Directory maintenance errors!'
    $EmailBody = 'Accounts that require manual attention are listed in the attached log files.'

    Send-MailMessage -From 'AD Maintenance <admaint@efrafa.net>' -To 'Help Desk <techsupport@efrafa.net>' `
        -Subject $EmailSubject -Body $EmailBody -SmtpServer 'smtp.efrafa.net' -Attachments $Attachments

    $Attachments | ForEach-Object { Remove-Item -Path $_ }
}