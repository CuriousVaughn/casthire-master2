class AddPeerToApplicants < ActiveRecord::Migration
  def change
    add_column :applicants, :peer, :string
  end
end
