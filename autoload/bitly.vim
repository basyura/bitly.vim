"
" license and version 
"          see readme
"
let s:api_shorten  = 'http://api.bitly.com/v3/shorten'
let s:api_expand   = 'http://api.bitly.com/v3/expand'
let s:api_validate = 'http://api.bitly.com/v3/validate'
"
" get shortened url
"
function! bitly#shorten(login, apiKey, longUrl)
  return 
    \ s:flatten(s:request(
    \   a:login, a:apiKey, s:api_shorten, {'longUrl' : a:longUrl}), 
    \   [
    \   'status_code' , 'status_txt' , 'url' ,
    \   'global_hash' , 'long_url' , 'new_hash'
    \   ])
endfunction
"
" get expanded url
"
function! bitly#expand(login, apiKey, shortUrl)
  return 
    \ s:flatten(s:request(
    \   a:login, a:apiKey, s:api_expand, {'shortUrl' : a:shortUrl}) , 
    \   [
    \   'status_code' , 'status_txt' , 'short_url' , 'long_url' ,
    \   'user_hash' , 'global_hash' , 'hash' , 'error'
    \   ])
endfunction

" private

function! s:request(login, apiKey, api, param)
  let param = a:param
  let param.login  = a:login
  let param.apiKey = a:apiKey
  let param.format = 'xml'
  return xml#parse(http#get(a:api , param).content)
endfunction

function! s:flatten(xml, names)
  let map = {}
  for name in a:names
    let map[name] = s:find_node_value(a:xml , name)
  endfor
  return map
endfunction

function! s:find_node_value(xml, name)
  let child = a:xml.find(a:name)
  return has_key(child , 'value') ? child.value() : ''
endfunction

