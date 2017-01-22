class AddPreInstalledSwToInstanceTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :instance_types, :pre_installed_sw, :string
  end
end
