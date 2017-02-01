class AddPrepayTypeToInstanceTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :instance_types, :prepay_type, :integer
  end
end
