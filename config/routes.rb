AuxiliaryAttendance::Application.routes.draw do
  get "class_session_students/new"
  devise_for :users
  root 'welcome#index'

  resources :class_sessions
  resources :class_session_students
  resources :admin
  get "/class_sessions/:id/close_session", to: "class_sessions#close_session", as: "close_session"
  post "/class_session_students/director", to: "class_session_students#director", as: "class_session_students_director"
  post "/class_session_students/join_session", to: "class_session_students#join_session", as: "class_session_students_join_session"
  post "/class_session_students/leave_session", to: "class_session_students#leave_session", as: "class_session_students_leave_session"
  
end