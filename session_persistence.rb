require "pg"

class DatabasePersistence
  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end

  def find_list(id)
    @session[:lists].find { |l| l[:id] == id }
  end

  def all_lists
    @session[:lists]
  end

  def <<(list)
    @session[:lists] << list
  end

  def destroy_list(id)
    @session[:lists].reject! { |list| list[:id] == id }
  end

  def create_new_list(name)
    id = next_element_id(@session[:lists])
    @session[:lists] << { id: id, name: name, todos: [] }
  end

  def next_element_id(elements)
    max = elements.map { |todo| todo[:id] }.max || 0
    max + 1
  end

  def update_list_name(list_id, new_name)
    list = find_list(list_id)
    list[:name] = new_name
  end

  def add_todo(list_id, todo_name)
    list = find_list(list_id)
    id = next_element_id(list[:todos])
    list[:todos] << { id: id, name: todo_name, completed: false }
  end

  def delete_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def toggle_todo(list, todo_id, status)
    is_completed = status == "true"
    todo = list[:todos].find { |todo| todo[:id] == todo_id }
    todo[:completed] = is_completed
  end

  def mark_all_completed(list)
    list[:todos].each do |todo|
      todo[:completed] = true
    end
  end
end
