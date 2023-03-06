#!/bin/bash
#pulls linux files of forensic importance from a live system
echo "Where would you like the logs to be saved?"
read log_location
echo "Files will be save to $log_location"

collect_usernames() {
	lastlog > $log_location/last.log
}

create_user_folders() {
	for user in $(ls /home); do
		mkdir $log_location/$user
	done
}

collect_syslogs() {
	mkdir $log_location/syslogs
	sudo cp - r /var/log/*.log $log_location/syslogs
}

collect_shell_history() {
	for user in $(ls /home); do
		mkdir $log_location/$user/shells
		cd /home/$user
		for log in $(find -name "*history"); do
			cp $log $log_location/$user/shells
		done
	done
}

collect_browser_logs() {
	for user in $(ls /home); do
		mkdir $log_location/$user/firefox
		cd /home/$user/.mozilla/firefox
		find . -name places.sqlite | xargs -I{} cp {} $log_location/$user/firefox
		find . -name cookies.sqlite | xargs -I{} cp {} $log_location/$user/firefox
		find . -name formhistory.sqlite | xargs -I{} cp {} $log_location/$user/firefox
		find . -name signons.sqlite | xargs -I{} cp {} $log_location/$user/firefox
		find . -name prefs.js | xargs -I{} cp {} $log_location/$user/firefox
		find . -name logins.json | xargs -I{} cp {} $log_location/$user/firefox
		find . -name key3.db | xargs -I{} cp {} $log_location/$user/firefox
		find . -name cert8.db | xargs -I{} cp {} $log_location/$user/firefox
		find . -name places.sqlite | xargs -I{} sqlite3 {} "SELECT datetime(last_visit_date/1000000,'unixepoch','localtime'),url FROM moz_places" > $log_location/$user/firefox/last_10_days.log
	done
}

collect_usernames
create_user_folders
collect_syslogs
collect_shell_history
collect_browser_logs
