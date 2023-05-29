require "sequel"

# Create riders table
Sequel.migration do
  change do
    create_table(:riders) do
      primary_key :id
      String :name, null: false
      String :lastname, null: false
      String :email, null: false
      String :phone, null: false
    end
  end

end
