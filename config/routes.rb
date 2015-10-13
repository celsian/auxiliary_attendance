AuxiliaryAttendance::Application.routes.draw do
  get "class_session_students/new"
  devise_for :users
  root 'welcome#index'

  resources :class_sessions
  # resources :class_session_students

  get "/class_sessions/:id/close_session", to: "class_sessions#close_session", as: "close_session"

  post "/class_session_students/director", to: "class_session_students#director", as: "class_session_students_director"
  post "/class_session_students/join_session", to: "class_session_students#join_session", as: "class_session_students_join_session"
  post "/class_session_students/leave_session", to: "class_session_students#leave_session", as: "class_session_students_leave_session"

  resources :admin, only: [:index]
  get "/admin/teacher_editor", to: "admin#teacher_editor", as: "teacher_editor"
  get "/admin/user/:id/add_teacher/:q", to: "admin#add_teacher", as: "add_teacher"
  get "/admin/user/:id/remove_teacher/:q", to: "admin#remove_teacher", as: "remove_teacher"
  get "/admin/admin_editor", to: "admin#admin_editor", as: "admin_editor"
  get "/admin/user/:id/add_admin/:q", to: "admin#add_admin", as: "add_admin"
  get "/admin/user/:id/remove_admin/:q", to: "admin#remove_admin", as: "remove_admin"
  
  resources :users
  get "/user_search", to: "users#user_search", as: "user_search"

  resources :students, only: [:index, :edit, :update]
  get "/student/import", to: "students#import", as: "import"
  post "/student/import/submit", to: "students#import", as: "import_submit"
  get "/student/:id/enable_disable", to: "students#enable_disable", as: "student_enable_disable"
  get "/student/:id/stats", to: "students#stats", as: "student_stats"

  resources :stats, only: [:index]

end