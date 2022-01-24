require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "todos")
          end
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec(statement, params)
  end

  def find_list(list_id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, list_id)

    todo_arr = all_todos(list_id)
    tuple = result.first
    {id: list_id, name: tuple['name'], todos: todo_arr }
  end

  def all_lists
    sql = 'SELECT * FROM lists;'
    result = query(sql)
    result.map do |tuple|
      list_id = tuple['id'].to_i
      todos = all_todos(list_id)
      {id: list_id, name: tuple['name'], todos: todos }
    end
  end

  def destroy_list(list_id)
    query("DELETE FROM todos WHERE list_id = $1;", list_id)
    query("DELETE FROM lists WHERE id = $1;", list_id)
  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1);"
    query(sql, list_name)
  end

  def update_list_name(list_id, new_name)
    query("UPDATE lists SET name = $1 WHERE id = $2", new_name, list_id)
  end

  def add_todo(list_id, todo_name)
    sql = "INSERT INTO todos (name, list_id) VALUES ($1, $2);"
    query(sql, todo_name, list_id)
  end

  def delete_todo(list_id, todo_id)
    sql = "DELETE FROM todos WHERE list_id = $1 AND id = $2;"
    query(sql, list_id, todo_id)
  end

  def toggle_todo(list_id, todo_id, new_status)
    sql = "UPDATE todos SET completed = $1 WHERE id = $2 AND list_id = $3;"
    query(sql, new_status, todo_id, list_id)
  end

  def mark_all_completed(list_id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1;"
    query(sql, list_id)
  end

  private

  def all_todos(list_id)
    sql = "SELECT * FROM todos WHERE list_id = $1"
    results = query(sql, list_id)
    results.map do |tuple|
      {id: tuple['id'].to_i,
       name: tuple['name'], 
       completed: (tuple['completed'] == "t") }
    end
  end
end
