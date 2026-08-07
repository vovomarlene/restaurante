class AddSentToKitchenAtToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :sent_to_kitchen_at, :datetime
  end
end
