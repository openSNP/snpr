module UsersHelper
  def genotype_parse_status_label(parse_status)
    label_class = case parse_status
                  when 'queued' then 'label-default'
                  when 'parsing' then 'label-primary'
                  when 'done' then 'label-success'
                  when 'error' then 'label-danger'
                  end
    content_tag('span', parse_status, class: "label #{label_class}")
  end
end
