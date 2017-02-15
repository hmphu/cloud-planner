class MachineType < ApplicationRecord
  belongs_to :provider
  has_many :instance_types

  def sce_os_licence_count
    unit_core_count = 2
    licence_count = self.core_count / unit_core_count
  end

  def sce_sql_licence_count
    unit_core_count = 2
    licence_count = self.core_count / unit_core_count
  end

  def self.load_aws_machine_types
    aws = Provider.find_by_name('aws').id
    aws.machine_types.delete_all
    @machine_types = HTTParty.get('http://localhost:3000/instances/machine_types')
    @machine_types.each do |m|
      create name: m[0],
             core_count: m[1],
             memory_size: m[2],
             provider_id: aws.id
    end
  end

  def self.lookup(cores, memory, provider = nil)
    providers = self.distinct.pluck(:provider_name)
    list = []
    providers.each do |p|
      next if provider && provider != p
      lt = bt = []
      eq =  self.where(provider_name: p).where(core_count: cores, memory_size: memory)
      if eq.size == 0
        lt = self.where(provider_name: p).where("core_count <= ?", cores).where("memory_size <= ?", memory).order(core_count: :desc, memory_size: :desc).limit(2)
      end
      if eq.size == 0
        bt = self.where(provider_name: p).where("core_count >= ?", cores).where("memory_size >= ?", memory).order(:core_count, :memory_size).limit(2)
      end
      list = list + lt.reverse + eq + bt
    end
    return list
  end

  def desc
    "#{provider_name.ljust(10)} #{name.to_s.ljust(15)} #{core_count.to_s.rjust(12)} cores #{memory_size.to_s.rjust(15)} GB\t#{disk_size.to_s.rjust(15)} GB"
  end

end
