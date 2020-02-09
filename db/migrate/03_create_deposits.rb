class CreateDeposits < ActiveRecord::Migration[5.1]
  def change
    create_table :deposits do |t|
      t.float :amount
      t.integer :user_id
    end
  end
end