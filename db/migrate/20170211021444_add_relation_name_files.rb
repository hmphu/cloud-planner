class AddRelationNameFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :instance_types, :provider_name, :string
    add_column :instance_types, :region_name, :string
    add_column :instance_types, :machine_name, :string
  end
end
