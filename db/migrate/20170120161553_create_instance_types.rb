class CreateInstanceTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :instance_types do |t|
      t.integer :provider_id
      t.integer :region_id
      t.integer :machine_type_id
      t.integer :os_type
      t.float :price
      t.float :price_1y

      t.timestamps
    end
  end
end
