# Change-Default-cron-Password-in-VICIdial
How to Change Default CRON Password in VICIdial

## Login to vicidial shell ##

cd /usr/share/astguiclient

vi /ADMIN_update_cron_pass.pl

copy and paste all the content of https://github.com/liveafzal/Change-Default-cron-Password-in-VICIdial/blob/main/ADMIN_update_cron_pass.pl

:wq

chmod +x ADMIN_update_cron_pass.pl

perl ADMIN_update_cron_pass.pl

it will ask password.
