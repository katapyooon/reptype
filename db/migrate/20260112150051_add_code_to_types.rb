class AddCodeToTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :types, :code, :string
    add_index  :types, :code, unique: true
  end
end
