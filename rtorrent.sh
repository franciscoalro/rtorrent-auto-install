#!/bin/bash
#
# Johannes Helgi Laxdal - 25.11.2012
# http://www.laxdal.org
#

## First we need to make sure we are running on Debian 6.x
if [ ! -e "/etc/debian_version" ]; then
        echo "You have the wrong distribution of Linux!.  This script requires Debian so I can't continue, sorry."
        exit
elif [ ! $(cat /etc/debian_version | cut -c1) -eq 6 ]; then
        echo "You have the wrong version of Debian!.  This script requires Debian 6.x so I can't continue, sorry."
        exit
fi

## Create our working directory if it doesn't exist
if [ ! -d "rutorrent" ]; then
  mkdir rutorrent
fi

## Enter our working directory
cd rutorrent

## We need the apache2-util package for htdigest to work
aptitude install -y apache2-utils

## Ask for user input
## Now we need user inputs
echo " "
echo "===================================================================="
echo "Please enter a username and password for the web interface"

## Username
while true; do
        read -p "Username: " _USERNAME
        if [ ! -z "$_USERNAME" ]; then
                break
        fi
        echo "   !Username cannot be empty"
done
htdigest -c passwords rut $_USERNAME

## Email
while true; do
        read -p "Email: " _EMAIL
        if [ ! -z "$_EMAIL" ]; then
                break
        fi
        echo "   !Email cannot be empty"
done

echo " "
echo "You don't need to answer the following questions, they are optional. Just press Enter to use default values."
echo " "

## UID for rtorrent user
while true; do
        read -p "User ID for the RTorrent User : " _USERID

        if [ -z "$_USERID" ]; then
                ## UserID is empty so we just use the default value
                break
        fi

        ## We need to check if we have a number
        if [ $_USERID -eq $_USERID ] 2>/dev/null; then
                ## USERID is a number so we can use it
                break
        fi
        echo "  Input is not valid, either insert a valid number or press enter to accept default values"
done

## GID for the rtorrent www group
while true; do
        read -p "Group ID for the RTorrent WWW group : " _GROUPID
        if [ -z "$_GROUPID" ]; then
                ## GroupID is empty so we just use the default values
                break
        fi

        ## We need to check if we have a number
        if [ $_GROUPID -eq $_GROUPID ] 2>/dev/null; then
                ## GROUPID is a number so we can use it
                break
        fi
        echo "  Input is not valid, either insert a valid number or press enter to accept default values"
done

## Directory for the incoming files
while true; do
        read -p "Directory to store incoming files : " _INCOMINGFOLDER

        ## Check to see if variable are empty
        if [ -z "$_INCOMINGFOLDER" ]; then
                ## it's empty so we just use default
                _INCOMINGFOLDER="/home/rtorrent/downloads/downloading"
                break
        fi

        ## Check to see if directory exists and create it if it doesn't
        if [ ! -d "$_INCOMINGFOLDER"  ]; then
		mkdir -p "$_INCOMINGFOLDER"
		break;
	else
		break;
        fi
        echo "  Invalid input or the directory does not exist, please enter valid path or leave it empty to use default path"
done

## Directory for the completed files
while true; do
        read -p "Directory that completed files will be moved to  : " _COMPLETEDFOLDER

        ## Check to see if variable are empty
        if [ -z "$_COMPLETEDFOLDER" ]; then
                _COMPLETEDFOLDER="/home/rtorrent/downloads/complete/"
                break
        fi

        ## Check to see if it is the same as for incoming
        if [ "$_COMPLETEDFOLDER" = "$_INCOMINGFOLDER" ]; then
                echo "  The incoming and completed directories are the same,  this is not advisable. please choose a new path"
                continue
        fi

        ## Check to see if directory exists and create it if it doesn't
        if [ ! -d "$_COMPLETEDFOLDER" ]; then
		mkdir -p "$_COMPLETEDFOLDER"
                break;
        else
                break;
        fi
        echo "  Invalid input or the directory does not exist, please enter valid path or leave it empty to use default path"
done

