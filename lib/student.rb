require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name 
    @grade = grade 
    @id =id
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER);"
  
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO students(name, grade) VALUES(?,?)"    
    
      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_instance = self.new(name, grade)
    new_instance.save    
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.new_from_db(row)
    self.new(name = row[1], grade = row[2], id = row[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?;"

    found = DB[:conn].execute(sql, name)[0]
    self.new(name = found[1], grade = found[2], id = found[0])
  end
end
