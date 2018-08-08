module QKbot
  module DB
    def self.create
      db = SQLite3::Database.new ENV['DBPATH']

      # create table
      class_info = <<-SQL
      create table class_info (
        id INTEGER PRIMARY KEY,
        type INTEGER,
        class_date TEXT,
        begin_period INTEGER,
        end_period INTEGER,
        grade INTEGER,
        department INTEGER,
        class_num INTEGER,
        before_name TEXT,
        before_place TEXT,
        before_teacher TEXT,
        after_name TEXT,
        after_place TEXT,
        after_teacher TEXT
      );
      SQL
      
      info_of_day = <<-SQL
      create table info_of_day (
        id INTEGER PRIMARY KEY,
        date TEXT,
        event TEXT,
        url TEXT,
        last_update TEXT
      );
      SQL
      
      user = <<-SQL
      create table user (
        twitter_id INTEGER PRIMARY KEY,
        service INTEGER,
        grade INTEGER,
        department INTEGER,
        class_num INTEGER
      );
      SQL

      db.transaction do
        db.execute(class_info)
        db.execute(info_of_day)
        db.execute(user)
      end
      
      db.close
    end
    
  end
  
end