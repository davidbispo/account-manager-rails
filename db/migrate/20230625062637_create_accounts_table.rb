class CreateAccountsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.float :balance, null: false
      t.timestamps
    end
  end
end
