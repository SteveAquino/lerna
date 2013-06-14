require 'typhoeus'

class Lerna
	attr_accessor :urls, :concurrency, :hydra, :url_options, :number_of_requests, :log_file

	def initialize(urls, options={})
		@urls = urls
		@concurrency = options[:concurrency] || 10
		@url_options = options[:url_options] || {}
		@number_of_requests = options[:number_of_requests] || 1
		@hydra = Typhoeus::Hydra.new(max_concurrency: @concurrency)
		set_up_queue(@urls)
	end

	def set_up_queue(urls)
		@concurrency.times do
			urls.each { |url| @hydra.queue new_request(url) }
		end
	end

	def new_request(url)
	  request = Typhoeus::Request.new(url, @url_options)
	  parallel_requests = []
	  @number_of_requests.times do |i|
			parallel_requests[i] = request.dup
		  parallel_requests[i].on_complete do |response|
		  	time = sprintf("%.2f", response.total_time).to_f
			  log("#{url} ====> HTTP #{response.code} #{response.status_message} in #{time} seconds", false)
			  if (i+1 < @number_of_requests)
					hydra.queue(parallel_requests[i+1])
			  end
		  end
	  end
	  request.on_complete do |response|
	  	time = sprintf("%.2f", response.total_time).to_f
		  log("#{url} ====> HTTP #{response.code} #{response.status_message} in #{time} seconds", false)
		  if response.success?
				hydra.queue(parallel_requests[0])
		  end
	  end
	  return request
	end

	def run
		@hydra.run
	end

	def log(text, silent=true)
		if @log_file
			f = File.open(@log_file, 'a')
			f.puts(text)
			f.close
			print "." unless silent
		else
			puts(text)
		end
	end
end
