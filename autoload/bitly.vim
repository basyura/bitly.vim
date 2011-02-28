"
" license and version 
"          see readme
"
let s:login  = 'bitlyvim'
let s:apiKey = 'R_6f34b5ca68aed589e0368d6707f86353'

let s:api_shorten          = 'http://api.bitly.com/v3/shorten'
let s:api_expand           = 'http://api.bitly.com/v3/expand'
let s:api_validate         = 'http://api.bitly.com/v3/validate'
let s:api_clicks           = 'http://api.bitly.com/v3/clicks'
let s:api_referrers        = 'http://api.bitly.com/v3/referrers'
let s:api_countries        = 'http://api.bitly.com/v3/countries'
let s:api_clicks_by_minute = 'http://api.bitly.com/v3/clicks_by_minute'
"
" get shortened url
"
function! bitly#shorten(longUrl)
  let xml = s:request(s:api_shorten , {'longUrl' : a:longUrl})
  return  s:flatten(xml , '')[0]
endfunction
"
" get expanded url
"
function! bitly#expand(shortUrls)
  return s:request_with_short_urls(
            \ a:shortUrls , s:api_expand , 'entry')
endfunction
"
" get clicks status
"
function! bitly#clicks(shortUrls)
  return s:request_with_short_urls(
            \ a:shortUrls , s:api_clicks , 'clicks')
endfunction
"
" get referrers
"
function! bitly#referrers(shortUrl)
  return s:request_with_short_urls(
            \ a:shortUrl , s:api_referrers , 'referrers')
endfunction
"
" get countries
"
function! bitly#countries(shortUrl)
  return s:request_with_short_urls(
            \ a:shortUrl , s:api_countries , 'countries')
endfunction
"
" get clicks by minutes
"
"function! bitly#clicks_by_minutes(shortUrl)
  "return s:request_with_short_urls(
            "\ a:shortUrl , s:api_clicks_by_minute , 'clicks_by_minute')
"endfunction


"
" private
"
function! s:request_with_short_urls(shortUrls, api, node_name)

  let shortUrls = type(a:shortUrls)  == 1 
                      \ ? [a:shortUrls] : a:shortUrls
  let param = []
  for url in shortUrls
    call add(param , 'shortUrl=' . url)
  endfor
  return s:flatten(s:request(a:api , param) , a:node_name)
endfunction

function! s:request(api, param)
  let param = a:param
  if type(a:param) == 3
    call add(param , 'login='  . s:login)
    call add(param , 'apiKey=' . s:apiKey)
    call add(param , 'format=' . 'xml')
  else
    let param.login  = s:login
    let param.apiKey = s:apiKey
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

