class AddProviderNameToMachineTypeAndRegion < ActiveRecord::Migration[5.0]
  def change
    add_column :machine_types, :provider_name, :string
    add_column :regions, :provider_name, :string

    Provider.all.each do |p|
      p.machine_types.update_all(provider_name: p.name)
      p.regions.update_all(provider_name: p.name)
    end
  end
end
