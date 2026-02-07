class AddImageToTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :types, :image_path, :string
  end
end
