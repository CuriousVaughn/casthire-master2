class AddStartedInterviewToCastings < ActiveRecord::Migration
  def change
    add_column :castings, :started_interview, :datetime
  end
end
