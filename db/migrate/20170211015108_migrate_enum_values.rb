class MigrateEnumValues < ActiveRecord::Migration[5.0]
  def change
    InstanceType.all.each do |i|
      i.tenancy = i.tenancy_type.to_s if i.tenancy_type
      i.contract = i.contract_type.to_s if i.contract_type
      i.price_unit = i.unit.to_s if i.unit
      i.offering = i.offering_class.to_s if i.offering_class
      i.prepay = i.prepay_type.to_s if i.prepay_type
      i.os = i.os_type.to_s if i.os_type
      i.save
    end
  end
end
