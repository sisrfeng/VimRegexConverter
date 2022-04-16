" 用法
    "  magic → very magic
    "             " :echo ConvertRegex('v', '\m-hi.*\<lucy\>' )
    "     " 去掉开头的\v-
    "             " :echo ConvertRegex('v', '\m-\(hi.*lucy\)' )[3:]
    "             " :echo ConvertRegex('v', '\m-' .. expand('<cword>')  )[3:]
    "             " :echo ConvertRegex('v', '\m-' .. @" ) [3:]
    "     " vnor <leader>r y:let @" = '/v' .. ConvertRegex('v', '\m-' .. @" )[4:]<cr><esc>:echom @"<cr>
    "     " vnor <leader>r y:let @" =  ConvertRegex('v', '\m-' .. @" )[4:]<cr><esc>:echom @"<cr>
    vnor <leader>r "ry<Cmd>let @o =  ConvertRegex('v',  '\m-/'.. @r  )[4:]<cr><esc>o\v<c-r>o<esc>
                                                          " 有些regex开头没加/, 这里加上
    " nnor <leader>r yiW:let @" = '\v' .. ConvertRegex('v', '\m-' .. @" )[4:]<cr><esc>/<c-r>"<cr>
    "                                                                                       " 不加<cr>:现在有些不准, 等校正
    " nnor <leader>r yiW:let @" = '\v' .. ConvertRegex('v', '\m-' .. @" )[4:]<cr><esc>/<c-r>"
    " " 不太准... \@=会变\@\=

" 不用converter插件:
    nnor <leader>r "ryiW:let @o = "<c-r>r" ->substitute( '\v\\(\W)' , '\1', 'ge' )<cr><esc>/\v<c-r>o
                 " "r: 复制到寄存器r                                                      " 最后不加<cr>:现在有些不准, 等校正
                         " @o: 输出到寄存器o
    " vnor <leader>r   y:let @" = "<c-r>r" ->substitute( '\v\\(\W)' , '\1', 'ge' )<cr><esc>o\v<c-r>"<esc>
    " 还是converter插件好用


"   slash变sharp
    "     : sub ^\/^#^gc


function! ConvertRegex(toMode, regex)
    " Get the original regex mode
    let fromMode = matchstr(a:regex, '..')

    " Save ignorecase setting
    let s:saveIgnoreCase=&ignorecase
    set noignorecase

    " Test toMode validity
    if a:toMode != 'm' && a:toMode != 'M' && a:toMode != 'v' && a:toMode != 'V'
        echoerr "Can't get the mode you want to convert the regex to"
        echoerr "Please make your first argument be 'm', 'M', 'v' or 'V'"
        return 1
    endif

    " Test fromMode validity
    if fromMode[0] != '\' || (fromMode[1] != 'm' && fromMode[1] != 'M' &&fromMode[1] != 'v' &&fromMode[1] != 'V')
        echoerr "Can't get the original mode of the regex to convert"
        echoerr "Please make your regex begin with '\\v', '\\m', '\\V' or '\\M'"
        return 1
    endif

    " Test conversion validity
    if fromMode[1] == a:toMode
        echo "The specified mode is the one already used in the regex"
        return
    endif

    " Dictionnary containing the characters to (un)escape from each conversion
    " Keys are of the format 'fromModeToMode'

    " " magic → very magic
    "     : sub #\v\\(\W)#\1#gc
    "  " slash变sharp
    "     : sub ^\/^#^gc


    let charsToEscape = {
            \'mv' : ['(', ')', '|', '=', '<', '>', '+', '{', '&', '%', '@'],
            "\ 2个以上的特殊字符挨在一起, 现在无法解决? @=!
            \'vm' : ['{', '(', ')', '|', '=', '<', '>', '+'],
            \
            \'mV' : ['.', '$', '*', '~', '[', '^'],
            \'mM' : ['.', '*', '~', '['],
            \'Mv' : ['.', '*', '~', '(', ')', '|', '{'],
            \'MV' : ['$'],
            \'Mm' : ['.', '*', '~'],
            \'vV' : ['.', '{', '$', '*', '~', '(', ')', '|'],
            \'vM' : ['.', '{', '*', '~', '(', ')', '|'],
            \'Vv' : ['.', '$', '*', '~', '(', ')', '|', '{'],
            \'Vm' : ['.', '$', '*', '~', '{', '}'],
            \'VM' : ['$']
        \}

    " Create the key of the subdictionary to use and call the conversion function
    let key = fromMode[1] . a:toMode
    let res= <sid>ApplyConversion(a:regex, charsToEscape[key], a:toMode)

    " Restore the ignorecase setting
    let &ignorecase=s:saveIgnoreCase
    unlet s:saveIgnoreCase

    return res
endfunction

function! s:ApplyConversion(regex, charsToEscape, toMode)
    let res = a:regex

    " Handle the chars where escaping needs to be inversed
    for char in a:charsToEscape
        let res = substitute(res, '\V\\'.char, 'UNESCAPEME', 'g')
        let res = substitute(res, '\V'.char, '\\'.char, 'g')
        let res = substitute(res, 'UNESCAPEME', char, 'g')
    endfor

    " Change the mode of the regex (first two characters)
    let res= substitute(res, '..', '\\'.a:toMode, '')

    return res
endfunction


" 貌似只是用作测试的:
    " Utility function to test the other one
    function! TestRegex(regex)
        let m = ConvertRegex('m', a:regex)
        let v = ConvertRegex('v', a:regex)
        let M = ConvertRegex('M', a:regex)
        let V = ConvertRegex('V', a:regex)

        let string = m . "\n" . v . "\n" . M . "\n" . V
        call setreg('z', string)
        normal "ap
    endfunction

