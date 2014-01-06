class HelpdeskHooks < Redmine::Hook::Listener
  
  # render partial for 'Send mail to supportclient'
  def view_issues_edit_notes_bottom(context={})
    i = Issue.find(context[:issue].id)
    c = CustomField.find_by_name('Email To')
    owner_email = i.custom_value_for(c).try(:value)
    return if owner_email.blank?
    action_view = ActionView::Base.new(File.dirname(__FILE__) + '/../app/views/')
    action_view.render(:partial => "issue_edit", :locals => {:email => owner_email})
  end
  
  # fetch 'send_to_owner' param and set the value into journal.send_to_owner
  def controller_issues_edit_before_save(context={})
    send_to_owner = (context[:params]['send_to_owner'] == "true")
    context[:journal].send_to_owner = send_to_owner
  end
  
  # add a history note on the journal
  def view_issues_history_journal_bottom(context={})
    return unless context[:journal].send_to_owner == true
    i = Issue.find(context[:journal].journalized_id)
    c = CustomField.find_by_name('Email To')
    owner_email = i.custom_value_for(c).try(:value)
    return if owner_email.blank?
    action_view = ActionView::Base.new(File.dirname(__FILE__) + '/../app/views/')
    action_view.render(:partial => "issue_history", :locals => {:email => owner_email})
  end
  
end
