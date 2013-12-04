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
problems_resolved_per_month = problems.aggregate([
  { "$match"   => { resolved: true } },
  { "$project" => { month_resolved: { "$month" => "$resolved_at"  }, message: "$message" }},
  { "$group"   => { _id: "$month_resolved", problems: { "$addToSet" => '$message' } } },
  { "$unwind"  =>  "$problems" },
  { "$group"   => { _id: "$_id", number: { "$sum" => 1 } } },
  { "$sort"    => { _id: 1 } },
  { "$limit"   => 3 }
]).map { |p| p['number'] }

puts "FOUND #{open_problems_number} unresolved problems"
puts "Resolutions for this month: #{problems_resolved_per_month[-1]}"

Geckoboard::Push.api_key = opts[:apiKey]
push = Geckoboard::Push.new(opts[:widgetKey])

push.number_and_secondary_value(open_problems_number, problems_resolved_per_month)
