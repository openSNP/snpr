module UsersHelper
  def display_parse_status(genotype)
    label_class = case genotype.parse_status
                  when 'queued' then 'label-default'
                  when 'parsing' then 'label-primary'
                  when 'done' then 'label-success'
                  when 'error' then 'label-danger'
                  end
    content_tag('span', genotype.parse_status, class: "label #{label_class}")
  end

  def delete_genotype_button(genotype)
    link_to(
      t('.genotypes.delete'),
      genotype,
      method: 'delete',
      class: "btn btn-default settings__deleting-button",
      data: {
        confirm: t('.genotypes.confirm_delete', file_name: genotype.genotype_file_name)
      }
    )
  end
end
