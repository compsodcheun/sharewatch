module ApplicationHelper
  def bootstrap_alert_type(type)
    (type.eql? 'notice') ? 'success' : 'warning'
  end

  def user_name
    (signed_in?) ? current_user.name : ''
  end

  def custom_will_paginate
    Class.new(WillPaginate::ActionView::LinkRenderer) do
      def container_attributes
        {class: "pagination"}
      end

      def page_number(page)
        if page == current_page
          %(
            <li class="page-item active">
              <a class="page-link" href="#" tabindex="-1">#{page}</a>
            </li>
          )
        else
          link(page, page, class: 'page-link', rel: rel_value(page))
        end
      end

      def gap
        text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
        %(<span class="mr2">#{text}</span>)
      end

      def previous_page
        num = @collection.current_page > 1 && @collection.current_page - 1
        previous_or_next_page(num, @options[:previous_label], 'page-link')
      end

      def next_page
        num = @collection.current_page < total_pages && @collection.current_page + 1
        previous_or_next_page(num, @options[:next_label], 'page-link')
      end

      def previous_or_next_page(page, text, classname)
        if page
          link(text, page, :class => classname)
        else
          %(
            <li class="page-item disabled">
              <a class="page-link" href="#" tabindex="-1">#{text}</a>
            </li>
          )
        end
      end
    end
  end

  def get_image_path(image, watch, is_thumbnail = false)
    return if image.blank? or watch.blank?
    image_download_path(
      image.id,
      watch_id: watch.id,
      thumbnail: is_thumbnail
    )
  end
end
