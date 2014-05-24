" encoding: utf-8

" File:        flay.vim
" Author:      Corey Prophitt <prophitt.corey [at] gmail [dot] com>
" Licence:     MIT

" Load gems first time we execute the script
ruby << EOF
    require "rubygems"
    require "flay"

    VIM.command ":sign define piet text=>> texthl=Search"

    $signs = []
    $info  = {}
EOF

let s:processed_file=0

" Used for commands and not for `on-save` events
function! flay#execute()
    if filereadable( expand("%:p") )
        silent write
        call flay#process_file()
    endif
endfunction

" Used for any readable file, doesn't force save
function! flay#process_file()
    if match(expand("%:p"), '/.git/*') != -1 || !filereadable( expand("%:p") )
        return
    endif

ruby << EOF
    flay = Flay.new
    flay.process(VIM::Buffer.current.name)
    flay.analyze

    new_signs = []
    total_mass = 0

    flay.masses.each do |hash, mass|
        total_mass += mass
        hash = flay.hashes[hash]

        lines = hash.map(&:line)
        lines.each do |line|
            type = flay.identical[hash] ? "Identical" : "Similar"
            new_signs << line.to_i
            $info[line] = "#{type} code found, mass = #{mass}, lines = #{lines.join(",")}"
            VIM.command ":sign place #{line} name=piet line=#{line} file=#{VIM::Buffer.current.name}"
        end
    end

    ($signs - new_signs).each do |bad_sign|
        VIM.command ":sign unplace #{bad_sign}"
    end

    $signs = new_signs

    VIM.command ":echo 'Total Flay score (lower is better) = #{total_mass}'"
EOF

    let s:processed_file=1
endfunction

" Clear all signs and info
function! flay#clear_signs()
    if s:processed_file
ruby << EOF
        $signs.each do |sign|
            VIM.command ":sign unplace #{sign}"
        end
        $signs = []
        $info  = {}
EOF
        let s:processed_file=0
        echo "All signs cleared"
    else
        echo "File not processed, did you run Flay?"
    end
endfunction

function! flay#draw_info()
ruby << EOF
    line = VIM.evaluate("line('.')").to_i
    if $signs.include?(line)
        VIM.command ":echo '#{$info[line]}'"
    else
        VIM.command ":echo ''"
    end
EOF
endfunction

function! flay#toggle()
    if s:processed_file
        call flay#clear_signs()
    else
        call flay#process_file()
    endif
endfunction

function! flay#list()
    if s:processed_file
ruby << EOF
        if $signs.length == 0
            VIM.command ":echo 'No lines to flay'"
        else
            VIM.command ":echo 'Lines to flay = #{$signs.join(",")}'"
        end
EOF
    else
        echo "File not processed, did you run Flay?"
    endif
endfunction

" vim: ai tabstop=4 expandtab shiftwidth=4 softtabstop=4
