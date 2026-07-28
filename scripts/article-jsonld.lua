local site_url = "https://gkrivtchik.com"

local author = {
  ["@type"] = "Person",
  name = "Guillaume Krivtchik",
  url = site_url .. "/",
  sameAs = {
    "https://github.com/GKrivtchik",
    "https://www.linkedin.com/in/guillaume-krivtchik-29b96693/",
  },
}

local months = {
  January = "01", February = "02", March = "03", April = "04",
  May = "05", June = "06", July = "07", August = "08",
  September = "09", October = "10", November = "11", December = "12",
}

local function text(value)
  return pandoc.utils.stringify(value)
end

local function iso_date(value)
  local date = text(value)
  if date:match("^%d%d%d%d%-%d%d%-%d%d$") then
    return date
  end

  local month, day, year = date:match("^(%a+) (%d+), (%d%d%d%d)$")
  return string.format("%s-%s-%02d", year, months[month], tonumber(day))
end

local function absolute_image_url(article_url, image)
  if image:match("^https?://") then
    return image
  elseif image:sub(1, 1) == "/" then
    return site_url .. image
  end
  return article_url .. image
end

function Pandoc(doc)
  if not quarto.doc.is_format("html") then
    return doc
  end

  local slug = quarto.doc.input_file:match("[/\\]posts[/\\]([^/\\]+)[/\\]index%.qmd$")
  if not slug then
    return doc
  end

  local article_url = site_url .. "/posts/" .. slug .. "/"
  local published = iso_date(doc.meta.date)
  local modified = doc.meta["date-modified"]
    and iso_date(doc.meta["date-modified"])
    or published

  local keywords = {}
  for _, category in ipairs(doc.meta.categories) do
    table.insert(keywords, text(category))
  end

  local first_image
  doc:walk({
    Image = function(image)
      first_image = first_image or image.src
    end,
  })

  local schema = {
    ["@context"] = "https://schema.org",
    ["@type"] = "BlogPosting",
    headline = text(doc.meta.title),
    description = text(doc.meta.description),
    url = article_url,
    mainEntityOfPage = article_url,
    author = author,
    datePublished = published,
    dateModified = modified,
    keywords = keywords,
    inLanguage = "en",
  }

  if first_image then
    schema.image = { absolute_image_url(article_url, first_image) }
  end

  local json = quarto.json.encode(schema):gsub("<", "\\u003c")
  quarto.doc.include_text(
    "in-header",
    '<script type="application/ld+json">\n' .. json .. "\n</script>"
  )

  return doc
end
