require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    query = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL

    DB[:conn].execute(query)
  end

  def self.drop_table
    query = <<-SQL
    DROP TABLE students
    SQL

    DB[:conn].execute(query)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    student = Student.new(row[0], row[1], row[2])
    student
  end

  def self.find_by_name(name)
    query = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    SQL

    DB[:conn].execute(query, name).map { |row| new_from_db(row) }.first
  end

  def save
    if @id
      update
    else
      query = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(query, @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    query = <<-SQL
    UPDATE students SET name = ?, grade = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(query, name, grade, @id)
  end
end
