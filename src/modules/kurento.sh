getTurnserverUsername () {
	read -p "  [?] Please enter a username for your turnserver: " username
}

getTurnserverPassword () {
	read -s -p "  [?] Please enter a password for your turnserver (input will be hidden): " password
}
kurentoUpdateTurnserver() {
	info "Updating Turnserver configuration"
	port=3478
	echo
	info "Your public hostname is $url"
	info "Your public IP is $ip"
	read -p "  [?] Would you like to use this for your turnserver configuration? [ Y/n ]: " answer

	if [ -z $answer ]; then
		answer="Y"
	fi

	if [ $answer != "Y" ]; then
		echo
		info "Please enter your public hostname i.e. myhost.com"
		read url
	fi

	echo
	read -p "  [?] Updating Turnserver url to $url ok? [ Y/n ]: " answer

	if [ -z $answer ]; then
		answer="Y"
	fi

	if [ $answer == "Y" ]; then	
		
		if [[ -f "/etc/turnserver.conf" ]]; then
			mv /etc/turnserver.conf /etc/turnserver.conf.bak
			touch /etc/turnserver.conf
		else
			touch /etc/turnserver.conf
		fi

		echo "listening-device=eth0" > /etc/turnserver.conf
		echo "listening-ip=$url" >> /etc/turnserver.conf
		echo "listening-port=$port" >> /etc/turnserver.conf
		echo "userdb=turnuserdb.conf" >> /etc/turnserver.conf
		echo "relay-device=eth0" >> /etc/turnserver.conf
		echo "realm=$url" >> /etc/turnserver.conf
		echo "lt-cred-mech" >> /etc/turnserver.conf
		echo "log-file=/var/log/turnserver.log" >> /etc/turnserver.conf
		echo
		info "Updated /etc/turnserver.conf:"
		cat /etc/turnserver.conf
		echo
	else
		warn "Not making any updates to turnserver.conf"
	fi

	info "Next we are creating a username and password for the Turn Server."
	info "The Turn Server handles user signaling for WebRTC peers and NAT traversal."

	getTurnserverUsername

	if [ -z $username ]; then
		getTurnserverUsername
	fi

	getTurnserverPassword

	echo

	if [ -z $password ]; then
		getTurnserverPassword
	fi

	info "Updating /etc/turnuserdb.conf"
	echo "$username:$password" > /etc/turnuserdb.conf

	echo
	info "Updating /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini"
	sed -i.bak -e 's#turnURL=.*#turnURL='$username':'$password'@'$ip':'$port'#' /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini

	info "Restarting Kurento..."
	service kurento-media-server-6.0 restart
	sleep 1s
	service turnserver restart
	sleep 1s
	echo
	info "Turnserver configuration complete."
	echo
	return 0
}