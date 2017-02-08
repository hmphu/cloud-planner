class AddDiskSizeAndChangeMemroySizeAsFloatToMachineTypes < ActiveRecord::Migration[5.0]
  def change
    change_column :machine_types, :memory_size, :float
    add_column :machine_types, :disk_size, :integer
  end
end
