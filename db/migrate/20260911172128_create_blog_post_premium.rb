class CreateBlogPostPremium < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_post_premiums do |t|
      t.references :blog_post, null: false, foreign_key: true, index: { unique: true }
      t.string :premium_title
      t.text :premium_content

      t.timestamps
    end
  end
end
