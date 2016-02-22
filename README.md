# EEG Dashboard

### Installation

The application is developed using the LAMP stack (Linux, Apache, MySQL and PHP). Follow the steps below to install and run it on your server.

##### Step 1: upload the application files to your server

Use any method you'd like to upload the application files to your server. For the following steps we'll assume the application is located at:

`/opt/eeg-dashboard/`

##### Step 2: initial setup & directory permissions

Run `make` in the application root directory. This will setup directory permissions and will create local configuration files, if needed.

```sh
$ cd /opt/eeg-dashboard && make
```

##### Step 3: configure MySQL connection details

Edit `cfg/db.php` and enter your database name and username/password to connect to the MySQL server.

##### Step 4: (optional) auto-create the MySQL database

If your database is not already created, you can run the following script:

```sh
$ ./bin/db setup --user=<MySQL root user> --pass=<MySQL root pass>
```

This will create a database with the name you provided in Step 3 and a user/pass to access this database. You'll need to provide the MySQL root login details for this to work.

##### Step 5: bootstrap database

```sh
$ make dbreset
```

DO NOT RUN THIS IF YOU ALREADY HAVE DATA IN YOUR DATABASE, IT WILL DELETE EVERYTHING IN THE DATABASE!!!

This will create the required database tables and add some bootstrap data to them. You'll have 2 users created:

Admin: username `admin@example.com` with password `p4ssword`.

Employee: username `employee@example.com` with password `p4ssword`.

To create your "real" admin user, login with the initial admin user and create a new admin. Don't forget to delete the admin/employee users provided by default.

##### Step 6: configure your webserver (Apache)

```
<VirtualHost *:80>
  DocumentRoot /opt/eeg-dashboard/webroot
  ServerName www.eeg-dashboard.com
    
    <Directory "/opt/eeg-dashboard/webroot">
      AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```
