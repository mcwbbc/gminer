ADMIN_DATA_VIEW_AUTHORIZATION = Proc.new { |controller| controller.send("admin_logged_in?") }
ADMIN_DATA_UPDATE_AUTHORIZATION = Proc.new { |controller| return false }
