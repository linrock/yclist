class CreateCompanies < ActiveRecord::Migration
  def up
    create_table :companies do |t|
      t.string :name
      t.string :url
      t.string :cohort
      t.string :status
      t.string :title
      t.string :description
      t.text :data
      t.timestamps
    end
  end

  def down
  end
end
