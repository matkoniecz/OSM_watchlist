def overpass_escape(text)
  raise "impossible escape <#{text}>" if text.include?("'") and text.include?('"')
  return '"' + text + '"' if text.include?("'")
  return "'#{text}'"
end

def filter_across_named_region(filter, name)
  return "[out:json][timeout:2500];
area[name=#{overpass_escape(name)}]->.searchArea;
(
  node#{filter}(area.searchArea);
  way#{filter}(area.searchArea);
  relation#{filter}(area.searchArea);
);
out meta;
>;
out meta qt;"
end

# tag negation is very slow - overpass will sometimes allow this type of query while using tag!=* will cause it to fail 
def two_pass_filter_across_named_region(filter, negative_filter, name)
  return "[out:json][timeout:2500];
area[name=#{overpass_escape(name)}]->.searchArea;
(
  way#{filter}(area.searchArea);
  node#{filter}(area.searchArea);
  relation#{filter}(area.searchArea);
)-> .a;
(
  way#{negative_filter}(area.searchArea);
  node#{negative_filter}(area.searchArea);
  relation#{negative_filter}(area.searchArea);
) -> .b;
(
.a - .b;
);
out meta;
>;
out meta qt;"
end