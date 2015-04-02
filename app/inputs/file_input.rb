class FileInput < Formtastic::Inputs::FileInput
  def to_html
    input_wrapping do
      label_html <<
        builder.file_field(method, input_html_options) <<
        progress_bar_html
    end
  end

private
  def progress_bar_html
    '<div id="progress"><div class="bar">0%</div></div>'.html_safe
  end
end
