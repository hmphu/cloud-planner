class CreateMachineTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :machine_types do |t|
      t.string :name
      t.integer :core_count
      t.integer :memory_size
      t.integer :provider_id

      t.timestamps
    end
  end
end
