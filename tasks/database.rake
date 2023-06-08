require "sequel"

namespace :db do
  DB = Sequel.connect(ENV["DATABASE_URL"])

  desc "current schema version"
  task :version do
    version = DB[:schema_info] ? DB[:schema_info].first[:version] : 0
    puts "Schema Version: #{version}"
  end

  desc "Run migrations"
  task :migrate do
    Sequel.extension :migration
    Sequel::Migrator.run(DB,"database/migrations")
    Rake::Task["db:version"].execute
    Dir.glob("./models/*.rb").each { |file| require file }
  end

  desc "Populate database"
  task :seed do
    Dir.glob("./models/*.rb").each { |file| require file }
    Dir.glob("./database/seeds/*.rb").each { |file| require file }
  end

  # TODO Move this to a separate file
  desc "Run tests"
  task :test do
    require "simplecov"
    SimpleCov.start do
      add_filter "/tests/"
    end
    DB[:rides].delete
    DB[:payment_methods].delete
    DB[:riders].delete
    DB[:drivers].delete

    Dir.glob("./models/*.rb").each { |file| require file }
    Dir.glob("./tests/models/*.rb").each { |file| require file }
    #Dir.glob("./tests/services/*.rb").each { |file| require file }
  end

end
