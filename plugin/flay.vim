" encoding: utf-8

if ( exists('g:loaded_flay') && g:loaded_flay ) || v:version < 700 || &cp
    finish
endif

if !has('signs') || !has('ruby')
    echoerr "Compile VIM with signs and ruby interop to use this plugin."
    finish
endif

let g:loaded_flay = 1

command! -bar Flay cal flay#execute()

augroup flayFiletypes
    autocmd!

    if exists("g:flay_on_open") && g:flay_on_open
        autocmd FileType ruby :call flay#execute()
    endif

    if exists("g:flay_on_save") && g:flay_on_save
        autocmd FileWritePre    * :call flay#execute()
        autocmd FileAppendPre   * :call flay#execute()
        autocmd FilterWritePre  * :call flay#execute()
        autocmd BufWritePre     * :call flay#execute()
    endif

augroup END

" vim: ai tabstop=4 expandtab shiftwidth=4 softtabstop=4
