" encoding: utf-8

if ( exists('g:loaded_flay') && g:loaded_flay ) || v:version < 700 || &cp
    finish
endif

let g:loaded_flay = 1

echom "Loading flay's plugin"

com! -bar Flay cal flay#execute()

" vim: ai tabstop=4 expandtab shiftwidth=4 softtabstop=4
