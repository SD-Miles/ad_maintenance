Objective
---------

Programmatically fix the most common human errors in Active Directory account configuration and maintenance.

Tasks
-----

1. Remove all disabled user accounts from all groups
2. Make sure all accounts in the disabled OU are actually disabled
3. Make sure staff accounts do NOT have the following properties checked:
   - User cannot change password
   - Password never expires
4. Make sure student accounts have the following property checked:
   - User cannot change password
5. Set all UPNs to pbsd.net
6. Set all staff accounts' Department attributes.
7. Email log files to IT administrators if errors occur.