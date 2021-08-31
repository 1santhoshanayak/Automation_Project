This automation script was created to preserve logs of apache

This script has been created and tested on Ubuntu 18.04, Hence kindly use Ubuntu 18.04 for testing

The primary function of this script is to achieve

        1.Perform an update of the package details and the package list at the start of the script.
        2.Install the apache2 and awscli package if it is not already installed.
        3.Ensure that the apache2 service is running. 
        4.Ensure that the apache2 service is enabled
        5.Create a tar archive of apache2 access logs and error logs that are present in the /var/log/apache2/ and upload the same to s3 bucket
