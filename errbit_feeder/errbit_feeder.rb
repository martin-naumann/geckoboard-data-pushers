require 'geckoboard-push'
require 'mongo'
require 'trollop'

include Mongo

opts = Trollop::options do
  opt :dbHost, "MongoDB Host address", :default => 'localhost', :type => :string
  opt :dbPort, "MongoDB Server port", :default => 27017, :type => :integer
  opt :dbName, "Name of the database to use", :default => 'errbit', :type => :string

  opt :apiKey, "Geckoboard API Key (from your account settings)", :type => :string
  opt :widgetKey, "Geckoboard Widget Key (from the custom widget settings)", :type => :string
end

db = MongoClient.new(opts[:dbHost], opts[:dbPort]).db(opts[:dbName])
problems = db.collection("problems")

open_problems_number = problems.find({resolved: false}).to_a.count
all_problems_number  = problems.count()

puts "FOUND #{open_problems_number} unresolved problems"
puts "FOUND #{all_problems_number} RESVOLED problems"

Geckoboard::Push.api_key = opts[:apiKey]
push = Geckoboard::Push.new(opts[:widgetKey])

push.geckometer(open_problems_number, 0, all_problems_number, true)
