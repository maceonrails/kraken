json.outlets @outlets do |outlet|
  json.partial! 'v1/outlets/details', outlet: outlet
end

json.total @total