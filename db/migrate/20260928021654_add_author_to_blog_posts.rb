class AddAuthorToBlogPosts < ActiveRecord::Migration[8.1]
  def up
    add_column :blog_posts, :author_id, :bigint
    add_index :blog_posts, :author_id

    execute <<~SQL
      UPDATE blog_posts AS b
      SET author_id = m.id
      FROM (
        SELECT DISTINCT ON (lower(btrim(full_name))) id, lower(btrim(full_name)) AS name_key
        FROM users
        WHERE btrim(coalesce(full_name, '')) <> ''
        ORDER BY lower(btrim(full_name)), id
      ) AS m
      WHERE b.author_id IS NULL
        AND btrim(coalesce(b.author_name, '')) <> ''
        AND lower(btrim(b.author_name)) = m.name_key
    SQL

    stats = connection.select_one(<<~SQL)
      SELECT count(*) FILTER (WHERE author_id IS NOT NULL) AS linked,
             count(*) FILTER (
               WHERE author_id IS NULL
                 AND btrim(coalesce(author_name, '')) <> ''
             ) AS unlinked
      FROM blog_posts
    SQL

    say "linked #{stats["linked"]} post(s) to a user by name, #{stats["unlinked"]} left without an author"
  end

  def down
    remove_index :blog_posts, :author_id
    remove_column :blog_posts, :author_id
  end
end
