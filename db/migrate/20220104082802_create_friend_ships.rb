class CreateFriendShips < ActiveRecord::Migration[6.1]
  def change
    create_table :friend_ships do |t|
      t.integer :member_id
      t.integer :friend_id
      t.string :status
      t.timestamps
    end
    add_index(:friend_ships, [:member_id, :friend_id], :unique => true)
    add_index(:friend_ships, [:friend_id, :member_id], :unique => true)
  end
end
