class AddAuthTokenToMember < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :auth_token, :string
    add_column :members, :is_token_valid, :boolean, default: false
  end
end
