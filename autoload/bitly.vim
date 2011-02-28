"
" license and version 
"          see readme
"
let s:api_shorten  = 'http://api.bitly.com/v3/shorten'
let s:api_expand   = 'http://api.bitly.com/v3/expand'
let s:api_validate = 'http://api.bitly.com/v3/validate'

function! bitly#shorten(login, apiKey, longUrl)

  let xml = xml#parse(http#get(s:api_shorten , {
        \ 'login'   : a:login  , 
        \ 'apiKey'  : a:apiKey , 
        \ 'format'  : 'xml'    , 
        \ 'longUrl' : a:longUrl
        \ }).content)

  return {
        \ 'status_code' : xml.find('status_code').value() ,
        \ 'status_txt'  : xml.find('status_txt').value()  ,
        \ 'url'         : xml.find('url').value()         ,
        \ 'global_hash' : xml.find('global_hash').value() ,
        \ 'long_url'    : xml.find('long_url').value()    ,
        \ 'new_hash'    : xml.find('new_hash').value()
        \}
  
endfunction


function! bitly#expand(login, apiKey, short_url)

  let xml = xml#parse(http#get(s:api_expand , {
        \ 'login'     : a:login  , 
        \ 'apiKey'    : a:apiKey , 
        \ 'format'    : 'xml'    , 
        \ 'shortUrl'  : a:short_url
        \ }).content)

  return {
        \ 'status_code' : s:find_node(xml , 'status_code') ,
        \ 'status_txt'  : s:find_node(xml , 'status_txt')  ,
        \ 'short_url'   : s:find_node(xml , 'short_url')   ,
        \ 'long_url'    : s:find_node(xml , 'long_url')    ,
        \ 'user_hash'   : s:find_node(xml , 'user_hash')   ,
        \ 'global_hash' : s:find_node(xml , 'global_hash') ,
        \ 'hash'        : s:find_node(xml , 'hash')        ,
        \ 'error'       : s:find_node(xml , 'error')
        \ }
  
endfunction

function! s:find_node(xml, name)
  let child = a:xml.find(a:name)
  return has_key(child , 'value') ? child.value() : ''
endfunction

