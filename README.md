Fix Active Directory Accounts
=============================

While we automate as much account maintenance as possible, changes can be and often are still made by manually, and that leads to mistakes, especially when your staff is green and/or has a high turnover. This is a dead-simple script I wrote to fix the most common mistakes in my organization. It runs on a daily schedule and is anonymized here with a fictional domain, efrafa.net.

Tasks
-----

1. Remove all disabled user accounts from all groups
2. Make sure all accounts in the disabled OU are actually disabled
3. Make sure staff accounts do NOT have the following properties checked:
   - User cannot change password
   - Password never expires
4. Make sure student accounts have the following property checked:
   - User cannot change password
5. Set all UPNs to efrafa.net
6. Set all staff accounts' Department attributes.
7. Email log files to IT administrators if errors occur.