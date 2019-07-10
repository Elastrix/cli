nosqlclientStart() {
	echo
	info "Starting NoSQLClient..."
	supervisorctl start nosqlclient
	echo
	info "NoSQLClient is running at http://$url:3000"
	echo
	return 0
}

nosqlclientStop() {
	echo
	info "Stopping NoSQLClient..."
	supervisorctl stop nosqlclient
	docker container kill nosqlclient
	echo
	info "NoSQLClient is not running"
	echo
	return 0
}