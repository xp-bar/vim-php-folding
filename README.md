## Vim PHP Folding

#### Installation
Put `folding.vim` under your vim installation directory under a `ftplugin/php/` directory.

For me, for example, that's under `~/.vim/ftplugin/php/folding.vim`, or for nvim `~/.config/nvim/ftplugin/php/folding.vim`.


#### Options
you can also add the following options to your `.vimrc` to configure the way your fold behave:
```
" 1 = true, 0 = false

" convert '@return ReturnType' to ': ReturnType' in function preview if there is no return type specified in the function declaration
let g:php_fold_return_comment_as_declaration=1

" convert function access (public, private, protected) to UPPERCASE in preview
let g:php_fold_uppercase_access_types=0

" if the return type can't be found from an @return tag or a return type declaration, show the return type as ': unknown type' 
let g:php_fold_show_unknown_types=1

" the maximum length for function comments (accross all lines) before being truncated with '...'
let g:php_fold_comment_length=60

" show a preview of the first line in the fold, otherwise show the number of hidden lines
let g:php_fold_show_fold_preview=0
```

#### Before Folding
![before folding](https://user-images.githubusercontent.com/22773226/50525439-7cbca780-0aa9-11e9-9f1b-607103bfda7b.png)

#### After Folding
![after folding](https://user-images.githubusercontent.com/22773226/50525521-e472f280-0aa9-11e9-9053-4f84f3e22f62.png)
