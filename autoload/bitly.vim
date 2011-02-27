"
" license and version 
"          see readme
"
let s:shorten_api = 'http://api.bitly.com/v3/shorten'

function! bitly#shorten(login, apiKey, longUrl)

  let xml = xml#parse(http#get(s:shorten_api , {
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
