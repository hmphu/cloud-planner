class UpdateRelationNames < ActiveRecord::Migration[5.0]
  def change
    Provider.all.each do |p|
      InstanceType.where(provider_id: p.id ).update_all(provider_name: p.name)
    end

    Region.all.each do |r|
      InstanceType.where(region_id: r.id ).update_all(region_name: r.name)
    end

    MachineType.all.each do |r|
      InstanceType.where(machine_type_id: r.id ).update_all(machine_name: r.name)
    end
  end
end
