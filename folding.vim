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
            if match(line, '\(public\|private\|protected\).*function .*') >= 0
                let result = substitute(line, 'function', '', '')
                if g:php_fold_uppercase_access_types == 1
                    let result = substitute(result, '\s\{4\}\(public\|private\|protected\)', '\U\1', '')
                endif
                let result = substitute(result, '\s\{2,\}', ' ', '')
                let result = substitute(result, '\s\{2,\}', ' ', '')
                let result = substitute(result, '{', '', '')
    
                if match(result, '.*\s*\:\s[a-z]*') < 0
                    let result = result . GetReturnComment(a:lines)
                endif
    
                let result = substitute(result, '^\s\(.*\)', '\1', '')
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
        let count = a:end-a:start+1
        if len(lines) < 1
            return spaces . "// " . count . " lines hidden"
        endif
    
        let funcdecl = GetFunctionDeclaration(lines)
        let funccomm = GetFunctionComments(lines)

        if match(funcdecl, '^\s*$') < 0
            let funcdecl = funcdecl . "    "
        else
            let funcdecl = "--- " . count . " lines hidden --- "
        endif

        let result = result . funcdecl . funccomm

        if match(result, '^\s*$') >= 0
            if g:php_fold_show_fold_preview == 1
                let line = lines[0]
                let length = 120
                if len(line) > length
                    let line = line[0:length-4]
                endif

                let line = substitute(line, '\s\{2,\}', ' ', '')

                return line . " ..."
            endif

            return "--- " . count . " lines hidden --- "
        endif
    
        return result
    endfunction
    " --- }}}
    
    " --- NextNonBlankLine --- {{{
    function! NextNonBlankLine(lnum)
        let numlines = line('$')
        let current = a:lnum + 1
    
        while current <= numlines
            if getline(current) =~? '\v\S'
                return current
            endif
    
            let current += 1
        endwhile
    
        return -2
    endfunction
    " --- }}}
    "
    " --- PrevNonBlankLine --- {{{
    function! PrevNonBlankLine(lnum)
        let numlines = line('$')
        let current = a:lnum - 1
    
        while current >= 0
            if getline(current) =~? '\v\S'
                return current
            endif
    
            let current -= 1
        endwhile
    
        return -2
    endfunction
    " --- }}}
" === }}}

" === FoldText === {{{
function! FoldText()
    let count = v:foldend-v:foldstart

    let ind = IndentLevel(v:foldstart)
    let i = 0
    let spaces = ''
    while i < ind*4
        let spaces .= ' '
        let i = i+1
    endwhile

    let text = GetCommentText(v:foldstart, v:foldend)

    return spaces . text
endfunction
"  === }}}

" === GetPHPFold === {{{
function! GetPHPFold(lnum)
    let this_indent = IndentLevel(a:lnum)
    let next_indent = IndentLevel(NextNonBlankLine(a:lnum))
    let prev_indent = IndentLevel(PrevNonBlankLine(a:lnum))

    if getline(a:lnum) =~? '\v^\s*$'
        return '-1'
    endif

    if match(getline(a:lnum), '^}$') >= 0
        return 0
    endif

    if this_indent == 0
        return '-1'
    endif

    if match(getline(a:lnum), '^[ ]\{4,\}\/\*\*') >= 0
        " Comment starts fold, return >indent
        return '>' . this_indent
    endif

    return this_indent
endfunction
" === }}}

" === options === {{{
setlocal foldmethod=expr
setlocal foldexpr=GetPHPFold(v:lnum)
setlocal foldtext=FoldText()
setlocal fillchars=fold:\ 
" === }}}
