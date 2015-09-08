json.printers @printers do |printer|
  json.partial! 'v1/printers/details', printer: printer
end
