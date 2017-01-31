class AddOfferingClassToInstanceTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :instance_types, :offering_class, :integer
  end
end
