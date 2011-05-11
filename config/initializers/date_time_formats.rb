Time::DATE_FORMATS.merge!(
  :us => '%m/%d/%y',
  :us_with_time => '%m/%d/%y, %l:%M %p',
  :short_day => '%e %B %Y',
  :long_day => '%A, %e %B %Y',
  :file => '%Y-%m-%d_%H-%M'
)

Date::DATE_FORMATS[:human] = "%B %e, %Y"
