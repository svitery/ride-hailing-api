require "sequel"

Sequel.migration do
  change do
    run <<-SQL
      CREATE TYPE ride_status AS ENUM ('STARTED', 'COMPLETED');
    SQL

    create_table(:rides) do
      primary_key :id
      foreign_key :driver_id, :drivers, null: false
      foreign_key :rider_id, :riders, null: false
      column :status, :ride_status, null: false
      Float :start_latitude, null: false
      Float :start_longitude, null: false
      Float :end_latitude
      Float :end_longitude
      DateTime :created_at, null: false
      DateTime :completed_at
    end
  end
end
