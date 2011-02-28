"
" license and version 
"          see readme
"
let s:api_shorten  = 'http://api.bitly.com/v3/shorten'
let s:api_expand   = 'http://api.bitly.com/v3/expand'
let s:api_validate = 'http://api.bitly.com/v3/validate'
let s:api_clicks   = 'http://api.bitly.com/v3/clicks'
"
" get shortened url
"
function! bitly#shorten(login, apiKey, longUrl)
  return 
    \ s:flatten(s:request(
    \ a:login, a:apiKey, s:api_shorten, {'longUrl' : a:longUrl}), 
    \ '')[0]
endfunction
"
" get expanded url
"
function! bitly#expand(login, apiKey, shortUrls)
  return s:request_with_short_urls(a:login , a:apiKey , a:shortUrls , s:api_expand , 'entry')
endfunction
"
" get clicks status
"
function! bitly#clicks(login, apiKey, shortUrls)
  return s:request_with_short_urls(a:login , a:apiKey , a:shortUrls , s:api_clicks , 'clicks')
endfunction

" private
"
function! s:request_with_short_urls(login, apiKey, shortUrls, api, node_name)
  let param = []
  for url in a:shortUrls
    call add(param , 'shortUrl=' . url)
  endfor
  return 
    \ s:flatten(s:request(
    \   a:login, a:apiKey, a:api , param) ,
    \   a:node_name)
endfunction

function! s:request(login, apiKey, api, param)
  let param = a:param
  if type(a:param) == 3
    call add(param , 'login='  . a:login)
    call add(param , 'apiKey=' . a:apiKey)
    call add(param , 'format=' . 'xml')
  else
    let param.login  = a:login
    let param.apiKey = a:apiKey
    let param.format = 'xml'
  endif
  return xml#parse(http#get(a:api , param).content)
endfunction

function! s:flatten(xml, node_name)
  let status_code = a:xml.find('status_code').value()
  let status_txt  = a:xml.find('status_txt').value()
  " 綺麗に xpath 解析したい
  "  data/*
  "  data/entry/*
  let data = a:xml.find('data')
  let children = [data]
  if a:node_name != ''
    let children = data.childNodes(a:node_name)
  endif

  let list = []
  for node in children
    let m = {'status_code' : status_code , 'status_txt' : status_txt}
    for child in node.childNodes()
      let m[child.name] = child.value()
    endfor
    call add(list , m)
  endfor
  return list
endfunction

function! s:find_node_value(xml, name)
  let child = a:xml.find(a:name)
  return has_key(child , 'value') ? child.value() : ''
endfunction

