module ApplicationHelper
  def money_to_s(money)
    pluralize(money, 'cent')
  end
end
