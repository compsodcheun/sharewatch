module ApplicationHelper
  def bootstrap_alert_type(type)
    (type.eql? 'notice') ? 'success' : 'warning'
  end
end
