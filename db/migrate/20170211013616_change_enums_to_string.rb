class ChangeEnumsToString < ActiveRecord::Migration[5.0]
  def change
    rename_column :instance_types, :tenancy, :tenancy_type
    add_column :instance_types, :tenancy, :string
    add_column :instance_types, :contract, :string
    add_column :instance_types, :price_unit, :string
    add_column :instance_types, :offering, :string
    add_column :instance_types, :prepay, :string
    add_column :instance_types, :os, :string
  end
end
