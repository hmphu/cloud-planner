class CreateRegions < ActiveRecord::Migration[5.0]
  def change
    create_table :regions do |t|
      t.string :name
      t.integer :provider_id

      t.timestamps
    end
  end
end
