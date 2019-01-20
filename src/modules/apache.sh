apacheUpdateMaxClients() {
	info "We are going to restart Apache2 and update for the most optimal settings" 
	read -p "  [?] Restart Apache now [ Y/n ]: " doNow
	if [[ $doNow = "Y" ]]; then
		echo
		APACHE="apache2"
		APACHEMEM=$(ps -aylC $APACHE |grep "$APACHE" |awk '{print $8'} |sort -n |tail -n 1)
		APACHEMEM=$(expr $APACHEMEM / 1024)
		SQLMEM=$(ps -aylC mysqld |grep "mysqld" |awk '{print $8'} |sort -n |tail -n 1)
		SQLMEM=$(expr $SQLMEM / 1024)
		info "Stopping $APACHE to calculate the amount of free memory"
		/etc/init.d/$APACHE stop &> /dev/null
		TOTALFREEMEM=$(free -m |head -n 2 |tail -n 1 |awk '{free=($4); print free}')
		TOTALMEM=$(free -m |head -n 2 |tail -n 1 |awk '{total=($2); print total}')
		SWAP=$(free -m |head -n 4 |tail -n 1 |awk '{swap=($3); print swap}')
		MAXCLIENTS=$(expr $TOTALFREEMEM / $APACHEMEM)
		MINSPARESERVERS=$(expr $MAXCLIENTS / 4)
		MAXSPARESERVERS=$(expr $MAXCLIENTS / 2)
		info "Starting $APACHE again"
		/etc/init.d/$APACHE start &> /dev/null
		info "Total memory $TOTALMEM"
		info "Free memory $TOTALFREEMEM"
		info "Amount of virtual memory being used $SWAP"
		info "Largest Apache Thread size $APACHEMEM"
		info "Amount of memory taking up by MySQL $SQLMEM"
		if [[ SWAP > TOTALMEM ]]; then
		      ERR="Virtual memory is too high"
			  warn "$ERR"
		else
		      ERR="Virtual memory is ok"
			  info "$ERR"
		fi
		echo
		info "Total Free Memory $TOTALFREEMEM"
		info "MaxClients should be around $MAXCLIENTS"
		info "MinSpareServers should be around $MINSPARESERVERS"
		info "MaxSpareServers should be around $MAXSPARESERVERS"
		echo
		return 0
	fi
}