require 'csv'
require 'pp'

# Download CSV
# wget https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/index.csv

def read_csv
  n = 0
  filename = 'tt.csv'
  cols =  [18, 9, 8, 11,16,21,24,25,22,23,]
  CSV.foreach(filename, converters: :numeric, headers: true) do |row|
    n = n+1
    next if n < 4
    cols.each do |c|
      print row[c], ", "
    end
    puts ""
    break if n >= 7
  end
end

read_csv
