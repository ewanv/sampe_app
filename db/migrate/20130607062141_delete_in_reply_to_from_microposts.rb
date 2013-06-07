class DeleteInReplyToFromMicroposts < ActiveRecord::Migration
  def change
  	remove_column :microposts, :in_reply_to_id
  end
end
