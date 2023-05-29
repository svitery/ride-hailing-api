require "sequel"

Sequel.migration do
  change do
    create_table(:payment_methods) do
      primary_key :id
      String :payment_provider_id, null: false
      foreign_key :rider_id, :riders, null: false
      DateTime :created_at, null: false
    end
  end
end
