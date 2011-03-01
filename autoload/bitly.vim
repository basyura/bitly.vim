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
"   a:lngUrl string
"
function! bitly#shorten(longUrl)
  let xml = s:request(s:api_shorten , {'longUrl' : a:longUrl})
  return  s:flatten(xml , '')[0]
endfunction
"
" get expanded url
"   a:shortUrls string or list
"
function! bitly#expand(shortUrls)
  return s:request_with_short_urls(
            \ a:shortUrls , s:api_expand , 'entry')
endfunction
"
" get clicks status
"   a:shortUrls string or list
"
function! bitly#clicks(shortUrls)
  return s:request_with_short_urls(
            \ a:shortUrls , s:api_clicks , 'clicks')
endfunction
"
" get referrers
"   a:shortUrl string
"
function! bitly#referrers(shortUrl)
  return s:request_with_short_urls(
            \ [a:shortUrl] , s:api_referrers , 'referrers')
endfunction
"
" get countries
"   a:countries string
"
function! bitly#countries(shortUrl)
  return s:request_with_short_urls(
            \ [a:shortUrl] , s:api_countries , 'countries')
endfunction
"
" get clicks by minutes
"
"function! bitly#clicks_by_minutes(shortUrl)
  "return s:request_with_short_urls(
            "\ a:shortUrl , s:api_clicks_by_minute , 'clicks_by_minute')
"endfunction



" private "


"
" the string is returns if a:shortUrls is a string.
" the list   is returns if a:shortUrls is a list.
"
function! s:request_with_short_urls(shortUrls, api, node_name)

  let shortUrls = type(a:shortUrls)  == 1 
                      \ ? [a:shortUrls] : a:shortUrls
  let param = []
  for url in shortUrls
    call add(param , 'shortUrl=' . url)
  endfor
  let ret = s:flatten(s:request(a:api , param) , a:node_name)
  return type(a:shortUrls) == 1 ? ret[0] : ret
endfunction
"
" request to server with bitly#http.
" bitly#http is a library of webapi-vim
"
function! s:request(api, param)

  let login  = exists('g:bitly_login')   ? g:bitly_login   : s:login
  let apiKey = exists('g:bitly_api_key') ? g:bitly_api_key : s:apiKey

  let param = a:param
  if type(a:param) == 3
    call add(param , 'login='  . login)
    call add(param , 'apiKey=' . apiKey)
    call add(param , 'format=' . 'xml')
  else
    let param.login  = login
    let param.apiKey = apiKey
    let param.format = 'xml'
  endif
  return bitly#xml#parse(
          \ bitly#http#get(a:api , param).content)
endfunction
"
" flatten xml to dictionary
"
function! s:flatten(xml, node_name)
  let status_code = a:xml.find('status_code').value()
  let status_txt  = a:xml.find('status_txt').value()
  "  i want to analyze xpath beautifully.
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
"
" empty string is returns if xml has no a:name node.
" value is returns if xml has a:name node.
"
function! s:find_node_value(xml, name)
  let child = a:xml.find(a:name)
  return has_key(child , 'value') ? child.value() : ''
endfunction

