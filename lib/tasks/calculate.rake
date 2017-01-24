namespace :calculate do
  desc "calcuate cost of AWS "
  task :aws, [:infile] =>  :environment do |t, args|
    CSV.foreach(args[:infile]) do |row|
      ap row
    end

  end

  desc "TODO"
  task azure: :environment do
  end

  desc "TODO"
  task google: :environment do
  end

end
