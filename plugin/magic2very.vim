" 用法
    nno <Leader>r    <Cmd>norm  vq"ry<cr>
                    \<Cmd>call Get_very_magiC()<cr>

    "\ 还得改
    "\ vno <leader>r    <cmd>call Get_very_magiC()<cr>

    func! Get_very_magiC()
        let @r = '\v' . s:very_magiC( @r )
        exe "norm \<M-?>"
        norm vq
        norm! "rp
    endf
        " \        pattern       : ' \(\S\+\s*[;=]\)\@=',


    "\ func! Get_very_magiC()
    "\     normal! "ry
    "\     let @r = '\v' . s:very_magiC( @r )
    "\     normal! hh
    "\     normal! mt
    "\     exec "normal! o\<esc>"
    "\     normal! `t
    "\     put r
    "\ endf

    "\ nno <Leader>r  y<cmd>call pairs#process("'`#" . '"', 'i')q<cr><esc><cmd>call Get_very_magiC()<cr>
                                             "\ ¿'"#¿ 都可以用于包裹regex


    " 不用本插件:
        "\ nnor <leader>r "ryiW:let @o = "<c-r>r" ->substitute( '\v\\(\W)' , '\1', 'ge' )<cr><esc>/\v<c-r>o
                    " "r: 复制到寄存器r                                                      " 最后不加<cr>:现在有些不准, 等校正
                            " @o: 输出到寄存器o
        " vnor <leader>r   y:let @" = "<c-r>r" ->substitute( '\v\\(\W)' , '\1', 'ge' )<cr><esc>o\v<c-r>"<esc>
        " 还是converter插件好用

" slash变sharp  : sub ^\/^#^gc


fun! s:very_magiC(magic_r)
    " Save ignorecase setting
    let s:saveIgnoreCase=&ignorecase
    set noignorecase

    " if fromMode[0] != '\' || (fromMode[1] != 'm' && fromMode[1] != 'M' &&fromMode[1] != 'v' &&fromMode[1] != 'V')
    "     echoerr "Can't get the original mode of the regex to convert"
    "     echoerr "Please make your regex begin with '\\v', '\\m', '\\V' or '\\M'"
    "     return 1
    " en



    let escape_us =  [
                      \'(',
                      \')',
                      \'<',
                      \'>',
                      \
                      \'=',
                      \'?',
                      \
                      \'{',
                      "\ '}',不用escape
                      \'|',
                      \'+',
                      \'&',
                      \'%',
                      \'@',
                      \]
            " 2个以上的特殊字符挨在一起, 现在无法解决?
            " 比如: @=!

            "仅留作参考:

                "     	'vm' : ['{', '(', ')', '|', '=', '<', '>', '+'],
                "
                "    	'mV' : ['.', '$', '*', '~', '[', '^'],
                "    	'mM' : ['.', '*', '~', '['],
                "    	'Mv' : ['.', '*', '~', '(', ')', '|', '{'],
                "    	'MV' : ['$'],
                "    	'Mm' : ['.', '*', '~'],
                "    	'vV' : ['.', '{', '$', '*', '~', '(', ')', '|'],
                "    	'vM' : ['.', '{', '*', '~', '(', ')', '|'],
                "    	'Vv' : ['.', '$', '*', '~', '(', ')', '|', '{'],
                "    	'Vm' : ['.', '$', '*', '~', '{', '}'],
                "    	'VM' : ['$']
                "


    let pieces = []
    let mr = a:magic_r

    " 处理[+-~*]等情况 (中括号内 别escape)
        let leftS = match(mr, '[')
        if leftS > -1
            let rightS = match(mr, ']')
            if rightS > -1
                let mr_head = mr[        :leftS]
                let mr_end  = 'Do NoT ToucH Me'.mr[rightS+1:     ]
                let mr_in   = mr[leftS+1 :rightS]
              endif
            call add(pieces, mr_head)
            call add(pieces, mr_in)
            call add(pieces, mr_end)
        el
            call add(pieces, mr)
        endif


    let new_pieces = []
    for a_str in pieces
        if match(a_str,'Do NoT ToucH Me') == 0
            let a_piece = a_str[14:]
            continue
        endif
        if match(a_str, '\\%(') != -1
                      " 变为'\%\('
                      " 然后下面再一块变为%(
                      " let @t =  a_str
            let a_str = substitute(a_str, '\V\\%(', '\\%\\(', 'g')
        en

        if match(a_str, '\\@>') != -1
                      " 变为'\@\<'
                      " 然后下面再一块变为@<
            let a_str = substitute(a_str, '\V\\@>', '\\@\\>', 'g')
        en



        if match(a_str, '\V\\@=') != -1
            let a_str = substitute(a_str, '\V\\@=', '\\@\\=', 'g')
        en

        if match(a_str, '\V\\@<!') != -1
            let a_str = substitute(a_str, '\V\\@<!', '\\@\\<!', 'g')
        en

        if match(a_str, '\V\\@<=') != -1
            let a_str = substitute(a_str, '\V\\@<=', '\\@\\<\\=', 'g')
        en

        " Handle the chars where escaping needs to be ✌inversed✌ : 用ProtecT暂时置换掉
        for char in escape_us
        " 只处理magic到very magic, 可以简化?
            let a_str = substitute(a_str, '\V\\'.char, 'ProtecT', 'g')
                                " 函数看到的是\V\某
            let a_str = substitute(a_str, '\V'.char, '\\'.char, 'g')
            let a_str = substitute(a_str, 'ProtecT', char, 'g')

        endfor
        call add(new_pieces, a_str)
    endfor
    return join(new_pieces, '')


    " Change the mode of the regex (first two characters)
    " let a_str= substitute(a_str, '..', '\\v', '')



    " Restore the ignorecase setting
    let &ignorecase=s:saveIgnoreCase
    unlet s:saveIgnoreCase

    return res
endf
