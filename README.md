# SimpleLock

SimpleLock is a locking adapter 
that can be used as a local or distributed lock with limitations:

- mutual exclusion is not guaranteed. 

    That means that if two processes try to acquire 
    the same lock at a time, they will probably do though probability is low in real cases.
    
    Anyway, you should not use this tool to protect business transactions.
    
    It is suitable rather to decrease the number of similar tasks executed at a time.
    E.g. if you have the same cron schedule on multiple instances  
    but would like to generate the report only once, you could use this locking approach.
    There will be no loss if you submit the report twice, 
    an this will MOST LIKELY never happen.

- lock robustness depends on the storage class you provide. 
    
    It is possible to use e.g. memorycache to store locks, 
    and all locks will be lost upon memorycache server restart.
     
     
Other features:

- You can set up the lock expiration time (if your adapter supports it).
This can be useful if a process acquired the lock is terminated unexpectedly or stuck 
(you would terminate stuck processes anyway). 

    E.g. if you set up the expiration time for a day, have a task hung and restarted,
    then you don't need to search for and manually sweep deadlocks 
    if you can afford one day of task inactivity. 
    This can be suitable for ETL processes that synchronize data on daily basis. 
    One day off is usually not a problem.

- By default SimpleLock uses `Rails.cache` as a storage for locks 
making it simple to use without any configuration.
    
    But Rails is not a dependency. You can use any adapter implemented 


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_lock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_lock

## Usage

```ruby
    SimpleLock.aquire('weekly_report', expires_in: 1.day) do
      report = WeeklyReport.generate
      Notificator.send('Weekly report', attachment: report)
    end  
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dimasamodurov/simple_lock.
