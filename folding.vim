" === utility functions === {{{
    " --- IndentLevel --- {{{
    function! IndentLevel(lnum)
        return indent(a:lnum) / &shiftwidth
    endfunction
    " --- }}}
    
    " --- GetLastCommentLine --- {{{
    function! GetLastCommentLine(lines)
        let index = 0
        for line in a:lines
            if match(line, '@') >= 0
                if index > 0
                    if match(line, '\s*\*\s*$')
                        return index-2
                    endif
                    return index-1
                else
                    return 0
                endif
            endif
    
            if match(line, '.*\*\/') >= 0
                return index-1
            endif
    
            let index = index+1
        endfor
    
        return -1
    endfunction
    " --- }}}
    
    " --- GetReturnComment --- {{{
    function! GetReturnComment(lines)
        for line in a:lines
            if match(line, '.*@return .*') >= 0
                let result = substitute(line, '[\*]\{1,\}', '', '')
                let result = substitute(result, '\s\{2,\}', ' ', '')
    
                if g:php_fold_return_comment_as_declaration == 1
                    let result = substitute(result, ' @return ', ': ', '')
                endif
    
                return result
            endif
        endfor
        if g:php_fold_show_unknown_types == 1
            return ": unknown type"
        endif
    
        return ""
    endfunction
    " --- }}}
    
    " --- GetFunctionDeclaration --- {{{
    function! GetFunctionDeclaration(lines)
        for line in a:lines
            if match(line, '.*function .*') >= 0
                let result = substitute(line, 'function', '', '')
                if g:php_fold_uppercase_access_types == 1
                    let result = substitute(result, '\s\{4\}\(public\|private\|protected\)', '\U\1', '')
                endif
                let result = substitute(result, '\s\{2,\}', ' ', '')
                let result = substitute(result, '\s\{2,\}', ' ', '')
    
                if match(result, '.*\s*\:\s[a-z]*') < 0
                    let result = result . GetReturnComment(a:lines)
                endif
    
                return result
            endif
        endfor
    
        return ""
    endfunction
    " --- }}}
    
    " --- GetFunctionComments --- {{{
    function! GetFunctionComments(lines)
        let last_line = GetLastCommentLine(a:lines)
        if last_line == -1
            return ""
        endif
    
        let result = ""
        let i = 1
        while i <= last_line
            let line = substitute(a:lines[i], '\s\{2,\}', ' ', '')
            let line = substitute(line, ' \*', '', '')
            let line = substitute(line, '/', '', '')
            if match(line, '\s*.*\(\!\|\,\|\;\)$') < 0 && i != last_line
                let line = line . ";"
            endif
    
            let result = result . line
            let i = i+1
        endwhile
    
        if result == ""
            return ""
        endif
    
        let max_length = 40
        if g:php_fold_comment_length > 0
            let max_length = g:php_fold_comment_length
        endif
    
        if len(result) > max_length - 4
            let result = result[0:max_length] . " ..."
        endif
    
        return "//" . result
    endfunction
    " --- }}}
    
    " --- GetCommentText --- {{{
    function! GetCommentText(start, end)
        let l:max_length = 60
        let l:result = ""
        let lines = getbufline(bufnr('%'), a:start, a:end)
        if len(lines) < 1
            return "{ ... }"
        endif
    
        let result = GetFunctionDeclaration(lines)
        let result = result . "    " . GetFunctionComments(lines)
    
        return result
    endfunction
    " --- }}}
" === }}}

" === FoldText === {{{
function! FoldText()
    let count = v:foldend-v:foldstart

    let ind = indent(v:foldstart)
    let i = 0
    let spaces = ' '
    while i < (ind - ind/4)
        let spaces .= ' '
        let i = i+1
    endwhile


    return spaces . GetCommentText(v:foldstart, v:foldend)
endfunction
"  === }}}

" === GetPHPFold === {{{
function! GetPHPFold(lnum)
    let this_indent = IndentLevel(a:lnum)

    if match(getline(a:lnum), '^[ ]\{4\}\/\*\*') >= 0
        " Comment starts fold, return >indent
        return '>' . this_indent
    endif

    if match(getline(a:lnum), '^[ ]\{4\}}') >= 0
        " closing parenthesis closes fold, return <indent
        return '<' . this_indent
    endif

    " on the same level as the surrounding folds
    return '-1'
endfunction
" === }}}

" === options === {{{
setlocal foldmethod=expr
setlocal foldexpr=GetPHPFold(v:lnum)
setlocal foldtext=FoldText()
setlocal fillchars=fold:\ 
" === }}}