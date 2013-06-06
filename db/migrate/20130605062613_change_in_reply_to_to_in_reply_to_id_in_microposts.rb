class ChangeInReplyToToInReplyToIdInMicroposts < ActiveRecord::Migration
  def change
  	rename_column :microposts, :in_reply_to, :in_reply_to_id
  end
end
