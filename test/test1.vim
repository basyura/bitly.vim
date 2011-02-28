
"let here = expand('<sfile>:p:h')
"execute 'source' here . '/../autoload/bitly.vim'
execute 'source ' . $HOME . '/.vim/gitplugins/bitly.vim/autoload/bitly.vim'

function! s:assert_equals(v1, v2)
  if a:v1 != a:v2
    echoerr 'false : ' . a:v1 . ' != ' . a:v2
  endif
endfunction


let s:shorten = bitly#shorten('http://basyura.org')
call s:assert_equals(s:shorten.status_code , 200)
call s:assert_equals(s:shorten.status_txt  , 'OK')
call s:assert_equals(s:shorten.url         , 'http://bit.ly/fHgr3a')

let s:shorten = bitly#shorten('http://google.com')
call s:assert_equals(s:shorten.status_code , 200)
call s:assert_equals(s:shorten.status_txt  , 'OK')
call s:assert_equals(s:shorten.url         , 'http://bit.ly/g2n8tN')

let s:expand = bitly#expand('http://bit.ly/fHgr3a')
call s:assert_equals(s:expand.status_code , 200)
call s:assert_equals(s:expand.long_url    , 'http://basyura.org')
call s:assert_equals(s:expand.short_url   , 'http://bit.ly/fHgr3a')


let s:expands = bitly#expand(['http://bit.ly/fHgr3a' , 'http://bit.ly/g2n8tN'])
call s:assert_equals(s:expands[0].status_code , 200)
call s:assert_equals(s:expands[0].long_url    , 'http://basyura.org')
call s:assert_equals(s:expands[0].short_url   , 'http://bit.ly/fHgr3a')
call s:assert_equals(s:expands[1].status_code , 200)
call s:assert_equals(s:expands[1].long_url    , 'http://google.com')
call s:assert_equals(s:expands[1].short_url   , 'http://bit.ly/g2n8tN')

let s:clicks = bitly#clicks('http://bit.ly/fHgr3a')

let s:referrers = bitly#referrers('http://bit.ly/djZ9g4')
for s:v in s:referrers
  if has_key(s:v , 'referrer')
    echo s:v.referrer . ' ' . s:v.clicks
  else
    echo s:v.referrer_app . ' ' . s:v.clicks
  endif
endfor

for s:v in bitly#countries('http://bit.ly/djZ9g4')
  echo s:v.country . ' ' . s:v.clicks
endfor

