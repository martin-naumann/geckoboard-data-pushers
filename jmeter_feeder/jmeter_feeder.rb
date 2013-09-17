require 'xml'
require 'csv'
require 'geckoboard-push'
require 'trollop'

opts = Trollop::options do
  opt :apiKey, "Geckoboard API Key (from your account settings)", :type => :string
  opt :widgetKey, "Geckoboard Widget Key (from the custom widget settings)", :type => :string
end

reader = XML::Reader.file(ARGV[0])
reader.read #Loads the file

#Iterate over the HTTP Samples
num_samples = 0
sum_times = 0
max_response_time = 0
reader.expand.each_element do |elem|
    num_samples = num_samples + 1
    load_time = elem['lt'].to_i #Load Time in ms
    sum_times = sum_times + load_time 
    
    if load_time > max_response_time
      max_response_time = load_time
    end
end

#Put it in a CSV, appending to all the old data. Fuck Geckoboard, really.
open('gecko_data.csv', 'a') { |f|
    f.puts "#{Time.now};#{sum_times / num_samples};#{max_response_time};"
}

#Read in the historical data (along with the latest data point)
avg_points = []
max_points = []
CSV.foreach('gecko_data.csv', {col_sep: ';'}) do |row|
    avg_points << row[1].to_i
    max_points << row[2].to_i
end

#Use the CSV to dump all this stuff to Geckoboard until they get a decent API -.-
Geckoboard::Push.api_key = opts[:apiKey]
push = Geckoboard::Push.new(opts[:widgetKey])

data = [{name:"Average", data: avg_points}, {name: "Max", data: max_points}]
puts data.to_json
push.highchart(data, {
    yAxis: {
        title: {text: "Response Time (ms)"}
    },
    chart: {backgroundColor: '#272727'}, 
    colors: ['#ffff00', '#ffaaaa', '#aaaaff'],
    title: { 
        text: "Response time",
        style: { color: '#ffffff' }
    },
    legend: {
        itemStyle: {
          color: '#ffffff'
        }
    }
})
