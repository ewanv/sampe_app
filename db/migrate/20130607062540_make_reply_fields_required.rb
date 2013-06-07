class MakeReplyFieldsRequired < ActiveRecord::Migration
  def change
  	change_column :replies, :micropost_id, :integer, null: false
  	change_column :replies, :in_reply_to_id, :integer, null: false
  end
end
