#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

Rake.application.remove_task "doc:app"
Rake.application.remove_task "test"
Rake.application.remove_task "test:recent"
Rake.application.remove_task "test:single"
Rake.application.remove_task "test:uncommitted"

Yclist::Application.load_tasks
