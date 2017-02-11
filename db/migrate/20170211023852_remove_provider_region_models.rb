class RemoveProviderRegionModels < ActiveRecord::Migration[5.0]
  def change
    # remove relations
    remove_column :instance_types, :provider_id
    remove_column :instance_types, :region_id

    # remvoe _name postfix
    rename_column :instance_types, :machine_name, :machine
    rename_column :instance_types, :provider_name, :provider
    rename_column :instance_types, :region_name, :region

    # remove old enum columns
    remove_column :instance_types, :os_type
    remove_column :instance_types, :unit
    remove_column :instance_types, :tenancy_type
    remove_column :instance_types, :offering_class
    remove_column :instance_types, :prepay_type
    remove_column :instance_types, :contract_type
  end
end
