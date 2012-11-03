class CreateCompanies < ActiveRecord::Migration
  def up
    create_table :companies do |t|
      t.string :name
      t.string :url
      t.string :yc_class
      t.string :status
      t.string :title
      t.string :description
      t.text :notes
      t.integer :acquisition_price
      t.timestamps
    end
  end

  def down
  end
end
