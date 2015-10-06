class StudentController < ApplicationController
  def index
    @students = Student.find(params[:])Student.all
  end

  def edit_student

  end

  def update_student

  end

  def import
    if params[:file]
      record_changes = Student.import(params[:file])
      redirect_to import_path, flash: {success: "#{record_changes[:success]} Students were imported or updated. #{record_changes[:failure]} failed."}
    end
  end

  private

  def student_params
    params.require(:student).permit(:first_name, :last_name, :id_number)
  end

end