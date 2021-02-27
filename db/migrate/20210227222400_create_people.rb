class CreatePeople < ActiveRecord::Migration[6.1]
  def change
    create_table :people do |t|
      t.string :name
      t.integer :messages
      t.references :chat, null: false, foreign_key: true

      t.timestamps
    end
  end
end
