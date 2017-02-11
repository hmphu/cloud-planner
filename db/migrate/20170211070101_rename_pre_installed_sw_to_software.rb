class RenamePreInstalledSwToSoftware < ActiveRecord::Migration[5.0]
  def change
    rename_column :instance_types, :pre_installed_sw, :software
  end
end
