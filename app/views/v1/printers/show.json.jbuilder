json.printer do
  json.partial! 'v1/printers/details', printer: @printer
end