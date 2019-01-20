ghostUpdateMysqlPassword() {
	read -s -p "  [?] Enter a new Ghost MySQL Password (input will be hidden): " newpass
	echo
	info "We will need your ROOT MySQL Password to complete the update."
	mysql -u root -p -e "SET PASSWORD FOR 'ghost'@'localhost' = PASSWORD('"$newpass"');FLUSH PRIVILEGES;"
	sed -i.bak -e 's/password: .*/password: '\'$newpass\','/' /var/www/html/ghost/config.js
	echo
	info "Restarting Ghost..."
	service ghost restart
	echo
	info "The MySQL password for user 'ghost' has been updated."
	info "$HOME/webroot/ghost/config.js was updated"
	echo
	return 0
}

ghostUpdateUrl() {
	info "Your public URL is http://$url"
	read -p "  [?] Would you like to use this as your Ghost URL? [ Y/n ]: " answer

	if [ -z $answer ]; then 
		answer="Y" 
	fi

	if [ $answer != "Y" ]; then
		echo
		info "Please enter your full URL with protocol i.e. http://myhost.com"
		read url
	else
		url="http://$url"
	fi

	echo
	read -p "  [?] Updating Ghost Config URL to $url ok? [ Y/n ]: " answer

	if [ -z $answer ]; then 
	        answer="Y" 
	fi

	if [ $answer == "Y" ]; then
		sed -i.bak -e 's#url: .*#url: '\'$url\','#' /var/www/html/ghost/config.js
		echo
		info "Ghost config URL updated, restarting Ghost now."
		service ghost restart
		sleep 1s
		return 0	
	fi
}