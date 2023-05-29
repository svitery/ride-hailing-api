require "sequel"

# Create drivers table
Sequel.migration do
  change do
    create_table(:drivers) do
      primary_key :id
      String :name, null: false
      String :lastname, null: false
      String :email, null: false
      String :phone, null: false
      Float :latitude, null: false
      Float :longitude, null: false
      Boolean :available, default: true
    end
  end
end
