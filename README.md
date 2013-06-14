Lerna is a Ruby tool based on the Typhoeus gem that allows you to easily simulate multiple,
concurrent web requests to test server load.  Setting up a script is as simple as a few lines
of code.

First install Typhoeus:

    gem install typhoeus
    
Then make a ruby script or run from irb:

    require 'learna'
    Lerna.new("http://test.mysite.com").run
    
You can pass options to Lerna for more complex tests:

    urls = %w(
      http://test1.mysite.com
      http://test2.mysite.com
      http://test3.mysite.com
    )
    options = {
      userpwd: "username:password",
      followlocation: true
    }
    lerna = Lerna.new(urls, url_options: options, concurrency: 100, number_of_requests: 10)
    lerna.run
    
Specifying a log file will silence terminal output and print to a chosen file location:

    lerna.log_file = 'lerna.log'
    
You can follow the ouput using tail:

    tail -f lerna.log
