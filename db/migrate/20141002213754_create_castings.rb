class CreateCastings < ActiveRecord::Migration
  def change
    create_table :castings do |t|
      t.references :user
      t.string :name

      t.timestamps
    end
  end
end
