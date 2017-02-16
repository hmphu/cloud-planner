class ChangeNilToNoInAwsInstanceTypes < ActiveRecord::Migration[5.0]
  def change
    InstanceType.where(prepay: nil).update_all(prepay: 'no')
  end
end
