class MyTodo {
  String? todoId;
  String? userId;
  String? todoTitle;
  String? todoDesc;
  String? todoCategory;
  String? todoDate;
  String? todoPriority;
  String? todoCompleted;
  String? todoReminder;
  String? dateCreate;

  MyTodo({
    this.todoId,
    this.userId,
    this.todoTitle,
    this.todoDesc,
    this.todoCategory,
    this.todoDate,
    this.todoPriority,
    this.todoCompleted,
    this.todoReminder,
    this.dateCreate,
  });

  MyTodo.fromJson(Map<String, dynamic> json) {
    todoId = json['todo_id'];
    userId = json['user_id'];
    todoTitle = json['todo_title'];
    todoDesc = json['todo_desc'];
    todoCategory = json['todo_category'];
    todoDate = json['todo_date'];
    todoPriority = json['todo_priority'];
    todoCompleted = json['todo_completed'];
    todoReminder = json['todo_reminder'];
    dateCreate = json['date_create'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['todo_id'] = todoId;
    data['user_id'] = userId;
    data['todo_title'] = todoTitle;
    data['todo_desc'] = todoDesc;
    data['todo_category'] = todoCategory;
    data['todo_date'] = todoDate;
    data['todo_priority'] = todoPriority;
    data['todo_completed'] = todoCompleted;
    data['todo_reminder'] = todoReminder;
    data['date_create'] = dateCreate;
    return data;
  }
}
