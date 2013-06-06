class CreateRepliesJoinTable < ActiveRecord::Migration
  def change
    create_table :replies do |t|
       t.integer :micropost_id
       t.integer :in_reply_to_id
      # t.index [:in_reply_to_id, :micropost_id]
    end
    add_index :replies, :micropost_id
    add_index :replies, :in_reply_to_id
    add_index :replies, [:micropost_id, :in_reply_to_id], unique: true
  end
end