## Directory to autoadd .torrent files from
while true; do
        read -p "Directory to autoadd .torrent files from  : " _WATCHFOLDER

        ## Check to see if variable are empty
        if [ -z "$_WATCHFOLDER" ]; then
                ## it's empty so we just use default
                _WATCHFOLDER="/home/rtorrent/watch"
                break
        fi

        ## Check to see if directory exists and create it if it doesn't
        if [ ! -d "$_WATCHFOLDER"  ]; then
                ## Directories do exist so everything is ok
		mkdir -p "$_WATCHFOLDER"
                break;
        else
                break;
        fi
        echo "  Invalid input or the directory does not exist, please enter valid path or leave it empty to use default path"
done


## Network ports to use
while true; do
        read -p "Torrent port to use (lower) : " _LOWERPORTNUMBER
        read -p "Torrent port to use (upper) : " _UPPERPORTNUMBER

        if [ -z "$_LOWERPORTNUMBER" ] && [ -z "$_LOWERPORTNUMBER" ]; then
                ## Both port numbers are empty so we just use the default values
                _LOWERPORTNUMBER="50100"
                _UPPERPORTNUMBER="50200"
                break
        fi

        if [ $_LOWERPORTNUMBER -eq $_LOWERPORTNUMBER ] 2>/dev/null && [ $_UPPERPORTNUMBER -eq $_UPPERPORTNUMBER ] 2>/dev/null; then
                ## Both variables are numbers so we can use them. We need to check if the lower number is lower than the upper one
                if [ $_LOWERPORTNUMBER -gt $_UPPERPORTNUMBER ]; then
                        echo "  Lower number cannot be higher than the upper number. Insert new port numbers or press enter to use default"
                        continue;
                elif [ $_LOWERPORTNUMBER -eq $_UPPERPORTNUMBER  ]; then
                        ## Numbers are the same so it's just single and that is ok
                        break
                else
                        ## everything seems normal
                        break
                fi
        else
                echo "  Input is not valid, either press enter to use default or insert valid numbers"
        fi
done

## DHT Port number
while true; do
        read -p "DHT Port number : " _DHTPORT
        if [ -z "$_DHTPORT" ]; then
                ## DHT port number is empty so we use default
                _DHTPORT="6881"
                break
        fi

        if [ $_DHTPORT -eq $_DHTPORT ] 2>/dev/null; then
                ## DHT Port number is really a number so everything is ok
                break
        fi
        echo "  Input is not valid, either press enter to use default or insert valid number"
done

## Recap the values
echo " "
echo " Values  "
echo " "
echo "Username : '$_USERNAME'"
echo "Email : '$_EMAIL'"
echo "Rtorrent userid : '$_USERID'"
echo "Rtorrent ww groupid : '$_GROUPID'"
echo "Incoming Folder : '$_INCOMINGFOLDER'"
echo "Completed folder : '$_COMPLETEDFOLDER'"
echo "Watch folder : '$_WATCHFOLDER'"
echo "Lower Port Number : '$_LOWERPORTNUMBER'"
echo "Upper Port Number : '$_UPPERPORTNUMBER'"
echo "DHT Port : '$_DHTPORT'"
echo " "
read -p "  Write this down somewhere if you need to and press enter to continue.." _EMPTY


## Update and Install required packages first
aptitude update -y
aptitude upgrade -y
aptitude install -y gcc g++ make subversion gcc ncurses libsigc++-2.0-dev pkg-config libssl0.9.8 libssl-dev libncurses5-dev libcurl4-gnutls-dev php5 php-xml-rpc curl unzip unrar-free ffmpeg tmux apache2 libapache-mod-security

_APTCHECK=$(dpkg-query -W -f='${Status}\n' apache2)
## Make sure Aptitude finished successfully
if [ $? != 0 ] || [ ! -z "$(echo $_APTCHECK | awk 'installed')" ]; then
  echo "!!! Error occured while running aptitude, terminating installation"
  exit
fi

## Install xmlrpc-c package from source
svn co http://xmlrpc-c.svn.sourceforge.net/svnroot/xmlrpc-c/advanced xmlrpc-c
cd xmlrpc-c
./configure
make
make install
cd ..

## Get rtorrent,rutorrent, libtorrent and plugins and build from scratch.
wget http://libtorrent.rakshasa.no/downloads/libtorrent-0.13.2.tar.gz
wget http://libtorrent.rakshasa.no/downloads/rtorrent-0.9.2.tar.gz
wget https://rutorrent.googlecode.com/files/plugins-3.4.tar.gz --no-check-certificate
wget https://rutorrent.googlecode.com/files/rutorrent-3.4.tar.gz --no-check-certificate

