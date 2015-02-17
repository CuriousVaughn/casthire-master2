class AddInterviewToCastings < ActiveRecord::Migration
  def change
    add_column :castings, :interview, :string
  end
end
