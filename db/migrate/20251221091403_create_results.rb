class CreateResults < ActiveRecord::Migration[8.0]
  def change
    create_table :results do |t|
      t.string :code, null: false
      t.references :type, null: false, foreign_key: true
      t.text :summary
      t.text :explanation

      t.timestamps
    end
  end
end