## Untar previous packages
tar xvf libtorrent*.tar.gz
tar xvf plugins*.tar.gz
tar xvf rtorrent*.tar.gz
tar xvf rutorrent*.tar.gz

## Configure, make, and install libtorrent
cd libtorrent*
./configure
make
make install
## Check to make sure make install was successful
if [ $? != 0 ]; then
  echo "!!! Couldn't install libtorrent,  terminating installation"
  exit
fi
ldconfig

## Configure, make, and install rtorrent
cd ../rtorrent*
./configure --with-xmlrpc-c=$(whereis xmlrpc-c-config|cut -d' ' -f2)
make
make install
if [ $? != 0 ]; then
  echo "!!! Couldn't install rtorrent,  terminating installation"
  exit
fi

## Set up rutorrent
cd ../
if [ ! -d "/var/www" ]; then
	mkdir /var/www
fi
mv rutorrent/* /var/www/
mv plugins/* /var/www/plugins/

## Move the password file to apache2 directory
mv passwords /etc/apache2/

## Determine if we are running 32bit or 64bit and fetch relevant binary files for mediainfo plugin
_OSBIT=$(getconf LONG_BIT)

if [ $_OSBIT -eq 32 ]; then
        echo "We are running 32bit os so we fetch 32bit binaries"
	wget http://downloads.sourceforge.net/project/zenlib/ZenLib/0.4.28/libzen0_0.4.28-1_i386.Debian_6.0.deb
	wget http://downloads.sourceforge.net/project/mediainfo/binary/libmediainfo0/0.7.61/libmediainfo0_0.7.61-1_i386.Debian_6.0.deb
	wget http://downloads.sourceforge.net/project/mediainfo/binary/mediainfo/0.7.61/mediainfo_0.7.61-1_i386.Debian_6.0.deb
else
        echo "We are running 64bit OS so we fetch 64bit binaries"
	wget http://downloads.sourceforge.net/zenlib/libzen0_0.4.26-1_amd64.Debian_6.0.deb
	wget http://downloads.sourceforge.net/mediainfo/libmediainfo0_0.7.58-1_amd64.Debian_6.0.deb
	wget http://downloads.sourceforge.net/mediainfo/mediainfo_0.7.58-1_amd64.Debian_6.0.deb
fi

## Install the plugin dependencies
dpkg -i libzen*
dpkg -i libmediainfo*
dpkg -i mediainfo*

## Create our apache2 site, first stop the server and then create our config
service apache2 stop

mv /etc/apache2/sites-available/default-ssl /etc/apache2/sites-available/default-ssl.rtorrentbackup
mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.rtorrentbackup

## http redirect to https
cat > /etc/apache2/sites-available/default << "EOF"
<VirtualHost *:80>
    RewriteEngine on
    RewriteCond %{REQUEST_METHOD} ^(TRACE|TRACK)
    RewriteRule .* - [F]
    RewriteRule ^/(.*) https://%{HTTP_HOST}/$1 [L,R]
</VirtualHost>
EOF

## https default config
cat > /etc/apache2/sites-available/default-ssl << "EOF"
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
        ServerAdmin webmaster@$localhost
        SSLEngine on
        ServerAlias www.localhost
        DocumentRoot /var/www
        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
        <Directory /var/www/>
                Options -Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>
        <Location />
                AuthType Digest
                AuthName "rut"
                AuthDigestDomain /var/www/
                AuthDigestProvider file
                AuthUserFile /etc/apache2/passwords
                Require valid-user
                SetEnv R_ENV "/var/www"
        </Location>
        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        LogLevel warn
        CustomLog ${APACHE_LOG_DIR}/ssl_access.log combined
        SSLEngine on
        SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
        SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
        <FilesMatch "\.(cgi|shtml|phtml|php)$">
                SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
                SSLOptions +StdEnvVars
        </Directory>
        BrowserMatch "MSIE [2-6]" \
                nokeepalive ssl-unclean-shutdown \
                downgrade-1.0 force-response-1.0
        BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
</VirtualHost>
</IfModule>
EOF
a2ensite default-ssl

## Create the startup script for rtorrent
mv /etc/init.d/rtorrent /etc/init.d/rtorrent.rtorrentbackup
cat > /etc/init.d/rtorrent << "EOF"
### BEGIN INIT INFO
# Provides: rtorrent
# Required-Start: $network $local_fs $syslog $time mountall
# Required-Stop: $network
# Default-Stop: 0 1 6
# Default-Start: 2 3 5
# Description: rtorrent screen
### END INIT INFO

startf()
{
        pid=$(pidof rtorrent)
        if [ "$pid" != "" ]
        then
                echo "rTorrent is running. PID: $pid"
        else
                su - rtorrent -c 'tmux new-session -d -s "rtorrent" /usr/local/bin/rtorrent'
                                echo
                                echo rtorrent started.
        fi
}
stopf()
{
        echo killing rTorrent
        kill $(pidof rtorrent)

        echo
        echo rtorrent stopped.
}
statusf()
{
        pid=$(pidof rtorrent)
        if [ "$pid" != "" ]
        then
                echo "rTorrent is running. PID: $pid"
        else
                echo "rTorrent is stopped."
        fi
}

case "$1" in
'start')
        startf
        ;;

'stop')
        stopf
        ;;

'restart')
        stopf
        echo sleeping for 1 sec
        sleep 1
        startf
        statusf
        ;;

'status')
        statusf
        ;;
*)
        echo "Usage: $0 { start | stop | restart | status }"
        ;;
esac
exit 0
EOF

## Make it executable
chmod +x /etc/init.d/rtorrent

## Create our Rtorrent user
if [ -z "$_USERID" ]; then
	useradd -m rtorrent -s /bin/bash
else
	useradd -u $_USERID -m rtorrent -s /bin/bash
fi

## Create the www torrent group
if [ -z "$_GROUPID" ]; then
        groupadd www-torrent
else
        groupadd -g $_GROUPID www-torrent
fi

## Create the Notification script
echo '#!/bin/bash' > /home/rtorrent/rtorrent_mail.sh
echo "echo \"\$(date) : \$1 - Download completed.\" | mail -s \"[rtorrent] - Download completed : \$1\" $_EMAIL" >> /home/rtorrent/rtorrent_mail.sh

## Backup existing rc file
if [ -e "/home/rtorrent/.rtorrent.rc" ]; then
	mv /home/rtorrent/.rtorrent.rc /home/rtorrent/.rtorrent.rc.rtorrentbackup
fi

## Populate a new rtorrent.rc file with our config
echo "max_uploads = 50" > /home/rtorrent/.rtorrent.rc
echo "download_rate = 0" >> /home/rtorrent/.rtorrent.rc
echo "upload_rate = 0" >> /home/rtorrent/.rtorrent.rc
echo "directory = $_INCOMINGFOLDER" >> /home/rtorrent/.rtorrent.rc
echo "session = /home/rtorrent/downloads/.session" >> /home/rtorrent/.rtorrent.rc
echo "schedule = watch_directory,5,5,load_start=$_WATCHFOLDER/*.torrent" >> /home/rtorrent/.rtorrent.rc
echo "schedule = low_diskspace,5,60,close_low_diskspace=10000M" >> /home/rtorrent/.rtorrent.rc
echo "system.method.set_key = event.download.finished,notify_me,\"execute=/home/rtorrent/rtorrent_mail.sh,$d.get_name=\"" >> /home/rtorrent/.rtorrent.rc
echo "port_range = $_LOWERPORTNUMBER-$_UPPERPORTNUMBER" >> /home/rtorrent/.rtorrent.rc
echo "scgi_port = 127.0.0.1:5000" >> /home/rtorrent/.rtorrent.rc
echo "check_hash = yes" >> /home/rtorrent/.rtorrent.rc
echo "encryption = allow_incoming,enable_retry,try_outgoing" >> /home/rtorrent/.rtorrent.rc
echo "dht = auto" >> /home/rtorrent/.rtorrent.rc
echo "dht_port = $_DHTPORT" >> /home/rtorrent/.rtorrent.rc
echo "peer_exchange = yes" >> /home/rtorrent/.rtorrent.rc
echo "system.file_allocate.set = yes" >> /home/rtorrent/.rtorrent.rc
echo "execute = {sh,-c,/usr/bin/php /var/www/php/initplugins.php www-data &}" >> /home/rtorrent/.rtorrent.rc

## Create a script to be run every minute until the configuration has been create and then inject the new autotools configuration to the config file
## First we need the string lengths
_COMPLETE_LENGTH=$(expr length "$_COMPLETEDFOLDER")
_WATCH_LENGTH=$(expr length "$_WATCHFOLDER")

## create the script that will create the config once the user has been created
echo "#!/bin/bash" > /opt/runthis.sh
echo "if [ -e /var/www/share/users/$_USERNAME/settings/ ]; then" >> /opt/runthis.sh
echo "        php /var/www/php/initplugins.php $_USERNAME" >> /opt/runthis.sh
echo "        echo \"O:10:\\\"rAutoTools\\\":9:{s:4:\\\"hash\\\";s:13:\\\"autotools.dat\\\";s:12:\\\"enable_label\\\";s:1:\\\"0\\\";s:14:\\\"label_template\\\";s:5:\\\"{DIR}\\\";s:11:\\\"enable_move\\\";s:1:\\\"1\\\";s:16:\\\"path_to_finished\\\";s:$_COMPLETE_LENGTH:\\\"$_COMPLETEDFOLDER\\\";s:11:\\\"fileop_type\\\";s:4:\\\"Move\\\";s:12:\\\"enable_watch\\\";s:1:\\\"1\\\";s:13:\\\"path_to_watch\\\";s:$_WATCH_LENGTH:\\\"$_WATCHFOLDER\\\";s:11:\\\"watch_start\\\";s:1:\\\"1\\\";}\" > /var/www/share/users/$_USERNAME/settings/autotools.dat" >> /opt/runthis.sh
echo "echo \"O:8:\\\"rCookies\\\":2:{s:4:\\\"hash\\\";s:11:\\\"cookies.dat\\\";s:4:\\\"list\\\";a:0:{}}\" > /var/www/share/users/$_USERNAME/settings/cookies.dat" >> /opt/runthis.sh
echo "        chown www-data:www-data /var/www/share/users/$_USERNAME/settings/autotools.dat" >> /opt/runthis.sh
echo "        chmod 666 /var/www/share/users/$_USERNAME/settings/autotools.dat" >> /opt/runthis.sh
echo "        chown www-data:www-data /var/www/share/users/$_USERNAME/settings/cookies.dat" >> /opt/runthis.sh
echo "        chmod 666 /var/www/share/users/$_USERNAME/settings/cookies.dat" >> /opt/runthis.sh
echo "        service apache2 stop" >> /opt/runthis.sh
echo "        sleep 2" >> /opt/runthis.sh
echo "        service rtorrent restart" >> /opt/runthis.sh
echo "        sleep 2" >> /opt/runthis.sh
echo "        service apache2 start" >> /opt/runthis.sh
echo "        rm /opt/runthis.sh" >> /opt/runthis.sh
echo "else" >> /opt/runthis.sh
echo "        at -f /opt/runthis.sh now + 1 minute" >> /opt/runthis.sh
echo "fi" >> /opt/runthis.sh
chmod +x /opt/runthis.sh
sh /opt/runthis.sh

## Create directories if needed
mkdir -p /home/rtorrent/downloads/.session
if [ ! -d "$_INCOMINGFOLDER" ]; then
  mkdir -p "$_INCOMINGFOLDER"
fi
if [ ! -d "$_COMPLETEDFOLDER" ]; then
  mkdir -p "$_COMPLETEDFOLDER"
fi
if [ ! -d "$_WATCHFOLDER" ]; then
  mkdir -p "$_WATCHFOLDER"
fi

## Change permissions of files
chown rtorrent:www-torrent /home/rtorrent/ -R
chmod 775 /home/rtorrent -R
chmod +s /home/rtorrent -R
chown www-data:www-data /var/www/ -R

## Add members to the Rtorrent WWW group
usermod -a -G www-torrent www-data
usermod -a -G www-torrent rtorrent

## Enable needed apache modules
a2enmod ssl
a2enmod auth_digest
a2enmod rewrite

## Start apache rtorrent
service apache2 start
service rtorrent start

## Display final message
IP=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
echo " "
echo " "
echo " Installation is almost complete."
echo " Next step is opening https://$IP/ and login with your chosen username and password to create the user."
echo " "
echo " After logging in please wait for approx. 1 minute for the user to be configured, the services will be restarted in the process which will make the Web GUI lose connection with Rtorrent.  When that happens you just need to refresh the page and then setup is complete."
echo " "
