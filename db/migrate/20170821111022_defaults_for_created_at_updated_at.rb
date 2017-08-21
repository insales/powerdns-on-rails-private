class DefaultsForCreatedAtUpdatedAt < ActiveRecord::Migration
  def up
    execute "alter table records alter column created_at set default now();"
    execute "alter table records alter column updated_at set default now();"
  end
  def down
    execute "alter table records alter column created_at drop default;"
    execute "alter table records alter column updated_at drop default;"
  end
end
