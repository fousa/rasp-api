require 'rubygems'
require 'notifo'

desc "This task is called by the Heroku cron add-on"
task :cron do
	dir = File.expand_path(File.dirname(__FILE__))
	begin
		result = sh "cd #{dir}; bundle exec ruby spec/*"
		message = "All the URL's are correct."
	rescue
		message = "There is a mismatch in one of the URL's."
	end

	notifo = Notifo.new(ENV['NOTIFIO_SERVICE_USERNAME'], ENV['NOTIFIO_SECRET'])
	notifo.post("fousa",message)
end
