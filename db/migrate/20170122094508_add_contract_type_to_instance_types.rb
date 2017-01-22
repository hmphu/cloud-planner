class AddContractTypeToInstanceTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :instance_types, :contract_type, :integer
  end
end
