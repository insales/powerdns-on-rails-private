class MakeChangeDateOptional < ActiveRecord::Migration
  def up
    change_column_null :records, :change_date, true
  end

  def down
    change_column_null :records, :change_date, false
  end
end
