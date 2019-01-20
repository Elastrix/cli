monitUpdateWebServer() {
	echo
	info "Configure Monit Web Server Settings."
	echo

	read -p "  [?] Monit Web Server Port (2812): " monitHttpPort
	read -p "  [?] Enter Username: " monitHttpUser
	read -s -p "  [?] Enter Password (hidden): " monitHttpPass

	if [[ -z $monitHttpPort ]]; then
		monitHttpPort=2812
	fi

	echo "set httpd port ${monitHttpPort} and" > /etc/monit/conf.d/monit-http.conf
	echo "    allow ${monitHttpUser}:${monitHttpPass}" >> /etc/monit/conf.d/monit-http.conf

	service monit restart
	echo
	info "Monit web server running at http://${url}:${monitHttpPort}"
	echo
	return 0
}

monitDisableWebServer() {
	echo
	info "Configure Monit Web Server Settings."
	echo
	if [ -e '/etc/monit/conf.d/monit-http.conf' ]; then
    	rm -fR /etc/monit/conf.d/monit-http.conf
    fi
    service monit restart
	echo
	info "Monit web server disabled"
	echo
	return 0
}