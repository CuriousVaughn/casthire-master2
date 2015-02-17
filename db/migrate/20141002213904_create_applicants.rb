class CreateApplicants < ActiveRecord::Migration
  def change
    create_table :applicants do |t|
      t.string :name
      t.references :casting

      t.timestamps
    end
  end
end
