class ChangeFitbitTypes < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute(<<-SQL)
      ALTER TABLE fitbit_bodies ALTER weight      TYPE float8 USING weight::float8
                               ,ALTER bmi         TYPE float8 USING bmi::float8
                               ,ALTER date_logged TYPE date   USING date_logged::date
    SQL
    ActiveRecord::Base.connection.execute(<<-SQL)
      ALTER TABLE fitbit_activities ALTER steps       TYPE integer USING steps::integer
                                   ,ALTER floors      TYPE integer USING floors::integer
                                   ,ALTER date_logged TYPE date    USING date_logged::date
    SQL
    ActiveRecord::Base.connection.execute(<<-SQL)
      ALTER TABLE fitbit_sleeps ALTER minutes_awake     TYPE integer USING minutes_awake::integer
                               ,ALTER minutes_asleep    TYPE integer USING minutes_asleep::integer
                               ,ALTER number_awakenings TYPE integer USING number_awakenings::integer
                               ,ALTER minutes_to_sleep  TYPE integer USING minutes_to_sleep::integer
                               ,ALTER date_logged       TYPE date    USING date_logged::date
    SQL
  end

  def self.down
    fail ActiveRecord::IrreversibleMigration
  end
end
