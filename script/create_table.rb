require 'sqlite3'

db = SQLite3::Database.new './data/info.db'

# create table
sql = <<-SQL
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
db.execute(sql)

sql = <<-SQL
create table info_of_day (
  id INTEGER PRIMARY KEY,
  date TEXT,
  event TEXT,
  url TEXT,
  last_update TEXT
);
SQL
db.execute(sql)

sql = <<-SQL
create table user (
  twitter_id INTEGER PRIMARY KEY,
  service INTEGER,
  grade INTEGER,
  department INTEGER,
  class_num INTEGER
);
SQL

db.execute(sql)