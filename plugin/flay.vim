" encoding: utf-8

if ( exists('g:loaded_flay') && g:loaded_flay ) || v:version < 700 || &cp
    finish
endif

let g:loaded_flay = 1

com! -bar Flay cal flay#execute()

augroup flayFiletypes
    autocmd!

    if exists("g:flay_on_open") && g:flay_on_open
        autocmd FileType ruby :call flay#execute()
    endif

augroup END

" vim: ai tabstop=4 expandtab shiftwidth=4 softtabstop=4
