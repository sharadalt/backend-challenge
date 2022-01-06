class CreateMemberWebsites < ActiveRecord::Migration[6.1]
  def change
    create_table :member_websites do |t|
      t.references :member
      t.string :website_url
      t.string :short_url
      t.string :heading_h1
      t.string :heading_h2
      t.string :heading_h3

      t.timestamps
    end
  end
end
