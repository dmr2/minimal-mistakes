# Open external (absolute http/https) links in a new tab and harden rel.
# Internal, anchor, and mailto links are left untouched.
Jekyll::Hooks.register [:pages, :documents], :post_render do |item|
  next unless item.output_ext == ".html"

  item.output = item.output.gsub(/<a\b[^>]*>/i) do |tag|
    next tag unless tag =~ /href\s*=\s*["']https?:\/\//i
    next tag if tag =~ /\btarget\s*=/i

    new_tag = tag.sub(/\s*>\z/, "")
    new_tag += ' target="_blank"'

    if new_tag =~ /\brel\s*=\s*(["'])(.*?)\1/i
      rel_val = Regexp.last_match(2)
      unless rel_val =~ /noopener/i && rel_val =~ /noreferrer/i
        rel_val = "#{rel_val} noopener noreferrer".strip
        new_tag = new_tag.sub(/\brel\s*=\s*(["']).*?\1/i, "rel=\\1#{rel_val}\\1")
      end
    else
      new_tag += ' rel="noopener noreferrer"'
    end

    new_tag + ">"
  end
end
