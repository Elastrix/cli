##
# initialize the interface
##

ELX_VERSION="1.3.4"

## Render the header and check the platform
header
checkPlatform
init

## Set the default color for
echo -e "\e[39m"
argsparse_use_option setup "Setup this app" short:s
argsparse_use_option nginx "Work with NGINX" short:x
argsparse_use_option ghost "Configure Ghost" short:g value
argsparse_use_option wp "Configure WordPress" short:w value
argsparse_use_option apache "Work with Apache" short:a value
argsparse_use_option ems "Configure Media Server" short:e
argsparse_use_option mysql "Configure MySQL" short:m
argsparse_use_option webmin "Configure Webmin user" short:u
argsparse_use_option parse "Configure Parse Server" short:p
argsparse_use_option monit "Configure Monit" short:n
argsparse_use_option version "View Elastrix Version" short:v
argsparse_use_option certs "Generate SSL certificates" short:c
argsparse_use_option nosqlclient "Start/Stop NoSQLClient" short:l value


# You can define your own usage function
usage() {
	#argsparse_usage
	echo
	echo -e "  \e[1m\e[4mApp Functions\e[0m"
	echo
	echo "  -h |  --help       Display this message"
	echo "  -s |  --setup      Run app setup"
	
	## Webmin functions
	if [ -e "/etc/init.d/webmin" ]; then
		echo "  -u |  --webmin     Configure Webmin user"
	fi

	## Ghost functions
	if [ -e "/var/www/html/ghost" ]; then
		echo
		echo "  -g |  --ghost db   Update Ghost database configuration"
		echo "        --ghost url  Update Ghost public URL"
	fi

	## Wordpress functions
	if [ -e "/var/www/html/wordpress" ]; then
		echo
		echo "  -w |  --wp db      Configure WordPress"
	fi

	## Kurento options
	if [ -e "/etc/turnuserdb.conf" ]; then
		echo
		echo -e "  \e[1m\e[4mElastrix Media Server\e[0m"
		echo
		echo "  -e |  --ems        Configure Elastrix Media Server"
	fi

	if [ -e "/etc/init.d/mysql" ]; then
		echo
		echo -e "  \e[1m\e[4mMySQL Functions\e[0m"
		echo
		echo "  -m |  --mysql       Configure MySQL root password"
	fi

	## Apache functions
	if [ -e "/etc/init.d/apache2" ]; then
		echo
		echo -e "  \e[1m\e[4mApache Functions\e[0m"
		echo
		echo "  -a |  --apache     Optimize Apache"
	fi

	## NGINX functions
	if hash nginx 2>/dev/null; then
		echo
		echo -e "  \e[1m\e[4mNGINX Functions\e[0m"
		echo
		echo "  -x |  --nginx enable  [name]    Enable [name] NGINX site"
		echo "        --nginx disable [name]    Disable [name] NGINX site"
		echo "        --nginx list              List NGINX sites"
		echo
	fi

	## Parse Server functions
	if [ -e "/etc/init/parse.conf" ]; then
		echo
		echo "  -p |  --parse auth 	Update Parse Dashboard Basic Authentication"
		echo "        --parse app 	Update Parse App Configuration"
		echo "        --parse db 	Update Parse MongoDB Configuration"
		echo "        --parse srv 	Update Parse Server Configuration"
	fi

	## Monit functions
	if [ -e "/etc/monit/monitrc" ]; then
		echo
		echo "  -n |  --monit web 	Update Monit Web Server"
		echo "        --monit kill 	Disable Monit Web Server"
	fi

	## HumongousDB functions
	if [ -e "/etc/mongodb.conf" ]; then
		echo
		echo "  -l |  --nosqlclient start	Start NoSQLClient application"
		echo "        --nosqlclient stop	Stop NoSQLClient application"
	fi

	## SSL functions
	echo
	echo "  -c |  --certs gen 	Generate self-sligned SSL certificates in ~/certs."
	echo
	
	exit 0
}

argsparse_parse_options "$@"

##
# Arguments
##

if argsparse_is_option_set "setup"
	then
	setup
elif argsparse_is_option_set "nginx"
	then
	case "$2" in
		enable)
			SELECTED_SITE=$3
			ngxEnableSite
			;;

		disable)
			SELECTED_SITE=$3
			ngxDisableSite
			;;

		list)
			ngxListSites
			;;
		*)
			ngxListSites
			;;
		esac
elif argsparse_is_option_set "apache"
	then
	apacheUpdateMaxClients
elif argsparse_is_option_set "ghost"
	then
	case "$2" in
		db)
			ghostUpdateUrl
			;;
		url)
			ghostUpdateMysqlPassword
			;;
		esac
elif argsparse_is_option_set "wp"
	then
	wordpressUpdateMysqlPassword
elif argsparse_is_option_set "ems"
	then
	kurentoUpdateTurnserver
elif argsparse_is_option_set "mysql"
	then
	mysqlUpdateRootPassword
elif argsparse_is_option_set "webmin"
	then
	webminCreateAdmin
elif argsparse_is_option_set "parse"
	then
	case "$2" in
		auth)
			parseUpdateDashboardAuth
			;;
		app)
			parseUpdateApp
			;;
		db)
			parseUpdateDb
			;;
		srv)
			parseUpdateSrv
			;;
		esac
elif argsparse_is_option_set "monit"
	then
	case "$2" in
		web)
			monitUpdateWebServer
			;;
		kill)
			monitDisableWebServer
			;;
		esac
elif argsparse_is_option_set "nosqlclient"
	then
	case "$2" in
		start)
			nosqlclientStart
			;;
		stop)
			nosqlclientStop
			;;
		esac
elif argsparse_is_option_set "version"
	then
	echo
	info "Elastrix CLI v${ELX_VERSION}"
	echo
elif argsparse_is_option_set "certs"
	then
	sslCreateServerCerts
else
	i=1
	for param in "${program_params[@]}"
	do
		printf "\e[1m\e[31m[!] Unrecognized option %s\n" $((i++)) "$param not recognized."
		echo -e "\e[39m[i] Try $me -h"
		echo
	done
	exit 1
fi