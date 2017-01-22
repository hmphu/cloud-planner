class AddUnitTenancySkuToInstanceTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :instance_types, :unit, :integer
    add_column :instance_types, :tenancy, :integer
    add_column :instance_types, :sku, :string
  end
end
